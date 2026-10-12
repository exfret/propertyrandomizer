#!/usr/bin/env python3
"""
PropertyRandomizer dependency-graph LP solver.

This replaces the old simplex-lp-export input.  It reads staged dumps made by
the data-final-fixes.lua loop:

    I IS THIS VALUE N
    logic.build(...)
    GRAPH DUMP
    serpent.dump(logic.graph)
    ... temporary science-pack cuts ...
    PATH DUMP
    serpent.dump(path)
    SORT INFO DUMP
    serpent.dump(sort_info)

Each stage's graph is retained separately because costs and quantitative edge
data may depend on the stage (for example through payback_time).  The subsequent
DATA_RAW dump is never read or parsed.

LP semantics are taken directly from logic.graph:

  * AND node -> one LP row/action
  * OR node  -> one LP price variable/state
  * AND -> OR edge with `amount=a` contributes +a
  * OR  -> AND edge with `amount=a` contributes -a
  * missing `amount` is ignored by the quantitative LP
  * traveler/ordinary row RHS = AND.cost
  * slot row RHS = AND.cost + AND.slot_additional_cost
  * every cost-bearing OR node is reified as OR -> AND(cost) -> OR
  * there is NO special case that makes a cost-bearing source OR available
  * an explicitly present amount=0 edge into an OR is an intentional
    zero-cost/free-production marker; missing-amount edges remain ignored
  * original AND nodes with coproduct=true keep simultaneous quantitative
    fan-out: one execution may produce/satisfy every outgoing quantitative edge
  * every other original AND node with >1 quantitative outgoing edge is given
    one conserved synthetic OR output commodity; its outgoing uses are routed
    through that commodity so one execution cannot be spent several ways at once
  * same-op edges are subdivided so the LP is strictly AND/OR bipartite

For each target, two LPs are solved: one with traveler/ordinary row costs and
one with slot row costs.  The traveler/ordinary formulation is:

    maximize p[target]
    subject to A p <= b
               p >= 0

Before calling HiGHS, the matrix is geometrically equilibrated by alternating
positive row and column scalings.  Row scaling multiplies the whole AND
constraint, including its RHS cost.  Column scaling is implemented as the
change of variables p = S q.  The reported objective and dual row usages are
converted back to the original unscaled material units, so the material costs
and producer information retain their original meaning.

The cost solve uses the equivalent primal production formulation because it is
more numerically robust on this graph: minimize total row cost while producing
one unit of the requested OR state.  Original row usages are recovered exactly
after equilibration.

By default the script targets every reachable item/fluid OR node, every exact
`fluid-temperature` graph node, and every original node whose `cost` field is
explicitly present (including AND nodes such as `entity-operate`).  Each exact
fluid temperature is therefore priced independently; the generic `fluid: NAME`
price remains the cheapest way to obtain that fluid at any accepted temperature.
AND targets (including `fluid-temperature` and cost-bearing actions) are priced by
forcing one execution of that row while requiring the full production plan to
cover all quantitative inputs.

Stage handling:
  * every node appearing anywhere in sort_info.sorted is considered reachable
    for that stage (the critical path is metadata only)
  * each stage's GRAPH DUMP is taken before the temporary science-pack cut, so
    the Python side replays that cut against the matching stage graph
  * at military science it also replays the extra py-science-pack-2 cut
  * old one-graph logs are still accepted by reusing that graph as a fallback

The script deliberately does not depend on science_flow.py.  The uploaded
science_flow.py is built around simplex-export row metadata/gross recipe IO;
that phase is separate from the material-price solve requested here.
"""

from __future__ import annotations

import argparse
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix, csr_matrix, save_npz


PACKS_IN_ORDER = [
    "automation-science-pack",
    "py-science-pack-1",
    "logistic-science-pack",
    "military-science-pack",
    "py-science-pack-2",
    "chemical-science-pack",
    "py-science-pack-3",
    "production-science-pack",
    "py-science-pack-4",
    "utility-science-pack",
    "space-science-pack",
    "full-pyrrhic-victory",
]

NUMBER_RE = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"
ENTRY_START_RE = re.compile(
    r'(?:\{|,)\["((?:\\.|[^"\\])*)"\]=\{object_type="(node|edge)"'
)
NODE_KEY_RE = re.compile(r'node_key="((?:\\.|[^"\\])*)"')
LOG_PREFIX_RE = re.compile(r"^\s*\d+(?:\.\d+)?\s+Script @.*?:\d+:\s?(.*)$")
STAGE_RE = re.compile(r"I IS THIS VALUE\s+(\d+)")


@dataclass(frozen=True)
class GraphNode:
    key: str
    op: str
    node_type: str | None
    name: str | None
    cost: float = 0.0
    slot_additional_cost: float = 0.0
    cost_present: bool = False
    slot_cost_present: bool = False
    coproduct: bool = False
    coproduct_present: bool = False
    synthetic: bool = False
    source: str | None = None


@dataclass(frozen=True)
class GraphEdge:
    key: str
    start: str
    stop: str
    amount: float
    amount_present: bool = True
    synthetic: bool = False
    source: str | None = None
    slot_additional_cost: float = 0.0
    slot_cost_present: bool = False


@dataclass(frozen=True)
class GraphDumpRef:
    byte_offset: int


@dataclass
class StageSnapshot:
    ordinal: int
    logged_index: int | None
    path_indices: list[int]
    reachable_nodes: set[str]
    target_hint: str | None

    @property
    def stage_index(self) -> int:
        return self.logged_index or self.ordinal

    @property
    def stage_name(self) -> str:
        i = self.stage_index
        if 1 <= i <= len(PACKS_IN_ORDER):
            return PACKS_IN_ORDER[i - 1]
        return f"stage-{i}"


# ---------------------------------------------------------------------------
# Tiny Serpent/Lua scalar parsing helpers
# ---------------------------------------------------------------------------


def _lua_unescape(raw: str) -> str:
    out: list[str] = []
    i = 0
    simple = {
        "a": "\a",
        "b": "\b",
        "f": "\f",
        "n": "\n",
        "r": "\r",
        "t": "\t",
        "v": "\v",
        "\\": "\\",
        '"': '"',
        "'": "'",
    }
    while i < len(raw):
        ch = raw[i]
        if ch != "\\":
            out.append(ch)
            i += 1
            continue
        i += 1
        if i >= len(raw):
            out.append("\\")
            break
        esc = raw[i]
        if esc in simple:
            out.append(simple[esc])
            i += 1
            continue
        if esc == "z":
            i += 1
            while i < len(raw) and raw[i].isspace():
                i += 1
            continue
        if esc == "x" and i + 2 < len(raw):
            try:
                out.append(chr(int(raw[i + 1 : i + 3], 16)))
                i += 3
                continue
            except ValueError:
                pass
        if esc.isdigit():
            j = i
            while j < len(raw) and j < i + 3 and raw[j].isdigit():
                j += 1
            try:
                out.append(chr(int(raw[i:j], 10)))
                i = j
                continue
            except ValueError:
                pass
        out.append(esc)
        i += 1
    return "".join(out)


def _find_string_field(text: str, start: int, end: int, field: str) -> str | None:
    pat = re.compile(rf'(?:\{{|,){re.escape(field)}="((?:\\.|[^"\\])*)"')
    m = pat.search(text, start, end)
    return _lua_unescape(m.group(1)) if m else None


def _find_number_field(text: str, start: int, end: int, field: str) -> float | None:
    pat = re.compile(rf'(?:\{{|,){re.escape(field)}=({NUMBER_RE})')
    m = pat.search(text, start, end)
    return float(m.group(1)) if m else None


def _find_bool_field(text: str, start: int, end: int, field: str) -> bool | None:
    pat = re.compile(rf'(?:\{{|,){re.escape(field)}=(true|false)')
    m = pat.search(text, start, end)
    if not m:
        return None
    return m.group(1) == "true"


def _strip_log_prefix(line: str) -> str:
    line = line.rstrip("\r\n")
    m = LOG_PREFIX_RE.match(line)
    return m.group(1) if m else line.strip()


def _parse_path_indices(payload: str) -> list[int]:
    m = re.search(r"(?:\{|,)path=\{([^}]*)\}", payload)
    if not m:
        # top.path has changed shape a few times; the path is useful only as
        # metadata, so do not make graph-cost solving depend on it.
        return []
    body = m.group(1).strip()
    if not body:
        return []
    values: list[int] = []
    for part in body.split(","):
        part = part.strip()
        if part:
            values.append(int(part))
    return values


def _parse_sort(payload: str, path_indices: Sequence[int]) -> tuple[set[str], str | None]:
    sorted_pos = payload.find("sorted={")
    if sorted_pos < 0:
        raise RuntimeError("SORT INFO DUMP has no sorted={...} table")

    keys = [_lua_unescape(m.group(1)) for m in NODE_KEY_RE.finditer(payload, sorted_pos)]
    if not keys:
        raise RuntimeError("SORT INFO DUMP contains no node_key entries")

    target_hint = None
    if path_indices:
        # top.path indices index sort_info.sorted (Lua 1-based).  Existing
        # dumps use the first path entry as the requested target pebble.
        idx = path_indices[0]
        if 1 <= idx <= len(keys):
            target_hint = keys[idx - 1]

    return set(keys), target_hint


