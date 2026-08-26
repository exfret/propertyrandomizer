#!/usr/bin/env python3
"""
PropertyRandomizer staged material-cost solver using the dependency graph dump.

Unlike the older solver, this does NOT read PROPERTYRANDOMIZER_LP_JSON exports
and does not depend on simplex-lp-export.lua.  It reconstructs the linear
program directly from logic.graph:

    AND node -> LP row/action
    OR node  -> LP column/state
    AND -> OR edge with amount a -> +a production
    OR -> AND edge with amount a -> -a consumption
    missing edge amount           -> no numeric coefficient
    AND.cost                      -> row cost

The staged reachability boundary comes from every pebble in each dumped
sort_info.sorted table.  The corresponding top.path dump is retained only as
critical-path/target metadata.

Pyanodons science-flow targets still need science-pack ratios.  Those ratios are
not quantitative dependency-graph edges, so this program reads only the
technology/unit/ingredients portion of the dumped data.raw and reconstructs the
same representative pack bundle that simplex-cost.lua used.  The LP matrix
itself is graph-derived.

science_flow.py remains a separate dependency.
"""

from __future__ import annotations

import argparse
import json
import math
import re
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Any, Iterator, Sequence

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix, csr_matrix

from science_flow_2 import (
    analyze_operational_loops,
    has_science_target,
    solve_science_flow,
    write_loops_lua,
)


PY_PACKS_IN_ORDER = [
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
]
PY_STAGE_COUNT = len(PY_PACKS_IN_ORDER) + 1
FINAL_STAGE_NAME = "full-pyrrhic-victory"

NUMBER_RE = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"
ENTRY_START_RE = re.compile(
    r'(?:\{|,)\["((?:\\.|[^"\\])*)"\]=\{object_type="(node|edge)"'
)
SORT_ITEM_RE = re.compile(
    r'\{node_key="((?:\\.|[^"\\])*)",context="((?:\\.|[^"\\])*)"\}'
)
LOG_PREFIX_RE = re.compile(
    r"^\s*\d+(?:\.\d+)?\s+Script\s+@.*?:\d+:\s*"
)


# ---------------------------------------------------------------------------
# Parsed graph / stage objects
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class GraphNode:
    key: str
    op: str
    node_type: str | None = None
    name: str | None = None
    fluid: str | None = None
    cost: float = 0.0
    slot_additional_cost: float = 0.0
    cost_present: bool = False
    slot_cost_present: bool = False
    synthetic: bool = False
    source_kind: str | None = None
    source_key: str | None = None


@dataclass(frozen=True)
class GraphEdge:
    key: str
    start: str
    stop: str
    amount: float = 0.0
    amount_present: bool = False
    slot_additional_cost: float = 0.0
    slot_cost_present: bool = False


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
    declared_index: int | None
    path_indices: list[int]
    reachable_nodes: set[str]
    contexts: dict[str, str]
    target_hint: str | None


# ---------------------------------------------------------------------------
# Lua / Serpent scalar helpers
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
    match = pat.search(text, start, end)
    return _lua_unescape(match.group(1)) if match else None


def _find_number_field(text: str, start: int, end: int, field: str) -> float | None:
    pat = re.compile(rf'(?:\{{|,){re.escape(field)}=({NUMBER_RE})')
    match = pat.search(text, start, end)
    return float(match.group(1)) if match else None


def _has_field(text: str, start: int, end: int, field: str) -> bool:
    return re.search(rf'(?:\{{|,){re.escape(field)}=', text[start:end]) is not None


def _strip_log_prefix(line: str) -> str:
    line = line.rstrip("\r\n")
    match = LOG_PREFIX_RE.match(line)
    return line[match.end() :] if match else line


def _scan_quoted_end(text: str, start: int) -> int:
    quote = text[start]
    i = start + 1
    while i < len(text):
        if text[i] == "\\":
            i += 2
            continue
        if text[i] == quote:
            return i + 1
        i += 1
    raise RuntimeError("Unterminated quoted string in Serpent dump")


def _find_matching_brace(text: str, start: int) -> int:
    if start >= len(text) or text[start] != "{":
        raise ValueError("_find_matching_brace must start on '{'")
    depth = 0
    i = start
    while i < len(text):
        ch = text[i]
        if ch in {'"', "'"}:
            i = _scan_quoted_end(text, i)
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise RuntimeError("Unbalanced table braces in Serpent dump")


def _skip_ws(text: str, i: int) -> int:
    while i < len(text) and text[i].isspace():
        i += 1
    return i


def _scan_value_end(text: str, start: int) -> int:
    start = _skip_ws(text, start)
    if start >= len(text):
        return start
    if text[start] == "{":
        return _find_matching_brace(text, start) + 1
    if text[start] in {'"', "'"}:
        return _scan_quoted_end(text, start)

    paren = bracket = 0
    i = start
    while i < len(text):
        ch = text[i]
        if ch in {'"', "'"}:
            i = _scan_quoted_end(text, i)
            continue
        if ch == "(":
            paren += 1
        elif ch == ")" and paren:
            paren -= 1
        elif ch == "[":
            bracket += 1
        elif ch == "]" and bracket:
            bracket -= 1
        elif paren == 0 and bracket == 0 and ch in ",;}":
            return i
        i += 1
    return i


def _parse_lua_scalar(raw: str) -> Any:
    raw = raw.strip()
    if not raw:
        return None
    if raw[0] in {'"', "'"} and raw[-1] == raw[0]:
        return _lua_unescape(raw[1:-1])
    if raw == "nil":
        return None
    if raw == "true":
        return True
    if raw == "false":
        return False
    if re.fullmatch(NUMBER_RE, raw):
        value = float(raw)
        return int(value) if value.is_integer() else value
    return raw


