#!/usr/bin/env python3
"""Dominant recipe-side eigenvectors for staged PropertyRandomizer graphs.

The input is the same staged Factorio log accepted by
``solve_lp_staged_slot_costs_v6.py``.  Its graph parser, stage reconstruction,
science-pack cuts, cost-node reification, non-coproduct conservation, and
OR-OR/AND-AND subdivisions are retained here.

After those transformations, ``build_matrix`` produces the signed amount
matrix ``S`` with shape AND/actions x OR/materials.  This script orients the
matrix requested for spectral analysis as

    A = S.T                       # OR/materials x AND/actions
    A.T @ A = S @ S.T             # AND/actions x AND/actions

Thus every eigenvector coordinate is an AND/action coordinate.  The Gram
matrix is not materialized: the eigensolver evaluates
``x -> S @ (S.T @ x)`` using sparse products.

Every selected stage gets JSON, CSV, and Lua output containing complete unit-L2
vectors, objectives, residuals, and node metadata.  The default unconstrained
mode computes ordinary eigenvectors.  ``--solution-mode nonnegative`` instead
approximately solves ``max x.T A.T A x`` subject to ``x >= 0`` and
``||x||_2 = 1`` using deterministic multi-start projected power iteration.
That nonconvex problem is not claimed to be solved globally.
``--solution-mode nonnegative-eigenvector`` instead searches eigenspaces from
largest eigenvalue downward and returns the largest exact eigenvector whose
entries can all be chosen nonnegative.  It uses action-overlap components and
reports an honest inconclusive result when a component exceeds the configured
dense-search limit.  Synthetic AND nodes created by normalization remain in the
vector because they are genuine columns of normalized ``A``; original recipe
nodes are labeled for filtering.

This is a spectral property of the signed amount matrix only.  It does not use
costs, crafting times, machines, nonnegative production-rate constraints,
inventory feasibility, or factory dynamics.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix, csr_matrix, save_npz
from scipy.sparse.linalg import ArpackNoConvergence, LinearOperator, eigsh


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

    A fluid-temperature AND is non-coproduct. Its conserved synthetic output
    commodity is therefore priced as the target, rather than forcing one gross
    execution of the row. This asks for one NET unit of that exact temperature
    and prevents its output from cycling back to subsidize its own prerequisite.
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
    reachable_targets: list[tuple[str, str | None]] = []

    def proxy_for(key: str, node: GraphNode) -> str | None:
        """
        A non-coproduct AND represents one unit of a reusable/alternative-use
        commodity. make_bipartite creates that commodity as

            AND --1--> __and_output__ (OR)

        Price that OR, not a gross execution of the AND row. Gross-row pricing
        is unsafe in cyclic networks because the action's own output may be
        recycled to cover its prerequisites, producing the characteristic
        near-direct-cost collapse seen for fluid-temperature targets.
        """
        if node.op != "AND" or node.coproduct:
            return None
        candidate = _synthetic_key("and_output", key)
        return candidate if candidate in col_index else None

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

        proxy = proxy_for(key, node)
        in_matrix = (
            (node.op == "OR" and key in col_index)
            or (node.op == "AND" and proxy is not None)
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

        reachable_targets.append((key, proxy))

    total = len(reachable_targets)
    for ordinal, (key, proxy) in enumerate(reachable_targets, start=1):
        if ordinal == 1 or ordinal == total or ordinal % progress_every == 0:
            suffix = f" -> {proxy}" if proxy is not None else ""
            print(f"    [{mode_name} {ordinal}/{total}] {key}{suffix}", flush=True)

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
        elif node.op == "AND" and proxy is not None:
            # Price one NET unit of the conserved output commodity. This is the
            # correct cost for non-coproduct AND targets such as
            # fluid-temperature and entity-operate.
            result = solve_one_or_target(
                A_original=A_original,
                A_scaled=A_scaled,
                b_scaled=b_scaled,
                row_scale=row_scale,
                col_scale=col_scale,
                row_keys=row_keys,
                col_keys=col_keys,
                node_meta=transformed_nodes,
                target_zero=col_index[proxy],
                target_key=key,
                method=method,
            )
            result["target_kind"] = "AND_AS_CONSERVED_OUTPUT"
            result["target_proxy"] = proxy
            result["original_target_op"] = "AND"
        elif node.op == "AND":
            # Coproduct ANDs keep their real simultaneous outputs. If one is
            # explicitly targeted, retain gross-execution semantics.
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
# Recipe-side Gram eigensolve and outputs
# ---------------------------------------------------------------------------


def _canonicalize_eigenvector(vector: np.ndarray) -> np.ndarray:
    """Choose the otherwise-arbitrary sign by making the largest entry positive."""
    vector = np.asarray(vector, dtype=float).reshape(-1).copy()
    if vector.size:
        pivot = int(np.argmax(np.abs(vector)))
        if vector[pivot] < 0.0:
            vector *= -1.0
    return vector


def _gram_matvec(S: csr_matrix, vector: np.ndarray) -> np.ndarray:
    """Evaluate (S S^T) vector without constructing the Gram matrix."""
    return np.asarray(S @ (S.T @ vector), dtype=float).reshape(-1)


def solve_recipe_gram_eigenvectors(
    S: csr_matrix,
    requested: int,
    tolerance: float,
    max_iterations: int | None,
    seed: int,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """
    Return dominant eigenpairs of S S^T, where rows of S are AND/actions.

    At least two eigenpairs are computed when possible so the output can report
    whether the leading direction is spectrally isolated.  Only ``requested``
    complete eigenvectors are returned.
    """
    if requested < 1:
        raise ValueError("The number of requested eigenvectors must be positive")
    if S.shape[0] == 0:
        raise RuntimeError("The stage has no AND/action nodes")
    if S.shape[1] == 0:
        raise RuntimeError("The stage has no OR/material nodes")
    if S.data.size and not np.all(np.isfinite(S.data)):
        raise RuntimeError("The amount matrix contains non-finite coefficients")

    num_actions = S.shape[0]
    returned_count = min(requested, num_actions)
    diagnostic_count = min(max(returned_count, 2), num_actions)
    frobenius_squared = float(np.dot(S.data, S.data))
    converged = True
    convergence_note: str | None = None

    if frobenius_squared == 0.0:
        values = np.zeros(diagnostic_count, dtype=float)
        vectors = np.eye(num_actions, diagnostic_count, dtype=float)
        convergence_note = "The amount matrix is identically zero."
    elif num_actions == 1:
        values = np.array([frobenius_squared], dtype=float)
        vectors = np.ones((1, 1), dtype=float)
    elif diagnostic_count == num_actions and num_actions <= 1024:
        # eigsh requires k < N.  Small stages can safely use a dense solve when
        # all eigenpairs are requested or when N=2 and the gap needs both.
        gram = (S @ S.T).toarray()
        values, vectors = np.linalg.eigh(gram)
    else:
        # For a large request of k >= N, keep the solve sparse.  The one omitted
        # eigenpair is necessarily at the bottom and cannot affect the dominant
        # vectors requested by this script.
        solve_count = min(diagnostic_count, num_actions - 1)
        operator = LinearOperator(
            shape=(num_actions, num_actions),
            matvec=lambda x: _gram_matvec(S, x),
            rmatvec=lambda x: _gram_matvec(S, x),
            dtype=np.dtype(float),
        )
        initial = np.random.default_rng(seed).standard_normal(num_actions)
        try:
            values, vectors = eigsh(
                operator,
                k=solve_count,
                which="LA",
                tol=tolerance,
                maxiter=max_iterations,
                v0=initial,
            )
        except ArpackNoConvergence as exc:
            values = exc.eigenvalues
            vectors = exc.eigenvectors
            converged = False
            convergence_note = str(exc)
            if values is None or vectors is None or len(values) == 0:
                raise RuntimeError(
                    "ARPACK did not converge and returned no eigenpairs"
                ) from exc

    order = np.argsort(np.asarray(values, dtype=float))[::-1]
    values = np.asarray(values, dtype=float)[order]
    vectors = np.asarray(vectors, dtype=float)[:, order]

    # Roundoff can make a theoretically nonnegative Gram eigenvalue minutely
    # negative.  Preserve real negative values, but turn numerical dust into 0.
    negative_roundoff_limit = 1e-12 * max(1.0, frobenius_squared)
    values = np.array(
        [0.0 if value < 0.0 and abs(value) <= negative_roundoff_limit else value
         for value in values],
        dtype=float,
    )

    pairs: list[dict[str, Any]] = []
    available_to_return = min(returned_count, vectors.shape[1])
    for index in range(available_to_return):
        value = float(values[index])
        vector = _canonicalize_eigenvector(vectors[:, index])
        norm = float(np.linalg.norm(vector))
        if norm == 0.0 or not math.isfinite(norm):
            raise RuntimeError(f"Eigenvector {index + 1} has invalid norm {norm!r}")
        vector /= norm

        residual = _gram_matvec(S, vector) - value * vector
        residual_norm = float(np.linalg.norm(residual))
        relative_residual = residual_norm / max(abs(value), 1.0)
        absolute_sum = float(np.abs(vector).sum())

        pairs.append(
            {
                "rank": index + 1,
                "solution_type": "unconstrained_eigenvector",
                "eigenvalue": value,
                "objective_value": value,
                "objective": "maximize ||A x||_2^2 with ||x||_2 = 1",
                "singular_value": math.sqrt(max(value, 0.0)),
                "frobenius_energy_fraction": (
                    value / frobenius_squared if frobenius_squared > 0.0 else None
                ),
                "residual_l2": residual_norm,
                "relative_residual": relative_residual,
                "absolute_component_sum": absolute_sum,
                "vector": vector,
            }
        )

    if not pairs:
        raise RuntimeError("No eigenvectors were available after the eigensolve")

    second_eigenvalue = float(values[1]) if values.size >= 2 else None
    leading_eigenvalue = pairs[0]["eigenvalue"]
    relative_gap = None
    if second_eigenvalue is not None:
        relative_gap = (
            (leading_eigenvalue - second_eigenvalue)
            / max(abs(leading_eigenvalue), 1e-300)
        )

    diagnostics = {
        "algorithm": "symmetric ARPACK eigensolve",
        "constraint": "unit_l2",
        "global_optimum_guaranteed": converged,
        "converged": converged,
        "convergence_note": convergence_note,
        "requested_eigenvectors": requested,
        "returned_eigenvectors": len(pairs),
        "diagnostic_eigenpairs_computed": int(values.size),
        "frobenius_norm_squared": frobenius_squared,
        "second_eigenvalue": second_eigenvalue,
        "leading_relative_spectral_gap": relative_gap,
        "leading_eigenvalue_multiplicity_warning": (
            relative_gap is not None and relative_gap <= max(10.0 * tolerance, 1e-10)
        ),
    }
    return pairs, diagnostics


def _normalize_nonnegative(vector: np.ndarray) -> np.ndarray | None:
    """Project onto the nonnegative orthant and normalize to unit L2 norm."""
    projected = np.maximum(np.asarray(vector, dtype=float).reshape(-1), 0.0)
    norm = float(np.linalg.norm(projected))
    if norm == 0.0 or not math.isfinite(norm):
        return None
    return projected / norm


def _projected_power_once(
    S: csr_matrix,
    initial: np.ndarray,
    tolerance: float,
    max_iterations: int,
) -> dict[str, Any]:
    """Run one generalized/projected power iteration from a feasible start."""
    vector = _normalize_nonnegative(initial)
    if vector is None:
        raise ValueError("Projected-power initial vector has no positive entries")

    converged = False
    fixed_point_residual = math.inf
    iterations = 0
    for iterations in range(1, max_iterations + 1):
        gram_vector = _gram_matvec(S, vector)
        next_vector = _normalize_nonnegative(gram_vector)
        if next_vector is None:
            # If the objective is exactly zero, Gx can be zero.  The current
            # feasible vector is as useful as this restart can make it.
            break
        fixed_point_residual = float(np.linalg.norm(next_vector - vector))
        vector = next_vector
        if fixed_point_residual <= tolerance:
            converged = True
            break

    gram_vector = _gram_matvec(S, vector)
    objective = float(np.dot(vector, gram_vector))
    if objective < 0.0 and abs(objective) <= 1e-12 * max(1.0, np.dot(S.data, S.data)):
        objective = 0.0

    # KKT conditions for max x^T Gx with x>=0 and ||x||=1 are
    #   (Gx)_i = objective*x_i  when x_i > 0
    #   (Gx)_i <= 0             when x_i = 0.
    active_threshold = max(10.0 * tolerance, 1e-14)
    active = vector > active_threshold
    kkt_error = np.empty_like(vector)
    kkt_error[active] = (
        gram_vector[active] - objective * vector[active]
    )
    kkt_error[~active] = np.maximum(gram_vector[~active], 0.0)
    kkt_residual = float(np.linalg.norm(kkt_error))
    relative_kkt_residual = kkt_residual / max(abs(objective), 1.0)
    full_eigen_residual = float(
        np.linalg.norm(gram_vector - objective * vector)
    )

    # Recompute the fixed-point error at the returned vector.  This is often a
    # more scale-independent convergence diagnostic than the KKT norm.
    projected_gram = _normalize_nonnegative(gram_vector)
    if projected_gram is not None:
        fixed_point_residual = float(np.linalg.norm(projected_gram - vector))

    return {
        "vector": vector,
        "objective": objective,
        "iterations": iterations,
        "converged": converged,
        "projected_fixed_point_residual": fixed_point_residual,
        "kkt_residual_l2": kkt_residual,
        "relative_kkt_residual": relative_kkt_residual,
        "full_eigen_residual_l2": full_eigen_residual,
        "positive_component_count": int(np.count_nonzero(vector > 0.0)),
    }


def solve_nonnegative_recipe_gram(
    S: csr_matrix,
    tolerance: float,
    max_iterations: int,
    seed: int,
    restarts: int,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """
    Approximately maximize x^T S S^T x over x>=0 and ||x||_2=1.

    This nonnegative principal-component problem is nonconvex and is generally
    not globally tractable.  We use the unconstrained solution as an upper
    bound and as two sign-split starts, add high-diagonal/basis and random
    starts, and retain the best projected-power stationary point.
    """
    if restarts < 1:
        raise ValueError("The number of nonnegative restarts must be positive")
    if max_iterations < 1:
        raise ValueError("The projected-power iteration limit must be positive")
    if S.shape[0] == 0 or S.shape[1] == 0:
        raise RuntimeError("The stage amount matrix is empty")
    if S.data.size and not np.all(np.isfinite(S.data)):
        raise RuntimeError("The amount matrix contains non-finite coefficients")

    unconstrained_pairs, unconstrained_diagnostics = solve_recipe_gram_eigenvectors(
        S=S,
        requested=1,
        tolerance=tolerance,
        max_iterations=max_iterations,
        seed=seed,
    )
    unconstrained = unconstrained_pairs[0]
    unconstrained_vector = unconstrained["vector"]
    unconstrained_upper_bound = float(unconstrained["eigenvalue"])
    num_actions = S.shape[0]

    starts: list[tuple[str, np.ndarray]] = []

    def add_start(label: str, candidate: np.ndarray) -> None:
        normalized = _normalize_nonnegative(candidate)
        if normalized is None or len(starts) >= restarts:
            return
        starts.append((label, normalized))

    # If the unconstrained leading vector is already feasible, it attains the
    # unconstrained upper bound and therefore globally solves the constrained
    # problem.  Still route it through the common diagnostics below.
    add_start("positive part of unconstrained eigenvector", unconstrained_vector)
    add_start("negative part of unconstrained eigenvector", -unconstrained_vector)

    row_norm_squared = np.asarray(S.multiply(S).sum(axis=1)).reshape(-1)
    diagonal_order = np.argsort(row_norm_squared)[::-1]
    for rank, action_index in enumerate(diagonal_order[: min(4, num_actions)], 1):
        basis = np.zeros(num_actions, dtype=float)
        basis[int(action_index)] = 1.0
        add_start(f"largest Gram diagonal basis #{rank}", basis)

    add_start("uniform positive vector", np.ones(num_actions, dtype=float))

    generator = np.random.default_rng(seed)
    random_ordinal = 0
    while len(starts) < restarts:
        random_ordinal += 1
        if random_ordinal % 2:
            candidate = generator.exponential(scale=1.0, size=num_actions)
            label = f"dense random positive #{random_ordinal}"
        else:
            candidate = np.zeros(num_actions, dtype=float)
            support_size = min(num_actions, max(1, int(math.sqrt(num_actions))))
            support = generator.choice(
                num_actions, size=support_size, replace=False
            )
            candidate[support] = generator.exponential(
                scale=1.0, size=support_size
            )
            label = f"sparse random positive #{random_ordinal}"
        add_start(label, candidate)

    restart_results: list[dict[str, Any]] = []
    for restart_index, (label, initial) in enumerate(starts, start=1):
        result = _projected_power_once(
            S=S,
            initial=initial,
            tolerance=tolerance,
            max_iterations=max_iterations,
        )
        result["restart_index"] = restart_index
        result["start"] = label
        restart_results.append(result)

    best = max(restart_results, key=lambda result: result["objective"])
    objective = float(best["objective"])
    frobenius_squared = float(np.dot(S.data, S.data))
    upper_gap = max(0.0, unconstrained_upper_bound - objective)
    relative_upper_gap = upper_gap / max(abs(unconstrained_upper_bound), 1.0)
    certification_tolerance = max(100.0 * tolerance, 1e-10)
    globally_certified = (
        unconstrained_diagnostics["converged"]
        and relative_upper_gap <= certification_tolerance
    )

    vector = best["vector"]
    pair = {
        "rank": 1,
        "solution_type": "nonnegative_projected_power_stationary_point",
        # Kept for output compatibility.  This is a Rayleigh quotient; it is an
        # actual eigenvalue only if the full eigen residual is small.
        "eigenvalue": objective,
        "objective_value": objective,
        "rayleigh_quotient": objective,
        "objective": "maximize ||A x||_2^2 with x >= 0 and ||x||_2 = 1",
        "singular_value": math.sqrt(max(objective, 0.0)),
        "frobenius_energy_fraction": (
            objective / frobenius_squared if frobenius_squared > 0.0 else None
        ),
        "residual_l2": best["kkt_residual_l2"],
        "relative_residual": best["relative_kkt_residual"],
        "residual_kind": "nonnegative KKT residual",
        "projected_fixed_point_residual": best[
            "projected_fixed_point_residual"
        ],
        "full_eigen_residual_l2": best["full_eigen_residual_l2"],
        "positive_component_count": best["positive_component_count"],
        "zero_component_count": int(
            num_actions - best["positive_component_count"]
        ),
        "minimum_component": float(vector.min()),
        "absolute_component_sum": float(vector.sum()),
        "iterations": best["iterations"],
        "best_restart_index": best["restart_index"],
        "best_restart_start": best["start"],
        "vector": vector,
    }

    diagnostics = {
        "algorithm": "deterministic multi-start projected power iteration",
        "constraint": "nonnegative_unit_l2",
        "global_optimum_guaranteed": globally_certified,
        "global_optimum_note": (
            "The feasible result reaches the converged unconstrained upper bound "
            "within tolerance."
            if globally_certified else
            "The problem is nonconvex; this is the best stationary point found, "
            "not a certificate of the global constrained maximum."
        ),
        "converged": bool(best["converged"]),
        "convergence_note": None if best["converged"] else (
            "The best restart reached the iteration limit before satisfying the "
            "projected fixed-point tolerance."
        ),
        "requested_eigenvectors": 1,
        "returned_eigenvectors": 1,
        "frobenius_norm_squared": frobenius_squared,
        "restarts": restarts,
        "best_restart_index": best["restart_index"],
        "unconstrained_upper_bound": unconstrained_upper_bound,
        "absolute_unconstrained_upper_bound_gap": upper_gap,
        "relative_unconstrained_upper_bound_gap": relative_upper_gap,
        "second_eigenvalue": unconstrained_diagnostics.get("second_eigenvalue"),
        "leading_relative_spectral_gap": unconstrained_diagnostics.get(
            "leading_relative_spectral_gap"
        ),
        "leading_eigenvalue_multiplicity_warning": (
            unconstrained_diagnostics.get(
                "leading_eigenvalue_multiplicity_warning", False
            )
        ),
        "restart_results": [
            {
                "restart_index": result["restart_index"],
                "start": result["start"],
                "objective_value": result["objective"],
                "iterations": result["iterations"],
                "converged": result["converged"],
                "projected_fixed_point_residual": result[
                    "projected_fixed_point_residual"
                ],
                "relative_kkt_residual": result["relative_kkt_residual"],
                "positive_component_count": result["positive_component_count"],
            }
            for result in restart_results
        ],
    }
    return [pair], diagnostics


def _action_overlap_components(S: csr_matrix) -> list[np.ndarray]:
    """
    Return structural connected components of the action-side Gram matrix.

    Two action rows are joined when they share any nonzero material column.
    A union-find over CSC columns avoids materializing S S^T merely to discover
    its block structure.  Exact coefficient cancellation can make a returned
    component coarser than necessary, but separate returned components are
    guaranteed to be separate true Gram blocks.
    """
    num_actions = S.shape[0]
    parent = np.arange(num_actions, dtype=np.int64)
    rank = np.zeros(num_actions, dtype=np.int8)

    def find(index: int) -> int:
        root = index
        while int(parent[root]) != root:
            root = int(parent[root])
        while int(parent[index]) != index:
            next_index = int(parent[index])
            parent[index] = root
            index = next_index
        return root

    def union(left: int, right: int) -> None:
        left_root = find(left)
        right_root = find(right)
        if left_root == right_root:
            return
        if rank[left_root] < rank[right_root]:
            left_root, right_root = right_root, left_root
        parent[right_root] = left_root
        if rank[left_root] == rank[right_root]:
            rank[left_root] += 1

    csc = S.tocsc()
    for column in range(csc.shape[1]):
        start = int(csc.indptr[column])
        stop = int(csc.indptr[column + 1])
        rows = csc.indices[start:stop]
        if rows.size <= 1:
            continue
        first = int(rows[0])
        for row in rows[1:]:
            union(first, int(row))

    grouped: dict[int, list[int]] = {}
    for action_index in range(num_actions):
        grouped.setdefault(find(action_index), []).append(action_index)
    components = [np.asarray(indices, dtype=np.int64) for indices in grouped.values()]
    components.sort(key=lambda indices: (-len(indices), int(indices[0])))
    return components


def _nonnegative_vector_in_eigenspace(
    basis: np.ndarray,
    feasibility_tolerance: float,
) -> tuple[np.ndarray | None, dict[str, Any]]:
    """Find a nonzero x>=0 in span(basis), if numerical LP feasibility allows."""
    dimension = basis.shape[1]
    if dimension == 1:
        candidate = basis[:, 0]
        if float(candidate.min()) >= -feasibility_tolerance:
            oriented = candidate
        elif float(candidate.max()) <= feasibility_tolerance:
            oriented = -candidate
        else:
            return None, {"method": "simple-eigenvalue sign test"}
        oriented = np.maximum(oriented, 0.0)
        norm = float(np.linalg.norm(oriented))
        if norm == 0.0:
            return None, {"method": "simple-eigenvalue sign test"}
        return oriented / norm, {"method": "simple-eigenvalue sign test"}

    # A nonzero nonnegative vector has positive coordinate sum, so fixing that
    # sum to one removes scale while leaving a linear feasibility problem in the
    # eigenspace coordinates c: basis*c >= 0, 1^T basis*c = 1.
    coordinate_sum = np.sum(basis, axis=0, keepdims=True)
    if float(np.linalg.norm(coordinate_sum)) <= feasibility_tolerance:
        return None, {"method": "eigenspace LP", "lp_status": "zero-sum span"}

    highs_tolerance = min(1e-7, max(1e-10, feasibility_tolerance))
    result = linprog(
        c=np.zeros(dimension, dtype=float),
        A_ub=-basis,
        b_ub=np.zeros(basis.shape[0], dtype=float),
        A_eq=coordinate_sum,
        b_eq=np.ones(1, dtype=float),
        bounds=[(None, None)] * dimension,
        method="highs",
        options={
            "primal_feasibility_tolerance": highs_tolerance,
            "dual_feasibility_tolerance": highs_tolerance,
        },
    )
    metadata = {
        "method": "eigenspace LP",
        "lp_status_code": int(result.status),
        "lp_status": str(result.message),
    }
    if not result.success or result.x is None:
        return None, metadata

    candidate = np.asarray(basis @ result.x, dtype=float).reshape(-1)
    minimum = float(candidate.min())
    metadata["preclip_minimum_component"] = minimum
    if minimum < -100.0 * feasibility_tolerance:
        metadata["rejected"] = "LP candidate exceeded negativity tolerance"
        return None, metadata
    candidate = np.maximum(candidate, 0.0)
    norm = float(np.linalg.norm(candidate))
    if norm == 0.0 or not math.isfinite(norm):
        metadata["rejected"] = "LP candidate had zero or invalid norm"
        return None, metadata
    return candidate / norm, metadata


def _largest_nonnegative_eigenpair_dense(
    gram: np.ndarray,
    eigenspace_tolerance: float,
) -> tuple[dict[str, Any] | None, dict[str, Any]]:
    """Completely search a manageable symmetric Gram block."""
    values, vectors = np.linalg.eigh(gram)
    num_values = len(values)
    clusters_tested = 0
    index = num_values - 1
    rejection_samples: list[dict[str, Any]] = []

    while index >= 0:
        reference = float(values[index])
        scale = max(1.0, abs(reference))
        cluster_start = index
        while cluster_start - 1 >= 0:
            candidate_value = float(values[cluster_start - 1])
            if abs(candidate_value - reference) > eigenspace_tolerance * max(
                scale, abs(candidate_value)
            ):
                break
            cluster_start -= 1

        cluster_indices = np.arange(cluster_start, index + 1)
        basis = vectors[:, cluster_indices]
        nonnegative, feasibility_meta = _nonnegative_vector_in_eigenspace(
            basis, eigenspace_tolerance
        )
        clusters_tested += 1
        if nonnegative is not None:
            gram_vector = np.asarray(gram @ nonnegative, dtype=float).reshape(-1)
            rayleigh = float(np.dot(nonnegative, gram_vector))
            residual = float(np.linalg.norm(gram_vector - rayleigh * nonnegative))
            relative_residual = residual / max(abs(rayleigh), 1.0)
            residual_limit = max(1e-8, 1000.0 * eigenspace_tolerance)
            if relative_residual <= residual_limit:
                return {
                    "eigenvalue": rayleigh,
                    "vector": nonnegative,
                    "residual_l2": residual,
                    "relative_residual": relative_residual,
                    "eigenspace_dimension": int(len(cluster_indices)),
                    "eigenvalue_cluster_min": float(values[cluster_start]),
                    "eigenvalue_cluster_max": float(values[index]),
                    "feasibility": feasibility_meta,
                }, {
                    "clusters_tested": clusters_tested,
                    "eigenvalues_computed": num_values,
                }
            feasibility_meta = {
                **feasibility_meta,
                "rejected": "candidate eigen residual exceeded tolerance",
                "relative_eigen_residual": relative_residual,
            }

        if len(rejection_samples) < 5:
            rejection_samples.append(
                {
                    "eigenvalue_cluster_min": float(values[cluster_start]),
                    "eigenvalue_cluster_max": float(values[index]),
                    "eigenspace_dimension": int(len(cluster_indices)),
                    "feasibility": feasibility_meta,
                }
            )
        index = cluster_start - 1

    return None, {
        "clusters_tested": clusters_tested,
        "eigenvalues_computed": num_values,
        "rejection_samples": rejection_samples,
    }


def find_largest_nonnegative_eigenvector(
    S: csr_matrix,
    eigenspace_tolerance: float,
    max_dense_component_actions: int,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """
    Find the largest-eigenvalue exact nonnegative eigenvector when certifiable.

    Every structural action-overlap component at or below the dense size limit
    is searched across its complete spectrum.  Oversized components are skipped
    and make a negative result inconclusive.  A found vector remains a verified
    eigenvector of the full sparse Gram matrix; its maximality is certified when
    every skipped component's Frobenius-squared spectral upper bound is no larger.
    """
    if max_dense_component_actions < 1:
        raise ValueError("The dense component action limit must be positive")
    if S.shape[0] == 0 or S.shape[1] == 0:
        raise RuntimeError("The stage amount matrix is empty")
    if S.data.size and not np.all(np.isfinite(S.data)):
        raise RuntimeError("The amount matrix contains non-finite coefficients")

    components = _action_overlap_components(S)
    searched: list[dict[str, Any]] = []
    skipped: list[dict[str, Any]] = []
    candidates: list[dict[str, Any]] = []

    for component_ordinal, action_indices in enumerate(components, start=1):
        component_S = S[action_indices, :]
        frobenius_squared = float(np.dot(component_S.data, component_S.data))
        component_size = len(action_indices)
        if component_size > max_dense_component_actions:
            skipped.append(
                {
                    "component_ordinal": component_ordinal,
                    "action_count": component_size,
                    "frobenius_squared_spectral_upper_bound": frobenius_squared,
                }
            )
            continue

        gram = (component_S @ component_S.T).toarray()
        local_candidate, local_meta = _largest_nonnegative_eigenpair_dense(
            gram=gram,
            eigenspace_tolerance=eigenspace_tolerance,
        )
        searched.append(
            {
                "component_ordinal": component_ordinal,
                "action_count": component_size,
                "found_nonnegative_eigenvector": local_candidate is not None,
                **local_meta,
            }
        )
        if local_candidate is None:
            continue
        global_vector = np.zeros(S.shape[0], dtype=float)
        global_vector[action_indices] = local_candidate["vector"]
        candidates.append(
            {
                **local_candidate,
                "vector": global_vector,
                "component_ordinal": component_ordinal,
                "component_action_count": component_size,
            }
        )

    best = max(candidates, key=lambda candidate: candidate["eigenvalue"], default=None)
    existence: bool | None
    search_status: str
    if best is not None:
        existence = True
        search_status = "found"
    elif skipped:
        existence = None
        search_status = "inconclusive"
    else:
        existence = False
        search_status = "none-exists-within-numerical-tolerance"

    maximality_certified = False
    if best is not None:
        maximality_certified = all(
            component["frobenius_squared_spectral_upper_bound"]
            <= best["eigenvalue"] * (1.0 + 100.0 * eigenspace_tolerance)
            + 100.0 * eigenspace_tolerance
            for component in skipped
        )

    diagnostics: dict[str, Any] = {
        "algorithm": (
            "complete dense eigenspace search per structural action-overlap "
            "component, with LP feasibility in repeated eigenspaces"
        ),
        "constraint": "exact_nonnegative_eigenvector",
        "search_status": search_status,
        "nonnegative_eigenvector_exists": existence,
        "largest_nonnegative_eigenvalue_certified": maximality_certified,
        "global_optimum_guaranteed": maximality_certified,
        "nonexistence_certified": best is None and not skipped,
        "converged": best is not None or not skipped,
        "convergence_note": (
            None if not skipped else
            f"{len(skipped)} component(s) exceeded the dense action limit; "
            "absence inside those components was not tested."
        ),
        "eigenspace_tolerance": eigenspace_tolerance,
        "max_dense_component_actions": max_dense_component_actions,
        "component_count": len(components),
        "searched_component_count": len(searched),
        "skipped_component_count": len(skipped),
        "largest_component_action_count": max(map(len, components), default=0),
        "searched_components": searched,
        "skipped_components": skipped,
        "requested_eigenvectors": 1,
        "returned_eigenvectors": 1 if best is not None else 0,
        "frobenius_norm_squared": float(np.dot(S.data, S.data)),
        "second_eigenvalue": None,
        "leading_relative_spectral_gap": None,
        "leading_eigenvalue_multiplicity_warning": False,
    }
    if best is None:
        return [], diagnostics

    vector = best["vector"]
    full_gram_vector = _gram_matvec(S, vector)
    eigenvalue = float(np.dot(vector, full_gram_vector))
    residual = float(np.linalg.norm(full_gram_vector - eigenvalue * vector))
    relative_residual = residual / max(abs(eigenvalue), 1.0)
    pair = {
        "rank": 1,
        "solution_type": "exact_nonnegative_eigenvector",
        "eigenvalue": eigenvalue,
        "objective_value": eigenvalue,
        "objective": (
            "largest eigenvalue found whose eigenspace intersects x >= 0"
        ),
        "singular_value": math.sqrt(max(eigenvalue, 0.0)),
        "frobenius_energy_fraction": (
            eigenvalue / diagnostics["frobenius_norm_squared"]
            if diagnostics["frobenius_norm_squared"] > 0.0 else None
        ),
        "residual_l2": residual,
        "relative_residual": relative_residual,
        "residual_kind": "full eigen-equation residual",
        "minimum_component": float(vector.min()),
        "positive_component_count": int(np.count_nonzero(vector > 0.0)),
        "zero_component_count": int(np.count_nonzero(vector == 0.0)),
        "absolute_component_sum": float(vector.sum()),
        "component_ordinal": best["component_ordinal"],
        "component_action_count": best["component_action_count"],
        "eigenspace_dimension": best["eigenspace_dimension"],
        "eigenvalue_cluster_min": best["eigenvalue_cluster_min"],
        "eigenvalue_cluster_max": best["eigenvalue_cluster_max"],
        "feasibility": best["feasibility"],
        "vector": vector,
    }
    return [pair], diagnostics


def _action_metadata(node: GraphNode) -> dict[str, Any]:
    return {
        "node_type": node.node_type,
        "name": node.name,
        "synthetic": bool(node.synthetic),
        "source": node.source,
        "coproduct": bool(node.coproduct),
        "is_original_recipe": bool(
            not node.synthetic and node.node_type == "recipe"
        ),
    }


def _stage_output_stem(snapshot: StageSnapshot) -> str:
    safe_name = re.sub(r"[^A-Za-z0-9._-]+", "-", snapshot.stage_name).strip("-")
    return f"stage-{snapshot.stage_index:02d}-{safe_name or 'unnamed'}"


def _json_safe_pair(pair: dict[str, Any], row_keys: Sequence[str]) -> dict[str, Any]:
    vector = pair["vector"]
    absolute_sum = pair["absolute_component_sum"]
    coefficient_by_key = {
        key: float(vector[index]) for index, key in enumerate(row_keys)
    }
    absolute_share_by_key = {
        key: (float(abs(vector[index]) / absolute_sum) if absolute_sum else 0.0)
        for index, key in enumerate(row_keys)
    }
    return {
        key: value for key, value in pair.items() if key != "vector"
    } | {
        "coefficient_by_action": coefficient_by_key,
        "absolute_share_by_action": absolute_share_by_key,
        "actions_by_descending_absolute_coefficient": sorted(
            row_keys,
            key=lambda key: abs(coefficient_by_key[key]),
            reverse=True,
        ),
    }


def write_eigenvector_json(
    path: Path,
    snapshot: StageSnapshot,
    S: csr_matrix,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    transformed_nodes: dict[str, GraphNode],
    pairs: Sequence[dict[str, Any]],
    diagnostics: dict[str, Any],
    stage_meta: dict[str, Any],
) -> None:
    row_index = {key: index for index, key in enumerate(row_keys)}
    metadata_by_action = {
        key: _action_metadata(transformed_nodes[key]) for key in row_keys
    }
    original_recipe_keys = [
        key for key in row_keys
        if metadata_by_action[key]["is_original_recipe"]
    ]
    output = {
        "format": "propertyrandomizer-staged-recipe-gram-eigenvectors-v1",
        "source": {
            "format": "staged logic.graph serpent dumps",
            "stage_index": snapshot.stage_index,
            "stage_name": snapshot.stage_name,
            "target_hint": snapshot.target_hint,
            "matrix_orientation": (
                "A is OR/material rows x AND/action columns; "
                "A^T A is AND/action x AND/action"
            ),
            "signed_amount_convention": (
                "AND->OR output positive; OR->AND input negative"
            ),
            "num_material_rows": len(col_keys),
            "num_action_columns": len(row_keys),
            "num_original_recipe_columns": len(original_recipe_keys),
            "nnz": int(S.nnz),
            **stage_meta,
        },
        "diagnostics": diagnostics,
        "action_metadata": metadata_by_action,
        "material_keys": list(col_keys),
        "eigenpairs": [_json_safe_pair(pair, row_keys) for pair in pairs],
        "original_recipe_rankings": [
            sorted(
                original_recipe_keys,
                key=lambda key, vector=pair["vector"]: abs(
                    vector[row_index[key]]
                ),
                reverse=True,
            )
            for pair in pairs
        ],
    }
    path.write_text(json.dumps(output, indent=2, sort_keys=True), encoding="utf-8")


def write_eigenvector_csv(
    path: Path,
    row_keys: Sequence[str],
    transformed_nodes: dict[str, GraphNode],
    pairs: Sequence[dict[str, Any]],
) -> None:
    vectors = [pair["vector"] for pair in pairs]
    absolute_sums = [pair["absolute_component_sum"] for pair in pairs]
    order = sorted(
        range(len(row_keys)),
        key=lambda index: abs(vectors[0][index]),
        reverse=True,
    )
    fieldnames = [
        "rank_by_abs_component_1",
        "matrix_index",
        "action_key",
        "node_type",
        "name",
        "synthetic",
        "source",
        "coproduct",
        "is_original_recipe",
    ]
    for rank in range(1, len(pairs) + 1):
        fieldnames.extend([f"component_{rank}", f"absolute_share_{rank}"])

    with path.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for display_rank, index in enumerate(order, start=1):
            key = row_keys[index]
            row: dict[str, Any] = {
                "rank_by_abs_component_1": display_rank,
                "matrix_index": index,
                "action_key": key,
                **_action_metadata(transformed_nodes[key]),
            }
            for pair_index, vector in enumerate(vectors, start=1):
                coefficient = float(vector[index])
                absolute_sum = absolute_sums[pair_index - 1]
                row[f"component_{pair_index}"] = f"{coefficient:.17g}"
                row[f"absolute_share_{pair_index}"] = (
                    f"{abs(coefficient) / absolute_sum:.17g}"
                    if absolute_sum else "0"
                )
            writer.writerow(row)


def write_eigenvector_lua(
    path: Path,
    snapshot: StageSnapshot,
    S: csr_matrix,
    pairs: Sequence[dict[str, Any]],
    row_keys: Sequence[str],
    diagnostics: dict[str, Any],
) -> None:
    lines = [
        "-- generated by solve_staged_recipe_eigenvectors.py",
        "return {",
        "    metadata = {",
        '        format = "propertyrandomizer-staged-recipe-gram-eigenvectors-v1",',
        f"        stage_index = {snapshot.stage_index},",
        f"        stage_name = {_lua_quote(snapshot.stage_name)},",
        f"        num_material_rows = {S.shape[1]},",
        f"        num_action_columns = {S.shape[0]},",
        f"        nnz = {int(S.nnz)},",
        "        a_rows = \"OR/materials\",",
        "        a_columns = \"AND/actions\",",
        "        gram_side = \"AND/actions\",",
        f"        constraint = {_lua_quote(str(diagnostics.get('constraint', 'unit_l2')))},",
        f"        converged = {str(bool(diagnostics['converged'])).lower()},",
        f"        global_optimum_guaranteed = "
        f"{str(bool(diagnostics.get('global_optimum_guaranteed', False))).lower()},",
        "    },",
        "    eigenpairs = {",
    ]
    for pair in pairs:
        lines.extend(
            [
                "        {",
                f"            rank = {pair['rank']},",
                f"            solution_type = {_lua_quote(pair['solution_type'])},",
                f"            eigenvalue = {pair['eigenvalue']:.17g},",
                f"            objective_value = {pair['objective_value']:.17g},",
                f"            singular_value = {pair['singular_value']:.17g},",
                f"            residual_l2 = {pair['residual_l2']:.17g},",
                "            coefficients = {",
            ]
        )
        vector = pair["vector"]
        for index, key in enumerate(row_keys):
            lines.append(
                f"                [{_lua_quote(key)}] = {float(vector[index]):.17g},"
            )
        lines.extend(["            },", "        },"])
    lines.extend(["    },", "}"])
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
            "Compute dominant recipe/action eigenvectors of A^T A for every "
            "selected staged PropertyRandomizer graph"
        )
    )
    parser.add_argument(
        "input",
        type=Path,
        help="Factorio log made by the staged graph/path/sort dump code",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help=(
            "Output folder for per-stage JSON, CSV, and Lua files (default: "
            "recipe-eigenvectors, or recipe-eigenvectors-nonnegative in "
            "nonnegative mode, or recipe-eigenvectors-exact-nonnegative in "
            "nonnegative-eigenvector mode)"
        ),
    )
    parser.add_argument(
        "--stages",
        default="all",
        help="Stage snapshots to solve: all, 1,3,5, or 2-6 (default all)",
    )
    parser.add_argument(
        "--eigenvectors",
        type=int,
        default=1,
        help="Number of dominant complete eigenvectors to output (default: 1)",
    )
    parser.add_argument(
        "--solution-mode",
        choices=[
            "unconstrained",
            "nonnegative",
            "nonnegative-eigenvector",
        ],
        default="unconstrained",
        help=(
            "unconstrained: ordinary dominant eigenvector(s); nonnegative: "
            "best multi-start projected-power solution with x>=0; "
            "nonnegative-eigenvector: search complete manageable eigenspaces "
            "for an actual x>=0 eigenvector (default: unconstrained)"
        ),
    )
    parser.add_argument(
        "--nonnegative-restarts",
        type=int,
        default=12,
        help=(
            "Deterministic starts used in nonnegative mode (default: 12; more "
            "starts improve the search but cannot guarantee the global optimum)"
        ),
    )
    parser.add_argument(
        "--max-dense-component-actions",
        type=int,
        default=2000,
        help=(
            "Largest action-overlap component searched across its complete "
            "spectrum in nonnegative-eigenvector mode (default: 2000)"
        ),
    )
    parser.add_argument(
        "--eigenspace-tolerance",
        type=float,
        default=1e-10,
        help=(
            "Relative eigenvalue clustering and nonnegative feasibility "
            "tolerance in nonnegative-eigenvector mode (default: 1e-10)"
        ),
    )
    parser.add_argument(
        "--tolerance",
        type=float,
        default=1e-9,
        help="ARPACK relative convergence tolerance (default: 1e-9)",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=None,
        help=(
            "Iteration limit: optional ARPACK limit in unconstrained mode; "
            "projected-power limit per restart in nonnegative mode "
            "(default there: 5000)"
        ),
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=0,
        help="Deterministic starting-vector seed (default: 0)",
    )
    parser.add_argument(
        "--save-matrix",
        action="store_true",
        help=(
            "Also save each stage's sparse A as A-materials-by-actions.npz; "
            "this transposed copy can require additional memory"
        ),
    )
    args = parser.parse_args()

    if args.eigenvectors < 1:
        raise ValueError("--eigenvectors must be at least 1")
    if args.solution_mode != "unconstrained" and args.eigenvectors != 1:
        raise ValueError(
            f"--solution-mode {args.solution_mode} currently defines one "
            "returned vector; use --eigenvectors 1"
        )
    if args.nonnegative_restarts < 1:
        raise ValueError("--nonnegative-restarts must be positive")
    if args.max_dense_component_actions < 1:
        raise ValueError("--max-dense-component-actions must be positive")
    if (
        args.eigenspace_tolerance <= 0.0
        or not math.isfinite(args.eigenspace_tolerance)
    ):
        raise ValueError("--eigenspace-tolerance must be finite and positive")
    if args.tolerance < 0.0 or not math.isfinite(args.tolerance):
        raise ValueError("--tolerance must be finite and nonnegative")
    if args.max_iterations is not None and args.max_iterations < 1:
        raise ValueError("--max-iterations must be positive")
    if args.output_dir is None:
        args.output_dir = Path(
            "recipe-eigenvectors-nonnegative"
            if args.solution_mode == "nonnegative" else
            "recipe-eigenvectors-exact-nonnegative"
            if args.solution_mode == "nonnegative-eigenvector" else
            "recipe-eigenvectors"
        )

    print("Parsing stage snapshots and staged GRAPH DUMPs...", flush=True)
    snapshots, graph_refs = parse_log(args.input)
    exact_graph_count = sum(key != 0 for key in graph_refs)
    fallback_available = 0 in graph_refs
    print(
        f"  found {len(snapshots)} stage snapshot(s), "
        f"{exact_graph_count} stage-specific graph dump(s)"
        + (" + fallback graph" if fallback_available else ""),
        flush=True,
    )

    args.output_dir.mkdir(parents=True, exist_ok=True)
    selected = parse_stage_selection(args.stages, len(snapshots))
    index_entries: list[dict[str, Any]] = []

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

            coproduct_true_count = sum(
                node.coproduct for node in all_nodes.values()
            )
            coproduct_field_count = sum(
                node.coproduct_present for node in all_nodes.values()
            )
            stage_nodes, stage_edges, extraction_meta = extract_stage_graph(
                snapshot, all_nodes, all_edges
            )
            transformed_nodes, transformed_edges, transform_meta = make_bipartite(
                stage_nodes, stage_edges
            )
            # build_matrix returns S = AND/actions x OR/materials.  The A named
            # in this script is S.T, so A.T A is S S.T on the action side.
            S, _unused_b1, _unused_b2, row_keys, col_keys = build_matrix(
                transformed_nodes, transformed_edges
            )
            del _unused_b1, _unused_b2
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
            "coproduct_true_node_count": int(coproduct_true_count),
            "coproduct_field_node_count": int(coproduct_field_count),
            "solution_mode": args.solution_mode,
        }
        original_recipe_count = sum(
            not transformed_nodes[key].synthetic
            and transformed_nodes[key].node_type == "recipe"
            for key in row_keys
        )
        print(
            f"  A={S.shape[1]} material rows x {S.shape[0]} action columns, "
            f"nnz={S.nnz}; original recipe columns={original_recipe_count}; "
            f"stage cuts={extraction_meta['stage_cut_edges_removed']}",
            flush=True,
        )
        if coproduct_field_count == 0:
            print(
                "WARNING: graph contains no `coproduct` node fields; all "
                "multi-output AND fan-out is treated as non-coproduct.",
                flush=True,
            )

        if args.solution_mode == "nonnegative-eigenvector":
            print(
                "  searching exact eigenspaces for an x>=0 eigenvector...",
                flush=True,
            )
        elif args.solution_mode == "nonnegative":
            print(
                "  searching for x>=0 maximizing x^T A^T A x...",
                flush=True,
            )
        else:
            print("  solving dominant eigenvector(s) of A^T A...", flush=True)
        try:
            if args.solution_mode == "nonnegative-eigenvector":
                pairs, diagnostics = find_largest_nonnegative_eigenvector(
                    S=S,
                    eigenspace_tolerance=args.eigenspace_tolerance,
                    max_dense_component_actions=(
                        args.max_dense_component_actions
                    ),
                )
            elif args.solution_mode == "nonnegative":
                pairs, diagnostics = solve_nonnegative_recipe_gram(
                    S=S,
                    tolerance=args.tolerance,
                    max_iterations=args.max_iterations or 5000,
                    seed=args.seed + snapshot.stage_index,
                    restarts=args.nonnegative_restarts,
                )
            else:
                pairs, diagnostics = solve_recipe_gram_eigenvectors(
                    S=S,
                    requested=args.eigenvectors,
                    tolerance=args.tolerance,
                    max_iterations=args.max_iterations,
                    seed=args.seed + snapshot.stage_index,
                )
        except Exception as exc:
            print(
                f"ERROR: stage {snapshot.stage_index} eigensolve failed: "
                f"{type(exc).__name__}: {exc}; skipping this stage",
                flush=True,
            )
            continue

        stem = _stage_output_stem(snapshot)
        json_path = args.output_dir / f"{stem}.json"
        csv_path = args.output_dir / f"{stem}.csv"
        lua_path = args.output_dir / f"{stem}.lua"
        write_eigenvector_json(
            json_path,
            snapshot,
            S,
            row_keys,
            col_keys,
            transformed_nodes,
            pairs,
            diagnostics,
            stage_meta,
        )
        if not pairs:
            print(
                f"  search status={diagnostics['search_status']}; "
                "no verified nonnegative eigenvector returned",
                flush=True,
            )
            print(f"  wrote {json_path}", flush=True)
            index_entries.append(
                {
                    "stage_index": snapshot.stage_index,
                    "stage_name": snapshot.stage_name,
                    "json": json_path.name,
                    "csv": None,
                    "lua": None,
                    "num_material_rows": S.shape[1],
                    "num_action_columns": S.shape[0],
                    "nnz": int(S.nnz),
                    "solution_mode": args.solution_mode,
                    "search_status": diagnostics["search_status"],
                    "nonnegative_eigenvector_exists": diagnostics[
                        "nonnegative_eigenvector_exists"
                    ],
                    "largest_nonnegative_eigenvalue_certified": False,
                    "converged": diagnostics["converged"],
                }
            )
            continue
        write_eigenvector_csv(
            csv_path, row_keys, transformed_nodes, pairs
        )
        write_eigenvector_lua(
            lua_path, snapshot, S, pairs, row_keys, diagnostics
        )
        if args.save_matrix:
            save_npz(
                args.output_dir / f"{stem}-A-materials-by-actions.npz",
                S.T.tocsr(),
            )

        leading = pairs[0]
        gap = diagnostics.get("leading_relative_spectral_gap")
        objective_label = (
            "nonnegative eigenvalue"
            if args.solution_mode == "nonnegative-eigenvector" else
            "nonnegative Rayleigh quotient"
            if args.solution_mode == "nonnegative" else "lambda_1"
        )
        print(
            f"  {objective_label}={leading['objective_value']:.9g}, "
            f"sigma_1={leading['singular_value']:.9g}, "
            f"relative residual={leading['relative_residual']:.3g}"
            + (f", relative gap={gap:.3g}" if gap is not None else ""),
            flush=True,
        )
        if args.solution_mode == "nonnegative":
            print(
                "  global constrained optimum certified="
                f"{diagnostics['global_optimum_guaranteed']}; "
                "gap to unconstrained upper bound="
                f"{diagnostics['relative_unconstrained_upper_bound_gap']:.3g}",
                flush=True,
            )
        elif args.solution_mode == "nonnegative-eigenvector":
            print(
                "  largest nonnegative eigenvalue certified="
                f"{diagnostics['largest_nonnegative_eigenvalue_certified']}; "
                f"components searched={diagnostics['searched_component_count']}/"
                f"{diagnostics['component_count']}",
                flush=True,
            )
        print(f"  wrote {json_path}", flush=True)
        print(f"  wrote {csv_path}", flush=True)
        print(f"  wrote {lua_path}", flush=True)

        index_entries.append(
            {
                "stage_index": snapshot.stage_index,
                "stage_name": snapshot.stage_name,
                "json": json_path.name,
                "csv": csv_path.name,
                "lua": lua_path.name,
                "num_material_rows": S.shape[1],
                "num_action_columns": S.shape[0],
                "nnz": int(S.nnz),
                "solution_mode": args.solution_mode,
                "solution_type": leading["solution_type"],
                "objective_value": leading["objective_value"],
                "largest_eigenvalue": leading["eigenvalue"],
                "largest_singular_value": leading["singular_value"],
                "leading_relative_spectral_gap": gap,
                "converged": diagnostics["converged"],
                "global_optimum_guaranteed": diagnostics.get(
                    "global_optimum_guaranteed", False
                ),
                "search_status": diagnostics.get("search_status"),
                "nonnegative_eigenvector_exists": diagnostics.get(
                    "nonnegative_eigenvector_exists"
                ),
                "largest_nonnegative_eigenvalue_certified": diagnostics.get(
                    "largest_nonnegative_eigenvalue_certified"
                ),
            }
        )

    index_path = args.output_dir / "index.json"
    index_path.write_text(
        json.dumps(
            {
                "format": "propertyrandomizer-staged-recipe-gram-index-v1",
                "matrix_orientation": (
                    "A is OR/material rows x AND/action columns; "
                    "A^T A is AND/action x AND/action"
                ),
                "solution_mode": args.solution_mode,
                "stages": index_entries,
            },
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )
    print(f"\nWrote stage index {index_path}", flush=True)


if __name__ == "__main__":
    main()