# ---------------------------------------------------------------------------
# Log parsing
# ---------------------------------------------------------------------------


def parse_log(path: Path) -> tuple[list[StageSnapshot], dict[int, GraphDumpRef]]:
    """
    Read stage path/sort snapshots and remember where each graph dump lives.

    Graph dumps can be enormous and there is now one per stage.  Keeping all
    twelve serialized graphs in memory would be wasteful, so this first pass
    stores byte offsets only.  A selected stage's graph line is read and parsed
    later, immediately before that stage is solved.

    New logging order is:

        I IS THIS VALUE N
        logic.build(...)
        GRAPH DUMP
        serpent.dump(logic.graph)
        ... temporary science-pack cuts ...
        PATH DUMP
        serpent.dump(path)
        SORT INFO DUMP
        serpent.dump(sort_info)

    A one-graph old-format log is still accepted and that graph becomes the
    fallback for every stage.
    """
    snapshots: list[StageSnapshot] = []
    current_stage: int | None = None
    pending_kind: str | None = None
    pending_path: list[int] | None = None
    graph_refs: dict[int, GraphDumpRef] = {}
    unscoped_graph_refs: list[GraphDumpRef] = []

    with path.open("rb") as fh:
        while True:
            byte_offset = fh.tell()
            raw_line = fh.readline()
            if not raw_line:
                break

            # The line after GRAPH DUMP is the giant payload. We already know
            # what it is, so do not decode or retain it in this indexing pass.
            if pending_kind == "graph":
                ref = GraphDumpRef(byte_offset=byte_offset)
                if current_stage is None:
                    unscoped_graph_refs.append(ref)
                else:
                    if current_stage in graph_refs:
                        print(
                            f"WARNING: multiple GRAPH DUMPs found for stage "
                            f"{current_stage}; using the last one",
                            flush=True,
                        )
                    graph_refs[current_stage] = ref
                pending_kind = None
                continue

            line = _strip_log_prefix(
                raw_line.decode("utf-8", errors="replace")
            )

            m_stage = STAGE_RE.search(line)
            if m_stage:
                current_stage = int(m_stage.group(1))
                continue

            if "PATH DUMP" in line:
                pending_kind = "path"
                continue
            if "SORT INFO DUMP" in line:
                pending_kind = "sort"
                continue
            if "GRAPH DUMP" in line:
                pending_kind = "graph"
                continue
            if "__DATA_RAW_BEGIN__" in line:
                break

            if pending_kind is None:
                continue

            if pending_kind == "path":
                pending_path = _parse_path_indices(line)
                pending_kind = None
                continue

            if pending_kind == "sort":
                path_indices = pending_path or []
                reachable, target_hint = _parse_sort(line, path_indices)
                snapshots.append(
                    StageSnapshot(
                        ordinal=len(snapshots) + 1,
                        logged_index=current_stage,
                        path_indices=path_indices,
                        reachable_nodes=reachable,
                        target_hint=target_hint,
                    )
                )
                pending_path = None
                pending_kind = None
                continue

    if not snapshots:
        raise RuntimeError("No PATH/SORT stage snapshots found in the log")

    if unscoped_graph_refs:
        if len(unscoped_graph_refs) > 1:
            print(
                "WARNING: multiple unscoped GRAPH DUMPs found; using the last one "
                "as the fallback graph",
                flush=True,
            )
        graph_refs[0] = unscoped_graph_refs[-1]

    if not graph_refs:
        raise RuntimeError("No GRAPH DUMP payload found in the log")

    if len(graph_refs) == 1 and 0 not in graph_refs:
        graph_refs[0] = next(iter(graph_refs.values()))

    return snapshots, graph_refs


def read_graph_payload(path: Path, ref: GraphDumpRef) -> str:
    """Read exactly one serialized graph line from its indexed byte offset."""
    with path.open("rb") as fh:
        fh.seek(ref.byte_offset)
        raw_line = fh.readline()
    if not raw_line:
        raise RuntimeError(
            f"GRAPH DUMP at byte offset {ref.byte_offset} could not be read"
        )
    return _strip_log_prefix(raw_line.decode("utf-8", errors="replace"))


# ---------------------------------------------------------------------------
# Full dependency graph parsing
# ---------------------------------------------------------------------------


def parse_full_graph(payload: str) -> tuple[dict[str, GraphNode], list[GraphEdge]]:
    starts = list(ENTRY_START_RE.finditer(payload))
    if not starts:
        raise RuntimeError("GRAPH DUMP contains no top-level node/edge objects")

    # Serpent normally appends shared-reference assignments after the initial
    # top-level table. Avoid letting the last object's field search leak there.
    tail_candidates = [
        payload.find("};_.nodes=", starts[-1].start()),
        payload.find(";_.nodes=", starts[-1].start()),
        payload.find("};_.edges=", starts[-1].start()),
    ]
    tail_candidates = [x for x in tail_candidates if x >= 0]
    table_tail = min(tail_candidates) if tail_candidates else len(payload)

    nodes: dict[str, GraphNode] = {}
    edges: list[GraphEdge] = []

    for i, m in enumerate(starts):
        key = _lua_unescape(m.group(1))
        object_type = m.group(2)
        start = m.start()
        end = starts[i + 1].start() if i + 1 < len(starts) else table_tail

        if object_type == "node":
            op = _find_string_field(payload, start, end, "op") or ""
            node_type = _find_string_field(payload, start, end, "type")
            name = _find_string_field(payload, start, end, "name")
            raw_cost = _find_number_field(payload, start, end, "cost")
            raw_slot_cost = _find_number_field(
                payload, start, end, "slot_additional_cost"
            )
            raw_coproduct = _find_bool_field(payload, start, end, "coproduct")
            cost = 0.0 if raw_cost is None else raw_cost
            slot_cost = 0.0 if raw_slot_cost is None else raw_slot_cost
            if key in nodes:
                raise RuntimeError(f"Duplicate graph node key {key!r}")
            nodes[key] = GraphNode(
                key=key,
                op=op,
                node_type=node_type,
                name=name,
                cost=cost,
                slot_additional_cost=slot_cost,
                cost_present=raw_cost is not None,
                slot_cost_present=raw_slot_cost is not None,
                coproduct=(raw_coproduct is True),
                coproduct_present=(raw_coproduct is not None),
            )
            continue

        edge_start = _find_string_field(payload, start, end, "start")
        edge_stop = _find_string_field(payload, start, end, "stop")
        if edge_start is None or edge_stop is None:
            raise RuntimeError(f"Graph edge {key!r} is missing start/stop")
        amount = _find_number_field(payload, start, end, "amount")
        raw_slot_cost = _find_number_field(
            payload, start, end, "slot_additional_cost"
        )
        edges.append(
            GraphEdge(
                key=key,
                start=edge_start,
                stop=edge_stop,
                amount=0.0 if amount is None else amount,
                amount_present=amount is not None,
                slot_additional_cost=(
                    0.0 if raw_slot_cost is None else raw_slot_cost
                ),
                slot_cost_present=raw_slot_cost is not None,
            )
        )

    bad_ops = [n.key for n in nodes.values() if n.op not in {"AND", "OR"}]
    if bad_ops:
        raise RuntimeError(
            f"{len(bad_ops)} graph nodes lack AND/OR op after graph setup; "
            f"sample={bad_ops[:8]}"
        )

    return nodes, edges


# ---------------------------------------------------------------------------
# Stage reconstruction + graph-to-LP transformation
# ---------------------------------------------------------------------------


def _science_cut_starts(snapshot: StageSnapshot) -> set[str]:
    i = snapshot.stage_index
    cuts: set[str] = set()
    if 1 <= i <= len(PACKS_IN_ORDER):
        current = PACKS_IN_ORDER[i - 1]
        if current != "full-pyrrhic-victory":
            cuts.add(f"item: {current}")
        if current == "military-science-pack":
            cuts.add("item: py-science-pack-2")
    return cuts


def extract_stage_graph(
    snapshot: StageSnapshot,
    all_nodes: dict[str, GraphNode],
    all_edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[GraphEdge], dict[str, int]]:
    included = snapshot.reachable_nodes & all_nodes.keys()
    nodes = {k: all_nodes[k] for k in included}
    cut_starts = _science_cut_starts(snapshot)

    edges: list[GraphEdge] = []
    cut_count = 0
    boundary_count = 0
    for edge in all_edges:
        if edge.start in cut_starts:
            cut_count += 1
            continue
        if edge.start not in nodes or edge.stop not in nodes:
            boundary_count += 1
            continue
        edges.append(edge)

    return nodes, edges, {
        "reachable_nodes": len(included),
        "stage_cut_edges_removed": cut_count,
        "cross_boundary_edges_removed": boundary_count,
    }