def _iter_lua_table_entries(table_text: str) -> Iterator[tuple[Any, str]]:
    """Yield immediate key/value entries from a plain Serpent table."""
    start = table_text.find("{")
    if start < 0:
        raise RuntimeError("Expected Lua table")
    end = _find_matching_brace(table_text, start)
    i = start + 1
    implicit_index = 1

    while True:
        i = _skip_ws(table_text, i)
        while i < end and table_text[i] in ",;":
            i = _skip_ws(table_text, i + 1)
        if i >= end:
            break

        key: Any = None
        value_start = i

        if table_text[i] == "[":
            j = i + 1
            j = _skip_ws(table_text, j)
            if table_text[j] in {'"', "'"}:
                key_end = _scan_quoted_end(table_text, j)
                key = _parse_lua_scalar(table_text[j:key_end])
                j = _skip_ws(table_text, key_end)
            else:
                close = table_text.find("]", j, end)
                if close < 0:
                    raise RuntimeError("Unterminated bracketed Lua table key")
                key = _parse_lua_scalar(table_text[j:close])
                j = close
            if j >= end or table_text[j] != "]":
                raise RuntimeError("Malformed bracketed Lua table key")
            j = _skip_ws(table_text, j + 1)
            if j >= end or table_text[j] != "=":
                raise RuntimeError("Bracketed Lua table key missing '='")
            value_start = _skip_ws(table_text, j + 1)
        else:
            ident = re.match(r"[A-Za-z_][A-Za-z0-9_]*", table_text[i:end])
            if ident:
                ident_end = i + ident.end()
                j = _skip_ws(table_text, ident_end)
                if j < end and table_text[j] == "=":
                    key = ident.group(0)
                    value_start = _skip_ws(table_text, j + 1)

        if key is None:
            key = implicit_index
            implicit_index += 1
            value_start = i

        value_end = _scan_value_end(table_text, value_start)
        yield key, table_text[value_start:value_end]
        i = value_end


def _find_table_field_raw(table_text: str, wanted: str) -> str | None:
    for key, raw in _iter_lua_table_entries(table_text):
        if key == wanted:
            return raw.strip()
    return None


def _extract_root_table(blob: str) -> str:
    # Serpent can emit either a plain table or `do local _={...}; ... end`.
    local_pos = blob.find("local _=")
    search_from = local_pos + len("local _=") if local_pos >= 0 else 0
    start = blob.find("{", search_from)
    if start < 0:
        raise RuntimeError("Could not find root table in Serpent dump")
    end = _find_matching_brace(blob, start)
    return blob[start : end + 1]


# ---------------------------------------------------------------------------
# Factorio log parsing
# ---------------------------------------------------------------------------


def _parse_path_indices(payload: str) -> list[int]:
    match = re.search(r"(?:\{|,)path=\{([^}]*)\}", payload)
    if not match:
        raise RuntimeError("Could not find path={...} in PATH DUMP")
    body = match.group(1).strip()
    if not body:
        return []
    try:
        return [int(part.strip()) for part in body.split(",") if part.strip()]
    except ValueError as exc:
        raise RuntimeError("PATH DUMP contains a non-integer path index") from exc


def _parse_sorted(payload: str) -> tuple[set[str], dict[str, str]]:
    marker = "sorted={"
    pos = payload.find(marker)
    if pos < 0:
        raise RuntimeError("SORT INFO DUMP has no sorted={...} field")
    brace = payload.find("{", pos + len("sorted="))
    end = _find_matching_brace(payload, brace)
    sorted_text = payload[brace : end + 1]

    reachable: set[str] = set()
    contexts: dict[str, str] = {}
    for match in SORT_ITEM_RE.finditer(sorted_text):
        key = _lua_unescape(match.group(1))
        context = _lua_unescape(match.group(2))
        reachable.add(key)
        contexts[key] = context

    if not reachable:
        raise RuntimeError("SORT INFO DUMP contained no sorted pebbles")
    return reachable, contexts


def _target_hint_for_stage(ordinal: int, py_mode_guess: bool = True) -> str | None:
    if py_mode_guess and 1 <= ordinal <= len(PY_PACKS_IN_ORDER):
        return f"item: {PY_PACKS_IN_ORDER[ordinal - 1]}"
    if py_mode_guess and ordinal == PY_STAGE_COUNT:
        return "technology: pyrrhic"
    return None


def parse_factorio_log(path: Path) -> tuple[list[StageSnapshot], str, str | None]:
    stage_records: list[dict[str, Any]] = []
    current_stage_index: int | None = None
    pending_dump: str | None = None
    current_path_payload: str | None = None
    graph_payload: str | None = None

    inside_data_raw = False
    data_raw_parts: list[str] = []

    def consume_dump(kind: str, payload: str) -> None:
        nonlocal current_path_payload, graph_payload
        if kind == "path":
            current_path_payload = payload
            return
        if kind == "sort":
            if current_path_payload is None:
                raise RuntimeError("SORT INFO DUMP appeared without preceding PATH DUMP")
            stage_records.append(
                {
                    "declared_index": current_stage_index,
                    "path_payload": current_path_payload,
                    "sort_payload": payload,
                }
            )
            current_path_payload = None
            return
        if kind == "graph":
            graph_payload = payload
            return
        raise AssertionError(kind)

    with path.open("r", encoding="utf-8", errors="replace") as fh:
        for raw_line in fh:
            payload = _strip_log_prefix(raw_line)

            if inside_data_raw:
                if "__DATA_RAW_END__" in payload:
                    before = payload.split("__DATA_RAW_END__", 1)[0]
                    if before:
                        data_raw_parts.append(before)
                    inside_data_raw = False
                else:
                    data_raw_parts.append(payload)
                continue

            if "__DATA_RAW_BEGIN__" in payload:
                after = payload.split("__DATA_RAW_BEGIN__", 1)[1]
                if "__DATA_RAW_END__" in after:
                    data_raw_parts.append(after.split("__DATA_RAW_END__", 1)[0])
                else:
                    if after:
                        data_raw_parts.append(after)
                    inside_data_raw = True
                continue

            stripped = payload.strip()
            if pending_dump is not None:
                if not stripped:
                    continue
                consume_dump(pending_dump, payload)
                pending_dump = None
                continue

            match = re.search(r"I IS THIS VALUE\s+(\d+)", payload)
            if match:
                current_stage_index = int(match.group(1))
                continue

            if stripped == "PATH DUMP" or stripped.endswith(": PATH DUMP"):
                pending_dump = "path"
                continue
            if stripped == "SORT INFO DUMP" or stripped.endswith(": SORT INFO DUMP"):
                pending_dump = "sort"
                continue
            if stripped == "GRAPH DUMP" or stripped.endswith(": GRAPH DUMP"):
                pending_dump = "graph"
                continue

    if inside_data_raw:
        raise RuntimeError("Log ended inside __DATA_RAW_BEGIN__/END block")
    if pending_dump is not None:
        raise RuntimeError(f"Log ended before payload for {pending_dump!r} dump")
    if not stage_records:
        raise RuntimeError("No PATH DUMP / SORT INFO DUMP stage pairs found")
    if graph_payload is None:
        raise RuntimeError("No GRAPH DUMP payload found")

    py_mode_guess = len(stage_records) == PY_STAGE_COUNT
    snapshots: list[StageSnapshot] = []
    for ordinal, record in enumerate(stage_records, start=1):
        declared = record["declared_index"]
        if declared is not None and declared != ordinal:
            raise RuntimeError(
                f"Stage order mismatch: stage record {ordinal} declares I={declared}"
            )
        path_indices = _parse_path_indices(record["path_payload"])
        reachable, contexts = _parse_sorted(record["sort_payload"])
        snapshots.append(
            StageSnapshot(
                ordinal=ordinal,
                declared_index=declared,
                path_indices=path_indices,
                reachable_nodes=reachable,
                contexts=contexts,
                target_hint=_target_hint_for_stage(ordinal, py_mode_guess),
            )
        )

    data_raw = "\n".join(data_raw_parts) if data_raw_parts else None
    return snapshots, graph_payload, data_raw


