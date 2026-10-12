#!/usr/bin/env python3
"""
Optimized dependency-graph material-cost solver for PropertyRandomizer.

Input:
  Factorio log containing the staged path/sort dumps and full dependency graph.
  Stage reachability comes from every pebble in sort_info.sorted; path is only
  retained as critical-path/target metadata.

Matrix semantics:
  * AND node = row/action
  * OR node = column/material/state
  * AND -> OR contributes +amount (production)
  * OR -> AND contributes -amount (consumption)
  * missing amount = 0
  * normal RHS = AND.cost
  * slot RHS = AND.cost + AND.slot_additional_cost

Before solving each stage, the program performs structural reductions:
  1. Reify cost-bearing OR nodes through an OR -> AND(cost) -> OR bridge.
  2. Contract nonzero-degree-one topological series paths, carrying arbitrary
     edge amounts through a multiplicative scale and retaining path membership
     for cost reconstruction. Cost-bearing followers start a new segment.
  3. Subdivide any remaining same-op edge to make the graph strictly bipartite.
  4. Remove provably-zero nodes. Seeds are source AND nodes with no cost
     parameter; propagation requires every nonzero incoming dependency to have
     already been proven zero. Slot-cost-bearing nodes are kept conservatively.
  5. Iteratively peel sinks. Individual linprog objectives are solved only for
     OR columns in the remaining sink-resistant core.
  6. Recover peeled acyclic OR-material costs by forward flow. Co-product
     credits are ignored, so these recovered values are upper bounds.

The solver writes per-stage core matrices, full original-material cost tables,
and a detailed optimization report with incremental/cumulative size reductions.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Iterable, Iterator, Sequence

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix, csr_matrix, save_npz


PATH_SOURCE_MARKER = "data-final-fixes.lua:212:"
SORT_SOURCE_MARKER = "data-final-fixes.lua:213:"
GRAPH_SOURCE_MARKER = "data-final-fixes.lua:218:"

# A top-level graph object always begins this way in Serpent's dump. Nested
# pre/dep/abilities tables do not contain object_type, so this is also a fast
# delimiter for the 95+ MB graph line.
ENTRY_START_RE = re.compile(
    r'(?:\{|,)\["((?:\\.|[^"\\])*)"\]=\{object_type="(node|edge)"'
)
SORT_ITEM_RE = re.compile(
    r'\{node_key="((?:\\.|[^"\\])*)",context="((?:\\.|[^"\\])*)"\}'
)
NUMBER_RE = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


@dataclass(frozen=True)
class GraphNode:
    key: str
    op: str
    cost: float = 0.0
    slot_additional_cost: float = 0.0
    cost_present: bool = False
    slot_cost_present: bool = False
    node_type: str | None = None
    name: str | None = None
    synthetic: bool = False
    source_edge: str | None = None


@dataclass(frozen=True)
class GraphEdge:
    key: str
    start: str
    stop: str
    amount: float = 0.0
    slot_additional_cost: float = 0.0


@dataclass(frozen=True)
class BipartiteEdge:
    start: str
    stop: str
    amount: float
    source_edge: str
    synthetic: bool = False


@dataclass
class StageSnapshot:
    ordinal: int
    path_indices: list[int]
    reachable_nodes: set[str]
    contexts: dict[str, str]
    target_hint: str | None


@dataclass
class ValidationReport:
    graph_nodes: int = 0
    graph_edges: int = 0
    and_nodes: int = 0
    or_nodes: int = 0
    same_and_edges: int = 0
    same_or_edges: int = 0
    mixed_edges: int = 0
    missing_endpoint_edges: int = 0
    non_and_or_nodes: int = 0
    node_costs_nonzero: int = 0
    node_slot_costs_nonzero: int = 0
    edge_amounts_missing: int = 0
    edge_slot_costs_nonzero: int = 0
    edge_slot_costs_not_or_or: int = 0
    or_nodes_with_cost: int = 0
    slot_cost_field_present: bool = False
    missing_endpoint_edge_examples: list[str] | None = None
    or_nodes_with_cost_examples: list[str] | None = None
    non_and_or_node_examples: list[str] | None = None
    warnings: list[str] | None = None


# ---------------------------------------------------------------------------
# Tiny Lua/Serpent scalar helpers
# ---------------------------------------------------------------------------


def _lua_unescape(raw: str) -> str:
    """Unescape the subset of Lua quoted-string escapes Serpent uses here."""
    out: list[str] = []
    i = 0
    n = len(raw)
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
    while i < n:
        ch = raw[i]
        if ch != "\\":
            out.append(ch)
            i += 1
            continue
        i += 1
        if i >= n:
            out.append("\\")
            break
        esc = raw[i]
        if esc in simple:
            out.append(simple[esc])
            i += 1
            continue
        if esc == "z":
            i += 1
            while i < n and raw[i].isspace():
                i += 1
            continue
        if esc == "x" and i + 2 < n:
            h = raw[i + 1 : i + 3]
            try:
                out.append(chr(int(h, 16)))
                i += 3
                continue
            except ValueError:
                pass
        if esc.isdigit():
            j = i
            while j < n and j < i + 3 and raw[j].isdigit():
                j += 1
            out.append(chr(int(raw[i:j], 10)))
            i = j
            continue
        # Preserve unknown escape's character rather than failing on a node
        # name that uses an escape we do not otherwise care about.
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


def _has_field(text: str, start: int, end: int, field: str) -> bool:
    pat = re.compile(rf'(?:\{{|,){re.escape(field)}=')
    return pat.search(text, start, end) is not None


def _after_log_prefix(line: str, marker: str) -> str:
    pos = line.find(marker)
    if pos < 0:
        raise ValueError(f"Marker {marker!r} not found")
    return line[pos + len(marker) :].lstrip()


# ---------------------------------------------------------------------------
# Stage/path parsing
# ---------------------------------------------------------------------------


def _parse_path_indices(payload: str) -> list[int]:
    m = re.search(r"(?:\{|,)path=\{([^}]*)\}", payload)
    if not m:
        raise RuntimeError("Could not find path={...} in path dump")
    body = m.group(1).strip()
    if not body:
        return []
    try:
        return [int(part) for part in body.split(",") if part]
    except ValueError as exc:
        raise RuntimeError("Path dump contains a non-integer path entry") from exc


def _resolve_path_from_sort(
    payload: str,
    path_indices: Sequence[int],
) -> tuple[set[str], dict[str, str], str | None]:
    """
    Resolve one stage snapshot from ``sort_info.sorted``.

    ``path_indices`` is only the critical/witness path returned by ``top.path``.
    The actual nodes reachable at this stage are *all* pebbles present in
    ``sort_info.sorted``.  Earlier versions of this program incorrectly used
    only the path entries as the stage node set, which made later stages appear
    smaller whenever OR nodes chose a different critical-path producer.
    """
    sorted_pos = payload.find("sorted={")
    if sorted_pos < 0:
        raise RuntimeError("Sort dump has no sorted={...} table")

    wanted = set(path_indices)
    reachable: set[str] = set()
    contexts: dict[str, str] = {}
    target_hint: str | None = None
    target_index = path_indices[0] if path_indices else None
    found_indices: set[int] = set()

    # Lua arrays are 1-indexed; path entries are indices into sorted.  Every
    # sorted pebble is reachable, while membership in ``wanted`` merely says
    # that pebble lies on the exported critical path.
    for lua_index, m in enumerate(SORT_ITEM_RE.finditer(payload, sorted_pos), start=1):
        key = _lua_unescape(m.group(1))
        context = _lua_unescape(m.group(2))
        reachable.add(key)
        contexts[key] = context

        if lua_index in wanted:
            found_indices.add(lua_index)
        if lua_index == target_index:
            target_hint = key

    missing = wanted - found_indices
    if missing:
        sample = sorted(missing)[:10]
        raise RuntimeError(
            f"Sort dump did not contain {len(missing)} path indices; sample={sample}"
        )

    return reachable, contexts, target_hint


def parse_stage_snapshots(log_path: Path) -> tuple[list[StageSnapshot], str]:
    """Return stage snapshots using all nodes in each ``sort_info.sorted`` table."""
    snapshots: list[StageSnapshot] = []
    pending_path: list[int] | None = None
    graph_payload: str | None = None

    with log_path.open("r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if PATH_SOURCE_MARKER in line and "path={" in line:
                if pending_path is not None:
                    raise RuntimeError("Found a new path dump before its sort dump")
                pending_path = _parse_path_indices(
                    _after_log_prefix(line, PATH_SOURCE_MARKER)
                )
                continue

            if SORT_SOURCE_MARKER in line and "sorted={" in line:
                if pending_path is None:
                    # Ignore unrelated sort-info logging if any exists.
                    continue
                reachable, contexts, target_hint = _resolve_path_from_sort(
                    _after_log_prefix(line, SORT_SOURCE_MARKER),
                    pending_path,
                )
                snapshots.append(
                    StageSnapshot(
                        ordinal=len(snapshots) + 1,
                        path_indices=list(pending_path),
                        reachable_nodes=reachable,
                        contexts=contexts,
                        target_hint=target_hint,
                    )
                )
                pending_path = None
                continue

            if GRAPH_SOURCE_MARKER in line and 'object_type="node"' in line:
                graph_payload = _after_log_prefix(line, GRAPH_SOURCE_MARKER)

    if pending_path is not None:
        raise RuntimeError("Log ended after path dump but before matching sort dump")
    if not snapshots:
        raise RuntimeError("No path/sort stage dumps found")
    if graph_payload is None:
        raise RuntimeError("No full dependency graph dump found")

    return snapshots, graph_payload


# ---------------------------------------------------------------------------
# Full graph parsing
# ---------------------------------------------------------------------------


def parse_full_graph(payload: str) -> tuple[dict[str, GraphNode], list[GraphEdge], bool]:
    """
    Parse only the scalar fields needed for the matrix.

    The graph is enormous. ENTRY_START_RE finds each top-level object in C via
    regex and lets us avoid recursively parsing pre/dep tables that are not
    needed for this task.
    """
    starts = list(ENTRY_START_RE.finditer(payload))
    if not starts:
        raise RuntimeError("Full graph dump contains no node/edge objects")

    nodes: dict[str, GraphNode] = {}
    edges: list[GraphEdge] = []
    slot_field_seen = False

    # The final object ends before the initial table's `};_.nodes=...` tail.
    table_tail = payload.find("};_.nodes=", starts[-1].start())
    if table_tail < 0:
        table_tail = payload.find(";_.nodes=", starts[-1].start())
    if table_tail < 0:
        table_tail = len(payload)

    for idx, m in enumerate(starts):
        key = _lua_unescape(m.group(1))
        object_type = m.group(2)
        start = m.start()
        end = starts[idx + 1].start() if idx + 1 < len(starts) else table_tail

        if _has_field(payload, start, end, "slot_additional_cost"):
            slot_field_seen = True

        if object_type == "node":
            op = _find_string_field(payload, start, end, "op")
            if op is None:
                op = ""
            cost_present = _has_field(payload, start, end, "cost")
            slot_cost_present = _has_field(payload, start, end, "slot_additional_cost")
            cost = _find_number_field(payload, start, end, "cost") or 0.0
            slot_cost = (
                _find_number_field(payload, start, end, "slot_additional_cost") or 0.0
            )
            node_type = _find_string_field(payload, start, end, "type")
            name = _find_string_field(payload, start, end, "name")
            if key in nodes:
                raise RuntimeError(f"Duplicate graph node key: {key!r}")
            nodes[key] = GraphNode(
                key=key,
                op=op,
                cost=cost,
                slot_additional_cost=slot_cost,
                cost_present=cost_present,
                slot_cost_present=slot_cost_present,
                node_type=node_type,
                name=name,
            )
            continue

        edge_start = _find_string_field(payload, start, end, "start")
        edge_stop = _find_string_field(payload, start, end, "stop")
        if edge_start is None or edge_stop is None:
            raise RuntimeError(f"Edge {key!r} is missing start/stop")
        amount = _find_number_field(payload, start, end, "amount")
        slot_cost = _find_number_field(payload, start, end, "slot_additional_cost")
        edges.append(
            GraphEdge(
                key=key,
                start=edge_start,
                stop=edge_stop,
                amount=0.0 if amount is None else amount,
                slot_additional_cost=0.0 if slot_cost is None else slot_cost,
            )
        )

    return nodes, edges, slot_field_seen


# ---------------------------------------------------------------------------
# Validation + bipartite subdivision
# ---------------------------------------------------------------------------


def validate_graph(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    slot_field_seen: bool,
) -> ValidationReport:
    report = ValidationReport(
        warnings=[],
        missing_endpoint_edge_examples=[],
        or_nodes_with_cost_examples=[],
        non_and_or_node_examples=[],
    )
    report.graph_nodes = len(nodes)
    report.graph_edges = len(edges)
    report.slot_cost_field_present = slot_field_seen

    for node in nodes.values():
        if node.op == "AND":
            report.and_nodes += 1
        elif node.op == "OR":
            report.or_nodes += 1
        else:
            report.non_and_or_nodes += 1
            if len(report.non_and_or_node_examples) < 8:
                report.non_and_or_node_examples.append(node.key)
        if node.cost != 0:
            report.node_costs_nonzero += 1
            if node.op == "OR":
                report.or_nodes_with_cost += 1
                if len(report.or_nodes_with_cost_examples) < 8:
                    report.or_nodes_with_cost_examples.append(
                        f"{node.key} (cost={node.cost:g})"
                    )
        if node.slot_additional_cost != 0:
            report.node_slot_costs_nonzero += 1

    for edge in edges:
        src = nodes.get(edge.start)
        dst = nodes.get(edge.stop)
        if src is None or dst is None:
            report.missing_endpoint_edges += 1
            if len(report.missing_endpoint_edge_examples) < 8:
                missing = []
                if src is None:
                    missing.append(f"start={edge.start!r}")
                if dst is None:
                    missing.append(f"stop={edge.stop!r}")
                report.missing_endpoint_edge_examples.append(
                    f"{edge.key}: missing {', '.join(missing)}"
                )
            continue
        if edge.amount == 0:
            report.edge_amounts_missing += 1
        if edge.slot_additional_cost != 0:
            report.edge_slot_costs_nonzero += 1
        if src.op == dst.op == "AND":
            report.same_and_edges += 1
            if edge.slot_additional_cost != 0:
                report.edge_slot_costs_not_or_or += 1
        elif src.op == dst.op == "OR":
            report.same_or_edges += 1
        elif {src.op, dst.op} == {"AND", "OR"}:
            report.mixed_edges += 1
            if edge.slot_additional_cost != 0:
                report.edge_slot_costs_not_or_or += 1

    if report.non_and_or_nodes:
        report.warnings.append(
            f"{report.non_and_or_nodes} graph nodes do not have op AND/OR; "
            "edges touching them cannot be represented in this matrix."
        )
    if report.missing_endpoint_edges:
        report.warnings.append(
            f"{report.missing_endpoint_edges} edges reference missing endpoints."
        )
    if report.edge_slot_costs_not_or_or:
        report.warnings.append(
            f"{report.edge_slot_costs_not_or_or} non-OR->OR edges carry "
            "slot_additional_cost; the stated rules only define how to transfer "
            "that field for OR->OR subdivision."
        )
    if not slot_field_seen:
        report.warnings.append(
            "No slot_additional_cost field occurs in this sample graph dump. "
            "The parser/solver supports it, but sample slot LPs will therefore "
            "match normal LPs unless synthetic/input data changes."
        )

    return report


def synthetic_key(kind: str, source_key: str) -> str:
    return f"__pr_lp_{kind}__:{source_key}"


def or_cost_pre_key(node_key: str) -> str:
    return synthetic_key("or_cost_pre", node_key)


def or_cost_and_key(node_key: str) -> str:
    return synthetic_key("or_cost_and", node_key)


def bipartize_graph(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[BipartiteEdge], dict[str, str]]:
    """
    Convert the graph to a strict AND/OR bipartite graph.

    Two transformations happen in this order:

      1. A cost-bearing OR material M becomes

             M_pre(OR) --1--> M_cost(AND, cost=M.cost) --1--> M(OR)

         Every original edge ending at M is redirected to M_pre. Every
         original edge starting at M still starts at M. Thus M's prerequisites
         live on the left side of the bridge and M's dependants live on the
         right side. The original key is retained by the downstream OR so LP
         targets and consumers continue to refer to the same material key.

      2. Remaining same-op edges are subdivided according to the user's amount
         convention.
    """
    out_nodes = dict(nodes)
    out_edges: list[BipartiteEdge] = []
    synthetic_owner: dict[str, str] = {}

    # OR node costs cannot live directly on a matrix column. Split them through
    # a cost-bearing AND row. Preserve the original key on the downstream OR.
    cost_or_nodes = {
        key for key, node in nodes.items() if node.op == "OR" and node.cost != 0.0
    }
    for key in cost_or_nodes:
        node = nodes[key]
        pre = or_cost_pre_key(key)
        cost_and = or_cost_and_key(key)
        for synthetic in (pre, cost_and):
            if synthetic in out_nodes:
                raise RuntimeError(f"Synthetic node key collision: {synthetic!r}")

        # The original downstream material becomes cost-free; its cost has been
        # reified as the bridge AND row. Any unexpected node-level slot cost is
        # moved with it as the closest row-equivalent interpretation.
        out_nodes[key] = GraphNode(
            key=node.key,
            op=node.op,
            cost=0.0,
            slot_additional_cost=0.0,
            node_type=node.node_type,
            name=node.name,
            synthetic=node.synthetic,
            source_edge=node.source_edge,
        )
        out_nodes[pre] = GraphNode(
            key=pre,
            op="OR",
            synthetic=True,
            source_edge=f"node-cost:{key}",
        )
        out_nodes[cost_and] = GraphNode(
            key=cost_and,
            op="AND",
            cost=node.cost,
            slot_additional_cost=node.slot_additional_cost,
            synthetic=True,
            source_edge=f"node-cost:{key}",
        )
        synthetic_owner[pre] = f"node-cost:{key}"
        synthetic_owner[cost_and] = f"node-cost:{key}"

        out_edges.append(
            BipartiteEdge(
                start=pre,
                stop=cost_and,
                amount=1.0,
                source_edge=f"node-cost:{key}:pre",
                synthetic=True,
            )
        )
        out_edges.append(
            BipartiteEdge(
                start=cost_and,
                stop=key,
                amount=1.0,
                source_edge=f"node-cost:{key}:post",
                synthetic=True,
            )
        )

    # Redirect incoming edges of a split OR to its prerequisite-side OR.
    def mapped_start(key: str) -> str:
        return key

    def mapped_stop(key: str) -> str:
        return or_cost_pre_key(key) if key in cost_or_nodes else key

    for edge in edges:
        original_src = nodes.get(edge.start)
        original_dst = nodes.get(edge.stop)
        if original_src is None or original_dst is None:
            continue
        if original_src.op not in {"AND", "OR"} or original_dst.op not in {"AND", "OR"}:
            continue

        start_key = mapped_start(edge.start)
        stop_key = mapped_stop(edge.stop)
        src = out_nodes[start_key]
        dst = out_nodes[stop_key]

        if src.op != dst.op:
            out_edges.append(
                BipartiteEdge(
                    start=start_key,
                    stop=stop_key,
                    amount=edge.amount,
                    source_edge=edge.key,
                )
            )
            continue

        if src.op == "AND":
            # A --X--> B  ==>  A --1--> M --X--> B
            mid = synthetic_key("or", edge.key)
            if mid in out_nodes:
                raise RuntimeError(f"Synthetic node key collision: {mid!r}")
            out_nodes[mid] = GraphNode(
                key=mid,
                op="OR",
                synthetic=True,
                source_edge=edge.key,
            )
            synthetic_owner[mid] = edge.key
            out_edges.append(
                BipartiteEdge(
                    start=start_key,
                    stop=mid,
                    amount=1.0,
                    source_edge=edge.key,
                    synthetic=True,
                )
            )
            out_edges.append(
                BipartiteEdge(
                    start=mid,
                    stop=stop_key,
                    amount=edge.amount,
                    source_edge=edge.key,
                    synthetic=True,
                )
            )
            continue

        # OR --X--> OR  ==>  OR --X--> R --1--> OR
        mid = synthetic_key("and", edge.key)
        if mid in out_nodes:
            raise RuntimeError(f"Synthetic node key collision: {mid!r}")
        out_nodes[mid] = GraphNode(
            key=mid,
            op="AND",
            cost=0.0,
            slot_additional_cost=edge.slot_additional_cost,
            synthetic=True,
            source_edge=edge.key,
        )
        synthetic_owner[mid] = edge.key
        out_edges.append(
            BipartiteEdge(
                start=start_key,
                stop=mid,
                amount=edge.amount,
                source_edge=edge.key,
                synthetic=True,
            )
        )
        out_edges.append(
            BipartiteEdge(
                start=mid,
                stop=stop_key,
                amount=1.0,
                source_edge=edge.key,
                synthetic=True,
            )
        )

    return out_nodes, out_edges, synthetic_owner


# ---------------------------------------------------------------------------
# Stage matrix construction
# ---------------------------------------------------------------------------


def stage_included_nodes(
    snapshot: StageSnapshot,
    original_nodes: dict[str, GraphNode],
    original_edges: Sequence[GraphEdge],
    transformed_nodes: dict[str, GraphNode],
) -> set[str]:
    included = {key for key in snapshot.reachable_nodes if key in original_nodes}

    # A cost-bearing OR is an intrinsic three-node representation of one
    # original material, so include both synthetic bridge nodes whenever the
    # original OR material is present in the stage.
    for key in list(included):
        node = original_nodes[key]
        if node.op == "OR" and node.cost != 0.0:
            pre = or_cost_pre_key(key)
            cost_and = or_cost_and_key(key)
            if pre in transformed_nodes:
                included.add(pre)
            if cost_and in transformed_nodes:
                included.add(cost_and)

    # A same-op edge subdivision node represents one original edge. It is
    # meaningful in a stage exactly when both original endpoints are present.
    # OR-cost endpoint redirection does not change the endpoint ops.
    for edge in original_edges:
        src = original_nodes.get(edge.start)
        dst = original_nodes.get(edge.stop)
        if src is None or dst is None or src.op != dst.op:
            continue
        if edge.start in included and edge.stop in included:
            kind = "or" if src.op == "AND" else "and"
            mid = synthetic_key(kind, edge.key)
            if mid in transformed_nodes:
                included.add(mid)

    return included


def build_stage_matrix(
    snapshot: StageSnapshot,
    original_nodes: dict[str, GraphNode],
    original_edges: Sequence[GraphEdge],
    transformed_nodes: dict[str, GraphNode],
    transformed_edges: Sequence[BipartiteEdge],
) -> tuple[csr_matrix, np.ndarray, np.ndarray, list[str], list[str], dict[str, Any]]:
    included = stage_included_nodes(
        snapshot, original_nodes, original_edges, transformed_nodes
    )

    row_keys = sorted(
        key for key in included if transformed_nodes[key].op == "AND"
    )
    col_keys = sorted(
        key for key in included if transformed_nodes[key].op == "OR"
    )
    row_index = {key: i for i, key in enumerate(row_keys)}
    col_index = {key: i for i, key in enumerate(col_keys)}

    rr: list[int] = []
    cc: list[int] = []
    vv: list[float] = []
    active_transformed_edges = 0
    skipped_cross_boundary_edges = 0

    for edge in transformed_edges:
        if edge.start not in included or edge.stop not in included:
            skipped_cross_boundary_edges += 1
            continue
        src = transformed_nodes[edge.start]
        dst = transformed_nodes[edge.stop]
        if src.op == "AND" and dst.op == "OR":
            r = row_index[edge.start]
            c = col_index[edge.stop]
            value = edge.amount
        elif src.op == "OR" and dst.op == "AND":
            r = row_index[edge.stop]
            c = col_index[edge.start]
            value = -edge.amount
        else:
            raise RuntimeError(
                f"Transformed edge is not bipartite: {edge.start!r} -> {edge.stop!r}"
            )
        # Explicit zero amounts are semantically valid but need not occupy the
        # sparse matrix.
        if value != 0.0:
            rr.append(r)
            cc.append(c)
            vv.append(value)
        active_transformed_edges += 1

    A = coo_matrix(
        (vv, (rr, cc)), shape=(len(row_keys), len(col_keys)), dtype=float
    ).tocsr()
    A.sum_duplicates()
    A.eliminate_zeros()

    b_normal = np.array(
        [transformed_nodes[key].cost for key in row_keys], dtype=float
    )
    b_slot = np.array(
        [
            transformed_nodes[key].cost
            + transformed_nodes[key].slot_additional_cost
            for key in row_keys
        ],
        dtype=float,
    )

    positive_entries = int(np.count_nonzero(A.data > 0))
    negative_entries = int(np.count_nonzero(A.data < 0))
    meta = {
        "stage": snapshot.ordinal,
        "target_hint": snapshot.target_hint,
        "critical_path_indices": len(snapshot.path_indices),
        "reachable_original_nodes_from_sorted": len(snapshot.reachable_nodes),
        "included_nodes_after_subdivision": len(included),
        "rows_and": len(row_keys),
        "cols_or": len(col_keys),
        "matrix_nnz": int(A.nnz),
        "positive_production_entries": positive_entries,
        "negative_consumption_entries": negative_entries,
        "active_transformed_edges": active_transformed_edges,
        "skipped_cross_boundary_transformed_edges": skipped_cross_boundary_edges,
        "normal_cost_nonzero_rows": int(np.count_nonzero(b_normal)),
        "slot_extra_nonzero_rows": int(np.count_nonzero(b_slot - b_normal)),
    }
    return A, b_normal, b_slot, row_keys, col_keys, meta


# ---------------------------------------------------------------------------
# LP solving
# ---------------------------------------------------------------------------


def solve_one_material(
    A: csr_matrix,
    b: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    target_zero: int,
    method: str,
) -> dict[str, Any]:
    c = np.zeros(A.shape[1], dtype=float)
    c[target_zero] = -1.0

    result = linprog(
        c=c,
        A_ub=A,
        b_ub=b,
        bounds=(0, None),
        method=method,
        options={"presolve": True},
    )

    if result.status != 0:
        status = (
            "unbounded"
            if result.status == 3
            else "infeasible"
            if result.status == 2
            else f"solver_status_{result.status}"
        )
        return {
            "status": status,
            "objective": None,
            "producer_row": None,
            "message": result.message,
            "nit": getattr(result, "nit", None),
        }

    # HiGHS inequality marginals correspond to primal row usages in the dual.
    marginals = np.asarray(result.ineqlin.marginals, dtype=float)
    row_usages = np.maximum(0.0, -marginals)

    producer_row: dict[str, Any] | None = None
    best_contribution = 0.0
    column = A.getcol(target_zero).tocoo()
    for row_zero, coefficient in zip(column.row, column.data):
        if coefficient <= 0.0:
            continue
        usage = float(row_usages[row_zero])
        contribution = usage * float(coefficient)
        if contribution > best_contribution + 1e-12:
            best_contribution = contribution
            producer_row = {
                "row_index": int(row_zero),
                "row_key": row_keys[row_zero],
                "usage": usage,
                "target_output_per_use": float(coefficient),
                "target_contribution": contribution,
            }

    return {
        "status": "optimal",
        "objective": float(-result.fun),
        "producer_row": producer_row,
        "message": result.message,
        "nit": getattr(result, "nit", None),
    }


def solve_all_materials(
    A: csr_matrix,
    b: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    method: str,
    progress_every: int,
) -> dict[str, Any]:
    results: dict[str, Any] = {}
    total = len(col_keys)
    for j, key in enumerate(col_keys):
        ordinal = j + 1
        if ordinal == 1 or ordinal == total or ordinal % progress_every == 0:
            print(f"      [{ordinal}/{total}] {key}", flush=True)
        results[key] = solve_one_material(
            A=A,
            b=b,
            row_keys=row_keys,
            col_keys=col_keys,
            target_zero=j,
            method=method,
        )
    return results


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------


def _slug_target(target: str | None) -> str:
    if not target:
        return "stage"
    if ": " in target:
        target = target.split(": ", 1)[1]
    target = re.sub(r"[^A-Za-z0-9._-]+", "-", target).strip("-")
    return target or "stage"


def write_stage_outputs(
    out_dir: Path,
    snapshot: StageSnapshot,
    A: csr_matrix,
    b_normal: np.ndarray,
    b_slot: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    meta: dict[str, Any],
    normal_results: dict[str, Any] | None,
    slot_results: dict[str, Any] | None,
) -> Path:
    stem = f"stage-{snapshot.ordinal:02d}-{_slug_target(snapshot.target_hint)}"
    stage_dir = out_dir / stem
    stage_dir.mkdir(parents=True, exist_ok=True)

    save_npz(stage_dir / "A.npz", A)
    np.save(stage_dir / "b-normal.npy", b_normal)
    np.save(stage_dir / "b-slot.npy", b_slot)

    metadata = {
        **meta,
        "coefficient_convention": {
            "AND_to_OR": "positive production",
            "OR_to_AND": "negative consumption",
            "missing_amount": 0,
        },
        "rows": list(row_keys),
        "columns": list(col_keys),
        "row_costs_normal": {
            key: float(b_normal[i]) for i, key in enumerate(row_keys)
        },
        "row_costs_slot": {key: float(b_slot[i]) for i, key in enumerate(row_keys)},
    }
    (stage_dir / "matrix.json").write_text(
        json.dumps(metadata, indent=2, sort_keys=True), encoding="utf-8"
    )

    if normal_results is not None or slot_results is not None:
        costs = {
            "format": "propertyrandomizer-dependency-costs-v1",
            "stage": snapshot.ordinal,
            "target_hint": snapshot.target_hint,
            "normal": normal_results,
            "slot": slot_results,
        }
        (stage_dir / "costs.json").write_text(
            json.dumps(costs, indent=2, sort_keys=True), encoding="utf-8"
        )

    return stage_dir



# ---------------------------------------------------------------------------
# Optimized stage reduction pipeline
# ---------------------------------------------------------------------------


@dataclass
class MatrixSize:
    rows: int
    cols: int
    nnz: int

    @property
    def cells(self) -> int:
        return self.rows * self.cols


class UnionFind:
    def __init__(self, keys: Iterable[str]):
        self.parent = {k: k for k in keys}
        self.rank = {k: 0 for k in keys}

    def find(self, x: str) -> str:
        p = self.parent[x]
        if p != x:
            self.parent[x] = self.find(p)
        return self.parent[x]

    def union(self, a: str, b: str) -> None:
        ra = self.find(a)
        rb = self.find(b)
        if ra == rb:
            return
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1


def split_or_costs_only(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[GraphEdge]]:
    """Reify OR-node costs, but do not subdivide same-op edges yet."""
    out_nodes = dict(nodes)
    out_edges: list[GraphEdge] = []
    cost_or_nodes = {
        key for key, node in nodes.items()
        if node.op == "OR" and (node.cost_present or node.slot_cost_present)
    }

    for key in cost_or_nodes:
        node = nodes[key]
        pre = or_cost_pre_key(key)
        cost_and = or_cost_and_key(key)
        if pre in out_nodes or cost_and in out_nodes:
            raise RuntimeError(f"Synthetic OR-cost key collision for {key!r}")

        out_nodes[key] = GraphNode(
            key=node.key,
            op="OR",
            cost=0.0,
            slot_additional_cost=0.0,
            cost_present=False,
            slot_cost_present=False,
            node_type=node.node_type,
            name=node.name,
            synthetic=node.synthetic,
            source_edge=node.source_edge,
        )
        out_nodes[pre] = GraphNode(
            key=pre,
            op="OR",
            synthetic=True,
            source_edge=f"node-cost:{key}",
        )
        out_nodes[cost_and] = GraphNode(
            key=cost_and,
            op="AND",
            cost=node.cost,
            slot_additional_cost=node.slot_additional_cost,
            cost_present=node.cost_present,
            slot_cost_present=node.slot_cost_present,
            synthetic=True,
            source_edge=f"node-cost:{key}",
        )
        out_edges.append(GraphEdge(
            key=f"node-cost:{key}:pre",
            start=pre,
            stop=cost_and,
            amount=1.0,
        ))
        out_edges.append(GraphEdge(
            key=f"node-cost:{key}:post",
            start=cost_and,
            stop=key,
            amount=1.0,
        ))

    for edge in edges:
        if edge.start not in nodes or edge.stop not in nodes:
            continue
        start = edge.start
        stop = or_cost_pre_key(edge.stop) if edge.stop in cost_or_nodes else edge.stop
        out_edges.append(GraphEdge(
            key=edge.key,
            start=start,
            stop=stop,
            amount=edge.amount,
            slot_additional_cost=edge.slot_additional_cost,
        ))

    return out_nodes, out_edges


def extract_stage_graph_after_or_cost_split(
    snapshot: StageSnapshot,
    original_nodes: dict[str, GraphNode],
    split_nodes: dict[str, GraphNode],
    split_edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[GraphEdge]]:
    included = {k for k in snapshot.reachable_nodes if k in original_nodes}
    for key in list(included):
        node = original_nodes[key]
        if node.op == "OR" and (node.cost_present or node.slot_cost_present):
            included.add(or_cost_pre_key(key))
            included.add(or_cost_and_key(key))
    stage_nodes = {k: split_nodes[k] for k in included if k in split_nodes}
    stage_edges = [e for e in split_edges if e.start in stage_nodes and e.stop in stage_nodes]
    return stage_nodes, stage_edges


def contract_linear_series_paths(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[
    dict[str, GraphNode],
    list[GraphEdge],
    dict[str, str],
    dict[str, float],
    dict[str, list[str]],
    dict[str, Any],
]:
    """
    Contract maximal directed series paths before same-op subdivision.

    Degree tests ignore amount==0 edges.  A topological series edge u->v is
    eligible when u has exactly one nonzero dependent edge and v has exactly
    one nonzero prerequisite edge.  Cyclic all-degree-one components are not
    contracted.

    To keep the graph rewrite homogeneous and exact, a follower v is collapsed
    only when v has no direct normal/slot cost parameter and neither the path
    edge nor any edge leaving v carries edge slot cost.  A cost-bearing node
    simply starts a new series segment.  This still captures the large wrapper
    chains while avoiding branch-specific additive offsets.

    For every collapsed node x we retain

        cost(x) = scale[x] * cost(base[x])

    The scale update for an edge u -a-> v is:
      * if v is AND:     multiply by a
      * if u is AND and v is OR: divide by a
      * if u is OR  and v is OR: multiply by a

    (AND->AND also multiplies because its normal subdivision is
    AND -> OR(1) -> AND(a).)
    """
    active = [e for e in edges if e.amount != 0.0]
    indeg = {k: 0 for k in nodes}
    outdeg = {k: 0 for k in nodes}
    outgoing: dict[str, list[GraphEdge]] = {k: [] for k in nodes}
    for e in active:
        indeg[e.stop] += 1
        outdeg[e.start] += 1
        outgoing[e.start].append(e)

    topo_edge_by_start: dict[str, GraphEdge] = {}
    topo_pred: dict[str, GraphEdge] = {}
    for e in active:
        if outdeg[e.start] == 1 and indeg[e.stop] == 1:
            topo_edge_by_start[e.start] = e
            topo_pred[e.stop] = e

    starts = sorted(k for k in topo_edge_by_start if k not in topo_pred)
    full_paths: list[list[str]] = []
    visited_edges: set[str] = set()
    for start_key in starts:
        path = [start_key]
        cur = start_key
        while cur in topo_edge_by_start:
            e = topo_edge_by_start[cur]
            if e.key in visited_edges:
                break
            visited_edges.add(e.key)
            cur = e.stop
            path.append(cur)
        if len(path) > 1:
            full_paths.append(path)

    cyclic_topology_edges = len(topo_edge_by_start) - len(visited_edges)

    rep = {k: k for k in nodes}
    scale = {k: 1.0 for k in nodes}
    members_by_rep: dict[str, list[str]] = {k: [k] for k in nodes}
    contracted_segments: list[list[str]] = []
    skipped_cost_followers = 0
    skipped_slot_followers = 0

    def edge_scale(src_key: str, dst_key: str, amount: float) -> float:
        src = nodes[src_key]
        dst = nodes[dst_key]
        if dst.op == "AND":
            return amount
        if src.op == "AND" and dst.op == "OR":
            if amount <= 0.0:
                raise RuntimeError("Series contraction requires positive AND->OR amount")
            return 1.0 / amount
        # OR->OR subdivision consumes `amount` from the source OR.
        return amount

    for full in full_paths:
        segment = [full[0]]
        for i in range(1, len(full)):
            prev = full[i - 1]
            cur = full[i]
            e = topo_edge_by_start[prev]
            node = nodes[cur]
            unsafe_cost = node.cost_present or node.slot_cost_present
            unsafe_slot = (
                e.slot_additional_cost != 0.0
                or any(x.slot_additional_cost != 0.0 for x in outgoing[cur])
            )
            if unsafe_cost or unsafe_slot:
                if len(segment) > 1:
                    contracted_segments.append(segment)
                if unsafe_cost:
                    skipped_cost_followers += 1
                if unsafe_slot:
                    skipped_slot_followers += 1
                segment = [cur]
                continue
            segment.append(cur)
        if len(segment) > 1:
            contracted_segments.append(segment)

    internal_edges: set[str] = set()
    for segment in contracted_segments:
        base = segment[0]
        cumulative = 1.0
        for i in range(1, len(segment)):
            prev = segment[i - 1]
            cur = segment[i]
            e = topo_edge_by_start[prev]
            cumulative *= edge_scale(prev, cur, e.amount)
            rep[cur] = base
            scale[cur] = cumulative
            members_by_rep[base].append(cur)
            members_by_rep.pop(cur, None)
            internal_edges.add(e.key)

    kept_nodes = {k: n for k, n in nodes.items() if rep[k] == k}

    def transformed_amount(e: GraphEdge, source_rep: str) -> float:
        if source_rep == e.start:
            return e.amount
        alpha = scale[e.start]
        src_orig = nodes[e.start]
        src_new = nodes[source_rep]
        dst = nodes[e.stop]
        if dst.op == "AND":
            return e.amount * alpha
        old_coeff = (1.0 / e.amount) if src_orig.op == "AND" else e.amount
        desired_coeff = alpha * old_coeff
        if src_new.op == "AND":
            if desired_coeff <= 0.0:
                raise RuntimeError("Nonpositive compressed AND->OR gain")
            return 1.0 / desired_coeff
        return desired_coeff

    out_edges: list[GraphEdge] = []
    for e in active:
        sr = rep[e.start]
        tr = rep[e.stop]
        if sr == tr and e.key in internal_edges:
            continue
        # An external edge cannot enter an interior node of a valid series
        # segment: interior nodes had nonzero indegree exactly one.
        if tr != e.stop:
            raise RuntimeError(
                f"Unexpected external edge into contracted series interior: {e.key}"
            )
        amount = transformed_amount(e, sr)
        out_edges.append(GraphEdge(
            key=e.key if sr == e.start else f"series:{e.key}",
            start=sr,
            stop=tr,
            amount=amount,
            slot_additional_cost=e.slot_additional_cost,
        ))

    stats = {
        "topological_series_edges": len(topo_edge_by_start),
        "topological_series_paths": len(full_paths),
        "cyclic_degree_one_edges_skipped": cyclic_topology_edges,
        "contracted_segments": len(contracted_segments),
        "contracted_edges": len(internal_edges),
        "nodes_before": len(nodes),
        "nodes_after": len(kept_nodes),
        "nodes_removed": len(nodes) - len(kept_nodes),
        "cost_bearing_followers_used_as_new_segment_bases": skipped_cost_followers,
        "slot_cost_followers_used_as_new_segment_bases": skipped_slot_followers,
        "max_segment_nodes": max((len(x) for x in contracted_segments), default=1),
    }
    return kept_nodes, out_edges, rep, scale, members_by_rep, stats

def subdivide_remaining_same_op(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    key_tag: str,
) -> tuple[dict[str, GraphNode], list[GraphEdge]]:
    """Make a strict AND/OR graph after unit contraction."""
    out_nodes = dict(nodes)
    out_edges: list[GraphEdge] = []
    for i, edge in enumerate(edges):
        src = out_nodes[edge.start]
        dst = out_nodes[edge.stop]
        if src.op != dst.op:
            out_edges.append(edge)
            continue

        mid = synthetic_key(
            "or" if src.op == "AND" else "and",
            f"{key_tag}:{i}:{edge.key}",
        )
        if mid in out_nodes:
            raise RuntimeError(f"Synthetic subdivision key collision: {mid!r}")

        if src.op == "AND":
            out_nodes[mid] = GraphNode(
                key=mid,
                op="OR",
                synthetic=True,
                source_edge=edge.key,
            )
            out_edges.append(GraphEdge(
                key=f"{edge.key}:sub-a",
                start=edge.start,
                stop=mid,
                amount=1.0,
            ))
            out_edges.append(GraphEdge(
                key=f"{edge.key}:sub-b",
                start=mid,
                stop=edge.stop,
                amount=edge.amount,
                slot_additional_cost=edge.slot_additional_cost,
            ))
        else:
            out_nodes[mid] = GraphNode(
                key=mid,
                op="AND",
                cost=0.0,
                slot_additional_cost=edge.slot_additional_cost,
                cost_present=False,
                slot_cost_present=edge.slot_additional_cost != 0.0,
                synthetic=True,
                source_edge=edge.key,
            )
            out_edges.append(GraphEdge(
                key=f"{edge.key}:sub-a",
                start=edge.start,
                stop=mid,
                amount=edge.amount,
            ))
            out_edges.append(GraphEdge(
                key=f"{edge.key}:sub-b",
                start=mid,
                stop=edge.stop,
                amount=1.0,
            ))
    return out_nodes, out_edges


def build_matrix_from_strict_graph(
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
                f"Graph not strict bipartite at {edge.start!r}->{edge.stop!r}"
            )

    A = coo_matrix(
        (vv, (rr, cc)),
        shape=(len(row_keys), len(col_keys)),
        dtype=float,
    ).tocsr()
    A.sum_duplicates()
    A.eliminate_zeros()
    b_normal = np.array([nodes[k].cost for k in row_keys], dtype=float)
    b_slot = np.array(
        [nodes[k].cost + nodes[k].slot_additional_cost for k in row_keys],
        dtype=float,
    )
    return A, b_normal, b_slot, row_keys, col_keys


def matrix_size(nodes: dict[str, GraphNode], edges: Sequence[GraphEdge]) -> MatrixSize:
    A, _, _, rows, cols = build_matrix_from_strict_graph(nodes, edges)
    return MatrixSize(rows=len(rows), cols=len(cols), nnz=int(A.nnz))


def find_provable_zero_cost_nodes(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> set[str]:
    """
    Find nodes whose cost is provably zero from graph structure.

    Seeds are source AND nodes with no direct cost parameter. Propagation uses
    only nonzero-amount incoming edges. Every later node is removed only when
    *all* of its nonzero incoming dependencies are already known zero, exactly
    matching the requested conservative zero-cost reduction. A slot-cost-bearing
    node is kept conservatively so this same
    reduced graph is valid for both normal and slot RHS solves.
    """
    preds: dict[str, list[str]] = {k: [] for k in nodes}
    deps: dict[str, list[str]] = {k: [] for k in nodes}
    for edge in edges:
        if edge.amount == 0.0:
            continue
        preds[edge.stop].append(edge.start)
        deps[edge.start].append(edge.stop)

    def has_direct_cost_parameter(key: str) -> bool:
        node = nodes[key]
        return node.cost_present or node.slot_cost_present

    zero: set[str] = set()
    zero_pred_count = {k: 0 for k in nodes}
    queue: list[str] = []

    for key, node in nodes.items():
        if node.op == "AND" and not preds[key] and not has_direct_cost_parameter(key):
            zero.add(key)
            queue.append(key)

    qpos = 0
    while qpos < len(queue):
        key = queue[qpos]
        qpos += 1
        for dep in deps[key]:
            if dep in zero or has_direct_cost_parameter(dep):
                continue
            zero_pred_count[dep] += 1
            ready = (
                len(preds[dep]) > 0
                and zero_pred_count[dep] == len(preds[dep])
            )
            if ready:
                zero.add(dep)
                queue.append(dep)
    return zero


def filter_graph_nodes(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    removed: set[str],
) -> tuple[dict[str, GraphNode], list[GraphEdge]]:
    kept_nodes = {k: n for k, n in nodes.items() if k not in removed}
    kept_edges = [
        e for e in edges
        if e.start in kept_nodes and e.stop in kept_nodes and e.amount != 0.0
    ]
    return kept_nodes, kept_edges


def peel_sinks_iteratively(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[set[str], list[str], dict[str, int]]:
    """Peel zero-outdegree nodes until only the sink-resistant core remains."""
    import heapq

    incoming: dict[str, list[str]] = {k: [] for k in nodes}
    outdegree = {k: 0 for k in nodes}
    for edge in edges:
        if edge.amount == 0.0:
            continue
        outdegree[edge.start] += 1
        incoming[edge.stop].append(edge.start)

    heap = [k for k, d in outdegree.items() if d == 0]
    heapq.heapify(heap)
    removed: set[str] = set()
    removal_order: list[str] = []
    peel_round: dict[str, int] = {}
    # Use distance-from-original-sink as a stable "round" diagnostic.
    round_no = {k: 0 for k in heap}

    while heap:
        key = heapq.heappop(heap)
        if key in removed:
            continue
        removed.add(key)
        removal_order.append(key)
        peel_round[key] = round_no.get(key, 0)
        for pred in incoming[key]:
            if pred in removed:
                continue
            outdegree[pred] -= 1
            round_no[pred] = max(round_no.get(pred, 0), peel_round[key] + 1)
            if outdegree[pred] == 0:
                heapq.heappush(heap, pred)

    core = set(nodes) - removed
    return core, removal_order, peel_round


def percent_reduction(before: int, after: int) -> float:
    if before == 0:
        return 0.0
    return 100.0 * (before - after) / before


def size_dict(size: MatrixSize) -> dict[str, int]:
    return {"rows": size.rows, "cols": size.cols, "nnz": size.nnz}


def build_optimized_stage(
    snapshot: StageSnapshot,
    original_nodes: dict[str, GraphNode],
    split_nodes: dict[str, GraphNode],
    split_edges: Sequence[GraphEdge],
) -> dict[str, Any]:
    stage_nodes, stage_edges = extract_stage_graph_after_or_cost_split(
        snapshot, original_nodes, split_nodes, split_edges
    )

    # Baseline = subdivide every same-op edge without series contraction.
    base_nodes, base_edges = subdivide_remaining_same_op(
        stage_nodes, stage_edges, f"baseline-stage-{snapshot.ordinal}"
    )
    baseline_size = matrix_size(base_nodes, base_edges)

    series_nodes, series_edges, old_to_rep, scale_by_node, members_by_rep, series_stats = (
        contract_linear_series_paths(stage_nodes, stage_edges)
    )
    strict_nodes, strict_edges = subdivide_remaining_same_op(
        series_nodes, series_edges, f"optimized-stage-{snapshot.ordinal}"
    )
    series_size = matrix_size(strict_nodes, strict_edges)

    zero_nodes = find_provable_zero_cost_nodes(strict_nodes, strict_edges)
    nz_nodes, nz_edges = filter_graph_nodes(strict_nodes, strict_edges, zero_nodes)
    zero_size = matrix_size(nz_nodes, nz_edges)

    core_set, sink_order, peel_round = peel_sinks_iteratively(nz_nodes, nz_edges)
    sink_removed = set(nz_nodes) - core_set
    core_nodes = {k: nz_nodes[k] for k in core_set}
    core_edges = [e for e in nz_edges if e.start in core_set and e.stop in core_set]
    A, b_normal, b_slot, row_keys, col_keys = build_matrix_from_strict_graph(
        core_nodes, core_edges
    )
    core_size = MatrixSize(len(row_keys), len(col_keys), int(A.nnz))

    original_keys = sorted(
        key for key in snapshot.reachable_nodes
        if key in original_nodes
    )
    original_to_rep = {
        key: old_to_rep.get(key, key)
        for key in original_keys
        if key in stage_nodes
    }
    original_scale = {
        key: scale_by_node.get(key, 1.0)
        for key in original_keys
        if key in stage_nodes
    }

    stats = {
        "baseline": size_dict(baseline_size),
        "after_series_path_contraction": size_dict(series_size),
        "after_zero_cost_elimination": size_dict(zero_size),
        "after_sink_peeling_core": size_dict(core_size),
        "series_contraction": series_stats,
        "zero_cost": {
            "nodes_removed": len(zero_nodes),
            "and_removed": sum(strict_nodes[k].op == "AND" for k in zero_nodes),
            "or_removed": sum(strict_nodes[k].op == "OR" for k in zero_nodes),
            "original_nodes_zero_via_representative": sum(
                rep in zero_nodes for rep in original_to_rep.values()
            ),
        },
        "sink_peeling": {
            "nodes_removed": len(sink_removed),
            "and_removed": sum(nz_nodes[k].op == "AND" for k in sink_removed),
            "or_removed": sum(nz_nodes[k].op == "OR" for k in sink_removed),
            "peel_rounds": (max(peel_round.values()) + 1) if peel_round else 0,
        },
        "reductions_percent": {
            "series_rows_incremental": percent_reduction(baseline_size.rows, series_size.rows),
            "series_cols_incremental": percent_reduction(baseline_size.cols, series_size.cols),
            "series_nnz_incremental": percent_reduction(baseline_size.nnz, series_size.nnz),
            "zero_rows_incremental": percent_reduction(series_size.rows, zero_size.rows),
            "zero_cols_incremental": percent_reduction(series_size.cols, zero_size.cols),
            "zero_nnz_incremental": percent_reduction(series_size.nnz, zero_size.nnz),
            "sink_rows_incremental": percent_reduction(zero_size.rows, core_size.rows),
            "sink_cols_incremental": percent_reduction(zero_size.cols, core_size.cols),
            "sink_nnz_incremental": percent_reduction(zero_size.nnz, core_size.nnz),
            "core_rows_from_baseline": percent_reduction(baseline_size.rows, core_size.rows),
            "core_cols_from_baseline": percent_reduction(baseline_size.cols, core_size.cols),
            "core_nnz_from_baseline": percent_reduction(baseline_size.nnz, core_size.nnz),
        },
    }

    return {
        "A": A,
        "b_normal": b_normal,
        "b_slot": b_slot,
        "row_keys": row_keys,
        "col_keys": col_keys,
        "core_nodes": core_nodes,
        "core_edges": core_edges,
        "post_zero_nodes": nz_nodes,
        "post_zero_edges": nz_edges,
        "zero_nodes": zero_nodes,
        "sink_removed": sink_removed,
        "sink_order": sink_order,
        "original_to_rep": original_to_rep,
        "original_scale": original_scale,
        "series_scale_by_node": scale_by_node,
        "members_by_rep": members_by_rep,
        "strict_nodes": strict_nodes,
        "stats": stats,
    }

def _flow_row_budget(
    key: str,
    nodes: dict[str, GraphNode],
    incoming: dict[str, list[GraphEdge]],
    or_costs: dict[str, float | None],
    slot: bool,
) -> float | None:
    node = nodes[key]
    budget = node.cost + (node.slot_additional_cost if slot else 0.0)
    for edge in incoming.get(key, []):
        if edge.amount == 0.0:
            continue
        pred = nodes[edge.start]
        if pred.op != "OR":
            continue
        value = or_costs.get(edge.start)
        if value is None or not math.isfinite(value):
            return None
        budget += edge.amount * value
    return budget


def flow_cost_pruned_nodes(
    post_zero_nodes: dict[str, GraphNode],
    post_zero_edges: Sequence[GraphEdge],
    core_set: set[str],
    core_results: dict[str, Any],
    slot: bool,
) -> tuple[dict[str, float | None], dict[str, float | None], dict[str, Any]]:
    """
    Price the acyclic sink-peeled tail by forward flow.

    Co-product credits are deliberately ignored, so this computes an upper
    bound. For an AND/action row, budget = direct cost + input flow costs. For
    each produced OR material, candidate upper bound = budget / output amount;
    multiple producers take the minimum candidate.
    """
    incoming: dict[str, list[GraphEdge]] = {k: [] for k in post_zero_nodes}
    outgoing: dict[str, list[GraphEdge]] = {k: [] for k in post_zero_nodes}
    for edge in post_zero_edges:
        if edge.amount == 0.0:
            continue
        incoming[edge.stop].append(edge)
        outgoing[edge.start].append(edge)

    or_costs: dict[str, float | None] = {}
    and_budget: dict[str, float | None] = {}

    for key in core_set:
        node = post_zero_nodes[key]
        if node.op != "OR":
            continue
        result = core_results.get(key)
        if result is not None and result.get("status") == "optimal":
            or_costs[key] = float(result["objective"])
        else:
            or_costs[key] = None

    # Core AND rows cannot have pruned predecessors (otherwise those
    # predecessors would retain an outgoing edge into the core), so their flow
    # budgets are determined entirely by solved core OR prices.
    for key in core_set:
        if post_zero_nodes[key].op == "AND":
            and_budget[key] = _flow_row_budget(
                key, post_zero_nodes, incoming, or_costs, slot
            )

    pruned = set(post_zero_nodes) - core_set
    indegree = {k: 0 for k in pruned}
    dependents: dict[str, list[str]] = {k: [] for k in pruned}
    for edge in post_zero_edges:
        if edge.amount == 0.0:
            continue
        if edge.start in pruned and edge.stop in pruned:
            indegree[edge.stop] += 1
            dependents[edge.start].append(edge.stop)

    import heapq
    heap = [k for k, d in indegree.items() if d == 0]
    heapq.heapify(heap)
    processed = 0
    unresolved = 0

    while heap:
        key = heapq.heappop(heap)
        processed += 1
        node = post_zero_nodes[key]
        if node.op == "AND":
            value = _flow_row_budget(
                key, post_zero_nodes, incoming, or_costs, slot
            )
            and_budget[key] = value
            if value is None:
                unresolved += 1
        else:
            candidates: list[float] = []
            for edge in incoming.get(key, []):
                if edge.amount <= 0.0:
                    continue
                producer = post_zero_nodes[edge.start]
                if producer.op != "AND":
                    continue
                budget = and_budget.get(edge.start)
                if budget is None or not math.isfinite(budget):
                    continue
                candidates.append(budget / edge.amount)
            value = min(candidates) if candidates else None
            or_costs[key] = value
            if value is None:
                unresolved += 1

        for dep in dependents[key]:
            indegree[dep] -= 1
            if indegree[dep] == 0:
                heapq.heappush(heap, dep)

    if processed != len(pruned):
        raise RuntimeError(
            f"Sink-pruned subgraph was expected acyclic, processed "
            f"{processed}/{len(pruned)} nodes"
        )

    return or_costs, and_budget, {
        "pruned_nodes_processed": processed,
        "unresolved_pruned_nodes": unresolved,
    }


def material_results_from_optimized_stage(
    optimized: dict[str, Any],
    original_nodes: dict[str, GraphNode],
    snapshot: StageSnapshot,
    core_results: dict[str, Any],
    slot: bool,
) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    core_set = set(optimized["core_nodes"])
    zero_nodes = optimized["zero_nodes"]
    original_to_rep = optimized["original_to_rep"]
    original_scale = optimized["original_scale"]
    strict_nodes = optimized["strict_nodes"]

    flow_or_costs, flow_and_budget, flow_stats = flow_cost_pruned_nodes(
        optimized["post_zero_nodes"],
        optimized["post_zero_edges"],
        core_set,
        core_results,
        slot,
    )

    def representative_value(rep: str) -> tuple[float | None, str, str]:
        if rep in zero_nodes:
            return 0.0, "optimal", "zero_cost_elimination"
        node = strict_nodes.get(rep)
        if node is None:
            return None, "missing_representative", "series_path"
        if node.op == "OR":
            value = flow_or_costs.get(rep)
            if value is None:
                return None, "unresolved", (
                    "individual_lp_core" if rep in core_set else "acyclic_flow_upper_bound"
                )
            if rep in core_set:
                base = core_results.get(rep)
                status = (base or {}).get("status", "unresolved")
                return float(value), status, "individual_lp_core"
            return float(value), "optimal_upper_bound", "acyclic_flow_upper_bound"
        value = flow_and_budget.get(rep)
        if value is None:
            return None, "flow_unresolved", "and_budget_upper_bound"
        return float(value), "optimal_upper_bound", "and_budget_upper_bound"

    results: dict[str, Any] = {}
    for original_key, rep in original_to_rep.items():
        if original_nodes[original_key].op != "OR":
            continue
        alpha = float(original_scale.get(original_key, 1.0))
        base_value, status, base_source = representative_value(rep)
        if base_value is None:
            results[original_key] = {
                "status": status,
                "objective": None,
                "producer_row": None,
                "source": base_source,
                "series_base": rep,
                "series_scale": alpha,
            }
            continue
        value = alpha * base_value
        if rep == original_key and alpha == 1.0 and rep in core_set and strict_nodes[rep].op == "OR":
            base = dict(core_results.get(rep) or {})
            base["source"] = "individual_lp_core"
            base["contracted_column"] = rep
            results[original_key] = base
        else:
            results[original_key] = {
                "status": status,
                "objective": float(value),
                "producer_row": None,
                "source": (
                    "series_path_propagated_from_" + base_source
                    if rep != original_key or alpha != 1.0
                    else base_source
                ),
                "series_base": rep,
                "series_scale": alpha,
                "base_objective": float(base_value),
            }

    # Explicitly report a propagated node cost for every *original* node that
    # participated in a collapsed series component.  This includes AND nodes,
    # which are budgets rather than LP columns.
    path_node_costs: dict[str, Any] = {}
    for rep, members in optimized["members_by_rep"].items():
        original_members = [k for k in members if k in original_nodes]
        if len(members) <= 1 or not original_members:
            continue
        base_value, base_status, base_source = representative_value(rep)
        for key in original_members:
            alpha = float(optimized["series_scale_by_node"].get(key, 1.0))
            path_node_costs[key] = {
                "op": original_nodes[key].op,
                "series_base": rep,
                "series_scale": alpha,
                "base_source": base_source,
                "status": base_status if base_value is not None else "unresolved",
                "cost": None if base_value is None else float(alpha * base_value),
            }

    return results, flow_stats, path_node_costs

def print_optimization_report(stats: dict[str, Any]) -> None:
    order = [
        ("baseline", "baseline"),
        ("after_series_path_contraction", "series-path"),
        ("after_zero_cost_elimination", "zero-cost"),
        ("after_sink_peeling_core", "sink-core"),
    ]
    base = stats["baseline"]
    prev = None
    for key, label in order:
        cur = stats[key]
        if prev is None:
            delta = ""
        else:
            delta = (
                f"; incremental rows -{percent_reduction(prev['rows'], cur['rows']):.1f}%, "
                f"cols -{percent_reduction(prev['cols'], cur['cols']):.1f}%, "
                f"nnz -{percent_reduction(prev['nnz'], cur['nnz']):.1f}%"
            )
        cumulative = (
            f"cumulative rows -{percent_reduction(base['rows'], cur['rows']):.1f}%, "
            f"cols -{percent_reduction(base['cols'], cur['cols']):.1f}%, "
            f"nnz -{percent_reduction(base['nnz'], cur['nnz']):.1f}%"
        )
        print(
            f"  {label:13s}: {cur['rows']} x {cur['cols']}, nnz={cur['nnz']} "
            f"({cumulative}{delta})",
            flush=True,
        )
        prev = cur
    sc = stats["series_contraction"]
    zc = stats["zero_cost"]
    sp = stats["sink_peeling"]
    print(
        f"    series edges contracted={sc['contracted_edges']}, "
        f"segments={sc['contracted_segments']}, nodes collapsed={sc['nodes_removed']}",
        flush=True,
    )
    print(
        f"    zero-cost nodes removed={zc['nodes_removed']} "
        f"(AND={zc['and_removed']}, OR={zc['or_removed']})",
        flush=True,
    )
    print(
        f"    sink-pruned nodes={sp['nodes_removed']} "
        f"(AND={sp['and_removed']}, OR={sp['or_removed']}), "
        f"rounds={sp['peel_rounds']}",
        flush=True,
    )


def write_optimized_stage_outputs(
    out_dir: Path,
    snapshot: StageSnapshot,
    optimized: dict[str, Any],
    normal_results: dict[str, Any] | None,
    slot_results: dict[str, Any] | None,
    flow_stats_normal: dict[str, Any] | None,
    flow_stats_slot: dict[str, Any] | None,
    path_costs_normal: dict[str, Any] | None,
    path_costs_slot: dict[str, Any] | None,
) -> Path:
    stem = f"stage-{snapshot.ordinal:02d}-{_slug_target(snapshot.target_hint)}"
    stage_dir = out_dir / stem
    stage_dir.mkdir(parents=True, exist_ok=True)

    A = optimized["A"]
    b_normal = optimized["b_normal"]
    b_slot = optimized["b_slot"]
    row_keys = optimized["row_keys"]
    col_keys = optimized["col_keys"]
    save_npz(stage_dir / "A-core.npz", A)
    np.save(stage_dir / "b-normal-core.npy", b_normal)
    np.save(stage_dir / "b-slot-core.npy", b_slot)

    collapsed_components = {
        rep: members
        for rep, members in optimized["members_by_rep"].items()
        if len(members) > 1
    }
    matrix_meta = {
        "format": "propertyrandomizer-dependency-optimized-v1",
        "stage": snapshot.ordinal,
        "target_hint": snapshot.target_hint,
        "critical_path_indices": len(snapshot.path_indices),
        "reachable_original_nodes_from_sorted": len(snapshot.reachable_nodes),
        "optimization": optimized["stats"],
        "core_rows": row_keys,
        "core_columns": col_keys,
        "collapsed_components": collapsed_components,
        "zero_cost_nodes": sorted(optimized["zero_nodes"]),
        "sink_pruned_nodes": sorted(optimized["sink_removed"]),
        "notes": {
            "series_paths": "nonzero degree-one topological chains contract before same-op subdivision; cost-bearing followers begin a new homogeneous segment",
            "zero_cost": "source AND/no-cost seeds; every later node requires all nonzero incoming dependencies zero",
            "sink_peeling": "iteratively remove zero-outdegree nodes; solve individual LPs only on remaining core",
            "flow_tail": "pruned acyclic materials use producer flow cost with co-product credits ignored, therefore an upper bound",
        },
    }
    (stage_dir / "matrix.json").write_text(
        json.dumps(matrix_meta, indent=2, sort_keys=True), encoding="utf-8"
    )

    if normal_results is not None or slot_results is not None:
        payload = {
            "format": "propertyrandomizer-dependency-costs-optimized-v1",
            "stage": snapshot.ordinal,
            "target_hint": snapshot.target_hint,
            "normal": normal_results,
            "slot": slot_results,
            "flow_stats_normal": flow_stats_normal,
            "flow_stats_slot": flow_stats_slot,
            "series_path_node_costs_normal": path_costs_normal,
            "series_path_node_costs_slot": path_costs_slot,
        }
        (stage_dir / "costs.json").write_text(
            json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8"
        )
    return stage_dir


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def parse_stage_selection(text: str, count: int) -> list[int]:
    if text.lower() == "all":
        return list(range(1, count + 1))
    result: list[int] = []
    for part in text.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            result.extend(range(int(a), int(b) + 1))
        else:
            result.append(int(part))
    result = sorted(set(result))
    bad = [x for x in result if x < 1 or x > count]
    if bad:
        raise ValueError(f"Stage(s) out of range 1..{count}: {bad}")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build/solve PropertyRandomizer dependency-graph LP matrices"
    )
    parser.add_argument("input", type=Path, help="Factorio log with path + graph dumps")
    parser.add_argument(
        "--out-dir", type=Path, default=Path("dependency-lp"), help="Output directory"
    )
    parser.add_argument(
        "--stages",
        default="all",
        help="Stage selection: all, 1,3,5, or 2-6 (default: all)",
    )
    parser.add_argument(
        "--solve",
        choices=["none", "normal", "slot", "both"],
        default="both",
        help="Which material-cost LPs to solve (default: both)",
    )
    parser.add_argument(
        "--method",
        choices=["highs", "highs-ds", "highs-ipm"],
        default="highs",
    )
    parser.add_argument("--progress-every", type=int, default=25)
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Treat representability/schema warnings as fatal",
    )
    args = parser.parse_args()

    print("Parsing stage snapshots + full graph dump...", flush=True)
    snapshots, graph_payload = parse_stage_snapshots(args.input)
    print(f"  found {len(snapshots)} stage snapshot(s)", flush=True)

    print("Parsing full dependency graph...", flush=True)
    nodes, edges, slot_field_seen = parse_full_graph(graph_payload)
    report = validate_graph(nodes, edges, slot_field_seen)
    print(
        f"  nodes={report.graph_nodes} (AND={report.and_nodes}, OR={report.or_nodes}) "
        f"edges={report.graph_edges}",
        flush=True,
    )
    print(
        f"  same-op edges: AND->AND={report.same_and_edges}, "
        f"OR->OR={report.same_or_edges}; mixed={report.mixed_edges}",
        flush=True,
    )

    if report.warnings:
        for warning in report.warnings:
            print(f"WARNING: {warning}", file=sys.stderr, flush=True)
        if args.strict:
            raise RuntimeError("Validation warnings present under --strict")

    print("Reifying OR-node costs (same-op edges remain unexpanded for optimization)...", flush=True)
    split_nodes, split_edges = split_or_costs_only(nodes, edges)
    print(
        f"  split graph nodes={len(split_nodes)} edges={len(split_edges)}",
        flush=True,
    )

    args.out_dir.mkdir(parents=True, exist_ok=True)
    (args.out_dir / "validation.json").write_text(
        json.dumps(asdict(report), indent=2, sort_keys=True), encoding="utf-8"
    )

    selected = parse_stage_selection(args.stages, len(snapshots))
    summary: dict[str, Any] = {}

    for stage_no in selected:
        snapshot = snapshots[stage_no - 1]
        print(
            f"\n=== stage {stage_no}: {snapshot.target_hint or 'unknown target'} ===",
            flush=True,
        )
        optimized = build_optimized_stage(
            snapshot=snapshot,
            original_nodes=nodes,
            split_nodes=split_nodes,
            split_edges=split_edges,
        )
        print_optimization_report(optimized["stats"])

        A = optimized["A"]
        b_normal = optimized["b_normal"]
        b_slot = optimized["b_slot"]
        row_keys = optimized["row_keys"]
        col_keys = optimized["col_keys"]

        normal_results: dict[str, Any] | None = None
        slot_results: dict[str, Any] | None = None
        flow_stats_normal: dict[str, Any] | None = None
        flow_stats_slot: dict[str, Any] | None = None
        path_costs_normal: dict[str, Any] | None = None
        path_costs_slot: dict[str, Any] | None = None
        core_normal: dict[str, Any] | None = None
        core_slot: dict[str, Any] | None = None

        if args.solve in {"normal", "both"}:
            print(
                f"  solving {len(col_keys)} core columns individually (normal)...",
                flush=True,
            )
            core_normal = solve_all_materials(
                A, b_normal, row_keys, col_keys, args.method, args.progress_every
            ) if len(col_keys) else {}
            normal_results, flow_stats_normal, path_costs_normal = material_results_from_optimized_stage(
                optimized, nodes, snapshot, core_normal, slot=False
            )
            print(
                f"  normal flow tail: processed={flow_stats_normal['pruned_nodes_processed']}, "
                f"unresolved={flow_stats_normal['unresolved_pruned_nodes']}",
                flush=True,
            )

        if args.solve in {"slot", "both"}:
            if core_normal is not None and np.array_equal(b_normal, b_slot):
                print(
                    "  slot core RHS equals normal RHS; reusing individual core LPs.",
                    flush=True,
                )
                core_slot = core_normal
            else:
                print(
                    f"  solving {len(col_keys)} core columns individually (slot)...",
                    flush=True,
                )
                core_slot = solve_all_materials(
                    A, b_slot, row_keys, col_keys, args.method, args.progress_every
                ) if len(col_keys) else {}
            slot_results, flow_stats_slot, path_costs_slot = material_results_from_optimized_stage(
                optimized, nodes, snapshot, core_slot or {}, slot=True
            )
            print(
                f"  slot flow tail: processed={flow_stats_slot['pruned_nodes_processed']}, "
                f"unresolved={flow_stats_slot['unresolved_pruned_nodes']}",
                flush=True,
            )

        stage_dir = write_optimized_stage_outputs(
            args.out_dir,
            snapshot,
            optimized,
            normal_results,
            slot_results,
            flow_stats_normal,
            flow_stats_slot,
            path_costs_normal,
            path_costs_slot,
        )
        print(f"  wrote {stage_dir}", flush=True)
        summary[str(stage_no)] = optimized["stats"]

    (args.out_dir / "optimization-summary.json").write_text(
        json.dumps(summary, indent=2, sort_keys=True), encoding="utf-8"
    )
    print(f"\nValidation report: {args.out_dir / 'validation.json'}", flush=True)
    print(f"Optimization summary: {args.out_dir / 'optimization-summary.json'}", flush=True)


if __name__ == "__main__":
    main()
