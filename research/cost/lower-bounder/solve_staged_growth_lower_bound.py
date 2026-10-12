#!/usr/bin/env python3
"""Finite-time relaxed production LP for staged PropertyRandomizer graphs.

This reads the same staged logic.graph dumps as solve_lp_staged_slot_costs_v6.py
and uses the same graph parsing, science-stage cuts, cost-node reification,
non-coproduct conservation, same-op subdivision, and signed amount matrix.

After normalization, S has shape AND/actions x OR/materials:

    AND -> OR amount a   => +a
    OR  -> AND amount a  => -a

For a candidate time delta whose amortized time/entity costs are ALREADY baked
into the graph edge amounts, let z >= 0 be total action usage over [0, delta].
The relaxed final finite inventory is

    x_final = x0 + S.T @ z.

All finite inventory coordinates start at zero except entity: character, which
starts at 1.  Reachable entity OR nodes with an explicit incoming amount=0 edge
are treated as infinite/autoplaced resources: their inventory constraints are
omitted.  The character is explicitly excluded from that infinite set.

The LP is

    maximize   goal_row(S.T) @ z + x0_goal
    subject to x0_j + (S.T @ z)_j >= 0  for every finite material j
               z >= 0.

Because the constant-rate schedule u(t)=z/delta traces the line segment between
x0 and x_final, endpoint nonnegativity implies nonnegativity for every t in
[0,delta].  This deliberately permits simultaneous/just-in-time production and
therefore is an optimistic relaxation suitable for proving LOWER bounds: if
even this LP cannot produce the requested goal amount by delta, the real game
cannot either.

--time-seconds is recorded in the result but is NOT applied a second time; the
graph is assumed to have been constructed using that same candidate delta.
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
        # Even a single-output non-coproduct AND gets a conserved output.
        # Besides making the transformation uniform, this is essential when
        # the original AND itself is a cost target: pricing the row directly
        # can let its own output circulate through a zero/net-positive cycle
        # and pay for its prerequisite. Pricing the conserved output instead
        # asks for one NET unit, which is the intended material/action cost.
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
        "noncoproduct_output_nodes_normalized": fanout_nodes_normalized,
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
# Finite-time relaxed production LP
# ---------------------------------------------------------------------------


def _resolve_single_stage(text: str, snapshots: Sequence[StageSnapshot]) -> StageSnapshot:
    """Resolve --stage as logged stage index, ordinal, or exact stage name."""
    stripped = text.strip()
    if not stripped:
        raise ValueError("--stage cannot be empty")

    try:
        numeric = int(stripped)
    except ValueError:
        numeric = None

    if numeric is not None:
        matches = [s for s in snapshots if s.stage_index == numeric]
        if len(matches) == 1:
            return matches[0]
        if 1 <= numeric <= len(snapshots):
            return snapshots[numeric - 1]
        raise ValueError(
            f"No stage with logged index/ordinal {numeric}; "
            f"available names={[s.stage_name for s in snapshots]}"
        )

    matches = [s for s in snapshots if s.stage_name == stripped]
    if len(matches) == 1:
        return matches[0]
    raise ValueError(
        f"Unknown stage {stripped!r}; available names="
        f"{[s.stage_name for s in snapshots]}"
    )


def detect_autoplaced_entity_keys(
    snapshot: StageSnapshot,
    all_nodes: dict[str, GraphNode],
    all_edges: Sequence[GraphEdge],
    character_key: str,
) -> tuple[set[str], dict[str, list[str]]]:
    """
    Find reachable original entity OR nodes having an explicit incoming amount=0.

    Detection happens before make_bipartite(), because that existing transform
    converts explicit-zero-to-OR edges into synthetic free-production rows.
    For this LP the same marker has a more direct interpretation: the original
    entity inventory coordinate is unlimited, so we omit its nonnegativity row.
    """
    reachable = snapshot.reachable_nodes & all_nodes.keys()
    sources: dict[str, list[str]] = {}
    for edge in all_edges:
        if edge.stop not in reachable:
            continue
        if not edge.amount_present or edge.amount != 0.0:
            continue
        node = all_nodes.get(edge.stop)
        if node is None:
            continue
        if node.op != "OR" or node.node_type != "entity":
            continue
        sources.setdefault(edge.stop, []).append(edge.key)

    # The player's one unit is a normalized finite time budget, even if the graph
    # also happens to contain a zero/free marker for the character entity.
    sources.pop(character_key, None)
    return set(sources), sources


def solve_relaxed_growth_lp(
    S: csr_matrix,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    transformed_nodes: dict[str, GraphNode],
    infinite_keys: set[str],
    goal_key: str,
    character_key: str,
    method: str,
    active_eps: float,
) -> dict[str, Any]:
    """Solve max goal final inventory over total nonnegative action usages z."""
    if S.shape != (len(row_keys), len(col_keys)):
        raise RuntimeError("Matrix/key dimensions are inconsistent")
    if S.data.size and not np.all(np.isfinite(S.data)):
        raise RuntimeError("Amount matrix contains non-finite coefficients")

    col_index = {key: i for i, key in enumerate(col_keys)}
    if goal_key not in col_index:
        raise RuntimeError(
            f"Goal material {goal_key!r} is not an OR/material coordinate in this stage"
        )
    if character_key not in col_index:
        raise RuntimeError(
            f"Character material {character_key!r} is not an OR/material coordinate "
            "in this stage"
        )

    n_materials = len(col_keys)
    n_actions = len(row_keys)
    x0 = np.zeros(n_materials, dtype=float)
    character_index = col_index[character_key]
    goal_index = col_index[goal_key]
    x0[character_index] = 1.0

    # N maps total action usages to net material changes.
    N = S.T.tocsr()  # materials x actions

    infinite_indices = {
        col_index[key] for key in infinite_keys if key in col_index and key != character_key
    }
    finite_indices = np.asarray(
        [i for i in range(n_materials) if i not in infinite_indices],
        dtype=np.int64,
    )

    # x0 + N z >= 0  <=>  -N z <= x0.
    A_ub = (-N[finite_indices, :]).tocsr()
    b_ub = x0[finite_indices].copy()

    goal_coeff = np.asarray(N.getrow(goal_index).toarray(), dtype=float).reshape(-1)
    c = -goal_coeff  # scipy minimizes

    result = linprog(
        c=c,
        A_ub=A_ub,
        b_ub=b_ub,
        bounds=(0.0, None),
        method=method,
    )

    status_map = {
        0: "optimal",
        1: "iteration_or_time_limit",
        2: "infeasible",
        3: "unbounded",
        4: "numerical_difficulty",
    }
    status = status_map.get(int(result.status), f"status_{result.status}")

    output: dict[str, Any] = {
        "status": status,
        "solver_status_code": int(result.status),
        "solver_message": str(result.message),
        "num_actions": n_actions,
        "num_materials": n_materials,
        "num_finite_material_constraints": int(finite_indices.size),
        "num_infinite_materials": len(infinite_indices),
        "goal_key": goal_key,
        "character_key": character_key,
    }

    if result.status != 0:
        return output

    z = np.asarray(result.x, dtype=float)
    finite_final = x0 + np.asarray(N @ z, dtype=float).reshape(-1)
    goal_final = float(finite_final[goal_index])
    min_finite_final = float(np.min(finite_final[finite_indices])) if finite_indices.size else math.inf

    active_actions: list[dict[str, Any]] = []
    for i, amount in enumerate(z):
        if amount <= active_eps:
            continue
        key = row_keys[i]
        node = transformed_nodes[key]
        active_actions.append(
            {
                "action_key": key,
                "total_amount": float(amount),
                "node_type": node.node_type,
                "name": node.name,
                "synthetic": bool(node.synthetic),
                "source": node.source,
                "coproduct": bool(node.coproduct),
            }
        )
    active_actions.sort(key=lambda item: item["total_amount"], reverse=True)

    positive_final: list[dict[str, Any]] = []
    depleted_final: list[dict[str, Any]] = []
    for i in finite_indices:
        value = float(finite_final[i])
        key = col_keys[int(i)]
        if value > active_eps or key in {goal_key, character_key}:
            positive_final.append({"material_key": key, "final_amount": value})
        if value <= active_eps:
            depleted_final.append({"material_key": key, "final_amount": value})
    positive_final.sort(key=lambda item: item["final_amount"], reverse=True)

    output.update(
        {
            "objective_goal_final_amount": goal_final,
            "objective_goal_net_production": float(goal_final - x0[goal_index]),
            "character_final_amount": float(finite_final[character_index]),
            "minimum_finite_final_inventory": min_finite_final,
            "active_action_count": len(active_actions),
            "active_actions": active_actions,
            "positive_finite_final_inventory": positive_final,
            "depleted_finite_materials": depleted_final,
            "total_action_l1": float(np.sum(z)),
        }
    )

    # HiGHS exposes inequality marginals.  These are for the minimization form;
    # retain them as diagnostics/certificate data without changing signs silently.
    ineqlin = getattr(result, "ineqlin", None)
    if ineqlin is not None and getattr(ineqlin, "marginals", None) is not None:
        marginals = np.asarray(ineqlin.marginals, dtype=float)
        dual_entries = []
        for local_i, marginal in enumerate(marginals):
            if abs(float(marginal)) <= active_eps:
                continue
            material_i = int(finite_indices[local_i])
            dual_entries.append(
                {
                    "material_key": col_keys[material_i],
                    "minimization_inequality_marginal": float(marginal),
                }
            )
        dual_entries.sort(
            key=lambda item: abs(item["minimization_inequality_marginal"]),
            reverse=True,
        )
        output["active_inequality_duals"] = dual_entries

    return output


def _json_safe(value: Any) -> Any:
    if isinstance(value, float):
        if math.isfinite(value):
            return value
        if math.isnan(value):
            return None
        return "Infinity" if value > 0 else "-Infinity"
    if isinstance(value, dict):
        return {str(k): _json_safe(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [_json_safe(v) for v in value]
    return value


def write_actions_csv(path: Path, result: dict[str, Any]) -> None:
    import csv

    fieldnames = [
        "rank",
        "action_key",
        "total_amount",
        "average_rate_per_second",
        "node_type",
        "name",
        "synthetic",
        "source",
        "coproduct",
    ]
    time_seconds = float(result["time_seconds"])
    with path.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for rank, action in enumerate(result.get("active_actions", []), start=1):
            row = dict(action)
            row["rank"] = rank
            row["average_rate_per_second"] = (
                float(action["total_amount"]) / time_seconds
                if time_seconds > 0.0
                else math.nan
            )
            writer.writerow({key: row.get(key) for key in fieldnames})


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Solve the finite-time optimistic production LP from a staged "
            "PropertyRandomizer dependency graph"
        )
    )
    parser.add_argument(
        "input",
        type=Path,
        help="Factorio log containing staged GRAPH/PATH/SORT dumps",
    )
    parser.add_argument(
        "--stage",
        default="1",
        help=(
            "Single stage to solve: logged index/ordinal (e.g. 1) or exact stage "
            "name (e.g. automation-science-pack); default 1"
        ),
    )
    parser.add_argument(
        "--goal",
        required=True,
        help=(
            "Goal item name only; the material coordinate is formed as "
            "'item: NAME'"
        ),
    )
    parser.add_argument(
        "--time-seconds",
        type=float,
        required=True,
        help=(
            "Candidate lower-bound time delta in seconds. Recorded/reported only: "
            "the same delta must already be baked into graph amortization amounts."
        ),
    )
    parser.add_argument(
        "--goal-amount",
        type=float,
        default=1.0,
        help=(
            "Amount of the goal item whose attainability is tested (default 1). "
            "If the relaxed optimum is below this, the candidate time is a proven "
            "lower bound for reaching this amount."
        ),
    )
    parser.add_argument(
        "--method",
        choices=["highs", "highs-ds", "highs-ipm"],
        default="highs",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("relaxed-growth-lp.json"),
        help="JSON result path (default relaxed-growth-lp.json)",
    )
    parser.add_argument(
        "--actions-csv",
        type=Path,
        default=None,
        help="Optional CSV path for positive optimal action totals",
    )
    parser.add_argument(
        "--save-lp-dir",
        type=Path,
        default=None,
        help="Optional directory to save S, LP inequalities, objective and metadata",
    )
    parser.add_argument(
        "--active-eps",
        type=float,
        default=1e-10,
        help="Reporting threshold for active actions/binding inventories",
    )
    args = parser.parse_args()

    if not math.isfinite(args.time_seconds) or args.time_seconds <= 0.0:
        raise ValueError("--time-seconds must be finite and > 0")
    if not math.isfinite(args.goal_amount) or args.goal_amount <= 0.0:
        raise ValueError("--goal-amount must be finite and > 0")
    if not math.isfinite(args.active_eps) or args.active_eps < 0.0:
        raise ValueError("--active-eps must be finite and >= 0")

    goal_key = f"item: {args.goal}"
    character_key = "entity: character"

    print("Parsing staged graph log...", flush=True)
    snapshots, graph_refs = parse_log(args.input)
    snapshot = _resolve_single_stage(args.stage, snapshots)
    print(
        f"Selected stage {snapshot.stage_index}: {snapshot.stage_name}; "
        f"goal={goal_key}; delta={args.time_seconds:g}s",
        flush=True,
    )

    graph_ref = graph_refs.get(snapshot.stage_index)
    graph_source = "stage-specific"
    if graph_ref is None:
        graph_ref = graph_refs.get(0)
        graph_source = "fallback"
    if graph_ref is None:
        raise RuntimeError(
            f"Stage {snapshot.stage_index} has no matching or fallback GRAPH DUMP"
        )

    graph_payload = read_graph_payload(args.input, graph_ref)
    all_nodes, all_edges = parse_full_graph(graph_payload)
    del graph_payload

    infinite_keys, infinite_sources = detect_autoplaced_entity_keys(
        snapshot=snapshot,
        all_nodes=all_nodes,
        all_edges=all_edges,
        character_key=character_key,
    )

    stage_nodes, stage_edges, extraction_meta = extract_stage_graph(
        snapshot, all_nodes, all_edges
    )
    transformed_nodes, transformed_edges, transform_meta = make_bipartite(
        stage_nodes, stage_edges
    )
    S, _b_traveler, _b_slot, row_keys, col_keys = build_matrix(
        transformed_nodes, transformed_edges
    )

    present_infinite_keys = {key for key in infinite_keys if key in set(col_keys)}
    missing_infinite_keys = sorted(infinite_keys - present_infinite_keys)

    print(
        f"Normalized S={S.shape[0]} actions x {S.shape[1]} materials, "
        f"nnz={S.nnz}; autoplaced/infinite entities={len(present_infinite_keys)}",
        flush=True,
    )
    if missing_infinite_keys:
        print(
            f"WARNING: {len(missing_infinite_keys)} detected infinite entity key(s) "
            "did not survive as material coordinates; ignoring them",
            flush=True,
        )

    result = solve_relaxed_growth_lp(
        S=S,
        row_keys=row_keys,
        col_keys=col_keys,
        transformed_nodes=transformed_nodes,
        infinite_keys=present_infinite_keys,
        goal_key=goal_key,
        character_key=character_key,
        method=args.method,
        active_eps=args.active_eps,
    )

    result.update(
        {
            "format": "propertyrandomizer-relaxed-growth-lp-v1",
            "stage_index": snapshot.stage_index,
            "stage_name": snapshot.stage_name,
            "target_hint": snapshot.target_hint,
            "graph_source": graph_source,
            "goal_item_name": args.goal,
            "goal_amount_requested": float(args.goal_amount),
            "time_seconds": float(args.time_seconds),
            "time_seconds_role": (
                "metadata only; candidate delta is assumed already baked into "
                "graph amortization amounts"
            ),
            "matrix_orientation": "S is AND/action rows x OR/material columns",
            "signed_amount_convention": (
                "AND->OR positive output; OR->AND negative consumption"
            ),
            "initial_inventory": {
                character_key: 1.0,
                "all_other_finite_coordinates": 0.0,
                "autoplaced_entities": "infinite (constraint omitted)",
            },
            "autoplaced_infinite_entity_keys": sorted(present_infinite_keys),
            "autoplaced_zero_edge_sources": {
                key: infinite_sources[key] for key in sorted(present_infinite_keys)
            },
            "stage_extraction": extraction_meta,
            "graph_normalization": transform_meta,
        }
    )

    if result["status"] == "optimal":
        optimum = float(result["objective_goal_final_amount"])
        # Use a tiny relative cushion only for the prose classification, not the LP.
        tol = 1e-9 * max(1.0, abs(optimum), abs(args.goal_amount))
        proved = optimum < args.goal_amount - tol
        result["lower_bound_test"] = {
            "proved": bool(proved),
            "interpretation": (
                f"Even the optimistic relaxation produces only {optimum:.17g} "
                f"< {args.goal_amount:.17g} by {args.time_seconds:g}s; therefore "
                "the real game requires more time."
                if proved
                else
                f"The optimistic relaxation can produce {optimum:.17g} >= "
                f"{args.goal_amount:.17g}; this candidate time is inconclusive."
            ),
        }
    elif result["status"] == "unbounded":
        result["lower_bound_test"] = {
            "proved": False,
            "interpretation": (
                "The optimistic relaxation is unbounded for this goal, so it cannot "
                "prove a lower bound at this candidate time."
            ),
        }
    else:
        result["lower_bound_test"] = {
            "proved": False,
            "interpretation": (
                "The LP did not return an optimal finite solution; no lower-bound "
                "claim is made."
            ),
        }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(_json_safe(result), indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    if args.actions_csv is not None and result["status"] == "optimal":
        args.actions_csv.parent.mkdir(parents=True, exist_ok=True)
        write_actions_csv(args.actions_csv, result)

    if args.save_lp_dir is not None:
        args.save_lp_dir.mkdir(parents=True, exist_ok=True)
        N = S.T.tocsr()
        col_index = {key: i for i, key in enumerate(col_keys)}
        x0 = np.zeros(len(col_keys), dtype=float)
        if character_key in col_index:
            x0[col_index[character_key]] = 1.0
        finite_indices = np.asarray(
            [i for i, key in enumerate(col_keys) if key not in present_infinite_keys],
            dtype=np.int64,
        )
        A_ub = (-N[finite_indices, :]).tocsr()
        b_ub = x0[finite_indices]
        goal_coeff = np.asarray(N.getrow(col_index[goal_key]).toarray()).reshape(-1)
        save_npz(args.save_lp_dir / "S-actions-by-materials.npz", S)
        save_npz(args.save_lp_dir / "A-ub.npz", A_ub)
        np.save(args.save_lp_dir / "b-ub.npy", b_ub)
        np.save(args.save_lp_dir / "goal-coeff.npy", goal_coeff)
        (args.save_lp_dir / "lp-metadata.json").write_text(
            json.dumps(
                {
                    "row_keys_actions": row_keys,
                    "col_keys_materials": col_keys,
                    "finite_material_indices": finite_indices.tolist(),
                    "infinite_material_keys": sorted(present_infinite_keys),
                    "goal_key": goal_key,
                    "character_key": character_key,
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

    print(f"LP status: {result['status']}", flush=True)
    if result["status"] == "optimal":
        print(
            f"Relaxed maximum {goal_key} by {args.time_seconds:g}s = "
            f"{result['objective_goal_final_amount']:.17g}",
            flush=True,
        )
        print(
            f"Character budget remaining = {result['character_final_amount']:.17g}; "
            f"active actions={result['active_action_count']}",
            flush=True,
        )
    print(result["lower_bound_test"]["interpretation"], flush=True)
    print(f"Wrote {args.output}", flush=True)
    if args.actions_csv is not None and result["status"] == "optimal":
        print(f"Wrote {args.actions_csv}", flush=True)


if __name__ == "__main__":
    main()