# ---------------------------------------------------------------------------
# Full dependency graph parsing
# ---------------------------------------------------------------------------


def parse_full_graph(payload: str) -> tuple[dict[str, GraphNode], list[GraphEdge]]:
    starts = list(ENTRY_START_RE.finditer(payload))
    if not starts:
        raise RuntimeError("GRAPH DUMP contains no top-level graph node/edge objects")

    # The first graph table contains each object once.  graph.nodes/graph.edges
    # later point back to those tables and are represented by Serpent reference
    # assignments.  Stop before that tail if present.
    table_tail = payload.find("};_.nodes=", starts[-1].start())
    if table_tail < 0:
        table_tail = payload.find(";_.nodes=", starts[-1].start())
    if table_tail < 0:
        table_tail = len(payload)

    nodes: dict[str, GraphNode] = {}
    edges: list[GraphEdge] = []

    for index, match in enumerate(starts):
        key = _lua_unescape(match.group(1))
        object_type = match.group(2)
        start = match.start()
        end = starts[index + 1].start() if index + 1 < len(starts) else table_tail

        if object_type == "node":
            if key in nodes:
                raise RuntimeError(f"Duplicate graph node key {key!r}")
            cost_present = _has_field(payload, start, end, "cost")
            slot_present = _has_field(payload, start, end, "slot_additional_cost")
            nodes[key] = GraphNode(
                key=key,
                op=_find_string_field(payload, start, end, "op") or "",
                node_type=_find_string_field(payload, start, end, "type"),
                name=_find_string_field(payload, start, end, "name"),
                fluid=_find_string_field(payload, start, end, "fluid"),
                cost=_find_number_field(payload, start, end, "cost") or 0.0,
                slot_additional_cost=(
                    _find_number_field(payload, start, end, "slot_additional_cost")
                    or 0.0
                ),
                cost_present=cost_present,
                slot_cost_present=slot_present,
            )
            continue

        edge_start = _find_string_field(payload, start, end, "start")
        edge_stop = _find_string_field(payload, start, end, "stop")
        if edge_start is None or edge_stop is None:
            raise RuntimeError(f"Graph edge {key!r} is missing start/stop")
        amount_present = _has_field(payload, start, end, "amount")
        slot_present = _has_field(payload, start, end, "slot_additional_cost")
        edges.append(
            GraphEdge(
                key=key,
                start=edge_start,
                stop=edge_stop,
                amount=_find_number_field(payload, start, end, "amount") or 0.0,
                amount_present=amount_present,
                slot_additional_cost=(
                    _find_number_field(payload, start, end, "slot_additional_cost")
                    or 0.0
                ),
                slot_cost_present=slot_present,
            )
        )

    return nodes, edges


# ---------------------------------------------------------------------------
# data.raw technology parsing for Py science-flow targets
# ---------------------------------------------------------------------------


def _parse_science_ingredient(raw: str) -> tuple[str, float] | None:
    raw = raw.strip()
    if not raw.startswith("{"):
        return None
    values: dict[Any, Any] = {}
    for key, value_raw in _iter_lua_table_entries(raw):
        values[key] = _parse_lua_scalar(value_raw)

    name = values.get("name", values.get(1))
    amount = values.get("amount", values.get(2, 1))
    if not isinstance(name, str):
        return None
    try:
        return name, float(amount)
    except (TypeError, ValueError):
        return None


def extract_technology_science_requirements(data_raw_blob: str) -> list[list[tuple[str, float]]]:
    root = _extract_root_table(data_raw_blob)
    technology_raw = _find_table_field_raw(root, "technology")
    if technology_raw is None or not technology_raw.startswith("{"):
        raise RuntimeError("data.raw dump has no top-level technology table")

    tech_requirements: list[list[tuple[str, float]]] = []
    for _tech_name, tech_raw in _iter_lua_table_entries(technology_raw):
        if not tech_raw.lstrip().startswith("{"):
            continue
        unit_raw = _find_table_field_raw(tech_raw, "unit")
        if unit_raw is None or not unit_raw.lstrip().startswith("{"):
            continue
        ingredients_raw = _find_table_field_raw(unit_raw, "ingredients")
        if ingredients_raw is None or not ingredients_raw.lstrip().startswith("{"):
            continue

        requirements: list[tuple[str, float]] = []
        for _key, ingredient_raw in _iter_lua_table_entries(ingredients_raw):
            parsed = _parse_science_ingredient(ingredient_raw)
            if parsed is not None:
                requirements.append(parsed)
        if requirements:
            tech_requirements.append(requirements)

    if not tech_requirements:
        raise RuntimeError("No technology.unit.ingredients entries parsed from data.raw")
    return tech_requirements