def _synthetic_key(kind: str, source: str) -> str:
    return f"__pr_graph_lp_{kind}__: {source}"


def make_bipartite(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[GraphEdge], dict[str, int]]:
    """
    Reify explicitly cost-bearing OR nodes, then subdivide same-op quantitative
    edges.

    Cost-bearing OR semantics are ALWAYS:

        producers -> M_pre(OR) --1--> M_cost(AND, cost) --1--> M(OR)
                                                            -> consumers

    There is deliberately NO special handling for a cost-bearing OR that lacks
    ordinary quantitative producers. If nothing can produce M_pre, then M is
    not cost-reachable and the target LP is infeasible. Merely putting `cost`
    on an OR node never makes that OR available.

    Edge amount semantics:

      * missing `amount`:
            reachability-only; ignored by the cost LP.

      * nonzero `amount`:
            normal quantitative graph coefficient.

      * explicitly present `amount = 0` INTO AN OR:
            intentional free-production marker. The edge's source is not a
            quantitative prerequisite; instead we add a synthetic zero-cost AND
            row that produces one unit of the destination OR. This gives the
            destination OR cost 0 while preserving the distinction from a
            missing-amount reachability edge.

            For a cost-bearing entity OR this becomes:

                free AND -> entity_pre(OR)
                                  |
                                  1
                                  v
                            entity_cost(AND)
                                  |
                                  1
                                  v
                              entity(OR)

            so the final entity receives its node cost, but only because the
            Lua graph explicitly marked the prerequisite-side OR as freely
            available.

      * explicitly present `amount = 0` INTO AN AND:
            no quantitative prerequisite; ignored.

    Any accidental explicit zero-output edge into an OR would therefore make
    that OR freely producible. Use amount=nil for "not quantitatively modeled"
    and amount=0 only for intentional free availability.
    """
    out_nodes = dict(nodes)
    intermediate_edges: list[GraphEdge] = []

    cost_or_nodes = {
        key for key, node in nodes.items()
        if node.op == "OR" and (node.cost_present or node.slot_cost_present)
    }

    # Every cost-bearing OR gets the same OR -> AND(cost) -> OR split.
    pre_for_cost_or: dict[str, str] = {}
    for key in sorted(cost_or_nodes):
        node = nodes[key]
        pre = _synthetic_key("or_cost_pre", key)
        row = _synthetic_key("or_cost_row", key)

        if pre in out_nodes or row in out_nodes:
            raise RuntimeError(f"Synthetic key collision while splitting {key!r}")

        pre_for_cost_or[key] = pre

        out_nodes[key] = GraphNode(
            key=key,
            op="OR",
            node_type=node.node_type,
            name=node.name,
            cost=0.0,
            slot_additional_cost=0.0,
            cost_present=False,
            slot_cost_present=False,
            coproduct=node.coproduct,
            coproduct_present=node.coproduct_present,
            synthetic=node.synthetic,
            source=node.source,
        )
        out_nodes[pre] = GraphNode(
            key=pre,
            op="OR",
            node_type=None,
            name=None,
            cost=0.0,
            slot_additional_cost=0.0,
            cost_present=False,
            slot_cost_present=False,
            synthetic=True,
            source=f"node-cost:{key}",
        )
        out_nodes[row] = GraphNode(
            key=row,
            op="AND",
            node_type=None,
            name=None,
            cost=node.cost,
            slot_additional_cost=node.slot_additional_cost,
            cost_present=node.cost_present,
            slot_cost_present=node.slot_cost_present,
            synthetic=True,
            source=f"node-cost:{key}",
        )

        intermediate_edges.append(
            GraphEdge(
                key=f"node-cost:{key}:pre",
                start=pre,
                stop=row,
                amount=1.0,
                amount_present=True,
                synthetic=True,
                source=f"node-cost:{key}",
            )
        )
        intermediate_edges.append(
            GraphEdge(
                key=f"node-cost:{key}:post",
                start=row,
                stop=key,
                amount=1.0,
                amount_present=True,
                synthetic=True,
                source=f"node-cost:{key}",
            )
        )

    ignored_missing_amount = 0
    ignored_zero_into_and = 0
    explicit_zero_free_producers = 0

    for ordinal, edge in enumerate(edges):
        if not edge.amount_present:
            ignored_missing_amount += 1
            continue

        # Producers of a cost-bearing OR feed its prerequisite-side OR.
        stop = pre_for_cost_or.get(edge.stop, edge.stop)

        if edge.amount == 0.0:
            dst = out_nodes[stop]

            if dst.op == "OR":
                # Explicit zero is a sentinel for FREE AVAILABILITY, not a
                # literal coefficient 0.
                free_row = _synthetic_key(
                    "explicit_zero_free_source",
                    f"{ordinal}:{edge.key}",
                )
                if free_row in out_nodes:
                    raise RuntimeError(
                        f"Synthetic key collision while handling explicit zero "
                        f"edge {edge.key!r}"
                    )

                out_nodes[free_row] = GraphNode(
                    key=free_row,
                    op="AND",
                    node_type=None,
                    name=None,
                    cost=0.0,
                    slot_additional_cost=0.0,
                    cost_present=True,
                    slot_cost_present=False,
                    synthetic=True,
                    source=f"explicit-zero:{edge.key}",
                )
                intermediate_edges.append(
                    GraphEdge(
                        key=f"{edge.key}:explicit-zero-free",
                        start=free_row,
                        stop=stop,
                        amount=1.0,
                        amount_present=True,
                        synthetic=True,
                        source=f"explicit-zero:{edge.key}",
                    )
                )
                explicit_zero_free_producers += 1
            else:
                # A zero amount into an AND means no quantitative prerequisite.
                ignored_zero_into_and += 1

            continue

        intermediate_edges.append(
            GraphEdge(
                key=edge.key,
                start=edge.start,
                stop=stop,
                amount=edge.amount,
                amount_present=True,
                synthetic=edge.synthetic,
                source=edge.source,
                slot_additional_cost=edge.slot_additional_cost,
                slot_cost_present=edge.slot_cost_present,
            )
        )

    # ------------------------------------------------------------------
    # Conserve fan-out from non-coproduct AND nodes.
    #
    # An ordinary AND is an action/use.  If it has several quantitative
    # dependents, those dependents are alternative uses of the SAME execution,
    # not simultaneous outputs.  Give that action one synthetic OR commodity:
    #
    #        A(AND) --1--> A_out(OR)
    #
    # and route every quantitative outgoing edge through A_out.
    #
    # For an original A --q--> B(AND), q is a consumption requirement of B,
    # so the routed edge is simply A_out --q--> B.
    #
    # For an original A --q--> M(OR), q is production per execution of A.
    # The equivalent conversion is:
    #
    #        A_out --1/q--> route(AND) --1--> M
    #
    # i.e. one unit of A_out can produce q units of M.  We initially express
    # this as an OR->OR edge with amount=1/q and let the normal OR->OR
    # subdivision below create the route row.
    #
    # coproduct=true opts out: all original quantitative outgoing edges remain
    # on the same row and therefore occur simultaneously, which is exactly what
    # we want for recipes, mining with multiple results, rocket-launch results,
    # etc.
    # ------------------------------------------------------------------

    outgoing_by_and: dict[str, list[GraphEdge]] = {}
    for edge in intermediate_edges:
        src = out_nodes[edge.start]
        if src.op == "AND" and not src.synthetic:
            outgoing_by_and.setdefault(edge.start, []).append(edge)

    fanout_nodes_normalized = 0
    fanout_edges_rerouted = 0
    coproduct_fanout_nodes_preserved = 0
    coproduct_fanout_edges_preserved = 0
    fanout_shared_edges: list[GraphEdge] = []
    rerouted_edge_ids: set[int] = set()

    for and_key, outgoing in outgoing_by_and.items():
        # No overcount is possible with zero/one quantitative outgoing edge.
        if len(outgoing) <= 1:
            continue

        node = out_nodes[and_key]
        if node.coproduct:
            coproduct_fanout_nodes_preserved += 1
            coproduct_fanout_edges_preserved += len(outgoing)
            continue

        shared = _synthetic_key("and_output", and_key)
        if shared in out_nodes:
            raise RuntimeError(
                f"Synthetic key collision while conserving fan-out of {and_key!r}"
            )

        out_nodes[shared] = GraphNode(
            key=shared,
            op="OR",
            node_type=None,
            name=None,
            cost=0.0,
            slot_additional_cost=0.0,
            cost_present=False,
            slot_cost_present=False,
            coproduct=False,
            coproduct_present=False,
            synthetic=True,
            source=f"noncoproduct-output:{and_key}",
        )

        # One execution of the AND creates one unit of its conserved output.
        fanout_shared_edges.append(
            GraphEdge(
                key=f"noncoproduct-output:{and_key}",
                start=and_key,
                stop=shared,
                amount=1.0,
                amount_present=True,
                synthetic=True,
                source=f"noncoproduct-output:{and_key}",
            )
        )

        fanout_nodes_normalized += 1
        fanout_edges_rerouted += len(outgoing)

        for edge in outgoing:
            rerouted_edge_ids.add(id(edge))
            dst = out_nodes[edge.stop]

            if edge.amount <= 0.0 or not math.isfinite(edge.amount):
                raise RuntimeError(
                    f"Non-coproduct AND fan-out edge {edge.key!r} has invalid "
                    f"quantitative amount {edge.amount!r}"
                )

            if dst.op == "AND":
                # Same consumption amount as the original AND->AND dependency.
                fanout_shared_edges.append(
                    GraphEdge(
                        key=f"{edge.key}:noncoproduct-route",
                        start=shared,
                        stop=edge.stop,
                        amount=edge.amount,
                        amount_present=True,
                        synthetic=True,
                        source=edge.key,
                        slot_additional_cost=edge.slot_additional_cost,
                        slot_cost_present=edge.slot_cost_present,
                    )
                )
            else:
                # Original AND->OR amount is output-per-use.  OR->OR amount is
                # input-per-output, hence the reciprocal.
                fanout_shared_edges.append(
                    GraphEdge(
                        key=f"{edge.key}:noncoproduct-route",
                        start=shared,
                        stop=edge.stop,
                        amount=1.0 / edge.amount,
                        amount_present=True,
                        synthetic=True,
                        source=edge.key,
                        slot_additional_cost=edge.slot_additional_cost,
                        slot_cost_present=edge.slot_cost_present,
                    )
                )

    if rerouted_edge_ids:
        intermediate_edges = [
            edge for edge in intermediate_edges if id(edge) not in rerouted_edge_ids
        ]
        intermediate_edges.extend(fanout_shared_edges)

    strict_edges: list[GraphEdge] = []
    same_and = 0
    same_or = 0

    for ordinal, edge in enumerate(intermediate_edges):
        src = out_nodes[edge.start]
        dst = out_nodes[edge.stop]

        if src.op != dst.op:
            strict_edges.append(edge)
            continue

        if src.op == "AND":
            same_and += 1
            mid = _synthetic_key("and_to_and_or", f"{ordinal}:{edge.key}")
            if mid in out_nodes:
                raise RuntimeError(f"Synthetic key collision {mid!r}")
            out_nodes[mid] = GraphNode(
                key=mid,
                op="OR",
                node_type=None,
                name=None,
                cost_present=False,
                synthetic=True,
                source=edge.key,
            )
            # A --X--> B  ==>  A --1--> M --X--> B
            strict_edges.append(
                GraphEdge(
                    f"{edge.key}:a", edge.start, mid, 1.0, True, True, edge.key
                )
            )
            strict_edges.append(
                GraphEdge(
                    f"{edge.key}:b", mid, edge.stop, edge.amount, True, True, edge.key
                )
            )
        else:
            same_or += 1
            mid = _synthetic_key("or_to_or_and", f"{ordinal}:{edge.key}")
            if mid in out_nodes:
                raise RuntimeError(f"Synthetic key collision {mid!r}")
            out_nodes[mid] = GraphNode(
                key=mid,
                op="AND",
                node_type=None,
                name=None,
                cost=0.0,
                slot_additional_cost=edge.slot_additional_cost,
                cost_present=True,
                slot_cost_present=edge.slot_cost_present,
                synthetic=True,
                source=edge.source or edge.key,
            )
            # A --X--> B  ==>  A --X--> R --1--> B
            strict_edges.append(
                GraphEdge(
                    f"{edge.key}:a", edge.start, mid, edge.amount, True, True,
                    edge.source or edge.key
                )
            )
            strict_edges.append(
                GraphEdge(
                    f"{edge.key}:b", mid, edge.stop, 1.0, True, True,
                    edge.source or edge.key
                )
            )

    return out_nodes, strict_edges, {
        "or_cost_nodes_split": len(cost_or_nodes),
        "source_cost_or_rows": 0,
        "nonsource_cost_or_bridges": len(cost_or_nodes),
        "source_cost_or_detection": "disabled",
        "missing_amount_edges_ignored": ignored_missing_amount,
        "explicit_zero_free_producer_edges": explicit_zero_free_producers,
        "explicit_zero_into_and_ignored": ignored_zero_into_and,
        "noncoproduct_fanout_nodes_normalized": fanout_nodes_normalized,
        "noncoproduct_fanout_edges_rerouted": fanout_edges_rerouted,
        "coproduct_fanout_nodes_preserved": coproduct_fanout_nodes_preserved,
        "coproduct_fanout_edges_preserved": coproduct_fanout_edges_preserved,
        "same_and_edges_subdivided": same_and,
        "same_or_edges_subdivided": same_or,
        "strict_nonzero_edges": len(strict_edges),
    }


