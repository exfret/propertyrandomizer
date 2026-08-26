#!/usr/bin/env python3
"""
PropertyRandomizer dependency-graph LP solver.

This replaces the old simplex-lp-export input.  It reads exactly the dumps made
by the data-final-fixes.lua snippet:

    I IS THIS VALUE N
    PATH DUMP
    serpent.dump(path)
    SORT INFO DUMP
    serpent.dump(sort_info)
    ...
    GRAPH DUMP
    serpent.dump(logic.graph)

The subsequent DATA_RAW dump is never read or parsed.

LP semantics are taken directly from logic.graph:

  * AND node -> one LP row/action
  * OR node  -> one LP price variable/state
  * AND -> OR edge with `amount=a` contributes +a
  * OR  -> AND edge with `amount=a` contributes -a
  * missing `amount` contributes 0 (reachability-only dependency)
  * an AND node's `cost` is the row RHS
  * a cost-bearing OR node is reified as OR -> AND(cost) -> OR
  * same-op edges are subdivided so the LP is strictly AND/OR bipartite

For each target material, this uses the same dual-price solve as the old
solve_lp_levels.py:

    maximize p[target]
    subject to A p <= b
               p >= 0

HiGHS inequality marginals are then used in the same way to identify the main
producer row.  Only original `item` and `fluid` OR nodes are solved as material
targets; all reachable OR states remain LP variables.

Stage handling:
  * every node appearing anywhere in sort_info.sorted is considered reachable
    for that stage (the critical path is metadata only)
  * the final GRAPH DUMP is the unrestricted graph, so the Python side replays
    the temporary science-pack outgoing-edge cuts used by the Lua snippet
  * at military science it also replays the extra py-science-pack-2 cut

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
    synthetic: bool = False
    source: str | None = None


@dataclass(frozen=True)
class GraphEdge:
    key: str
    start: str
    stop: str
    amount: float
    synthetic: bool = False
    source: str | None = None


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


def parse_log(path: Path) -> tuple[list[StageSnapshot], str]:
    """Read path/sort snapshots and the one final graph dump, then stop."""
    snapshots: list[StageSnapshot] = []
    current_stage: int | None = None
    pending_kind: str | None = None
    pending_path: list[int] | None = None
    graph_payload: str | None = None

    with path.open("r", encoding="utf-8", errors="replace") as fh:
        for raw_line in fh:
            line = _strip_log_prefix(raw_line)

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
                # We have all useful information already.  This avoids reading
                # the enormous data.raw payload at all.
                break

            if pending_kind is None:
                continue

            payload = line
            if pending_kind == "path":
                pending_path = _parse_path_indices(payload)
                pending_kind = None
                continue

            if pending_kind == "sort":
                path_indices = pending_path or []
                reachable, target_hint = _parse_sort(payload, path_indices)
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

            if pending_kind == "graph":
                graph_payload = payload
                pending_kind = None
                # The graph comes after all stage snapshots in the supplied Lua
                # snippet. We can stop here and never scan data.raw.
                break

    if not snapshots:
        raise RuntimeError("No PATH/SORT stage snapshots found in the log")
    if graph_payload is None:
        raise RuntimeError("No GRAPH DUMP payload found in the log")

    return snapshots, graph_payload


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
            cost = _find_number_field(payload, start, end, "cost") or 0.0
            if key in nodes:
                raise RuntimeError(f"Duplicate graph node key {key!r}")
            nodes[key] = GraphNode(
                key=key,
                op=op,
                node_type=node_type,
                name=name,
                cost=cost,
            )
            continue

        edge_start = _find_string_field(payload, start, end, "start")
        edge_stop = _find_string_field(payload, start, end, "stop")
        if edge_start is None or edge_stop is None:
            raise RuntimeError(f"Graph edge {key!r} is missing start/stop")
        amount = _find_number_field(payload, start, end, "amount")
        edges.append(
            GraphEdge(
                key=key,
                start=edge_start,
                stop=edge_stop,
                amount=0.0 if amount is None else amount,
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
    """Reify OR costs, then subdivide every remaining nonzero same-op edge."""
    out_nodes = dict(nodes)
    intermediate_edges: list[GraphEdge] = []

    cost_or_nodes = {
        key for key, node in nodes.items()
        if node.op == "OR" and node.cost != 0.0
    }

    # Split M(cost) into M_pre -> M_cost_row -> M. Incoming prerequisites go
    # to M_pre, while outgoing dependants still consume the original M.
    for key in sorted(cost_or_nodes):
        node = nodes[key]
        pre = _synthetic_key("or_cost_pre", key)
        row = _synthetic_key("or_cost_row", key)
        if pre in out_nodes or row in out_nodes:
            raise RuntimeError(f"Synthetic key collision while splitting {key!r}")

        out_nodes[key] = GraphNode(
            key=key,
            op="OR",
            node_type=node.node_type,
            name=node.name,
            cost=0.0,
            synthetic=node.synthetic,
            source=node.source,
        )
        out_nodes[pre] = GraphNode(
            key=pre,
            op="OR",
            node_type=None,
            name=None,
            synthetic=True,
            source=f"node-cost:{key}",
        )
        out_nodes[row] = GraphNode(
            key=row,
            op="AND",
            node_type=None,
            name=None,
            cost=node.cost,
            synthetic=True,
            source=f"node-cost:{key}",
        )
        intermediate_edges.append(
            GraphEdge(
                key=f"node-cost:{key}:pre",
                start=pre,
                stop=row,
                amount=1.0,
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
                synthetic=True,
                source=f"node-cost:{key}",
            )
        )

    for edge in edges:
        # Missing/zero amounts are reachability-only and have zero coefficient.
        # They do not need a synthetic matrix state.
        if edge.amount == 0.0:
            continue
        stop = _synthetic_key("or_cost_pre", edge.stop) if edge.stop in cost_or_nodes else edge.stop
        intermediate_edges.append(
            GraphEdge(
                key=edge.key,
                start=edge.start,
                stop=stop,
                amount=edge.amount,
                synthetic=edge.synthetic,
                source=edge.source,
            )
        )

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
                synthetic=True,
                source=edge.key,
            )
            # A --a--> B means one unit of A-state feeds a units into B:
            # A -> M uses +1 on A's row; M -> B consumes a on B's row.
            strict_edges.append(
                GraphEdge(f"{edge.key}:a", edge.start, mid, 1.0, True, edge.key)
            )
            strict_edges.append(
                GraphEdge(f"{edge.key}:b", mid, edge.stop, edge.amount, True, edge.key)
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
                synthetic=True,
                source=edge.key,
            )
            # X --a--> Y becomes a-unit consumption of X producing one Y.
            strict_edges.append(
                GraphEdge(f"{edge.key}:a", edge.start, mid, edge.amount, True, edge.key)
            )
            strict_edges.append(
                GraphEdge(f"{edge.key}:b", mid, edge.stop, 1.0, True, edge.key)
            )

    return out_nodes, strict_edges, {
        "or_cost_nodes_split": len(cost_or_nodes),
        "same_and_edges_subdivided": same_and,
        "same_or_edges_subdivided": same_or,
        "strict_nonzero_edges": len(strict_edges),
    }


def build_matrix(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[csr_matrix, np.ndarray, list[str], list[str]]:
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
    b = np.array([nodes[k].cost for k in row_keys], dtype=float)
    return A, b, row_keys, col_keys


# ---------------------------------------------------------------------------
# Exact per-material LP solve (same method as old solve_lp_levels.py)
# ---------------------------------------------------------------------------


def solve_one_material(
    A: csr_matrix,
    b: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    node_meta: dict[str, GraphNode],
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
            "unbounded" if result.status == 3
            else "infeasible" if result.status == 2
            else f"solver_status_{result.status}"
        )
        return {
            "status": status,
            "objective": None,
            "recipe": None,
            "producer": None,
            "message": result.message,
            "nit": getattr(result, "nit", None),
        }

    marginals = np.asarray(result.ineqlin.marginals, dtype=float)
    row_usages = np.maximum(0.0, -marginals)

    producer = None
    best_contribution = 0.0
    column = A.getcol(target_zero).tocoo()
    for row_zero, coefficient in zip(column.row, column.data):
        if coefficient <= 0.0:
            continue
        usage = float(row_usages[row_zero])
        contribution = usage * float(coefficient)
        if contribution <= 1e-9:
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

    # In the dependency graph an item is often reached through one or more
    # bookkeeping OR->OR links (for example recipe -> item-craft -> item).
    # Those links become synthetic AND rows, so the immediate positive row for
    # the target is not necessarily the recipe itself.  Preserve the old
    # solver's useful `recipes` output by tracing *only through synthetic rows*
    # in the active dual plan until an original recipe row is reached.  We do
    # not recurse through arbitrary real AND nodes, which would risk reporting
    # a recipe for a machine/fuel prerequisite rather than the material source.
    if recipe is None:
        visited_cols: set[int] = set()

        def trace_recipe(col_zero: int) -> str | None:
            if col_zero in visited_cols:
                return None
            visited_cols.add(col_zero)

            col = A.getcol(col_zero).tocoo()
            candidates: list[tuple[float, int]] = []
            for r, coeff in zip(col.row, col.data):
                if coeff <= 0.0:
                    continue
                usage = float(row_usages[r])
                contribution = usage * float(coeff)
                if contribution > 1e-9:
                    candidates.append((contribution, int(r)))
            candidates.sort(reverse=True)

            for _, r in candidates:
                row_key = row_keys[r]
                row_node = node_meta[row_key]
                if row_node.node_type == "recipe" and row_node.name is not None:
                    return row_node.name
                if not row_node.synthetic:
                    continue

                row = A.getrow(r).tocoo()
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

        recipe = trace_recipe(target_zero)

    return {
        "status": "optimal",
        "objective": float(-result.fun),
        "recipe": recipe,
        "producer": producer,
        "message": result.message,
        "nit": getattr(result, "nit", None),
    }


def material_keys(all_nodes: dict[str, GraphNode]) -> list[str]:
    return sorted(
        key
        for key, node in all_nodes.items()
        if node.op == "OR" and node.node_type in {"item", "fluid"}
    )


def solve_stage_materials(
    A: csr_matrix,
    b: np.ndarray,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    transformed_nodes: dict[str, GraphNode],
    original_material_keys: Sequence[str],
    reachable_original_nodes: set[str],
    method: str,
    progress_every: int,
) -> dict[str, Any]:
    col_index = {key: i for i, key in enumerate(col_keys)}
    reachable_targets = [
        key for key in original_material_keys
        if key in reachable_original_nodes and key in col_index
    ]

    results: dict[str, Any] = {}

    # Preserve a status entry for every material, like the old exported tables,
    # while avoiding pointless LP calls for materials the stage sort never made
    # reachable.
    for key in original_material_keys:
        if key not in reachable_original_nodes or key not in col_index:
            results[key] = {
                "status": "unbounded",
                "reason": "material node was not reachable in this stage sort",
                "objective": None,
                "recipe": None,
                "producer": None,
                "message": None,
                "nit": None,
            }

    total = len(reachable_targets)
    for ordinal, key in enumerate(reachable_targets, start=1):
        if ordinal == 1 or ordinal == total or ordinal % progress_every == 0:
            print(f"    [{ordinal}/{total}] {key}", flush=True)
        results[key] = solve_one_material(
            A=A,
            b=b,
            row_keys=row_keys,
            col_keys=col_keys,
            node_meta=transformed_nodes,
            target_zero=col_index[key],
            method=method,
        )

    return results


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
    results: dict[str, Any],
) -> None:
    output = {
        "format": "propertyrandomizer-material-costs-graph-v1",
        "source": {
            "format": "logic.graph serpent dump",
            "stage_index": snapshot.stage_index,
            "stage_name": snapshot.stage_name,
            "target_hint": snapshot.target_hint,
            "num_rows": len(row_keys),
            "num_columns": len(col_keys),
            "nnz": int(A.nnz),
            **stage_meta,
        },
        "results_by_key": results,
        "costs": {},
        "recipes": {},
        "statuses": {},
    }

    for key, result in results.items():
        value = result.get("objective")
        if value is not None and math.isfinite(float(value)):
            output["costs"][key] = float(value)
        if result.get("recipe") is not None:
            output["recipes"][key] = result["recipe"]
        output["statuses"][key] = result["status"]

    path.write_text(json.dumps(output, indent=2, sort_keys=True), encoding="utf-8")


def write_material_lua(
    path: Path,
    snapshot: StageSnapshot,
    A: csr_matrix,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    results: dict[str, Any],
) -> None:
    lines = [
        "-- generated by solve_lp_graph.py",
        "return {",
        "    metadata = {",
        '        format = "propertyrandomizer-material-costs-graph-v1",',
        '        source_format = "logic.graph",',
        "        is_pyanodons = true,",
        "        staged_costs = true,",
        f"        stage_index = {snapshot.stage_index},",
        f"        stage_name = {_lua_quote(snapshot.stage_name)},",
        f"        num_rows = {len(row_keys)},",
        f"        num_columns = {len(col_keys)},",
        f"        nnz = {int(A.nnz)},",
        "    },",
        "    costs = {",
    ]

    for key in sorted(results):
        value = results[key].get("objective")
        if value is None or not math.isfinite(float(value)):
            continue
        lines.append(f"        [{_lua_quote(key)}] = {float(value):.17g},")

    lines.extend(["    },", "    statuses = {"])
    for key in sorted(results):
        lines.append(
            f"        [{_lua_quote(key)}] = {_lua_quote(results[key]['status'])},"
        )

    lines.extend(["    },", "    recipes = {"])
    for key in sorted(results):
        recipe = results[key].get("recipe")
        if recipe is not None:
            lines.append(f"        [{_lua_quote(key)}] = {_lua_quote(recipe)},")

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
        description="Solve PropertyRandomizer material costs from logic.graph dumps"
    )
    parser.add_argument("input", type=Path, help="Factorio log made by the supplied dump code")
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
        help="Optional folder to also save each stage A.npz/b.npy/matrix metadata",
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
        "--matrix-only",
        action="store_true",
        help="Build matrices and metadata but do not run per-material LPs",
    )
    args = parser.parse_args()

    print("Parsing stage snapshots and final GRAPH DUMP...", flush=True)
    snapshots, graph_payload = parse_log(args.input)
    print(f"  found {len(snapshots)} stage snapshot(s)", flush=True)

    print("Parsing logic.graph...", flush=True)
    all_nodes, all_edges = parse_full_graph(graph_payload)
    original_materials = material_keys(all_nodes)
    print(
        f"  graph nodes={len(all_nodes)} edges={len(all_edges)} "
        f"item/fluid targets={len(original_materials)}",
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

        stage_nodes, stage_edges, extraction_meta = extract_stage_graph(
            snapshot, all_nodes, all_edges
        )
        transformed_nodes, transformed_edges, transform_meta = make_bipartite(
            stage_nodes, stage_edges
        )
        A, b, row_keys, col_keys = build_matrix(transformed_nodes, transformed_edges)

        stage_meta = {
            **extraction_meta,
            **transform_meta,
            "reachable_material_targets": sum(
                key in snapshot.reachable_nodes for key in original_materials
            ),
        }
        print(
            f"  matrix={A.shape[0]} x {A.shape[1]}, nnz={A.nnz}; "
            f"stage cuts={extraction_meta['stage_cut_edges_removed']}; "
            f"same-op subdivisions="
            f"{transform_meta['same_and_edges_subdivided'] + transform_meta['same_or_edges_subdivided']}",
            flush=True,
        )

        if args.matrix_dir is not None:
            stem = f"stage-{snapshot.stage_index:02d}-{snapshot.stage_name}"
            stage_dir = args.matrix_dir / stem
            stage_dir.mkdir(parents=True, exist_ok=True)
            save_npz(stage_dir / "A.npz", A)
            np.save(stage_dir / "b.npy", b)
            (stage_dir / "matrix.json").write_text(
                json.dumps(
                    {
                        "stage_index": snapshot.stage_index,
                        "stage_name": snapshot.stage_name,
                        "target_hint": snapshot.target_hint,
                        "rows": row_keys,
                        "columns": col_keys,
                        "row_costs": {
                            key: float(b[i]) for i, key in enumerate(row_keys)
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

        results = solve_stage_materials(
            A=A,
            b=b,
            row_keys=row_keys,
            col_keys=col_keys,
            transformed_nodes=transformed_nodes,
            original_material_keys=original_materials,
            reachable_original_nodes=snapshot.reachable_nodes,
            method=args.method,
            progress_every=args.progress_every,
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
            results,
        )
        write_material_lua(
            lua_path,
            snapshot,
            A,
            row_keys,
            col_keys,
            results,
        )
        print(f"  wrote {json_path}", flush=True)
        print(f"  wrote {lua_path}", flush=True)


if __name__ == "__main__":
    main()