def build_py_science_bundles(data_raw_blob: str) -> dict[str, list[tuple[str, float]]]:
    """Mirror simplex-cost.lua's representative-tech selection by pack level."""
    technology_requirements = extract_technology_science_requirements(data_raw_blob)
    bundles: dict[str, list[tuple[str, float]]] = {}

    for index, pack in enumerate(PY_PACKS_IN_ORDER):
        allowed = set(PY_PACKS_IN_ORDER[: index + 1])
        selected: list[tuple[str, float]] | None = None

        for requirements in technology_requirements:
            valid = False
            for name, _amount in requirements:
                if name == pack:
                    valid = True
                if name not in allowed:
                    valid = False
                    break
            if valid:
                selected = requirements
                break

        if selected is None:
            raise RuntimeError(
                f"Could not find a representative technology for Py pack {pack!r} "
                "in dumped data.raw"
            )
        bundles[pack] = selected

    return bundles


# ---------------------------------------------------------------------------
# Strict bipartite conversion of the quantitative graph
# ---------------------------------------------------------------------------


def synthetic_key(kind: str, source_key: str) -> str:
    return f"__pr_lp_{kind}__:{source_key}"


def or_cost_pre_key(node_key: str) -> str:
    return synthetic_key("or_cost_pre", node_key)


def or_cost_and_key(node_key: str) -> str:
    return synthetic_key("or_cost_and", node_key)


def bipartize_stage_graph(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[BipartiteEdge]]:
    out_nodes = dict(nodes)
    out_edges: list[BipartiteEdge] = []

    cost_or_nodes = {
        key for key, node in nodes.items() if node.op == "OR" and node.cost != 0.0
    }

    # Reify OR-node cost as OR(pre) -> AND(cost) -> OR(original).
    for key in cost_or_nodes:
        node = nodes[key]
        pre = or_cost_pre_key(key)
        cost_and = or_cost_and_key(key)
        if pre in out_nodes or cost_and in out_nodes:
            raise RuntimeError(f"Synthetic node key collision while splitting {key!r}")

        out_nodes[key] = replace(
            node,
            cost=0.0,
            slot_additional_cost=0.0,
            cost_present=False,
            slot_cost_present=False,
        )
        out_nodes[pre] = GraphNode(
            key=pre,
            op="OR",
            synthetic=True,
            source_kind="node-cost-pre",
            source_key=key,
        )
        out_nodes[cost_and] = GraphNode(
            key=cost_and,
            op="AND",
            cost=node.cost,
            slot_additional_cost=node.slot_additional_cost,
            cost_present=True,
            slot_cost_present=node.slot_cost_present,
            synthetic=True,
            source_kind="node-cost",
            source_key=key,
        )
        out_edges.extend(
            [
                BipartiteEdge(pre, cost_and, 1.0, f"node-cost:{key}:pre", True),
                BipartiteEdge(cost_and, key, 1.0, f"node-cost:{key}:post", True),
            ]
        )

    for edge in edges:
        src_key = edge.start
        dst_key = or_cost_pre_key(edge.stop) if edge.stop in cost_or_nodes else edge.stop
        src = out_nodes[src_key]
        dst = out_nodes[dst_key]

        if src.op != dst.op:
            out_edges.append(
                BipartiteEdge(src_key, dst_key, edge.amount, edge.key, False)
            )
            continue

        if src.op == "AND":
            # AND --a--> AND  =>  AND --1--> OR(mid) --a--> AND
            mid = synthetic_key("or", edge.key)
            if mid in out_nodes:
                raise RuntimeError(f"Synthetic node key collision {mid!r}")
            out_nodes[mid] = GraphNode(
                key=mid,
                op="OR",
                synthetic=True,
                source_kind="same-op-edge",
                source_key=edge.key,
            )
            out_edges.extend(
                [
                    BipartiteEdge(src_key, mid, 1.0, edge.key, True),
                    BipartiteEdge(mid, dst_key, edge.amount, edge.key, True),
                ]
            )
            continue

        # OR --a--> OR  =>  OR --a--> AND(mid) --1--> OR
        mid = synthetic_key("and", edge.key)
        if mid in out_nodes:
            raise RuntimeError(f"Synthetic node key collision {mid!r}")
        out_nodes[mid] = GraphNode(
            key=mid,
            op="AND",
            cost=0.0,
            slot_additional_cost=edge.slot_additional_cost,
            cost_present=True,
            slot_cost_present=edge.slot_cost_present,
            synthetic=True,
            source_kind="same-op-edge",
            source_key=edge.key,
        )
        out_edges.extend(
            [
                BipartiteEdge(src_key, mid, edge.amount, edge.key, True),
                BipartiteEdge(mid, dst_key, 1.0, edge.key, True),
            ]
        )

    return out_nodes, out_edges


# ---------------------------------------------------------------------------
# Recipe gross-I/O metadata for science-flow loop protection
# ---------------------------------------------------------------------------


def _fluid_name_from_node(node: GraphNode) -> str | None:
    if node.fluid:
        return node.fluid
    if node.name:
        return node.name.split(": ", 1)[0]
    return None


def _ingredient_material_key(node: GraphNode) -> str | None:
    if node.node_type == "item":
        return node.key
    if node.node_type == "fluid":
        return node.key
    if node.node_type == "fluid-temperature-range":
        fluid = _fluid_name_from_node(node)
        return f"fluid: {fluid}" if fluid else None
    return None


def _product_material_key(node: GraphNode) -> str | None:
    if node.node_type == "item":
        return node.key
    if node.node_type == "item-craft" and node.name is not None:
        return f"item: {node.name}"
    if node.node_type == "fluid" and node.name is not None:
        return f"fluid: {node.name}"
    if node.node_type in {
        "fluid-craft-temperature",
        "fluid-create-temperature",
        "fluid-create",
        "fluid-craft",
    }:
        fluid = _fluid_name_from_node(node)
        return f"fluid: {fluid}" if fluid else None
    return None