def build_matrix(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[csr_matrix, np.ndarray, np.ndarray, list[str], list[str]]:
    row_keys = sorted(k for k, n in nodes.items() if n.op == "AND")
    col_keys = sorted(k for k, n in nodes.items() if n.op == "OR")
    row_index = {k: i for i, k in enumerate(row_keys)}
    col_index = {k: i for i, k in enumerate(col_keys)}

    rr: list[int] = []
    cc: list[int] = []
    vv: list[float] = []

    for edge in edges:
        if edge.amount == 0.0:
            continue
        src = nodes[edge.start]
        dst = nodes[edge.stop]
        if src.op == "AND" and dst.op == "OR":
            rr.append(row_index[edge.start])
            cc.append(col_index[edge.stop])
            vv.append(edge.amount)
        elif src.op == "OR" and dst.op == "AND":
            rr.append(row_index[edge.stop])
            cc.append(col_index[edge.start])
            vv.append(-edge.amount)
        else:
            raise RuntimeError(
                f"Graph is not bipartite at {edge.start!r} -> {edge.stop!r}"
            )

    A = coo_matrix(
        (vv, (rr, cc)),
        shape=(len(row_keys), len(col_keys)),
        dtype=float,
    ).tocsr()
    A.sum_duplicates()
    A.eliminate_zeros()
    b_traveler = np.array([nodes[k].cost for k in row_keys], dtype=float)
    b_slot = np.array(
        [nodes[k].cost + nodes[k].slot_additional_cost for k in row_keys],
        dtype=float,
    )
    return A, b_traveler, b_slot, row_keys, col_keys


# ---------------------------------------------------------------------------
# Geometric equilibration
# ---------------------------------------------------------------------------


def _positive_abs_range(values: np.ndarray) -> tuple[float | None, float | None]:
    """Return min/max finite positive absolute values, or (None, None)."""
    if values.size == 0:
        return None, None
    abs_values = np.abs(np.asarray(values, dtype=float))
    abs_values = abs_values[np.isfinite(abs_values) & (abs_values > 0.0)]
    if abs_values.size == 0:
        return None, None
    return float(abs_values.min()), float(abs_values.max())


def _geometric_center_factor(
    minimum: float,
    maximum: float,
    factor_limit: float,
) -> float:
    """
    Scale [minimum, maximum] so its geometric midpoint is near 1.

    The logarithmic form avoids overflow/underflow in minimum*maximum.
    Clamping does NOT change LP semantics: any positive scale is exact; it only
    limits how aggressive one equilibration pass may be.
    """
    log_factor = -0.5 * (math.log(minimum) + math.log(maximum))
    log_limit = math.log(factor_limit)
    log_factor = max(-log_limit, min(log_limit, log_factor))
    return math.exp(log_factor)


def geometric_equilibrate(
    A: csr_matrix,
    b: np.ndarray,
    passes: int = 4,
    factor_limit: float = 1e12,
) -> tuple[
    csr_matrix,
    np.ndarray,
    np.ndarray,
    np.ndarray,
    dict[str, Any],
]:
    """
    Alternating geometric row/column scaling.

    Produces

        A_scaled = R A S
        b_scaled = R b
        p = S q

    where R and S are positive diagonal matrices represented by row_scale and
    col_scale.  Thus the feasible set in original prices p is unchanged.

    Row ranges include the nonzero RHS cost as well as nonzero matrix
    coefficients because the RHS is part of the numerical constraint presented
    to HiGHS.  Column ranges use matrix coefficients only.

    For each row/column, the nonzero absolute range [m, M] is multiplied by

        1 / sqrt(m M),

    centering its extreme coefficients geometrically around 1.  Alternating
    passes are useful because row scaling perturbs column ranges and vice versa.
    """
    if passes < 0:
        raise ValueError("scaling passes must be >= 0")
    if not math.isfinite(factor_limit) or factor_limit <= 1.0:
        raise ValueError("scaling factor limit must be finite and > 1")

    A_scaled = A.copy().tocsr().astype(float)
    b_scaled = np.asarray(b, dtype=float).copy()

    if np.any(~np.isfinite(A_scaled.data)):
        raise RuntimeError("LP matrix contains non-finite coefficients")
    if np.any(~np.isfinite(b_scaled)):
        raise RuntimeError("LP RHS contains non-finite costs")

    row_scale = np.ones(A_scaled.shape[0], dtype=float)
    col_scale = np.ones(A_scaled.shape[1], dtype=float)

    before_min, before_max = _positive_abs_range(A_scaled.data)
    before_b_min, before_b_max = _positive_abs_range(b_scaled)

    for _ in range(passes):
        # ---- Rows: scale A row and its RHS by the same positive factor. ----
        row_factors = np.ones(A_scaled.shape[0], dtype=float)
        for r in range(A_scaled.shape[0]):
            start, end = A_scaled.indptr[r], A_scaled.indptr[r + 1]
            vals = np.abs(A_scaled.data[start:end])
            vals = vals[np.isfinite(vals) & (vals > 0.0)]

            rhs = abs(float(b_scaled[r]))
            if rhs > 0.0 and math.isfinite(rhs):
                if vals.size:
                    minimum = min(float(vals.min()), rhs)
                    maximum = max(float(vals.max()), rhs)
                else:
                    minimum = maximum = rhs
            elif vals.size:
                minimum = float(vals.min())
                maximum = float(vals.max())
            else:
                continue

            row_factors[r] = _geometric_center_factor(
                minimum,
                maximum,
                factor_limit,
            )

        if A_scaled.nnz:
            A_scaled.data *= np.repeat(
                row_factors,
                np.diff(A_scaled.indptr),
            )
        b_scaled *= row_factors
        row_scale *= row_factors

        # ---- Columns: p = S q, so multiply each matrix column by S_j. ----
        A_csc = A_scaled.tocsc()
        col_factors = np.ones(A_csc.shape[1], dtype=float)
        for c in range(A_csc.shape[1]):
            start, end = A_csc.indptr[c], A_csc.indptr[c + 1]
            vals = np.abs(A_csc.data[start:end])
            vals = vals[np.isfinite(vals) & (vals > 0.0)]
            if not vals.size:
                continue

            col_factors[c] = _geometric_center_factor(
                float(vals.min()),
                float(vals.max()),
                factor_limit,
            )

        if A_csc.nnz:
            A_csc.data *= np.repeat(
                col_factors,
                np.diff(A_csc.indptr),
            )
        col_scale *= col_factors
        A_scaled = A_csc.tocsr()
        A_scaled.sum_duplicates()
        A_scaled.eliminate_zeros()

    after_min, after_max = _positive_abs_range(A_scaled.data)
    after_b_min, after_b_max = _positive_abs_range(b_scaled)
    row_scale_min, row_scale_max = _positive_abs_range(row_scale)
    col_scale_min, col_scale_max = _positive_abs_range(col_scale)

    def ratio(lo: float | None, hi: float | None) -> float | None:
        if lo is None or hi is None:
            return None
        return hi / lo

    stats = {
        "method": "alternating-geometric-minmax",
        "passes": int(passes),
        "factor_limit_per_pass": float(factor_limit),
        "matrix_abs_before": {
            "min": before_min,
            "max": before_max,
            "ratio": ratio(before_min, before_max),
        },
        "matrix_abs_after": {
            "min": after_min,
            "max": after_max,
            "ratio": ratio(after_min, after_max),
        },
        "rhs_abs_before": {
            "min": before_b_min,
            "max": before_b_max,
            "ratio": ratio(before_b_min, before_b_max),
        },
        "rhs_abs_after": {
            "min": after_b_min,
            "max": after_b_max,
            "ratio": ratio(after_b_min, after_b_max),
        },
        "row_scale_range": {
            "min": row_scale_min,
            "max": row_scale_max,
            "ratio": ratio(row_scale_min, row_scale_max),
        },
        "column_scale_range": {
            "min": col_scale_min,
            "max": col_scale_max,
            "ratio": ratio(col_scale_min, col_scale_max),
        },
    }

    return A_scaled, b_scaled, row_scale, col_scale, stats


# ---------------------------------------------------------------------------
# Exact per-material LP solve (same method as old solve_lp_levels.py)
# ---------------------------------------------------------------------------


def _solver_status(result) -> str:
    if result.status == 0:
        return "optimal"
    if result.status == 2:
        return "infeasible"
    if result.status == 3:
        return "unbounded"
    return f"solver_status_{result.status}"


def _raise_on_internal_solver_failure(result, target_key: str) -> None:
    """
    Kept as a compatibility hook. Internal/unknown HiGHS statuses are now
    reported by solve_stage_targets instead of aborting the whole stage.
    """
    return None


def _recipe_from_original_usages(
    A_original: csr_matrix,
    row_usages: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    node_meta: dict[str, GraphNode],
    target_zero: int,
) -> tuple[str | None, dict[str, Any] | None]:
    """Trace the active production plan back through synthetic bookkeeping."""
    producer = None
    best_contribution = 0.0
    column = A_original.getcol(target_zero).tocoo()
    for row_zero, coefficient in zip(column.row, column.data):
        if coefficient <= 0.0:
            continue
        usage = float(row_usages[row_zero])
        contribution = usage * float(coefficient)
        if contribution <= 1e-10:
            continue
        if contribution > best_contribution:
            row_key = row_keys[row_zero]
            row_node = node_meta[row_key]
            best_contribution = contribution
            producer = {
                "row_index": int(row_zero) + 1,
                "row_key": row_key,
                "source_type": row_node.node_type,
                "source_name": row_node.name,
                "synthetic": row_node.synthetic,
                "source": row_node.source,
                "usage": usage,
                "target_output_per_use": float(coefficient),
                "target_contribution": contribution,
            }

    recipe = (
        producer["source_name"]
        if producer is not None
        and producer.get("source_type") == "recipe"
        else None
    )

    if recipe is not None:
        return recipe, producer

    visited_cols: set[int] = set()

    def trace_recipe(col_zero: int) -> str | None:
        if col_zero in visited_cols:
            return None
        visited_cols.add(col_zero)

        col = A_original.getcol(col_zero).tocoo()
        candidates: list[tuple[float, int]] = []
        for r, coeff in zip(col.row, col.data):
            if coeff <= 0.0:
                continue
            contribution = float(row_usages[r]) * float(coeff)
            if contribution > 1e-10:
                candidates.append((contribution, int(r)))
        candidates.sort(reverse=True)

        for _, r in candidates:
            row_key = row_keys[r]
            row_node = node_meta[row_key]
            if row_node.node_type == "recipe" and row_node.name is not None:
                return row_node.name
            if not row_node.synthetic:
                continue

            row = A_original.getrow(r).tocoo()
            inputs = [
                (abs(float(coeff)) * float(row_usages[r]), int(c))
                for c, coeff in zip(row.col, row.data)
                if coeff < 0.0
            ]
            inputs.sort(reverse=True)
            for _, c in inputs:
                found = trace_recipe(c)
                if found is not None:
                    return found
        return None

    return trace_recipe(target_zero), producer


def solve_one_or_target(
    A_original: csr_matrix,
    A_scaled: csr_matrix,
    b_scaled: np.ndarray,
    row_scale: np.ndarray,
    col_scale: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    node_meta: dict[str, GraphNode],
    target_zero: int,
    target_key: str,
    method: str,
) -> dict[str, Any]:
    """
    Solve the primal production LP for an OR/state target.

    Original problem:

        min b^T y
        s.t. A^T y >= e_target
             y >= 0

    With A_scaled = R A S and b_scaled = R b, solving for one *scaled* target
    unit gives an original amount 1/S[target].  Multiplying the objective and
    recovered row usages by S[target] converts back to one original unit.
    """
    target = np.zeros(A_scaled.shape[1], dtype=float)
    target[target_zero] = 1.0

    try:
        result = linprog(
            c=b_scaled,
            A_ub=-A_scaled.T,
            b_ub=-target,
            bounds=(0, None),
            method=method,
            options={"presolve": True},
        )
    except Exception as exc:
        return {
            "status": "solver_exception",
            "objective": None,
            "recipe": None,
            "producer": None,
            "message": f"{type(exc).__name__}: {exc}",
            "nit": None,
            "target_kind": "OR",
        }
    _raise_on_internal_solver_failure(result, target_key)

    if result.status != 0:
        return {
            "status": _solver_status(result),
            "objective": None,
            "recipe": None,
            "producer": None,
            "message": result.message,
            "nit": getattr(result, "nit", None),
            "target_kind": "OR",
        }

    scale = float(col_scale[target_zero])
    original_usages = np.asarray(result.x, dtype=float) * row_scale * scale
    objective = float(result.fun) * scale
    if abs(objective) < 1e-13:
        objective = 0.0

    recipe, producer = _recipe_from_original_usages(
        A_original=A_original,
        row_usages=original_usages,
        row_keys=row_keys,
        col_keys=col_keys,
        node_meta=node_meta,
        target_zero=target_zero,
    )

    return {
        "status": "optimal",
        "objective": objective,
        "scaled_objective": float(result.fun),
        "target_column_scale": scale,
        "target_kind": "OR",
        "recipe": recipe,
        "producer": producer,
        "message": result.message,
        "nit": getattr(result, "nit", None),
    }


def solve_one_and_target(
    A_scaled: csr_matrix,
    b_scaled: np.ndarray,
    row_scale: np.ndarray,
    row_keys: Sequence[str],
    target_row_zero: int,
    target_key: str,
    method: str,
) -> dict[str, Any]:
    """
    Cost of executing one original AND/action row while covering every numeric
    input in the production network.

        min b^T y
        s.t. A^T y >= 0
             y[target_row] >= 1
             y >= 0

    Since y_original = R y_scaled, the scaled lower bound is 1/R[target_row].
    The scaled objective b_scaled^T y_scaled already equals the original cost.
    """
    lower = 1.0 / float(row_scale[target_row_zero])
    bounds: list[tuple[float, float | None]] = [(0.0, None)] * A_scaled.shape[0]
    bounds[target_row_zero] = (lower, None)

    try:
        result = linprog(
            c=b_scaled,
            A_ub=-A_scaled.T,
            b_ub=np.zeros(A_scaled.shape[1], dtype=float),
            bounds=bounds,
            method=method,
            options={"presolve": True},
        )
    except Exception as exc:
        return {
            "status": "solver_exception",
            "objective": None,
            "recipe": None,
            "producer": None,
            "message": f"{type(exc).__name__}: {exc}",
            "nit": None,
            "target_kind": "AND",
        }
    _raise_on_internal_solver_failure(result, target_key)

    if result.status != 0:
        return {
            "status": _solver_status(result),
            "objective": None,
            "recipe": None,
            "producer": None,
            "message": result.message,
            "nit": getattr(result, "nit", None),
            "target_kind": "AND",
        }

    original_usages = np.asarray(result.x, dtype=float) * row_scale
    objective = float(result.fun)
    if abs(objective) < 1e-13:
        objective = 0.0

    return {
        "status": "optimal",
        "objective": objective,
        "target_kind": "AND",
        "direct_cost": float(b_scaled[target_row_zero] / row_scale[target_row_zero]),
        "target_row_usage": float(original_usages[target_row_zero]),
        "recipe": None,
        "producer": None,
        "message": result.message,
        "nit": getattr(result, "nit", None),
    }


def cost_target_keys(all_nodes: dict[str, GraphNode]) -> list[str]:
    """
    Price the ordinary item/fluid material states, every exact fluid-temperature
    state, and every original node that explicitly carries a cost.

    Exact temperatures are represented in logic.graph by AND nodes such as

        fluid-temperature: steam: 250

    A unit execution of that AND node consumes one unit of the corresponding
    `fluid-create-temperature` state and exposes that same unit to the generic
    fluid/range states.  Forcing that row once therefore asks for the minimum
    cost of producing one unit of *that exact temperature*, without collapsing
    it into the generic `fluid: steam` target.
    """
    return sorted(
        key
        for key, node in all_nodes.items()
        if (
            (node.op == "OR" and node.node_type in {"item", "fluid"})
            or node.node_type == "fluid-temperature"
            or node.cost_present
            or node.slot_cost_present
        )
    )


def _report_cost_problem(
    key: str,
    result: dict[str, Any],
    zero_cost_eps: float,
    mode_name: str,
) -> bool:
    """
    Print a warning/error for suspicious reachable-target results, but never
    abort the remaining stage. Returns True if a problem was reported.
    """
    status = result.get("status")
    prefix = f"[{mode_name}] {key!r}"

    if status != "optimal":
        print(
            f"ERROR: {prefix}: status={status!r}; "
            f"message={result.get('message')!r}",
            flush=True,
        )
        return True

    objective = result.get("objective")
    if objective is None or not math.isfinite(float(objective)):
        print(
            f"ERROR: {prefix}: non-finite cost {objective!r}",
            flush=True,
        )
        return True

    objective = float(objective)
    if objective < -zero_cost_eps:
        print(
            f"ERROR: {prefix}: negative cost {objective:.17g}",
            flush=True,
        )
        return True
    if objective <= zero_cost_eps:
        print(
            f"WARNING: {prefix}: zero/near-zero cost {objective:.17g} "
            f"(threshold {zero_cost_eps:.3g})",
            flush=True,
        )
        return True

    return False


def solve_stage_targets(
    A_original: csr_matrix,
    A_scaled: csr_matrix,
    b_scaled: np.ndarray,
    row_scale: np.ndarray,
    col_scale: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    transformed_nodes: dict[str, GraphNode],
    original_nodes: dict[str, GraphNode],
    target_keys: Sequence[str],
    reachable_original_nodes: set[str],
    method: str,
    progress_every: int,
    zero_cost_eps: float,
    mode_name: str,
) -> tuple[dict[str, Any], int]:
    row_index = {key: i for i, key in enumerate(row_keys)}
    col_index = {key: i for i, key in enumerate(col_keys)}

    results: dict[str, Any] = {}
    issues = 0
    reachable_targets: list[str] = []

    for key in target_keys:
        node = original_nodes[key]

        if key not in reachable_original_nodes:
            results[key] = {
                "status": "unreachable",
                "objective": None,
                "recipe": None,
                "producer": None,
                "message": None,
                "nit": None,
                "target_kind": node.op,
            }
            continue

        in_matrix = (
            (node.op == "OR" and key in col_index)
            or (node.op == "AND" and key in row_index)
        )
        if not in_matrix:
            results[key] = {
                "status": "missing_from_matrix",
                "objective": None,
                "recipe": None,
                "producer": None,
                "message": (
                    "Target was reachable in the stage sort but is absent from "
                    "the quantitative LP matrix"
                ),
                "nit": None,
                "target_kind": node.op,
            }
            issues += 1
            print(
                f"ERROR: [{mode_name}] {key!r}: reachable target is absent "
                f"from the quantitative LP matrix",
                flush=True,
            )
            continue

        reachable_targets.append(key)

    total = len(reachable_targets)
    for ordinal, key in enumerate(reachable_targets, start=1):
        if ordinal == 1 or ordinal == total or ordinal % progress_every == 0:
            print(f"    [{mode_name} {ordinal}/{total}] {key}", flush=True)

        node = original_nodes[key]
        if node.op == "OR":
            result = solve_one_or_target(
                A_original=A_original,
                A_scaled=A_scaled,
                b_scaled=b_scaled,
                row_scale=row_scale,
                col_scale=col_scale,
                row_keys=row_keys,
                col_keys=col_keys,
                node_meta=transformed_nodes,
                target_zero=col_index[key],
                target_key=key,
                method=method,
            )
        elif node.op == "AND":
            result = solve_one_and_target(
                A_scaled=A_scaled,
                b_scaled=b_scaled,
                row_scale=row_scale,
                row_keys=row_keys,
                target_row_zero=row_index[key],
                target_key=key,
                method=method,
            )
        else:
            result = {
                "status": "invalid_target_op",
                "objective": None,
                "recipe": None,
                "producer": None,
                "message": f"Unexpected target op {node.op!r}",
                "nit": None,
                "target_kind": node.op,
            }

        results[key] = result
        if _report_cost_problem(key, result, zero_cost_eps, mode_name):
            issues += 1

    return results, issues


# ---------------------------------------------------------------------------
# Outputs compatible in spirit with the old material-cost tables
# ---------------------------------------------------------------------------


def _pack_to_old_style_name(pack: str) -> str:
    if pack.startswith("py-science-pack-"):
        return "py-science-" + pack.removeprefix("py-science-pack-")
    if pack.endswith("-science-pack"):
        return pack.removesuffix("-pack")
    return pack


def stage_basename(snapshot: StageSnapshot) -> str:
    name = snapshot.stage_name
    if name == "full-pyrrhic-victory":
        return "py-full-pyrrhic-victory"
    return "py-full-" + _pack_to_old_style_name(name)


def _lua_quote(value: str) -> str:
    return json.dumps(value)


def write_material_json(
    path: Path,
    snapshot: StageSnapshot,
    A: csr_matrix,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    stage_meta: dict[str, Any],
    traveler_results: dict[str, Any],
    slot_results: dict[str, Any],
) -> None:
    all_keys = sorted(set(traveler_results) | set(slot_results))
    combined_results = {
        key: {
            "traveler": traveler_results.get(key),
            "slot": slot_results.get(key),
        }
        for key in all_keys
    }

    output = {
        "format": "propertyrandomizer-material-costs-graph-v2",
        "source": {
            "format": "staged logic.graph serpent dumps",
            "stage_index": snapshot.stage_index,
            "stage_name": snapshot.stage_name,
            "target_hint": snapshot.target_hint,
            "num_rows": len(row_keys),
            "num_columns": len(col_keys),
            "nnz": int(A.nnz),
            **stage_meta,
        },
        "results_by_key": combined_results,

        # `costs` remains a backwards-compatible alias for the ordinary /
        # traveler cost table.
        "costs": {},
        "traveler_costs": {},
        "slot_costs": {},

        "recipes": {},
        "traveler_recipes": {},
        "slot_recipes": {},

        "statuses": {},
        "traveler_statuses": {},
        "slot_statuses": {},
    }

    for key in all_keys:
        traveler = traveler_results.get(key) or {}
        slot = slot_results.get(key) or {}

        traveler_value = traveler.get("objective")
        if traveler_value is not None and math.isfinite(float(traveler_value)):
            value = float(traveler_value)
            output["costs"][key] = value
            output["traveler_costs"][key] = value

        slot_value = slot.get("objective")
        if slot_value is not None and math.isfinite(float(slot_value)):
            output["slot_costs"][key] = float(slot_value)

        traveler_recipe = traveler.get("recipe")
        if traveler_recipe is not None:
            output["recipes"][key] = traveler_recipe
            output["traveler_recipes"][key] = traveler_recipe

        slot_recipe = slot.get("recipe")
        if slot_recipe is not None:
            output["slot_recipes"][key] = slot_recipe

        traveler_status = traveler.get("status", "missing")
        slot_status = slot.get("status", "missing")
        output["statuses"][key] = traveler_status
        output["traveler_statuses"][key] = traveler_status
        output["slot_statuses"][key] = slot_status

    path.write_text(json.dumps(output, indent=2, sort_keys=True), encoding="utf-8")


def _append_lua_numeric_table(
    lines: list[str],
    name: str,
    results: dict[str, Any],
) -> None:
    lines.append(f"    {name} = {{")
    for key in sorted(results):
        value = results[key].get("objective")
        if value is None or not math.isfinite(float(value)):
            continue
        lines.append(f"        [{_lua_quote(key)}] = {float(value):.17g},")
    lines.append("    },")


def _append_lua_status_table(
    lines: list[str],
    name: str,
    results: dict[str, Any],
) -> None:
    lines.append(f"    {name} = {{")
    for key in sorted(results):
        lines.append(
            f"        [{_lua_quote(key)}] = "
            f"{_lua_quote(results[key].get('status', 'missing'))},"
        )
    lines.append("    },")


def _append_lua_recipe_table(
    lines: list[str],
    name: str,
    results: dict[str, Any],
) -> None:
    lines.append(f"    {name} = {{")
    for key in sorted(results):
        recipe = results[key].get("recipe")
        if recipe is not None:
            lines.append(f"        [{_lua_quote(key)}] = {_lua_quote(recipe)},")
    lines.append("    },")


def write_material_lua(
    path: Path,
    snapshot: StageSnapshot,
    A: csr_matrix,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    traveler_results: dict[str, Any],
    slot_results: dict[str, Any],
) -> None:
    lines = [
        "-- generated by solve_lp_staged_slot_costs.py",
        "return {",
        "    metadata = {",
        '        format = "propertyrandomizer-material-costs-graph-v2",',
        '        source_format = "staged logic.graph",',
        "        is_pyanodons = true,",
        "        staged_costs = true,",
        "        has_slot_costs = true,",
        f"        stage_index = {snapshot.stage_index},",
        f"        stage_name = {_lua_quote(snapshot.stage_name)},",
        f"        num_rows = {len(row_keys)},",
        f"        num_columns = {len(col_keys)},",
        f"        nnz = {int(A.nnz)},",
        "    },",
    ]

    # Backward-compatible ordinary/traveler alias plus explicit tables.
    _append_lua_numeric_table(lines, "costs", traveler_results)
    _append_lua_numeric_table(lines, "traveler_costs", traveler_results)
    _append_lua_numeric_table(lines, "slot_costs", slot_results)

    _append_lua_status_table(lines, "statuses", traveler_results)
    _append_lua_status_table(lines, "traveler_statuses", traveler_results)
    _append_lua_status_table(lines, "slot_statuses", slot_results)

    _append_lua_recipe_table(lines, "recipes", traveler_results)
    _append_lua_recipe_table(lines, "traveler_recipes", traveler_results)
    _append_lua_recipe_table(lines, "slot_recipes", slot_results)

    lines.append("}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def parse_stage_selection(text: str, count: int) -> list[int]:
    if text.lower() == "all":
        return list(range(1, count + 1))
    out: set[int] = set()
    for piece in text.split(","):
        piece = piece.strip()
        if not piece:
            continue
        if "-" in piece:
            a, b = piece.split("-", 1)
            out.update(range(int(a), int(b) + 1))
        else:
            out.add(int(piece))
    result = sorted(out)
    bad = [i for i in result if i < 1 or i > count]
    if bad:
        raise ValueError(f"Stage selection out of range 1..{count}: {bad}")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Solve staged PropertyRandomizer traveler and slot costs from "
            "per-stage logic.graph dumps"
        )
    )
    parser.add_argument(
        "input",
        type=Path,
        help="Factorio log made by the supplied staged graph/path/sort dump code",
    )
    parser.add_argument(
        "--material-cost-dir",
        type=Path,
        default=Path("material-costs"),
        help="Output folder for material-cost JSON/Lua files",
    )
    parser.add_argument(
        "--matrix-dir",
        type=Path,
        default=None,
        help=(
            "Optional folder to save A plus traveler/slot RHS and scaled matrices"
        ),
    )
    parser.add_argument(
        "--stages",
        default="all",
        help="Stage snapshots to solve: all, 1,3,5, or 2-6 (default all)",
    )
    parser.add_argument(
        "--method",
        choices=["highs", "highs-ds", "highs-ipm"],
        default="highs",
    )
    parser.add_argument("--progress-every", type=int, default=25)
    parser.add_argument(
        "--zero-cost-eps",
        type=float,
        default=1e-12,
        help=(
            "Reachable targets at or below this positive threshold print a "
            "warning but do not abort (default: 1e-12)"
        ),
    )
    parser.add_argument(
        "--scaling-passes",
        type=int,
        default=4,
        help=(
            "Alternating geometric row/column equilibration passes "
            "(default: 4; use 0 to disable)"
        ),
    )
    parser.add_argument(
        "--scaling-factor-limit",
        type=float,
        default=1e12,
        help=(
            "Maximum reciprocal scale factor applied in one equilibration pass "
            "(default: 1e12)"
        ),
    )
    parser.add_argument(
        "--matrix-only",
        action="store_true",
        help="Build matrices and metadata but do not run per-target LPs",
    )
    args = parser.parse_args()

    if args.zero_cost_eps < 0.0 or not math.isfinite(args.zero_cost_eps):
        raise ValueError("--zero-cost-eps must be a finite nonnegative number")

    print("Parsing stage snapshots and staged GRAPH DUMPs...", flush=True)
    snapshots, graph_refs = parse_log(args.input)
    exact_graph_count = sum(k != 0 for k in graph_refs)
    fallback_available = 0 in graph_refs
    print(
        f"  found {len(snapshots)} stage snapshot(s), "
        f"{exact_graph_count} stage-specific graph dump(s)"
        + (" + fallback graph" if fallback_available else ""),
        flush=True,
    )

    args.material_cost_dir.mkdir(parents=True, exist_ok=True)
    if args.matrix_dir is not None:
        args.matrix_dir.mkdir(parents=True, exist_ok=True)

    selected = parse_stage_selection(args.stages, len(snapshots))

    for stage_no in selected:
        snapshot = snapshots[stage_no - 1]
        print(
            f"\n=== stage {snapshot.stage_index}: {snapshot.stage_name} ===",
            flush=True,
        )

        graph_ref = graph_refs.get(snapshot.stage_index)
        graph_source = "stage-specific"
        if graph_ref is None:
            graph_ref = graph_refs.get(0)
            graph_source = "fallback"
        if graph_ref is None:
            print(
                f"ERROR: stage {snapshot.stage_index} has no matching GRAPH DUMP; "
                "skipping this stage",
                flush=True,
            )
            continue

        try:
            graph_payload = read_graph_payload(args.input, graph_ref)
            all_nodes, all_edges = parse_full_graph(graph_payload)
            del graph_payload
        except Exception as exc:
            print(
                f"ERROR: could not parse stage {snapshot.stage_index} graph: "
                f"{type(exc).__name__}: {exc}; skipping this stage",
                flush=True,
            )
            continue

        original_targets = cost_target_keys(all_nodes)
        node_slot_count = sum(
            node.slot_cost_present or node.slot_additional_cost != 0.0
            for node in all_nodes.values()
        )
        coproduct_true_count = sum(node.coproduct for node in all_nodes.values())
        coproduct_field_count = sum(
            node.coproduct_present for node in all_nodes.values()
        )
        edge_slot_count = sum(
            edge.slot_cost_present or edge.slot_additional_cost != 0.0
            for edge in all_edges
        )

        print(
            f"  graph ({graph_source}) nodes={len(all_nodes)} "
            f"edges={len(all_edges)} targets={len(original_targets)}; "
            f"slot-cost nodes={node_slot_count}, slot-cost edges={edge_slot_count}; "
            f"coproduct=true nodes={coproduct_true_count}",
            flush=True,
        )

        if coproduct_field_count == 0:
            print(
                "WARNING: graph contains no `coproduct` node fields. This looks "
                "like a pre-coproduct graph dump; all multi-output AND fan-out "
                "will be treated as alternative-use/non-coproduct.",
                flush=True,
            )

        # Edge slot cost has a natural row representation for OR->OR edges:
        # subdivision creates the synthetic AND row that owns the edge.
        # Anything else is suspicious, since this solver otherwise defines slot
        # additions on rows/nodes.
        unsupported_edge_slot = 0
        for edge in all_edges:
            if edge.slot_additional_cost == 0.0:
                continue
            src = all_nodes.get(edge.start)
            dst = all_nodes.get(edge.stop)
            if src is None or dst is None or not (src.op == dst.op == "OR"):
                unsupported_edge_slot += 1
        if unsupported_edge_slot:
            print(
                f"WARNING: {unsupported_edge_slot} edge(s) have "
                "slot_additional_cost but are not OR->OR; those edge-level slot "
                "costs have no defined synthetic-row owner and are ignored",
                flush=True,
            )

        try:
            stage_nodes, stage_edges, extraction_meta = extract_stage_graph(
                snapshot, all_nodes, all_edges
            )
            transformed_nodes, transformed_edges, transform_meta = make_bipartite(
                stage_nodes,
                stage_edges,
            )
            A, b_traveler, b_slot, row_keys, col_keys = build_matrix(
                transformed_nodes, transformed_edges
            )

            (
                A_traveler_scaled,
                b_traveler_scaled,
                traveler_row_scale,
                traveler_col_scale,
                traveler_scaling_meta,
            ) = geometric_equilibrate(
                A,
                b_traveler,
                passes=args.scaling_passes,
                factor_limit=args.scaling_factor_limit,
            )

            (
                A_slot_scaled,
                b_slot_scaled,
                slot_row_scale,
                slot_col_scale,
                slot_scaling_meta,
            ) = geometric_equilibrate(
                A,
                b_slot,
                passes=args.scaling_passes,
                factor_limit=args.scaling_factor_limit,
            )
        except Exception as exc:
            print(
                f"ERROR: stage {snapshot.stage_index} matrix construction failed: "
                f"{type(exc).__name__}: {exc}; skipping this stage",
                flush=True,
            )
            continue

        stage_meta = {
            **extraction_meta,
            **transform_meta,
            "graph_source": graph_source,
            "reachable_cost_targets": sum(
                key in snapshot.reachable_nodes for key in original_targets
            ),
            "node_slot_additional_cost_count": int(node_slot_count),
            "coproduct_true_node_count": int(coproduct_true_count),
            "coproduct_field_node_count": int(coproduct_field_count),
            "edge_slot_additional_cost_count": int(edge_slot_count),
            "unsupported_edge_slot_cost_count": int(unsupported_edge_slot),
            "geometric_scaling": {
                "traveler": traveler_scaling_meta,
                "slot": slot_scaling_meta,
            },
        }

        print(
            f"  matrix={A.shape[0]} x {A.shape[1]}, nnz={A.nnz}; "
            f"stage cuts={extraction_meta['stage_cut_edges_removed']}; "
            f"noncoproduct fanouts="
            f"{transform_meta['noncoproduct_fanout_nodes_normalized']}; "
            f"coproduct fanouts="
            f"{transform_meta['coproduct_fanout_nodes_preserved']}; "
            f"same-op subdivisions="
            f"{transform_meta['same_and_edges_subdivided'] + transform_meta['same_or_edges_subdivided']}",
            flush=True,
        )

        for mode_name, scaling_meta in (
            ("traveler", traveler_scaling_meta),
            ("slot", slot_scaling_meta),
        ):
            before = scaling_meta["matrix_abs_before"]
            after = scaling_meta["matrix_abs_after"]
            print(
                f"  {mode_name} geometric scaling: "
                f"|A| {before['min']!s}..{before['max']!s} -> "
                f"{after['min']!s}..{after['max']!s}",
                flush=True,
            )

        if args.matrix_dir is not None:
            stem = f"stage-{snapshot.stage_index:02d}-{snapshot.stage_name}"
            stage_dir = args.matrix_dir / stem
            stage_dir.mkdir(parents=True, exist_ok=True)

            save_npz(stage_dir / "A.npz", A)
            np.save(stage_dir / "b-traveler.npy", b_traveler)
            np.save(stage_dir / "b-slot.npy", b_slot)

            # Backward-compatible aliases point to traveler/ordinary costs.
            np.save(stage_dir / "b.npy", b_traveler)

            save_npz(stage_dir / "A-traveler-scaled.npz", A_traveler_scaled)
            np.save(stage_dir / "b-traveler-scaled.npy", b_traveler_scaled)
            np.save(stage_dir / "traveler-row-scale.npy", traveler_row_scale)
            np.save(stage_dir / "traveler-column-scale.npy", traveler_col_scale)

            save_npz(stage_dir / "A-slot-scaled.npz", A_slot_scaled)
            np.save(stage_dir / "b-slot-scaled.npy", b_slot_scaled)
            np.save(stage_dir / "slot-row-scale.npy", slot_row_scale)
            np.save(stage_dir / "slot-column-scale.npy", slot_col_scale)

            # More backward-compatible traveler aliases.
            save_npz(stage_dir / "A-scaled.npz", A_traveler_scaled)
            np.save(stage_dir / "b-scaled.npy", b_traveler_scaled)
            np.save(stage_dir / "row-scale.npy", traveler_row_scale)
            np.save(stage_dir / "column-scale.npy", traveler_col_scale)

            (stage_dir / "matrix.json").write_text(
                json.dumps(
                    {
                        "stage_index": snapshot.stage_index,
                        "stage_name": snapshot.stage_name,
                        "target_hint": snapshot.target_hint,
                        "rows": row_keys,
                        "columns": col_keys,
                        "row_costs_traveler": {
                            key: float(b_traveler[i])
                            for i, key in enumerate(row_keys)
                        },
                        "row_costs_slot": {
                            key: float(b_slot[i])
                            for i, key in enumerate(row_keys)
                        },
                        "row_slot_additional_costs": {
                            key: float(b_slot[i] - b_traveler[i])
                            for i, key in enumerate(row_keys)
                            if b_slot[i] != b_traveler[i]
                        },
                        **stage_meta,
                    },
                    indent=2,
                    sort_keys=True,
                ),
                encoding="utf-8",
            )

        if args.matrix_only:
            continue

        print("  solving traveler/ordinary costs...", flush=True)
        traveler_results, traveler_issues = solve_stage_targets(
            A_original=A,
            A_scaled=A_traveler_scaled,
            b_scaled=b_traveler_scaled,
            row_scale=traveler_row_scale,
            col_scale=traveler_col_scale,
            row_keys=row_keys,
            col_keys=col_keys,
            transformed_nodes=transformed_nodes,
            original_nodes=all_nodes,
            target_keys=original_targets,
            reachable_original_nodes=snapshot.reachable_nodes,
            method=args.method,
            progress_every=args.progress_every,
            zero_cost_eps=args.zero_cost_eps,
            mode_name="traveler",
        )

        print("  solving slot costs...", flush=True)
        slot_results, slot_issues = solve_stage_targets(
            A_original=A,
            A_scaled=A_slot_scaled,
            b_scaled=b_slot_scaled,
            row_scale=slot_row_scale,
            col_scale=slot_col_scale,
            row_keys=row_keys,
            col_keys=col_keys,
            transformed_nodes=transformed_nodes,
            original_nodes=all_nodes,
            target_keys=original_targets,
            reachable_original_nodes=snapshot.reachable_nodes,
            method=args.method,
            progress_every=args.progress_every,
            zero_cost_eps=args.zero_cost_eps,
            mode_name="slot",
        )

        from collections import Counter

        traveler_status_counts = Counter(
            result["status"] for result in traveler_results.values()
        )
        slot_status_counts = Counter(
            result["status"] for result in slot_results.values()
        )
        print(
            f"  traveler statuses={dict(traveler_status_counts)}; "
            f"warnings/errors={traveler_issues}",
            flush=True,
        )
        print(
            f"  slot statuses={dict(slot_status_counts)}; "
            f"warnings/errors={slot_issues}",
            flush=True,
        )

        basename = stage_basename(snapshot)
        json_path = args.material_cost_dir / f"{basename}.json"
        lua_path = args.material_cost_dir / f"{basename}.lua"

        write_material_json(
            json_path,
            snapshot,
            A,
            row_keys,
            col_keys,
            stage_meta,
            traveler_results,
            slot_results,
        )
        write_material_lua(
            lua_path,
            snapshot,
            A,
            row_keys,
            col_keys,
            traveler_results,
            slot_results,
        )
        print(f"  wrote {json_path}", flush=True)
        print(f"  wrote {lua_path}", flush=True)


if __name__ == "__main__":
    main()
