#!/usr/bin/env python3
"""Finite-time moment-relaxed production LP for staged PropertyRandomizer graphs.

This reads the same staged logic.graph dumps as solve_lp_staged_slot_costs_v6.py
and keeps the same stage extraction, cost-node reification, non-coproduct
conservation, same-op subdivision, and signed amount convention.

After normalization, S has shape AND/actions x OR/materials and its transpose N
maps total action amounts to ORDINARY net inventory change:

    AND -> OR amount a   => +a
    OR  -> AND amount a  => -a

Edges carrying ``used_payback`` are different.  A dumped edge of the form

    amount = actual_duration / used_payback

is removed from ordinary inventory balance and converted to a capacity-duration
matrix C using

    actual_duration = amount * used_payback.

Thus operating a machine does not destroy the machine.  Instead C[j,r] is the
number of seconds of material/entity j occupied by one unit of action r.
The candidate time delta enters the LP directly; the graph no longer has to be
regenerated or rebased for each delta.

The LP uses normalized remaining-time moments of each nonnegative action rate
u_r(t):

    q_0[r] = integral u_r(t) dt
    q_k[r] = integral ((delta-t)/delta)^k u_r(t) dt,  k>=1.

Every q_k has the same units as total action amount and necessarily satisfies

    0 <= q_{k+1} <= q_k.

Let x0 be the initial finite inventory (one ``entity: character`` and zero for
other finite coordinates) and let autoplaced entity ORs with explicit incoming
amount=0 be infinite, so their inventory/capacity rows are omitted.

Necessary conditions for every real continuous schedule include:

    endpoint inventory:
        x0 + N q_0 >= 0

    weighted inventory moments, for k=0..K-1:
        x0 + N q_{k+1} >= 0

    weighted capacity moments, for k=0..K-1:
        ((k+1)/delta) C q_k <= x0 + N q_{k+1}.

The last identity comes from multiplying the instantaneous capacity inequality
C u(t) <= x(t) by ((delta-t)/delta)^k and integrating.  K=1 is the first-moment
relaxation.  K=2 also constrains when capacity itself is used and is the default,
because K=1 can still place an algebraically self-supporting factory entirely at
t=0.  Larger K gives a tighter single-LP hierarchy without time discretization.

These are necessary, not sufficient, scheduling conditions.  Therefore the LP
remains optimistic: if even it cannot reach the requested science amount by
delta, delta is a rigorous lower bound for the real game.
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
from scipy.sparse import coo_matrix, csr_matrix, eye, hstack, save_npz, vstack


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
    used_payback: float | None = None


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
        raw_used_payback = _find_number_field(payload, start, end, "used_payback")
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
                used_payback=raw_used_payback,
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


def split_used_payback_capacity_edges(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[list[GraphEdge], list[dict[str, Any]], dict[str, Any]]:
    """Separate amortized capacity edges from ordinary inventory-flow edges.

    A used_payback edge must be an OR/material -> AND/action requirement.  The
    dumped coefficient is ``actual_duration / used_payback``; recover the actual
    occupied time as ``amount * used_payback`` and omit that edge from S.
    """
    ordinary: list[GraphEdge] = []
    capacity_specs: list[dict[str, Any]] = []
    durations: list[float] = []
    paybacks: list[float] = []
    stored_amounts: list[float] = []
    sample: list[dict[str, Any]] = []

    for edge in edges:
        used = edge.used_payback
        if used is None:
            ordinary.append(edge)
            continue
        if not edge.amount_present:
            raise RuntimeError(
                f"Edge {edge.key!r} has used_payback={used!r} but no amount"
            )
        if not math.isfinite(used) or used <= 0.0:
            raise RuntimeError(
                f"Edge {edge.key!r} has invalid used_payback={used!r}; expected > 0"
            )
        if not math.isfinite(edge.amount) or edge.amount <= 0.0:
            raise RuntimeError(
                f"Edge {edge.key!r} has used_payback but invalid positive amount "
                f"{edge.amount!r}"
            )
        src = nodes.get(edge.start)
        dst = nodes.get(edge.stop)
        if src is None or dst is None:
            raise RuntimeError(f"Capacity edge {edge.key!r} references a missing node")
        if src.op != "OR" or dst.op != "AND":
            raise RuntimeError(
                f"used_payback edge {edge.key!r} must be OR/material -> AND/action; "
                f"got {src.op}->{dst.op} ({edge.start!r}->{edge.stop!r})"
            )

        duration = float(edge.amount) * float(used)
        if not math.isfinite(duration) or duration <= 0.0:
            raise RuntimeError(
                f"Capacity edge {edge.key!r} recovered invalid duration {duration!r}"
            )
        spec = {
            "edge_key": edge.key,
            "material_key": edge.start,
            "action_key": edge.stop,
            "stored_amount": float(edge.amount),
            "used_payback": float(used),
            "actual_duration_seconds": duration,
        }
        capacity_specs.append(spec)
        durations.append(duration)
        paybacks.append(float(used))
        stored_amounts.append(float(edge.amount))
        if len(sample) < 12:
            sample.append(dict(spec))

    if capacity_specs:
        meta: dict[str, Any] = {
            "capacity_edge_count": len(capacity_specs),
            "formula": "actual_duration_seconds = stored_amount * used_payback",
            "actual_duration_seconds_range": {
                "min": min(durations),
                "max": max(durations),
            },
            "used_payback_range": {"min": min(paybacks), "max": max(paybacks)},
            "stored_amount_abs_range": {
                "min": min(abs(x) for x in stored_amounts),
                "max": max(abs(x) for x in stored_amounts),
            },
            "sample": sample,
        }
    else:
        meta = {
            "capacity_edge_count": 0,
            "formula": "actual_duration_seconds = stored_amount * used_payback",
            "note": "No selected-stage edge carried used_payback.",
            "sample": [],
        }
    return ordinary, capacity_specs, meta

def make_bipartite(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    zero_free_excluded_or_keys: set[str] | None = None,
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
    zero_free_excluded_or_keys = zero_free_excluded_or_keys or set()

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
    ignored_zero_free_excluded_or = 0
    explicit_zero_free_producers = 0

    for ordinal, edge in enumerate(edges):
        if not edge.amount_present:
            ignored_missing_amount += 1
            continue

        # A few zero-amount edges mean "initial stock" rather than an
        # indefinitely repeatable free-production action.  The character is the
        # important case: it starts with one normalized unit of player time.
        # Test the ORIGINAL destination before any cost-OR splitting.
        if edge.amount == 0.0 and edge.stop in zero_free_excluded_or_keys:
            ignored_zero_free_excluded_or += 1
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
        "explicit_zero_initial_stock_edges_ignored": ignored_zero_free_excluded_or,
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



def build_capacity_matrix(
    capacity_specs: Sequence[dict[str, Any]],
    row_keys: Sequence[str],
    col_keys: Sequence[str],
) -> csr_matrix:
    """Build C with shape materials x actions, measured in seconds per action."""
    row_index = {key: i for i, key in enumerate(row_keys)}
    col_index = {key: i for i, key in enumerate(col_keys)}
    rr: list[int] = []
    cc: list[int] = []
    vv: list[float] = []
    for spec in capacity_specs:
        material_key = str(spec["material_key"])
        action_key = str(spec["action_key"])
        if material_key not in col_index:
            raise RuntimeError(
                f"Capacity material {material_key!r} did not survive graph normalization"
            )
        if action_key not in row_index:
            raise RuntimeError(
                f"Capacity action {action_key!r} did not survive graph normalization"
            )
        rr.append(col_index[material_key])
        cc.append(row_index[action_key])
        vv.append(float(spec["actual_duration_seconds"]))
    C = coo_matrix(
        (vv, (rr, cc)),
        shape=(len(col_keys), len(row_keys)),
        dtype=float,
    ).tocsr()
    C.sum_duplicates()
    C.eliminate_zeros()
    return C



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


def solve_moment_growth_lp(
    S: csr_matrix,
    C: csr_matrix,
    row_keys: Sequence[str],
    col_keys: Sequence[str],
    transformed_nodes: dict[str, GraphNode],
    infinite_keys: set[str],
    goal_key: str,
    character_key: str,
    time_seconds: float,
    moment_order: int,
    method: str,
    active_eps: float,
) -> dict[str, Any]:
    """Solve the K-moment optimistic continuous-time production relaxation."""
    if moment_order < 1:
        raise ValueError("moment_order must be >= 1")
    if S.shape != (len(row_keys), len(col_keys)):
        raise RuntimeError("Matrix/key dimensions are inconsistent")
    if C.shape != (len(col_keys), len(row_keys)):
        raise RuntimeError("Capacity matrix/key dimensions are inconsistent")
    if S.data.size and not np.all(np.isfinite(S.data)):
        raise RuntimeError("Amount matrix contains non-finite coefficients")
    if C.data.size and (not np.all(np.isfinite(C.data)) or np.any(C.data < 0.0)):
        raise RuntimeError("Capacity matrix contains invalid coefficients")

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
    blocks = moment_order + 1
    total_vars = blocks * n_actions
    x0 = np.zeros(n_materials, dtype=float)
    character_index = col_index[character_key]
    goal_index = col_index[goal_key]
    x0[character_index] = 1.0

    # N maps action totals to ordinary net inventory changes. Capacity occupancy
    # from used_payback edges has deliberately been removed from N and lives in C.
    N = S.T.tocsr()  # materials x actions

    infinite_indices = {
        col_index[key] for key in infinite_keys if key in col_index and key != character_key
    }
    finite_indices = np.asarray(
        [i for i in range(n_materials) if i not in infinite_indices],
        dtype=np.int64,
    )
    capacity_row_mask = np.asarray(C.getnnz(axis=1)).reshape(-1) > 0
    finite_capacity_indices = np.asarray(
        [i for i in finite_indices if capacity_row_mask[int(i)]],
        dtype=np.int64,
    )

    def block_row(nrows: int, placements: dict[int, csr_matrix]) -> csr_matrix:
        pieces = []
        for block in range(blocks):
            mat = placements.get(block)
            if mat is None:
                mat = csr_matrix((nrows, n_actions), dtype=float)
            pieces.append(mat)
        return hstack(pieces, format="csr")

    constraint_mats: list[csr_matrix] = []
    constraint_rhs: list[np.ndarray] = []
    constraint_groups: list[dict[str, Any]] = []

    def add_group(name: str, mat: csr_matrix, rhs: np.ndarray, **meta: Any) -> None:
        start = sum(x.shape[0] for x in constraint_mats)
        constraint_mats.append(mat)
        constraint_rhs.append(np.asarray(rhs, dtype=float))
        constraint_groups.append({
            "name": name,
            "row_start": start,
            "row_stop_exclusive": start + mat.shape[0],
            **meta,
        })

    Nf = N[finite_indices, :].tocsr()
    x0f = x0[finite_indices]

    # Endpoint inventory: x0 + N q0 >= 0.
    add_group(
        "endpoint_inventory",
        block_row(len(finite_indices), {0: -Nf}),
        x0f,
        moment=0,
    )

    eye_actions = eye(n_actions, format="csr", dtype=float)

    for k in range(moment_order):
        # q_{k+1} <= q_k. Nonnegativity of every q block is imposed via bounds.
        add_group(
            f"moment_monotonicity_{k+1}",
            block_row(n_actions, {k: -eye_actions, k + 1: eye_actions}),
            np.zeros(n_actions, dtype=float),
            lower_moment=k,
            upper_moment=k + 1,
        )

        # Weighted inventory nonnegativity. With normalized moments this has the
        # same coefficient scale as the endpoint inventory condition.
        add_group(
            f"inventory_moment_{k+1}",
            block_row(len(finite_indices), {k + 1: -Nf}),
            x0f,
            moment=k + 1,
        )

        # Weighted capacity condition:
        #   ((k+1)/delta) C q_k <= x0 + N q_{k+1}.
        if finite_capacity_indices.size:
            Cc = C[finite_capacity_indices, :].tocsr()
            Nc = N[finite_capacity_indices, :].tocsr()
            x0c = x0[finite_capacity_indices]
            add_group(
                f"capacity_moment_{k}",
                block_row(
                    len(finite_capacity_indices),
                    {
                        k: ((k + 1.0) / time_seconds) * Cc,
                        k + 1: -Nc,
                    },
                ),
                x0c,
                capacity_moment=k,
                inventory_moment=k + 1,
                coefficient_factor=(k + 1.0) / time_seconds,
            )

    A_ub = vstack(constraint_mats, format="csr")
    b_ub = np.concatenate(constraint_rhs) if constraint_rhs else np.zeros(0)

    goal_coeff = np.asarray(N.getrow(goal_index).toarray(), dtype=float).reshape(-1)
    c = np.zeros(total_vars, dtype=float)
    c[:n_actions] = -goal_coeff  # scipy minimizes

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
        "num_variables": total_vars,
        "num_inequalities": int(A_ub.shape[0]),
        "num_finite_material_constraints": int(finite_indices.size),
        "num_capacity_resources": int(np.count_nonzero(capacity_row_mask)),
        "num_finite_capacity_resources": int(finite_capacity_indices.size),
        "capacity_matrix_nnz": int(C.nnz),
        "moment_order": int(moment_order),
        "goal_key": goal_key,
        "character_key": character_key,
        "constraint_groups": constraint_groups,
    }

    if result.status != 0:
        if result.status == 3:
            # Find a homogeneous unbounded direction satisfying all moment and
            # capacity constraints and producing at least one unit of goal.
            ray_goal = np.zeros(total_vars, dtype=float)
            ray_goal[:n_actions] = -goal_coeff
            ray_A = vstack([A_ub, csr_matrix(ray_goal.reshape(1, -1))], format="csr")
            ray_b = np.concatenate([
                np.zeros(A_ub.shape[0], dtype=float),
                np.array([-1.0], dtype=float),
            ])
            ray_c = np.zeros(total_vars, dtype=float)
            ray_c[:n_actions] = 1.0
            ray_result = linprog(
                c=ray_c,
                A_ub=ray_A,
                b_ub=ray_b,
                bounds=(0.0, None),
                method=method,
            )
            ray_info: dict[str, Any] = {
                "status_code": int(ray_result.status),
                "message": str(ray_result.message),
            }
            if ray_result.status == 0:
                y = np.asarray(ray_result.x, dtype=float)
                moments = [
                    y[k * n_actions:(k + 1) * n_actions]
                    for k in range(blocks)
                ]
                q0 = moments[0]
                change = np.asarray(N @ q0, dtype=float).reshape(-1)
                ray_actions: list[dict[str, Any]] = []
                for i, amount in enumerate(q0):
                    if amount <= active_eps:
                        continue
                    key = row_keys[i]
                    node = transformed_nodes[key]
                    item: dict[str, Any] = {
                        "action_key": key,
                        "amount_per_unit_goal_ray": float(amount),
                        "node_type": node.node_type,
                        "name": node.name,
                        "synthetic": bool(node.synthetic),
                        "source": node.source,
                    }
                    if moment_order >= 1:
                        frac = float(moments[1][i] / amount) if amount > 0 else 0.0
                        frac = min(1.0, max(0.0, frac))
                        item["mean_time_seconds"] = float(time_seconds * (1.0 - frac))
                        item["remaining_fraction_moment_1"] = frac
                    ray_actions.append(item)
                ray_actions.sort(
                    key=lambda item: item["amount_per_unit_goal_ray"], reverse=True
                )
                ray_info.update({
                    "goal_net_production": float(goal_coeff @ q0),
                    "action_l1": float(np.sum(q0)),
                    "active_actions": ray_actions,
                    "minimum_homogeneous_constraint_slack": float(
                        np.min(-(A_ub @ y)) if A_ub.shape[0] else math.inf
                    ),
                    "interpretation": (
                        "This moment-feasible nonnegative direction can be scaled "
                        "arbitrarily while producing positive goal. Increase "
                        "--moment-order or inspect its active actions/capacity rows."
                    ),
                })
            output["unbounded_ray"] = ray_info
        return output

    y = np.asarray(result.x, dtype=float)
    moments = [y[k * n_actions:(k + 1) * n_actions] for k in range(blocks)]
    z = moments[0]
    final_inventory = x0 + np.asarray(N @ z, dtype=float).reshape(-1)
    goal_final = float(final_inventory[goal_index])
    min_finite_final = (
        float(np.min(final_inventory[finite_indices])) if finite_indices.size else math.inf
    )

    active_actions: list[dict[str, Any]] = []
    for i, amount in enumerate(z):
        if amount <= active_eps:
            continue
        key = row_keys[i]
        node = transformed_nodes[key]
        item: dict[str, Any] = {
            "action_key": key,
            "total_amount": float(amount),
            "node_type": node.node_type,
            "name": node.name,
            "synthetic": bool(node.synthetic),
            "source": node.source,
            "coproduct": bool(node.coproduct),
            "normalized_moments": [float(m[i]) for m in moments],
        }
        if moment_order >= 1:
            frac = float(moments[1][i] / amount)
            frac = min(1.0, max(0.0, frac))
            item["remaining_fraction_moment_1"] = frac
            item["mean_time_seconds"] = float(time_seconds * (1.0 - frac))
        active_actions.append(item)
    active_actions.sort(key=lambda item: item["total_amount"], reverse=True)

    positive_final: list[dict[str, Any]] = []
    depleted_final: list[dict[str, Any]] = []
    for i in finite_indices:
        value = float(final_inventory[i])
        key = col_keys[int(i)]
        if value > active_eps or key in {goal_key, character_key}:
            positive_final.append({"material_key": key, "final_amount": value})
        if value <= active_eps:
            depleted_final.append({"material_key": key, "final_amount": value})
    positive_final.sort(key=lambda item: item["final_amount"], reverse=True)

    capacity_diagnostics: list[dict[str, Any]] = []
    for j in finite_capacity_indices:
        jj = int(j)
        total_usage_fraction = float((C.getrow(jj) @ z)[0] / time_seconds)
        average_available = float(x0[jj] + (N.getrow(jj) @ moments[1])[0])
        capacity_diagnostics.append({
            "material_key": col_keys[jj],
            "normalized_total_capacity_usage": total_usage_fraction,
            "normalized_average_available": average_available,
            "moment_0_slack": average_available - total_usage_fraction,
        })
    capacity_diagnostics.sort(
        key=lambda item: item["normalized_total_capacity_usage"], reverse=True
    )

    output.update({
        "objective_goal_final_amount": goal_final,
        "objective_goal_net_production": float(goal_final - x0[goal_index]),
        "character_final_amount": float(final_inventory[character_index]),
        "minimum_finite_final_inventory": min_finite_final,
        "active_action_count": len(active_actions),
        "active_actions": active_actions,
        "positive_finite_final_inventory": positive_final,
        "depleted_finite_materials": depleted_final,
        "total_action_l1": float(np.sum(z)),
        "capacity_diagnostics": capacity_diagnostics,
    })

    if character_index in set(int(i) for i in finite_capacity_indices):
        char_usage = float((C.getrow(character_index) @ z)[0] / time_seconds)
        char_available = float(x0[character_index] + (N.getrow(character_index) @ moments[1])[0])
        output["character_capacity"] = {
            "normalized_total_usage": char_usage,
            "normalized_average_available": char_available,
            "moment_0_slack": char_available - char_usage,
            "seconds_used": char_usage * time_seconds,
            "seconds_available_if_no_character_production": time_seconds,
        }

    ineqlin = getattr(result, "ineqlin", None)
    if ineqlin is not None and getattr(ineqlin, "marginals", None) is not None:
        marginals = np.asarray(ineqlin.marginals, dtype=float)
        group_duals = []
        for group in constraint_groups:
            lo = int(group["row_start"])
            hi = int(group["row_stop_exclusive"])
            values = marginals[lo:hi]
            max_abs = float(np.max(np.abs(values))) if values.size else 0.0
            if max_abs <= active_eps:
                continue
            group_duals.append({
                "name": group["name"],
                "max_abs_minimization_marginal": max_abs,
            })
        output["active_constraint_group_duals"] = group_duals

    # Private data used by --save-lp-dir; removed before JSON serialization.
    output["_lp_internal"] = {
        "A_ub": A_ub,
        "b_ub": b_ub,
        "objective": c,
        "finite_indices": finite_indices,
        "finite_capacity_indices": finite_capacity_indices,
    }
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
        "mean_time_seconds",
        "remaining_fraction_moment_1",
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
                if time_seconds > 0.0 else math.nan
            )
            writer.writerow({key: row.get(key) for key in fieldnames})

def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Solve the finite-time moment-relaxed production LP from a staged "
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
            "Candidate lower-bound time delta in seconds. used_payback edges are "
            "converted back to actual capacity durations and delta enters the "
            "moment/capacity inequalities directly."
        ),
    )
    parser.add_argument(
        "--moment-order",
        type=int,
        default=2,
        help=(
            "Number of normalized remaining-time moments to enforce (default 2). "
            "Use 1 for the basic first-moment relaxation; larger values tighten "
            "timing without introducing time slices."
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
        help="Optional directory to save S, C, LP inequalities, objective and metadata",
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
    if args.moment_order < 1:
        raise ValueError("--moment-order must be >= 1")
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
    ordinary_edges, capacity_specs, payback_meta = split_used_payback_capacity_edges(
        stage_nodes, stage_edges
    )
    print(
        f"Recovered {payback_meta['capacity_edge_count']} used_payback edge(s) "
        "as actual capacity durations",
        flush=True,
    )
    transformed_nodes, transformed_edges, transform_meta = make_bipartite(
        stage_nodes, ordinary_edges, zero_free_excluded_or_keys={character_key}
    )
    S, _b_traveler, _b_slot, row_keys, col_keys = build_matrix(
        transformed_nodes, transformed_edges
    )
    C = build_capacity_matrix(capacity_specs, row_keys, col_keys)

    present_infinite_keys = {key for key in infinite_keys if key in set(col_keys)}
    missing_infinite_keys = sorted(infinite_keys - present_infinite_keys)

    print(
        f"Normalized S={S.shape[0]} actions x {S.shape[1]} materials, "
        f"nnz={S.nnz}; capacity nnz={C.nnz}; "
        f"autoplaced/infinite entities={len(present_infinite_keys)}",
        flush=True,
    )
    if missing_infinite_keys:
        print(
            f"WARNING: {len(missing_infinite_keys)} detected infinite entity key(s) "
            "did not survive as material coordinates; ignoring them",
            flush=True,
        )

    result = solve_moment_growth_lp(
        S=S,
        C=C,
        row_keys=row_keys,
        col_keys=col_keys,
        transformed_nodes=transformed_nodes,
        infinite_keys=present_infinite_keys,
        goal_key=goal_key,
        character_key=character_key,
        time_seconds=args.time_seconds,
        moment_order=args.moment_order,
        method=args.method,
        active_eps=args.active_eps,
    )

    result.update(
        {
            "format": "propertyrandomizer-moment-growth-lp-v4",
            "stage_index": snapshot.stage_index,
            "stage_name": snapshot.stage_name,
            "target_hint": snapshot.target_hint,
            "graph_source": graph_source,
            "goal_item_name": args.goal,
            "goal_amount_requested": float(args.goal_amount),
            "time_seconds": float(args.time_seconds),
            "time_seconds_role": (
                "active: used_payback edges are recovered as actual-duration "
                "capacity requirements; delta appears directly in moment constraints"
            ),
            "moment_order": int(args.moment_order),
            "payback_capacity_recovery": payback_meta,
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

    lp_internal = result.pop("_lp_internal", None)

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
        save_npz(args.save_lp_dir / "S-ordinary-actions-by-materials.npz", S)
        save_npz(args.save_lp_dir / "C-capacity-seconds-materials-by-actions.npz", C)
        if lp_internal is not None:
            save_npz(args.save_lp_dir / "A-ub.npz", lp_internal["A_ub"])
            np.save(args.save_lp_dir / "b-ub.npy", lp_internal["b_ub"])
            np.save(args.save_lp_dir / "objective.npy", lp_internal["objective"])
            finite_indices = lp_internal["finite_indices"]
            finite_capacity_indices = lp_internal["finite_capacity_indices"]
        else:
            finite_indices = np.asarray([], dtype=np.int64)
            finite_capacity_indices = np.asarray([], dtype=np.int64)
        (args.save_lp_dir / "lp-metadata.json").write_text(
            json.dumps(
                {
                    "row_keys_actions": row_keys,
                    "col_keys_materials": col_keys,
                    "finite_material_indices": finite_indices.tolist(),
                    "finite_capacity_material_indices": finite_capacity_indices.tolist(),
                    "infinite_material_keys": sorted(present_infinite_keys),
                    "goal_key": goal_key,
                    "character_key": character_key,
                    "time_seconds": float(args.time_seconds),
                    "moment_order": int(args.moment_order),
                    "payback_capacity_recovery": payback_meta,
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
        if "character_capacity" in result:
            print(
                f"Character time used = {result['character_capacity']['seconds_used']:.17g}s "
                f"of {args.time_seconds:g}s; active actions={result['active_action_count']}",
                flush=True,
            )
        else:
            print(
                f"Character final inventory = {result['character_final_amount']:.17g}; "
                f"active actions={result['active_action_count']}",
                flush=True,
            )
    print(result["lower_bound_test"]["interpretation"], flush=True)
    print(f"Wrote {args.output}", flush=True)
    if args.actions_csv is not None and result["status"] == "optimal":
        print(f"Wrote {args.actions_csv}", flush=True)


if __name__ == "__main__":
    main()