def build_recipe_gross_io(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> dict[str, dict[str, list[dict[str, Any]]]]:
    ingredients: dict[str, dict[str, float]] = {}
    products: dict[str, dict[str, float]] = {}

    for edge in edges:
        if not edge.amount_present or edge.amount <= 0.0:
            continue
        src = nodes.get(edge.start)
        dst = nodes.get(edge.stop)
        if src is None or dst is None:
            continue

        if dst.node_type == "recipe" and dst.op == "AND":
            material_key = _ingredient_material_key(src)
            if material_key:
                bucket = ingredients.setdefault(dst.key, {})
                bucket[material_key] = bucket.get(material_key, 0.0) + edge.amount

        if src.node_type == "recipe" and src.op == "AND":
            material_key = _product_material_key(dst)
            if material_key:
                bucket = products.setdefault(src.key, {})
                bucket[material_key] = bucket.get(material_key, 0.0) + edge.amount

    recipe_keys = set(ingredients) | set(products)
    output: dict[str, dict[str, list[dict[str, Any]]]] = {}
    for recipe_key in recipe_keys:
        output[recipe_key] = {
            "gross_ingredients": [
                {"key": key, "amount": amount}
                for key, amount in sorted(ingredients.get(recipe_key, {}).items())
            ],
            "gross_products": [
                {"key": key, "amount": amount}
                for key, amount in sorted(products.get(recipe_key, {}).items())
            ],
        }
    return output


# ---------------------------------------------------------------------------
# Stage LP construction
# ---------------------------------------------------------------------------


def _blocked_pack_keys(snapshot: StageSnapshot, py_mode: bool) -> set[str]:
    if not py_mode or snapshot.ordinal > len(PY_PACKS_IN_ORDER):
        return set()
    blocked = {f"item: {PY_PACKS_IN_ORDER[snapshot.ordinal - 1]}"}
    if PY_PACKS_IN_ORDER[snapshot.ordinal - 1] == "military-science-pack":
        blocked.add("item: py-science-pack-2")
    return blocked


def _stage_science_metadata(
    snapshot: StageSnapshot,
    py_mode: bool,
    stage_count: int,
    bundles: dict[str, list[tuple[str, float]]] | None,
    material_index_by_key: dict[str, int],
) -> dict[str, Any]:
    if not py_mode:
        return {
            "mode": "generic",
            "is_pyanodons": False,
            "staged_costs": False,
            "stage_index": snapshot.ordinal,
            "stage_count": stage_count,
            "current": None,
        }

    if snapshot.ordinal == PY_STAGE_COUNT:
        return {
            "mode": "pyanodons-staged-graph",
            "is_pyanodons": True,
            "staged_costs": True,
            "stage_index": snapshot.ordinal,
            "stage_count": PY_STAGE_COUNT,
            "stage_name": FINAL_STAGE_NAME,
            "blocked_pack": None,
            "current": None,
            "py_packs_in_order": PY_PACKS_IN_ORDER,
        }

    pack = PY_PACKS_IN_ORDER[snapshot.ordinal - 1]
    if bundles is None or pack not in bundles:
        raise RuntimeError(f"No reconstructed science bundle for {pack!r}")

    requirements: list[dict[str, Any]] = []
    for name, amount in bundles[pack]:
        key = f"item: {name}"
        index = material_index_by_key.get(key)
        if index is None:
            raise RuntimeError(
                f"Stage {snapshot.ordinal} science requirement {key!r} is not "
                "a column in the graph LP.  Check the stage sort boundary."
            )
        requirements.append(
            {
                "name": name,
                "amount": float(amount),
                "material_index": index,
                "key": key,
            }
        )

    return {
        "mode": "pyanodons-staged-graph",
        "is_pyanodons": True,
        "staged_costs": True,
        "stage_index": snapshot.ordinal,
        "stage_count": PY_STAGE_COUNT,
        "stage_name": f"pre-{pack}",
        "blocked_pack": pack,
        "current": {
            "name": pack,
            "stage_index": snapshot.ordinal,
            "requirements": requirements,
        },
        "py_packs_in_order": PY_PACKS_IN_ORDER,
        "flow_extra_rows": [],
    }


def build_stage_lp(
    snapshot: StageSnapshot,
    original_nodes: dict[str, GraphNode],
    original_edges: Sequence[GraphEdge],
    recipe_gross_io: dict[str, dict[str, list[dict[str, Any]]]],
    py_mode: bool,
    stage_count: int,
    science_bundles: dict[str, list[tuple[str, float]]] | None,
) -> tuple[dict[str, Any], csr_matrix, np.ndarray]:
    included_original = {
        key: original_nodes[key]
        for key in snapshot.reachable_nodes
        if key in original_nodes and original_nodes[key].op in {"AND", "OR"}
    }

    blocked_starts = _blocked_pack_keys(snapshot, py_mode)
    numeric_edges: list[GraphEdge] = []
    missing_amount_inside = 0
    blocked_numeric_edges = 0
    missing_endpoint_edges = 0

    for edge in original_edges:
        if edge.start not in included_original or edge.stop not in included_original:
            continue
        if edge.start in blocked_starts:
            if edge.amount_present and edge.amount != 0.0:
                blocked_numeric_edges += 1
            continue
        if not edge.amount_present:
            missing_amount_inside += 1
            continue
        if edge.amount == 0.0:
            continue
        if edge.start not in original_nodes or edge.stop not in original_nodes:
            missing_endpoint_edges += 1
            continue
        numeric_edges.append(edge)

    transformed_nodes, transformed_edges = bipartize_stage_graph(
        included_original,
        numeric_edges,
    )

    row_keys = sorted(
        key for key, node in transformed_nodes.items() if node.op == "AND"
    )
    col_keys = sorted(
        key for key, node in transformed_nodes.items() if node.op == "OR"
    )
    row_index = {key: i for i, key in enumerate(row_keys)}
    col_index = {key: i for i, key in enumerate(col_keys)}

    rr: list[int] = []
    cc: list[int] = []
    vv: list[float] = []
    for edge in transformed_edges:
        src = transformed_nodes[edge.start]
        dst = transformed_nodes[edge.stop]
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
                f"Internal error: transformed edge is not bipartite: "
                f"{edge.start!r} -> {edge.stop!r}"
            )

    A = coo_matrix(
        (vv, (rr, cc)),
        shape=(len(row_keys), len(col_keys)),
        dtype=float,
    ).tocsr()
    A.sum_duplicates()
    A.eliminate_zeros()

    b = np.asarray(
        [transformed_nodes[key].cost for key in row_keys],
        dtype=float,
    )

    materials: list[dict[str, Any]] = []
    material_index_by_key: dict[str, int] = {}
    cost_target_count = 0
    for index, key in enumerate(col_keys, start=1):
        node = transformed_nodes[key]
        target = (
            not node.synthetic
            and node.node_type in {"item", "fluid"}
            and key in included_original
        )
        if target:
            cost_target_count += 1
        metadata = {
            "index": index,
            "key": key,
            "type": node.node_type or ("synthetic" if node.synthetic else "graph-state"),
            "name": node.name if node.name is not None else key,
            "cost_target": target,
        }
        materials.append(metadata)
        material_index_by_key[key] = index

    rows: list[dict[str, Any]] = []
    for row_zero, key in enumerate(row_keys):
        node = transformed_nodes[key]
        row = A.getrow(row_zero)
        coeffs = [
            [int(col_zero) + 1, float(value)]
            for col_zero, value in zip(row.indices, row.data)
        ]

        if node.synthetic:
            source_type = node.source_kind or "synthetic"
            source_name = node.source_key or key
        else:
            source_type = node.node_type
            source_name = node.name

        gross = recipe_gross_io.get(key, {}) if source_type == "recipe" else {}
        rows.append(
            {
                "index": row_zero + 1,
                "cost": float(b[row_zero]),
                "coeffs": coeffs,
                "source_type": source_type,
                "source_name": source_name,
                "row_key": key,
                "gross_ingredients": gross.get("gross_ingredients", []),
                "gross_products": gross.get("gross_products", []),
            }
        )

    science = _stage_science_metadata(
        snapshot=snapshot,
        py_mode=py_mode,
        stage_count=stage_count,
        bundles=science_bundles,
        material_index_by_key=material_index_by_key,
    )

    lp = {
        "format": "propertyrandomizer-graph-lp-v1",
        "run": {
            "is_pyanodons": py_mode,
            "staged_costs": py_mode,
            "source": "logic.graph",
        },
        "science": science,
        "materials": materials,
        "rows": rows,
        "num_materials": len(materials),
        "num_rows": len(rows),
        "num_cost_targets": cost_target_count,
        "graph": {
            "reachable_original_nodes": len(included_original),
            "quantitative_original_edges": len(numeric_edges),
            "nonquantitative_edges_ignored": missing_amount_inside,
            "blocked_numeric_edges_ignored": blocked_numeric_edges,
            "missing_endpoint_edges": missing_endpoint_edges,
            "transformed_nodes": len(transformed_nodes),
            "transformed_edges": len(transformed_edges),
            "matrix_nnz": int(A.nnz),
            "critical_path_indices": len(snapshot.path_indices),
            "target_hint": snapshot.target_hint,
        },
    }
    return lp, A, b


def build_all_stage_lps(
    input_path: Path,
) -> list[tuple[int, dict[str, Any], csr_matrix, np.ndarray]]:
    snapshots, graph_payload, data_raw = parse_factorio_log(input_path)
    nodes, edges = parse_full_graph(graph_payload)
    recipe_gross = build_recipe_gross_io(nodes, edges)

    py_mode = len(snapshots) == PY_STAGE_COUNT
    science_bundles: dict[str, list[tuple[str, float]]] | None = None
    if py_mode:
        if data_raw is None:
            raise RuntimeError(
                "Pyanodons staged log has no __DATA_RAW_BEGIN__/END dump. "
                "The graph provides production amounts, but exact research-pack "
                "ratios must be reconstructed from data.raw.technology."
            )
        science_bundles = build_py_science_bundles(data_raw)

    print(
        f"Parsed dependency graph: {len(nodes)} nodes, {len(edges)} edges; "
        f"stages={len(snapshots)} mode={'pyanodons-staged' if py_mode else 'generic'}",
        flush=True,
    )

    stages: list[tuple[int, dict[str, Any], csr_matrix, np.ndarray]] = []
    for snapshot in snapshots:
        lp, A, b = build_stage_lp(
            snapshot=snapshot,
            original_nodes=nodes,
            original_edges=edges,
            recipe_gross_io=recipe_gross,
            py_mode=py_mode,
            stage_count=len(snapshots),
            science_bundles=science_bundles,
        )
        stages.append((snapshot.ordinal, lp, A, b))
        print(
            f"  stage {snapshot.ordinal}: "
            f"{lp['num_rows']} rows x {lp['num_materials']} cols, "
            f"nnz={A.nnz}, cost-targets={lp['num_cost_targets']}",
            flush=True,
        )

    return stages


# ---------------------------------------------------------------------------
# Compatibility helpers / output naming
# ---------------------------------------------------------------------------


def run_info(lp: dict[str, Any]) -> dict[str, Any]:
    return lp.get("run") or {}


def is_pyanodons(lp: dict[str, Any]) -> bool:
    return bool(run_info(lp).get("is_pyanodons"))


def staged_costs(lp: dict[str, Any]) -> bool:
    return bool(run_info(lp).get("staged_costs"))


def _pack_to_old_style_name(pack: str) -> str:
    if pack.startswith("py-science-pack-"):
        return "py-science-" + pack.removeprefix("py-science-pack-")
    if pack.endswith("-science-pack"):
        return pack.removesuffix("-pack")
    return pack


def py_stage_basename(lp: dict[str, Any]) -> str:
    science = lp.get("science") or {}
    stage_index = science.get("stage_index")
    stage_count = science.get("stage_count")
    current = science.get("current") or {}

    if (
        stage_index is not None
        and stage_count is not None
        and int(stage_index) == int(stage_count)
        and not current
    ):
        return "py-full-pyrrhic-victory"

    pack = science.get("blocked_pack") or current.get("name")
    if not pack:
        raise RuntimeError("Could not determine Py stage filename")
    return "py-full-" + _pack_to_old_style_name(str(pack))


def material_cost_basename(lp: dict[str, Any], generic_basename: str) -> str:
    return py_stage_basename(lp) if is_pyanodons(lp) else generic_basename


def flow_basename(lp: dict[str, Any]) -> str:
    return py_stage_basename(lp)


# ---------------------------------------------------------------------------
# Material-cost LP solves (same HiGHS dual formulation as prior solver)
# ---------------------------------------------------------------------------


def _recipe_producer_from_usages(
    rows: Sequence[dict[str, Any]],
    row_usages: np.ndarray,
    target_key: str,
) -> tuple[str | None, dict[str, Any] | None]:
    best: dict[str, Any] | None = None
    best_contribution = 0.0

    for row in rows:
        if row.get("source_type") != "recipe":
            continue
        row_zero = int(row["index"]) - 1
        usage = float(row_usages[row_zero])
        if usage <= 1e-12:
            continue
        for product in row.get("gross_products") or []:
            if product.get("key") != target_key:
                continue
            amount = float(product.get("amount", 0.0))
            contribution = usage * amount
            if contribution > best_contribution + 1e-12:
                best_contribution = contribution
                best = {
                    "row_index": int(row["index"]),
                    "source_type": "recipe",
                    "source_name": row.get("source_name"),
                    "usage": usage,
                    "target_output_per_use": amount,
                    "target_contribution": contribution,
                }

    return (best.get("source_name") if best else None), best


def solve_one_material(
    A: csr_matrix,
    b: np.ndarray,
    rows: list[dict[str, Any]],
    target_zero: int,
    target_key: str,
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
            "recipe": None,
            "producer": None,
            "message": result.message,
            "nit": getattr(result, "nit", None),
        }

    # For max c^T x subject to Ax<=b, HiGHS' inequality marginals are the
    # negatives of the primal row usages of the dual production plan.
    marginals = np.asarray(result.ineqlin.marginals, dtype=float)
    row_usages = np.maximum(0.0, -marginals)

    recipe, recipe_producer = _recipe_producer_from_usages(
        rows=rows,
        row_usages=row_usages,
        target_key=target_key,
    )

    # Keep a direct positive-row producer as fallback/diagnostic.  With the
    # dependency graph this may be a synthetic bridge rather than the recipe.
    direct_producer: dict[str, Any] | None = None
    best_direct = 0.0
    column = A.getcol(target_zero).tocoo()
    rows_by_index = {int(row["index"]) - 1: row for row in rows}
    for row_zero, coefficient in zip(column.row, column.data):
        if coefficient <= 0.0:
            continue
        usage = float(row_usages[row_zero])
        contribution = usage * float(coefficient)
        if contribution > best_direct + 1e-12:
            row = rows_by_index[int(row_zero)]
            best_direct = contribution
            direct_producer = {
                "row_index": int(row["index"]),
                "source_type": row.get("source_type"),
                "source_name": row.get("source_name"),
                "usage": usage,
                "target_output_per_use": float(coefficient),
                "target_contribution": contribution,
            }

    producer = recipe_producer or direct_producer
    return {
        "status": "optimal",
        "objective": float(-result.fun),
        "recipe": recipe,
        "producer": producer,
        "direct_producer": direct_producer,
        "message": result.message,
        "nit": getattr(result, "nit", None),
    }


def solve_all_materials(
    A: csr_matrix,
    b: np.ndarray,
    lp: dict[str, Any],
    method: str,
    progress_every: int,
) -> dict[str, Any]:
    materials = {
        int(material["index"]): material
        for material in lp["materials"]
    }
    indices = sorted(
        index for index, material in materials.items() if material.get("cost_target")
    )
    results: dict[str, Any] = {}

    for ordinal, material_index in enumerate(indices, start=1):
        material = materials[material_index]
        if (
            ordinal == 1
            or ordinal % progress_every == 0
            or ordinal == len(indices)
        ):
            print(
                f"    [{ordinal}/{len(indices)}] {material['key']}",
                flush=True,
            )

        results[str(material_index)] = solve_one_material(
            A=A,
            b=b,
            rows=lp["rows"],
            target_zero=material_index - 1,
            target_key=str(material["key"]),
            method=method,
        )

    return results


# ---------------------------------------------------------------------------
# Material-cost outputs
# ---------------------------------------------------------------------------


def _lua_quote(value: str) -> str:
    return json.dumps(value)


def write_material_json(
    path: Path,
    lp: dict[str, Any],
    A: csr_matrix,
    results: dict[str, Any],
) -> None:
    materials = {
        int(material["index"]): material
        for material in lp["materials"]
    }
    output: dict[str, Any] = {
        "format": "propertyrandomizer-material-costs-v3",
        "source": {
            "format": lp.get("format"),
            "run": lp.get("run"),
            "science": lp.get("science"),
            "graph": lp.get("graph"),
            "num_materials": int(lp["num_materials"]),
            "num_columns": int(lp["num_materials"]),
            "num_rows": int(lp["num_rows"]),
            "num_cost_targets": int(lp.get("num_cost_targets", len(results))),
            "nnz": int(A.nnz),
        },
        "results_by_lua_index": results,
        "costs": {},
        "recipes": {},
        "statuses": {},
    }

    for index_text, result in results.items():
        key = materials[int(index_text)]["key"]
        if result.get("objective") is not None:
            output["costs"][key] = result["objective"]
        if result.get("recipe") is not None:
            output["recipes"][key] = result["recipe"]
        output["statuses"][key] = result["status"]

    path.write_text(
        json.dumps(output, indent=2, sort_keys=True),
        encoding="utf-8",
    )


def write_material_lua(
    path: Path,
    lp: dict[str, Any],
    results: dict[str, Any],
) -> None:
    materials = {
        int(material["index"]): material
        for material in lp["materials"]
    }

    lines = [
        "-- generated by solve_lp.py from logic.graph",
        "return {",
        "    metadata = {",
        '        format = "propertyrandomizer-material-costs-v3",',
        f"        source_format = {_lua_quote(str(lp.get('format')))},",
        f"        is_pyanodons = {str(is_pyanodons(lp)).lower()},",
        f"        staged_costs = {str(staged_costs(lp)).lower()},",
        f"        num_materials = {int(lp['num_materials'])},",
        f"        num_columns = {int(lp['num_materials'])},",
        f"        num_rows = {int(lp['num_rows'])},",
        f"        num_cost_targets = {int(lp.get('num_cost_targets', len(results)))},",
        "    },",
        "    costs = {",
    ]

    for index_text in sorted(results, key=int):
        value = results[index_text].get("objective")
        if value is None or not math.isfinite(float(value)):
            continue
        key = materials[int(index_text)]["key"]
        lines.append(f"        [{_lua_quote(key)}] = {float(value):.17g},")

    lines.extend(["    },", "    statuses = {"])
    for index_text in sorted(results, key=int):
        key = materials[int(index_text)]["key"]
        lines.append(
            f"        [{_lua_quote(key)}] = "
            f"{_lua_quote(results[index_text]['status'])},"
        )

    lines.extend(["    },", "    recipes = {"])
    for index_text in sorted(results, key=int):
        recipe = results[index_text].get("recipe")
        if recipe is None:
            continue
        key = materials[int(index_text)]["key"]
        lines.append(f"        [{_lua_quote(key)}] = {_lua_quote(recipe)},")

    lines.extend(["    },", "}"])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# ---------------------------------------------------------------------------
# Stage selection / validation
# ---------------------------------------------------------------------------


def validate_and_select_cost_stages(stages):
    flags = {
        (is_pyanodons(lp), staged_costs(lp))
        for _, lp, _, _ in stages
    }
    if len(flags) != 1:
        raise RuntimeError("Stages mix incompatible Py/generic modes")

    py_mode, staged = flags.pop()
    if py_mode:
        if not staged:
            raise RuntimeError("Pyanodons graph stages unexpectedly have staged_costs=false")
        stage_indices = [
            int((lp.get("science") or {})["stage_index"])
            for _, lp, _, _ in stages
        ]
        if stage_indices != list(range(1, len(stage_indices) + 1)):
            raise RuntimeError(f"Py stages are out of order: {stage_indices}")
        if len(stage_indices) != PY_STAGE_COUNT:
            raise RuntimeError(
                f"Expected {PY_STAGE_COUNT} Py stages, got {len(stage_indices)}"
            )
        return True, stages

    if staged:
        raise RuntimeError("Generic graph stage unexpectedly has staged_costs=true")
    if len(stages) > 1:
        print(
            f"WARNING: found {len(stages)} generic stage dumps; only the LAST "
            "one will receive material costs.",
            flush=True,
        )
    return False, [stages[-1]]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Solve PropertyRandomizer costs directly from dumped logic.graph + "
            "PATH/SORT stage dumps; no simplex_export is required."
        )
    )
    parser.add_argument(
        "input",
        type=Path,
        help="Factorio log containing PATH/SORT, GRAPH DUMP, and data.raw dump",
    )
    parser.add_argument(
        "--material-cost-dir",
        type=Path,
        default=Path("material-costs"),
        help="Output folder for material cost .json/.lua files",
    )
    parser.add_argument(
        "--flow-dir",
        type=Path,
        default=Path("science-flows"),
        help="Output folder for Py science-flow/loop files",
    )
    parser.add_argument(
        "--generic-basename",
        default="full",
        help="Basename for the single generic material-cost table",
    )
    parser.add_argument(
        "--method",
        choices=["highs", "highs-ds", "highs-ipm"],
        default="highs",
    )
    parser.add_argument("--max-cycle-length", type=int, default=10)
    parser.add_argument("--plan-eps", type=float, default=1e-9)
    parser.add_argument("--progress-every", type=int, default=25)
    parser.add_argument(
        "--science-only",
        action="store_true",
        help="Run Py science-flow/loop analysis and stop before material costs",
    )
    args = parser.parse_args()

    args.material_cost_dir.mkdir(parents=True, exist_ok=True)
    args.flow_dir.mkdir(parents=True, exist_ok=True)

    stages = build_all_stage_lps(args.input)
    py_mode, cost_stages = validate_and_select_cost_stages(stages)

    # ---------------------------------------------------------------
    # PHASE 1: Py science production flows + operational loops.
    # ---------------------------------------------------------------
    if py_mode:
        targeted = [stage for stage in stages if has_science_target(stage[1])]
        if targeted:
            print("\n===== PHASE 1: PY SCIENCE FLOWS + LOOPS =====", flush=True)

        for _ordinal, lp, A, b in targeted:
            basename = flow_basename(lp)
            print(f"\n=== {basename} science flow ===", flush=True)

            flow = solve_science_flow(
                A=A,
                b=b,
                lp=lp,
                method=args.method,
                active_eps=args.plan_eps,
            )

            flow_path = args.flow_dir / f"{basename}-flow.json"
            flow_path.write_text(
                json.dumps(flow, indent=2, sort_keys=True),
                encoding="utf-8",
            )

            loops = analyze_operational_loops(
                lp=lp,
                flow=flow,
                max_cycle_length=args.max_cycle_length,
            )
            loops_json = args.flow_dir / f"{basename}-loops.json"
            loops_lua = args.flow_dir / f"{basename}-loops.lua"
            loops_json.write_text(
                json.dumps(loops, indent=2, sort_keys=True),
                encoding="utf-8",
            )
            write_loops_lua(loops_lua, loops)

            stats = loops.get("stats") or {}
            print(
                f"  flow status={flow['status']} cost={flow.get('objective')}",
                flush=True,
            )
            print(
                "  protected edges="
                f"{stats.get('protected_recipe_ingredient_edges', 0)} "
                "by length="
                f"{stats.get('protected_by_min_cycle_length', {})}",
                flush=True,
            )
            print(f"  wrote {flow_path}", flush=True)
            print(f"  wrote {loops_json}", flush=True)
            print(f"  wrote {loops_lua}", flush=True)

    if args.science_only:
        if not py_mode:
            print(
                "--science-only requested in generic mode; no science-flow phase.",
                flush=True,
            )
        return

    # ---------------------------------------------------------------
    # PHASE 2: material costs.
    # ---------------------------------------------------------------
    print("\n===== PHASE 2: MATERIAL COSTS =====", flush=True)
    for _ordinal, lp, A, b in cost_stages:
        basename = material_cost_basename(lp, args.generic_basename)
        print(f"\n=== {basename} ===", flush=True)

        results = solve_all_materials(
            A=A,
            b=b,
            lp=lp,
            method=args.method,
            progress_every=args.progress_every,
        )

        json_path = args.material_cost_dir / f"{basename}.json"
        lua_path = args.material_cost_dir / f"{basename}.lua"
        write_material_json(json_path, lp, A, results)
        write_material_lua(lua_path, lp, results)
        print(f"  wrote {json_path}", flush=True)
        print(f"  wrote {lua_path}", flush=True)


if __name__ == "__main__":
    main()
