#!/usr/bin/env python3
"""Finite-time moment-relaxed production + technology LP for staged PropertyRandomizer graphs.

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
import time
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FutureTimeoutError
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import coo_matrix, csr_matrix, diags, eye, hstack, save_npz, vstack


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
# Technology-cone cost parsing and unlock metadata
# ---------------------------------------------------------------------------


def _parse_serpent_numeric_map(payload: str) -> dict[str, float]:
    """Parse the simple { [\"name\"] = number, ... } tables emitted for tech costs."""
    out: dict[str, float] = {}
    pat = re.compile(r'\["((?:\\.|[^"\\])*)"\]\s*=\s*(' + NUMBER_RE + r')')
    for match in pat.finditer(payload):
        out[_lua_unescape(match.group(1))] = float(match.group(2))
    return out


def parse_tech_cone_costs(path: Path) -> dict[str, dict[str, float]]:
    """Read TECHNOLOGY/name + serpent.dump(costs) records after TECH CONE COSTS."""
    costs: dict[str, dict[str, float]] = {}
    in_section = False
    pending_tech: str | None = None
    with path.open('rb') as fh:
        for raw in fh:
            line = _strip_log_prefix(raw.decode('utf-8', errors='replace'))
            if 'TECH CONE COSTS' in line:
                in_section = True
                pending_tech = None
                continue
            if not in_section:
                continue
            if '__DATA_RAW_BEGIN__' in line:
                break
            if line.startswith('TECHNOLOGY: '):
                pending_tech = line[len('TECHNOLOGY: '):].strip()
                continue
            if pending_tech is not None:
                # serpent.dump() commonly emits `do local _={...};return _;end`,
                # not a line beginning with `{`.  The Lua logger emits exactly one
                # serialized table immediately after each TECHNOLOGY line, so parse
                # that next nonempty line directly.
                if line.strip():
                    costs[pending_tech] = _parse_serpent_numeric_map(line)
                    pending_tech = None
    return costs


def technology_prerequisite_map(
    nodes: dict[str, GraphNode], edges: Sequence[GraphEdge]
) -> dict[str, set[str]]:
    """Return tech -> immediate prerequisite tech names from nonquantitative graph edges."""
    out: dict[str, set[str]] = {}
    for edge in edges:
        src = nodes.get(edge.start)
        dst = nodes.get(edge.stop)
        if src is None or dst is None:
            continue
        if src.node_type == 'technology' and dst.node_type == 'technology':
            if src.name is not None and dst.name is not None:
                out.setdefault(dst.name, set()).add(src.name)
                out.setdefault(src.name, set())
    return out


def _technology_ancestors(
    tech: str,
    prereqs: dict[str, set[str]],
    memo: dict[str, set[str]],
    visiting: set[str],
) -> set[str]:
    if tech in memo:
        return memo[tech]
    if tech in visiting:
        raise RuntimeError(f'Technology prerequisite cycle involving {tech!r}')
    visiting.add(tech)
    result: set[str] = set()
    for pre in prereqs.get(tech, set()):
        result.add(pre)
        result.update(_technology_ancestors(pre, prereqs, memo, visiting))
    visiting.remove(tech)
    memo[tech] = result
    return result


def recover_direct_technology_costs(
    cone_costs: dict[str, dict[str, float]],
    prereqs: dict[str, set[str]],
    tolerance: float = 1e-8,
) -> tuple[dict[str, dict[str, float]], dict[str, set[str]]]:
    """Möbius-invert inclusive ancestor-cone science costs into direct per-tech costs."""
    ancestor_memo: dict[str, set[str]] = {}
    all_ancestors = {
        tech: _technology_ancestors(tech, prereqs, ancestor_memo, set())
        for tech in cone_costs
    }
    # Ancestor count gives a valid topological order because every prerequisite has
    # strictly fewer ancestors in an acyclic graph.
    order = sorted(cone_costs, key=lambda t: (len(all_ancestors[t]), t))
    direct: dict[str, dict[str, float]] = {}
    for tech in order:
        residual = dict(cone_costs.get(tech, {}))
        for anc in all_ancestors[tech]:
            for pack, amount in direct.get(anc, {}).items():
                residual[pack] = residual.get(pack, 0.0) - amount
        cleaned: dict[str, float] = {}
        bad: dict[str, float] = {}
        for pack, amount in residual.items():
            if abs(amount) <= tolerance:
                continue
            if amount < -tolerance:
                bad[pack] = amount
            elif amount > 0.0:
                cleaned[pack] = amount
        if bad:
            raise RuntimeError(
                'TECH CONE COSTS are inconsistent with the technology prerequisite '
                f'graph at {tech!r}; negative recovered direct costs: {bad}. '
                'A common cause is iterating tech.prerequisites as prototype objects; '
                'Factorio stores prerequisite names as strings, so use '
                'data.raw.technology[prereq_name].'
            )
        direct[tech] = cleaned
    return direct, all_ancestors


def unique_recipe_unlock_technologies(
    nodes: dict[str, GraphNode], edges: Sequence[GraphEdge]
) -> tuple[dict[str, str], dict[str, str]]:
    """Find recipes whose recipe-unlock path has exactly one technology producer.

    Any alternative non-technology producer makes the recipe deliberately ungated
    in this relaxation. The returned mapping is recipe name -> technology name.
    """
    incoming: dict[str, list[GraphEdge]] = {}
    for edge in edges:
        incoming.setdefault(edge.stop, []).append(edge)

    recipe_to_tech: dict[str, str] = {}
    skipped: dict[str, str] = {}
    for recipe_key, recipe_node in nodes.items():
        if recipe_node.node_type != 'recipe' or recipe_node.name is None:
            continue
        unlock_sources = [
            edge.start for edge in incoming.get(recipe_key, [])
            if nodes.get(edge.start) is not None
            and nodes[edge.start].node_type == 'recipe-unlock'
        ]
        if not unlock_sources:
            continue  # enabled recipe
        if len(unlock_sources) != 1:
            skipped[recipe_node.name] = f'{len(unlock_sources)} recipe-unlock prerequisites'
            continue

        frontier = [unlock_sources[0]]
        seen: set[str] = set()
        technologies: set[str] = set()
        alternative = False
        while frontier:
            key = frontier.pop()
            if key in seen:
                continue
            seen.add(key)
            for edge in incoming.get(key, []):
                src = nodes.get(edge.start)
                if src is None:
                    continue
                if src.node_type == 'technology' and src.name is not None:
                    technologies.add(src.name)
                elif src.op == 'OR' and src.node_type in {'recipe-unlock', 'recipe-tech-unlock'}:
                    frontier.append(edge.start)
                else:
                    # Script/fixed-recipe/other unlock path: treat recipe as available
                    # from t=0 in the optimistic relaxation.
                    alternative = True

        if not alternative and len(technologies) == 1:
            recipe_to_tech[recipe_node.name] = next(iter(technologies))
        else:
            reason = []
            if alternative:
                reason.append('alternative non-tech unlock')
            if len(technologies) != 1:
                reason.append(f'{len(technologies)} technology producers')
            skipped[recipe_node.name] = ', '.join(reason) or 'ambiguous unlock'
    return recipe_to_tech, skipped


def prune_stage_to_quantitative_goals(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    goal_keys: set[str],
) -> tuple[dict[str, GraphNode], list[GraphEdge], dict[str, Any]]:
    """Union of the quantitative ancestor cones of several material goals."""
    missing = sorted(key for key in goal_keys if key not in nodes)
    if missing:
        raise RuntimeError(f'Quantitative prune goal(s) not in selected stage: {missing[:8]}')
    incoming: dict[str, list[GraphEdge]] = {}
    for edge in edges:
        if not edge.amount_present:
            continue
        incoming.setdefault(edge.stop, []).append(edge)
    needed_nodes: set[str] = set(goal_keys)
    needed_edge_ids: set[int] = set()
    stack = list(goal_keys)
    retained_zero = 0
    while stack:
        stop = stack.pop()
        for edge in incoming.get(stop, []):
            needed_edge_ids.add(id(edge))
            if edge.amount == 0.0:
                retained_zero += 1
                needed_nodes.add(edge.start)
                continue
            if edge.start not in needed_nodes:
                needed_nodes.add(edge.start)
                stack.append(edge.start)
    pruned_nodes = {k: nodes[k] for k in needed_nodes if k in nodes}
    pruned_edges = [edge for edge in edges if id(edge) in needed_edge_ids]
    return pruned_nodes, pruned_edges, {
        'enabled': True,
        'goal_keys': sorted(goal_keys),
        'nodes_before': len(nodes),
        'nodes_after': len(pruned_nodes),
        'edges_before': len(edges),
        'edges_after': len(pruned_edges),
        'nodes_removed': len(nodes) - len(pruned_nodes),
        'edges_removed': len(edges) - len(pruned_edges),
        'retained_zero_markers': retained_zero,
    }


def technology_quantitative_prune_closure(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    primary_goal: str,
    recipe_to_tech_all: dict[str, str],
    direct_costs: dict[str, dict[str, float]],
    all_ancestors: dict[str, set[str]],
) -> tuple[dict[str, GraphNode], list[GraphEdge], set[str], dict[str, Any]]:
    """Add science-pack production cones needed by tech-gated relevant recipes."""
    quantitative_goals: set[str] = {primary_goal}
    modeled_techs: set[str] = set()
    iterations = 0
    final_nodes: dict[str, GraphNode] = {}
    final_edges: list[GraphEdge] = []
    last_meta: dict[str, Any] = {}
    while True:
        iterations += 1
        final_nodes, final_edges, last_meta = prune_stage_to_quantitative_goals(
            nodes, edges, quantitative_goals
        )
        relevant_recipes = {
            node.name for node in final_nodes.values()
            if node.node_type == 'recipe' and node.name is not None
        }
        new_techs = {
            recipe_to_tech_all[r] for r in relevant_recipes
            if r in recipe_to_tech_all
        }
        closure = set(new_techs)
        for tech in list(new_techs):
            closure.update(all_ancestors.get(tech, set()))
        new_goals = set(quantitative_goals)
        for tech in closure:
            for pack in direct_costs.get(tech, {}):
                key = f'item: {pack}'
                if key in nodes:
                    new_goals.add(key)
        if closure <= modeled_techs and new_goals == quantitative_goals:
            modeled_techs.update(closure)
            break
        modeled_techs.update(closure)
        if new_goals == quantitative_goals and closure <= modeled_techs:
            break
        quantitative_goals = new_goals
        if iterations > 20:
            raise RuntimeError('Technology/science quantitative-prune closure did not converge')
    last_meta = dict(last_meta)
    last_meta.update({
        'technology_closure_iterations': iterations,
        'science_goal_count': len(quantitative_goals),
        'modeled_technology_count': len(modeled_techs),
    })
    return final_nodes, final_edges, modeled_techs, last_meta


def mandatory_goal_technology_quantitative_prune(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    primary_goal: str,
    mandatory_techs: set[str],
    direct_costs: dict[str, dict[str, float]],
) -> tuple[dict[str, GraphNode], list[GraphEdge], dict[str, Any]]:
    """Prune to the goal plus science packs needed by its mandatory tech cone.

    Optional technologies are deliberately ignored: their recipes remain optimistically
    available from t=0.  Only the unique unlock technology of the named goal recipe and
    its recursive prerequisite cone are charged.
    """
    quantitative_goals: set[str] = {primary_goal}
    for tech in mandatory_techs:
        for pack in direct_costs.get(tech, {}):
            key = f'item: {pack}'
            if key in nodes:
                quantitative_goals.add(key)
    final_nodes, final_edges, meta = prune_stage_to_quantitative_goals(
        nodes, edges, quantitative_goals
    )
    meta = dict(meta)
    meta.update({
        'science_goal_count': len(quantitative_goals),
        'modeled_technology_count': len(mandatory_techs),
        'technology_scope': 'mandatory unique unlock of named goal recipe plus ancestors',
    })
    return final_nodes, final_edges, meta



def infer_required_named_goal_recipe_runs(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    goal_name: str,
    goal_amount: float,
) -> dict[str, Any]:
    """Prove a minimum execution count for ``recipe: <goal_name>``.

    For the current item/science graph shape we require the quantitative producer
    chain to be uniquely

        recipe: NAME -> item-craft: NAME -> item: NAME.

    If any alternative positive producer exists at either step, refuse rather than
    strengthen the lower-bound relaxation unsafely.
    """
    recipe_key = f'recipe: {goal_name}'
    craft_key = f'item-craft: {goal_name}'
    item_key = f'item: {goal_name}'
    for key in (recipe_key, craft_key, item_key):
        if key not in nodes:
            raise RuntimeError(
                f'Cannot eliminate technology big-M: required goal-chain node {key!r} '
                'is missing from the selected stage.'
            )

    incoming: dict[str, list[GraphEdge]] = {}
    for edge in edges:
        if edge.amount_present and edge.amount != 0.0:
            incoming.setdefault(edge.stop, []).append(edge)

    item_producers = incoming.get(item_key, [])
    if len(item_producers) != 1 or item_producers[0].start != craft_key:
        desc = [(e.start, e.amount) for e in item_producers]
        raise RuntimeError(
            'Cannot eliminate technology big-M rigorously because the goal item does '
            f'not have the unique expected producer {craft_key!r}. Producers: {desc[:12]}'
        )
    craft_to_item = float(item_producers[0].amount)

    craft_producers = incoming.get(craft_key, [])
    if len(craft_producers) != 1 or craft_producers[0].start != recipe_key:
        desc = [(e.start, e.amount) for e in craft_producers]
        raise RuntimeError(
            'Cannot eliminate technology big-M rigorously because the goal item-craft '
            f'node does not have the unique expected producer {recipe_key!r}. '
            f'Producers: {desc[:12]}'
        )
    recipe_to_craft = float(craft_producers[0].amount)

    yield_per_run = recipe_to_craft * craft_to_item
    if not math.isfinite(yield_per_run) or yield_per_run <= 0.0:
        raise RuntimeError(
            f'Invalid inferred yield for {recipe_key!r}: {yield_per_run!r}'
        )
    required_runs = float(goal_amount) / yield_per_run
    return {
        'recipe': goal_name,
        'recipe_key': recipe_key,
        'craft_key': craft_key,
        'item_key': item_key,
        'recipe_to_craft_amount': recipe_to_craft,
        'craft_to_item_amount': craft_to_item,
        'yield_per_run': yield_per_run,
        'required_runs': required_runs,
        'proof_condition': (
            'unique positive quantitative producer chain recipe -> item-craft -> item'
        ),
    }


def augment_with_required_goal_recipe_copy(
    S: csr_matrix,
    C: csr_matrix,
    row_keys: list[str],
    transformed_nodes: dict[str, GraphNode],
    recipe_name: str,
    required_runs: float,
    technology: str,
    tech_info: dict[str, Any],
    requirement_meta: dict[str, Any],
) -> tuple[csr_matrix, csr_matrix, list[str], dict[str, GraphNode], dict[str, Any]]:
    """Duplicate the goal recipe row for the target-required executions.

    The original recipe row remains unrestricted and represents any overproduction.
    The duplicate has q_0 fixed to ``required_runs`` and is the only copy whose
    moments are constrained to occur after the mandatory unlock technology.
    """
    recipe_key = f'recipe: {recipe_name}'
    try:
        source_index = row_keys.index(recipe_key)
    except ValueError as exc:
        raise RuntimeError(
            f'Normalized action matrix has no row for required goal recipe {recipe_key!r}'
        ) from exc

    required_key = f'__pr_graph_lp_required_goal_recipe__: {recipe_name}'
    if required_key in transformed_nodes:
        raise RuntimeError(f'Duplicate required-goal synthetic key {required_key!r}')

    source_row = S.getrow(source_index)
    S2 = vstack([S, source_row], format='csr')
    source_capacity = C.getcol(source_index)
    C2 = hstack([C, source_capacity], format='csr')
    new_rows = list(row_keys) + [required_key]
    new_nodes = dict(transformed_nodes)
    new_nodes[required_key] = GraphNode(
        key=required_key,
        op='AND',
        node_type='required-goal-recipe',
        name=recipe_name,
        synthetic=True,
        source=recipe_key,
        coproduct=transformed_nodes[recipe_key].coproduct,
    )
    info = dict(tech_info)
    info['recipe_constraints'] = []
    info['required_goal_recipe'] = {
        'action_index': len(row_keys),
        'source_action_index': source_index,
        'recipe': recipe_name,
        'technology': technology,
        'required_runs': float(required_runs),
        **requirement_meta,
    }
    return S2, C2, new_rows, new_nodes, info


def augment_matrices_with_technology_research(
    S: csr_matrix,
    C: csr_matrix,
    row_keys: list[str],
    col_keys: list[str],
    transformed_nodes: dict[str, GraphNode],
    modeled_techs: set[str],
    direct_costs: dict[str, dict[str, float]],
    prereqs: dict[str, set[str]],
    recipe_to_tech: dict[str, str],
) -> tuple[csr_matrix, csr_matrix, list[str], dict[str, GraphNode], dict[str, Any]]:
    """Append one full research action per mandatory modeled technology."""
    col_index = {key: i for i, key in enumerate(col_keys)}
    ordered_techs = sorted(modeled_techs)
    rr: list[int] = []
    cc: list[int] = []
    vv: list[float] = []
    missing_pack_costs: list[dict[str, Any]] = []
    for ti, tech in enumerate(ordered_techs):
        for pack, amount in direct_costs.get(tech, {}).items():
            key = f'item: {pack}'
            j = col_index.get(key)
            if j is None:
                missing_pack_costs.append({'technology': tech, 'pack': pack, 'amount': amount})
                continue
            rr.append(ti); cc.append(j); vv.append(-float(amount))
    if missing_pack_costs:
        raise RuntimeError(
            'Technology science-pack material coordinates are missing after pruning: '
            + json.dumps(missing_pack_costs[:10])
        )
    tech_rows = coo_matrix(
        (vv, (rr, cc)), shape=(len(ordered_techs), len(col_keys)), dtype=float
    ).tocsr()
    S2 = vstack([S, tech_rows], format='csr') if ordered_techs else S
    if ordered_techs:
        C2 = hstack(
            [C, csr_matrix((C.shape[0], len(ordered_techs)), dtype=float)],
            format='csr',
        )
    else:
        C2 = C
    new_rows = list(row_keys)
    new_nodes = dict(transformed_nodes)
    tech_action_index: dict[str, int] = {}
    for tech in ordered_techs:
        key = f'__pr_graph_lp_technology_research__: {tech}'
        tech_action_index[tech] = len(new_rows)
        new_rows.append(key)
        new_nodes[key] = GraphNode(
            key=key, op='AND', node_type='technology-research', name=tech,
            synthetic=True, source='TECH CONE COSTS/direct-cost inversion'
        )
    row_index = {key: i for i, key in enumerate(new_rows)}
    recipe_constraints: list[tuple[int, str, str]] = []
    for recipe, tech in sorted(recipe_to_tech.items()):
        if tech not in modeled_techs:
            continue
        key = f'recipe: {recipe}'
        if key in row_index:
            recipe_constraints.append((row_index[key], recipe, tech))
    prereq_pairs = sorted(
        (tech, pre)
        for tech in ordered_techs
        for pre in prereqs.get(tech, set())
        if pre in modeled_techs
    )
    info = {
        'technology_names': ordered_techs,
        'technology_action_index': tech_action_index,
        'recipe_constraints': recipe_constraints,
        'prerequisite_pairs': prereq_pairs,
        'direct_costs': {tech: direct_costs.get(tech, {}) for tech in ordered_techs},
    }
    return S2, C2, new_rows, new_nodes, info

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


def prune_stage_to_goal_quantitative(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
    goal_key: str,
) -> tuple[dict[str, GraphNode], list[GraphEdge], dict[str, Any]]:
    """Keep only quantitative ancestors that can affect ``goal_key``.

    Missing-amount edges are ignored because the growth LP ignores them too.
    Explicit amount=0 edges are free-availability markers: retain the marker and
    its source node when its destination is needed, but do not recurse through
    that source because it is not a quantitative prerequisite.

    This pruning is exact for the quantitative LP objective: any action/material
    with no directed quantitative path into the goal cannot improve the goal or
    relax a constraint on a goal-relevant path.
    """
    if goal_key not in nodes:
        raise RuntimeError(f"Goal {goal_key!r} is not present in the selected stage graph")

    incoming: dict[str, list[GraphEdge]] = {}
    for edge in edges:
        if not edge.amount_present:
            continue
        incoming.setdefault(edge.stop, []).append(edge)

    needed_nodes: set[str] = {goal_key}
    needed_edge_ids: set[int] = set()
    stack = [goal_key]
    traversed_nonzero_edges = 0
    retained_zero_markers = 0

    while stack:
        stop = stack.pop()
        for edge in incoming.get(stop, []):
            needed_edge_ids.add(id(edge))
            if edge.amount == 0.0:
                retained_zero_markers += 1
                # The source is metadata for free availability, not a paid
                # prerequisite. Keep it only so the edge remains well-formed.
                needed_nodes.add(edge.start)
                continue
            traversed_nonzero_edges += 1
            if edge.start not in needed_nodes:
                needed_nodes.add(edge.start)
                stack.append(edge.start)

    pruned_nodes = {k: nodes[k] for k in needed_nodes if k in nodes}
    pruned_edges = [edge for edge in edges if id(edge) in needed_edge_ids]
    return pruned_nodes, pruned_edges, {
        "enabled": True,
        "goal_key": goal_key,
        "nodes_before": len(nodes),
        "nodes_after": len(pruned_nodes),
        "edges_before": len(edges),
        "edges_after": len(pruned_edges),
        "nodes_removed": len(nodes) - len(pruned_nodes),
        "edges_removed": len(edges) - len(pruned_edges),
        "traversed_nonzero_edges": traversed_nonzero_edges,
        "retained_zero_markers": retained_zero_markers,
    }


def _synthetic_key(kind: str, source: str) -> str:
    return f"__pr_graph_lp_{kind}__: {source}"



def subdivide_used_payback_same_op_edges(
    nodes: dict[str, GraphNode],
    edges: Sequence[GraphEdge],
) -> tuple[dict[str, GraphNode], list[GraphEdge], dict[str, Any]]:
    """Subdivide used_payback OR->OR edges before capacity extraction.

    A used_payback edge conceptually means "using this persistent OR/material
    enables some action for an amount of time".  Most such edges are already
    OR->AND (for example entity -> entity-operate), but Py module requirements
    are represented as OR alternatives:

        item: module  --amount, used_payback-->  entity-operate-py-module (OR)

    Capacity accounting needs an actual action column, so turn that into

        item: module --amount, used_payback--> route(AND) --1--> module-choice(OR)

    The first leg is later removed from ordinary material flow and placed in the
    capacity matrix C; the second leg remains ordinary flow.  This is the same
    OR->AND->OR subdivision that make_bipartite would otherwise perform, but it
    must happen *before* split_used_payback_capacity_edges so the capacity use
    has an action coordinate to attach to.
    """
    out_nodes = dict(nodes)
    out_edges: list[GraphEdge] = []
    subdivided = 0
    sample: list[dict[str, Any]] = []

    for ordinal, edge in enumerate(edges):
        if edge.used_payback is None:
            out_edges.append(edge)
            continue

        src = out_nodes.get(edge.start)
        dst = out_nodes.get(edge.stop)
        if src is None or dst is None:
            raise RuntimeError(
                f"used_payback edge {edge.key!r} references a missing node"
            )

        if src.op == "OR" and dst.op == "AND":
            out_edges.append(edge)
            continue

        if src.op == "OR" and dst.op == "OR":
            mid = _synthetic_key(
                "used_payback_or_to_or_and",
                f"{ordinal}:{edge.key}",
            )
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
                coproduct=False,
                coproduct_present=False,
                synthetic=True,
                source=edge.source or edge.key,
            )

            # Preserve used_payback only on the consuming leg.  The output leg
            # is ordinary flow: one execution of the route produces one unit of
            # the destination OR alternative.
            out_edges.append(
                GraphEdge(
                    key=f"{edge.key}:capacity",
                    start=edge.start,
                    stop=mid,
                    amount=edge.amount,
                    amount_present=edge.amount_present,
                    synthetic=True,
                    source=edge.source or edge.key,
                    slot_additional_cost=0.0,
                    slot_cost_present=False,
                    used_payback=edge.used_payback,
                )
            )
            out_edges.append(
                GraphEdge(
                    key=f"{edge.key}:output",
                    start=mid,
                    stop=edge.stop,
                    amount=1.0,
                    amount_present=True,
                    synthetic=True,
                    source=edge.source or edge.key,
                    slot_additional_cost=edge.slot_additional_cost,
                    slot_cost_present=edge.slot_cost_present,
                    used_payback=None,
                )
            )
            subdivided += 1
            if len(sample) < 12:
                sample.append({
                    "original_edge_key": edge.key,
                    "start": edge.start,
                    "stop": edge.stop,
                    "synthetic_action_key": mid,
                    "stored_amount": float(edge.amount),
                    "used_payback": float(edge.used_payback),
                })
            continue

        raise RuntimeError(
            f"used_payback edge {edge.key!r} must start at an OR/material and "
            f"end at OR or AND; got {src.op}->{dst.op} "
            f"({edge.start!r}->{edge.stop!r})"
        )

    return out_nodes, out_edges, {
        "used_payback_or_or_subdivided": subdivided,
        "sample": sample,
    }


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
    reify_cost_or_nodes: bool = True,
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

    cost_or_nodes = (
        {
            key for key, node in nodes.items()
            if node.op == "OR" and (node.cost_present or node.slot_cost_present)
        }
        if reify_cost_or_nodes
        else set()
    )

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
        "cost_or_reification_enabled": bool(reify_cost_or_nodes),
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


def _format_elapsed(seconds: float) -> str:
    seconds = max(0.0, float(seconds))
    if seconds < 60.0:
        return f"{seconds:.1f}s"
    minutes, sec = divmod(seconds, 60.0)
    if minutes < 60:
        return f"{int(minutes)}m {sec:04.1f}s"
    hours, minute = divmod(int(minutes), 60)
    return f"{hours}h {minute:02d}m"


def _linprog_with_heartbeat(
    *,
    c: np.ndarray,
    A_ub: csr_matrix,
    b_ub: np.ndarray,
    method: str,
    solver_options: dict[str, Any],
    heartbeat_seconds: float,
    label: str,
    bounds: Any = (0.0, None),
) -> tuple[Any, float]:
    """Run SciPy/HiGHS while periodically proving to the user it is alive."""
    kwargs = dict(
        c=c,
        A_ub=A_ub,
        b_ub=b_ub,
        bounds=bounds,
        method=method,
        options=solver_options or None,
    )
    start = time.perf_counter()
    if heartbeat_seconds <= 0.0:
        result = linprog(**kwargs)
        return result, time.perf_counter() - start

    with ThreadPoolExecutor(max_workers=1, thread_name_prefix="highs") as pool:
        future = pool.submit(linprog, **kwargs)
        while True:
            try:
                result = future.result(timeout=heartbeat_seconds)
                return result, time.perf_counter() - start
            except FutureTimeoutError:
                elapsed = time.perf_counter() - start
                print(
                    f"{label}: still solving; elapsed {_format_elapsed(elapsed)}",
                    flush=True,
                )



def _sparse_abs_range(A: csr_matrix) -> tuple[float | None, float | None]:
    """Return min/max positive absolute stored coefficient, ignoring structural zeros."""
    if A.nnz == 0:
        return None, None
    vals = np.abs(A.data)
    vals = vals[vals > 0.0]
    if vals.size == 0:
        return None, None
    return float(np.min(vals)), float(np.max(vals))


def _max_abs_by_axis(A: csr_matrix, axis: int) -> np.ndarray:
    """Sparse max(abs(A), axis), returned as a dense 1-D vector."""
    if A.shape[axis] == 0:
        return np.zeros(0, dtype=float)
    # scipy sparse max returns a sparse matrix on some versions and a matrix on others.
    m = abs(A).max(axis=axis)
    if hasattr(m, 'toarray'):
        arr = np.asarray(m.toarray(), dtype=float)
    else:
        arr = np.asarray(m, dtype=float)
    return arr.reshape(-1)


def _scale_lp_rows_and_columns(
    A: csr_matrix,
    b: np.ndarray,
    c: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    mode: str,
) -> tuple[csr_matrix, np.ndarray, np.ndarray, list[tuple[float | None, float | None]], np.ndarray, np.ndarray, dict[str, Any]]:
    """Apply an explicit positive diagonal scaling without changing LP feasibility.

    We solve in variables y = D z.  Row scaling R then gives

        R A D z <= R b.

    This is mathematically equivalent to A y <= b.  The returned ``column_scale``
    is diag(D), so the original solution is recovered as y = column_scale * z.

    The strategy is intentionally conservative:
      1. scale every inequality row so max(|row coefficients|, |rhs|) is 1;
      2. column-equilibrate only columns that are still far from unit scale;
      3. row-scale once more after the column change.

    Because the moment-monotonicity constraints already put unit coefficients in
    most q columns, step 2 usually changes relatively few variables while step 1
    removes the enormous differences between e.g. joules, fluids, items, and
    normalized timing constraints.
    """
    mode = str(mode)
    if mode not in {'none', 'row', 'row-column'}:
        raise ValueError(f'Unknown lp_scaling mode {mode!r}')

    A0 = A.tocsr()
    b0 = np.asarray(b, dtype=float).copy()
    c0 = np.asarray(c, dtype=float).copy()
    nrows, ncols = A0.shape
    row_scale_total = np.ones(nrows, dtype=float)
    col_scale_total = np.ones(ncols, dtype=float)
    As = A0.copy()
    bs = b0.copy()
    cs = c0.copy()

    before_min, before_max = _sparse_abs_range(As)

    def do_row_scale() -> None:
        nonlocal As, bs, row_scale_total
        row_max = _max_abs_by_axis(As, axis=1)
        denom = np.maximum(row_max, np.abs(bs))
        factors = np.ones_like(denom)
        mask = np.isfinite(denom) & (denom > 0.0)
        factors[mask] = 1.0 / denom[mask]
        # Avoid creating absurd scaling factors for pathological near-zero rows.
        factors = np.clip(factors, 1e-12, 1e12)
        As = (diags(factors, format='csr') @ As).tocsr()
        bs *= factors
        row_scale_total *= factors

    if mode in {'row', 'row-column'}:
        do_row_scale()

    if mode == 'row-column':
        col_max = _max_abs_by_axis(As, axis=0)
        # Include objective coefficients so maximize-mode objective scaling is not ignored.
        if cs.size:
            col_max = np.maximum(col_max, np.abs(cs))
        factors = np.ones(ncols, dtype=float)
        # Only touch columns whose scale is materially poor after row normalization.
        small = (col_max > 0.0) & (col_max < 1e-2)
        large = col_max > 1e2
        factors[small | large] = 1.0 / col_max[small | large]
        factors = np.clip(factors, 1e-8, 1e8)

        # Keep finite upper-bounded variables from acquiring extreme scaled bounds.
        # h variables and mandatory-tech q0 variables generally have bounds around 1,
        # and there is little benefit in rescaling such columns after row normalization.
        for j, (lo, hi) in enumerate(bounds):
            finite_mag = 0.0
            if lo is not None and math.isfinite(lo):
                finite_mag = max(finite_mag, abs(float(lo)))
            if hi is not None and math.isfinite(hi):
                finite_mag = max(finite_mag, abs(float(hi)))
            if finite_mag > 0.0:
                proposed_scaled_mag = finite_mag / factors[j]
                if proposed_scaled_mag > 1e6 or proposed_scaled_mag < 1e-6:
                    factors[j] = 1.0

        As = (As @ diags(factors, format='csr')).tocsr()
        cs *= factors
        col_scale_total *= factors
        # Column equilibration perturbs row maxima, so normalize the rows once more.
        do_row_scale()

    scaled_bounds: list[tuple[float | None, float | None]] = []
    for j, (lo, hi) in enumerate(bounds):
        sj = float(col_scale_total[j])
        slo = None if lo is None else float(lo) / sj
        shi = None if hi is None else float(hi) / sj
        scaled_bounds.append((slo, shi))

    after_min, after_max = _sparse_abs_range(As)
    nontrivial_rows = int(np.count_nonzero(np.abs(row_scale_total - 1.0) > 1e-12))
    nontrivial_cols = int(np.count_nonzero(np.abs(col_scale_total - 1.0) > 1e-12))
    meta = {
        'mode': mode,
        'matrix_abs_coefficient_range_before': [before_min, before_max],
        'matrix_abs_coefficient_range_after': [after_min, after_max],
        'nontrivially_scaled_rows': nontrivial_rows,
        'nontrivially_scaled_columns': nontrivial_cols,
        'row_scale_min': float(np.min(row_scale_total)) if row_scale_total.size else 1.0,
        'row_scale_max': float(np.max(row_scale_total)) if row_scale_total.size else 1.0,
        'column_scale_min': float(np.min(col_scale_total)) if col_scale_total.size else 1.0,
        'column_scale_max': float(np.max(col_scale_total)) if col_scale_total.size else 1.0,
        'solution_recovery': 'original_y = column_scale * solver_z',
    }
    return As, bs, cs, scaled_bounds, row_scale_total, col_scale_total, meta


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
    solve_mode: str,
    goal_amount: float,
    heartbeat_seconds: float,
    solver_log: bool,
    solver_time_limit: float | None,
    lp_scaling: str = "row-column",
    tech_info: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Solve the K-moment optimistic continuous-time production relaxation.

    If ``tech_info`` is supplied, every modeled technology belongs to the
    mandatory unlock cone of the named goal recipe and is forced to be fully
    researched. Completion-moment variables h[T,k] represent
    ((delta-t_unlock)/delta)^k in real schedules.

    v10 eliminates big-M entirely and explicitly equilibrates the final LP before HiGHS. The goal recipe is split into a required copy
    with known total amount R = goal_amount / proven_yield_per_run and an
    unrestricted extra copy (the original recipe row). Only the required copy is
    technology-timed, using the linear inequalities

        q_required,k <= R h[T,k].

    Any overproduction is allowed through the original untimed row, so this is
    still an optimistic relaxation of every real schedule.
    """
    if moment_order < 1:
        raise ValueError('moment_order must be >= 1')
    if S.shape != (len(row_keys), len(col_keys)):
        raise RuntimeError('Matrix/key dimensions are inconsistent')
    if C.shape != (len(col_keys), len(row_keys)):
        raise RuntimeError('Capacity matrix/key dimensions are inconsistent')
    if S.data.size and not np.all(np.isfinite(S.data)):
        raise RuntimeError('Amount matrix contains non-finite coefficients')
    if C.data.size and (not np.all(np.isfinite(C.data)) or np.any(C.data < 0.0)):
        raise RuntimeError('Capacity matrix contains invalid coefficients')

    tech_info = tech_info or {
        'technology_names': [], 'technology_action_index': {},
        'recipe_constraints': [], 'prerequisite_pairs': [], 'direct_costs': {},
    }
    tech_names: list[str] = list(tech_info.get('technology_names', []))
    tech_action_index: dict[str, int] = dict(tech_info.get('technology_action_index', {}))
    recipe_constraints: list[tuple[int, str, str]] = list(tech_info.get('recipe_constraints', []))
    required_goal_recipe: dict[str, Any] | None = tech_info.get('required_goal_recipe')
    prerequisite_pairs: list[tuple[str, str]] = list(tech_info.get('prerequisite_pairs', []))
    n_tech = len(tech_names)
    tech_pos = {tech: i for i, tech in enumerate(tech_names)}

    col_index = {key: i for i, key in enumerate(col_keys)}
    if goal_key not in col_index:
        raise RuntimeError(f'Goal material {goal_key!r} is not an OR/material coordinate in this stage')
    if character_key not in col_index:
        raise RuntimeError(f'Character material {character_key!r} is not an OR/material coordinate in this stage')

    n_materials = len(col_keys)
    n_actions = len(row_keys)
    blocks = moment_order + 1
    q_total_vars = blocks * n_actions
    h_total_vars = moment_order * n_tech
    total_vars = q_total_vars + h_total_vars

    def h_index(tech: str, k: int) -> int:
        if k < 1 or k > moment_order:
            raise IndexError(k)
        return q_total_vars + tech_pos[tech] * moment_order + (k - 1)

    x0 = np.zeros(n_materials, dtype=float)
    character_index = col_index[character_key]
    goal_index = col_index[goal_key]
    x0[character_index] = 1.0
    N = S.T.tocsr()

    infinite_indices = {
        col_index[key] for key in infinite_keys if key in col_index and key != character_key
    }
    finite_indices = np.asarray(
        [i for i in range(n_materials) if i not in infinite_indices], dtype=np.int64
    )
    capacity_row_mask = np.asarray(C.getnnz(axis=1)).reshape(-1) > 0
    finite_capacity_indices = np.asarray(
        [i for i in finite_indices if capacity_row_mask[int(i)]], dtype=np.int64
    )

    def block_row_q(nrows: int, placements: dict[int, csr_matrix]) -> csr_matrix:
        pieces = []
        for block in range(blocks):
            mat = placements.get(block)
            if mat is None:
                mat = csr_matrix((nrows, n_actions), dtype=float)
            pieces.append(mat)
        return hstack(pieces, format='csr')

    def extend_q(mat_q: csr_matrix) -> csr_matrix:
        if h_total_vars == 0:
            return mat_q
        return hstack([mat_q, csr_matrix((mat_q.shape[0], h_total_vars))], format='csr')

    constraint_mats: list[csr_matrix] = []
    constraint_rhs: list[np.ndarray] = []
    constraint_groups: list[dict[str, Any]] = []

    def add_group(name: str, mat: csr_matrix, rhs: np.ndarray, **meta: Any) -> None:
        start = sum(x.shape[0] for x in constraint_mats)
        constraint_mats.append(mat)
        constraint_rhs.append(np.asarray(rhs, dtype=float))
        constraint_groups.append({
            'name': name, 'row_start': start,
            'row_stop_exclusive': start + mat.shape[0], **meta,
        })

    def add_sparse_rows(name: str, rows: list[dict[int, float]], rhs: list[float], **meta: Any) -> None:
        if not rows:
            return
        rr: list[int] = []
        cc: list[int] = []
        vv: list[float] = []
        for i, row in enumerate(rows):
            for j, value in row.items():
                if value != 0.0:
                    rr.append(i); cc.append(j); vv.append(float(value))
        mat = coo_matrix((vv, (rr, cc)), shape=(len(rows), total_vars), dtype=float).tocsr()
        add_group(name, mat, np.asarray(rhs, dtype=float), **meta)

    Nf = N[finite_indices, :].tocsr()
    x0f = x0[finite_indices]
    add_group(
        'endpoint_inventory',
        extend_q(block_row_q(len(finite_indices), {0: -Nf})),
        x0f, moment=0,
    )

    eye_actions = eye(n_actions, format='csr', dtype=float)
    for k in range(moment_order):
        add_group(
            f'moment_monotonicity_{k+1}',
            extend_q(block_row_q(n_actions, {k: -eye_actions, k + 1: eye_actions})),
            np.zeros(n_actions), lower_moment=k, upper_moment=k + 1,
        )
        add_group(
            f'inventory_moment_{k+1}',
            extend_q(block_row_q(len(finite_indices), {k + 1: -Nf})),
            x0f, moment=k + 1,
        )
        if finite_capacity_indices.size:
            Cc = C[finite_capacity_indices, :].tocsr()
            Nc = N[finite_capacity_indices, :].tocsr()
            x0c = x0[finite_capacity_indices]
            add_group(
                f'capacity_moment_{k}',
                extend_q(block_row_q(
                    len(finite_capacity_indices),
                    {k: ((k + 1.0) / time_seconds) * Cc, k + 1: -Nc},
                )),
                x0c, capacity_moment=k, inventory_moment=k + 1,
                coefficient_factor=(k + 1.0) / time_seconds,
            )

    # Bounds for the q variables and technology-completion moments.
    bounds: list[tuple[float, float | None]] = [(0.0, None)] * total_vars
    for tech in tech_names:
        ai = tech_action_index[tech]
        # Every modeled technology is in the mandatory prerequisite cone of the
        # named goal recipe, so its complete science cost must be paid exactly once.
        bounds[ai] = (1.0, 1.0)
    for tech in tech_names:
        for k in range(1, moment_order + 1):
            bounds[h_index(tech, k)] = (0.0, 1.0)

    # No big-M pre-solve in v10.  The required goal-recipe copy has a known
    # zeroth moment R, so its timing moments can be scaled directly by R.
    if recipe_constraints:
        raise RuntimeError(
            'Internal v10 error: generic recipe_constraints should be empty; '
            'technology timing must use required_goal_recipe instead.'
        )
    if required_goal_recipe is not None:
        req_idx = int(required_goal_recipe['action_index'])
        req_runs = float(required_goal_recipe['required_runs'])
        req_tech = str(required_goal_recipe['technology'])
        if req_tech not in tech_pos:
            raise RuntimeError(
                f'Required goal recipe technology {req_tech!r} is not modeled'
            )
        if not math.isfinite(req_runs) or req_runs <= 0.0:
            raise RuntimeError(f'Invalid required goal recipe amount {req_runs!r}')
        bounds[req_idx] = (req_runs, req_runs)

    # Technology completion moment constraints.
    if tech_names:
        rows: list[dict[int, float]] = []
        rhs: list[float] = []
        # h_1 <= y, h_{k+1} <= h_k; and completion cannot precede
        # completion of the technology's own direct research expenditure.
        for tech in tech_names:
            ai = tech_action_index[tech]
            rows.append({h_index(tech, 1): 1.0, ai: -1.0}); rhs.append(0.0)
            for k in range(2, moment_order + 1):
                rows.append({h_index(tech, k): 1.0, h_index(tech, k-1): -1.0}); rhs.append(0.0)
            for k in range(1, moment_order + 1):
                # h[T,k] <= q_T,k : all direct research is at or before completion.
                rows.append({h_index(tech, k): 1.0, k * n_actions + ai: -1.0}); rhs.append(0.0)
        add_sparse_rows('technology_completion_moments', rows, rhs)

        # Prerequisite activation/completion and direct-research ordering.
        rows = []; rhs = []
        for tech, pre in prerequisite_pairs:
            ai_t = tech_action_index[tech]
            ai_p = tech_action_index[pre]
            rows.append({ai_t: 1.0, ai_p: -1.0}); rhs.append(0.0)  # y_T <= y_P
            for k in range(1, moment_order + 1):
                rows.append({h_index(tech, k): 1.0, h_index(pre, k): -1.0}); rhs.append(0.0)
                # Research of T itself happens only after P has completed.
                rows.append({k * n_actions + ai_t: 1.0, h_index(pre, k): -1.0}); rhs.append(0.0)
        add_sparse_rows('technology_prerequisite_timing', rows, rhs)

        if required_goal_recipe is not None:
            r = int(required_goal_recipe['action_index'])
            tech = str(required_goal_recipe['technology'])
            R = float(required_goal_recipe['required_runs'])
            rows = []; rhs = []
            for k in range(1, moment_order + 1):
                rows.append({k * n_actions + r: 1.0, h_index(tech, k): -R}); rhs.append(0.0)
            add_sparse_rows(
                'required_goal_recipe_after_mandatory_unlock', rows, rhs,
                required_recipe_runs=R, technology=tech,
                formulation='q_required,k <= R * h[technology,k]; no big-M',
            )

    goal_coeff = np.asarray(N.getrow(goal_index).toarray(), dtype=float).reshape(-1)
    if solve_mode == 'feasibility':
        row = {i: -float(v) for i, v in enumerate(goal_coeff) if v != 0.0}
        add_sparse_rows(
            'goal_attainability', [row], [float(x0[goal_index] - goal_amount)],
            requested_goal_amount=float(goal_amount),
        )
    elif solve_mode != 'maximize':
        raise ValueError(f'Unknown solve_mode {solve_mode!r}')

    A_ub = vstack(constraint_mats, format='csr')
    b_ub = np.concatenate(constraint_rhs) if constraint_rhs else np.zeros(0)
    c = np.zeros(total_vars, dtype=float)
    if solve_mode == 'maximize':
        c[:n_actions] = -goal_coeff

    A_solve, b_solve, c_solve, bounds_solve, row_scale, column_scale, scaling_meta = (
        _scale_lp_rows_and_columns(A_ub, b_ub, c, bounds, lp_scaling)
    )
    bef = scaling_meta['matrix_abs_coefficient_range_before']
    aft = scaling_meta['matrix_abs_coefficient_range_after']
    print(
        f"LP scaling={lp_scaling}: |A| nonzero range "
        f"[{bef[0]:.3g}, {bef[1]:.3g}] -> [{aft[0]:.3g}, {aft[1]:.3g}]; "
        f"scaled rows={scaling_meta['nontrivially_scaled_rows']:,}, "
        f"columns={scaling_meta['nontrivially_scaled_columns']:,}",
        flush=True,
    )

    solver_options: dict[str, Any] = {'disp': bool(solver_log)}
    if solver_time_limit is not None:
        solver_options['time_limit'] = float(solver_time_limit)
    print(
        f'Starting HiGHS ({method}, mode={solve_mode}): variables={total_vars:,}, '
        f'inequalities={A_solve.shape[0]:,}, A_ub nnz={A_solve.nnz:,}', flush=True,
    )
    result, solve_elapsed = _linprog_with_heartbeat(
        c=c_solve, A_ub=A_solve, b_ub=b_solve, method=method,
        solver_options=solver_options, heartbeat_seconds=heartbeat_seconds,
        label='HiGHS', bounds=bounds_solve,
    )
    print(f'HiGHS finished after {_format_elapsed(solve_elapsed)}: {result.message}', flush=True)

    status_map = {0:'optimal',1:'iteration_or_time_limit',2:'infeasible',3:'unbounded',4:'numerical_difficulty'}
    status = status_map.get(int(result.status), f'status_{result.status}')
    output: dict[str, Any] = {
        'status': status, 'solver_status_code': int(result.status),
        'solver_message': str(result.message), 'num_actions': n_actions,
        'num_materials': n_materials, 'num_variables': total_vars,
        'num_inequalities': int(A_ub.shape[0]), 'constraint_matrix_nnz': int(A_ub.nnz),
        'solve_mode': solve_mode, 'solve_elapsed_seconds': float(solve_elapsed),
        'method': method, 'num_finite_material_constraints': int(finite_indices.size),
        'num_capacity_resources': int(np.count_nonzero(capacity_row_mask)),
        'num_finite_capacity_resources': int(finite_capacity_indices.size),
        'capacity_matrix_nnz': int(C.nnz), 'moment_order': int(moment_order),
        'goal_key': goal_key, 'character_key': character_key,
        'constraint_groups': constraint_groups,
        'lp_scaling': scaling_meta,
        'technology_relaxation': {
            'enabled': bool(tech_names), 'technology_count': n_tech,
            'gated_recipe_count': 1 if required_goal_recipe is not None else 0,
            'big_m': None,
            'required_goal_recipe': required_goal_recipe,
            'interpretation': (
                'Only the unique unlock technology of the named goal recipe and its '
                'recursive prerequisite cone are modeled. Those technologies are forced '
                'to be fully researched (q0=1), so their direct science costs are paid '
                'exactly once. Optional technologies are left free/ungated, which is an '
                'optimistic relaxation and preserves lower-bound validity. Goal-recipe timing uses a fixed required-copy amount, so no big-M pre-solve is needed.'
            ) if tech_names else None,
        },
    }
    if result.status != 0:
        return output

    y = column_scale * np.asarray(result.x, dtype=float)
    moments = [y[k*n_actions:(k+1)*n_actions] for k in range(blocks)]
    z = moments[0]
    final_inventory = x0 + np.asarray(N @ z, dtype=float).reshape(-1)
    goal_final = float(final_inventory[goal_index])
    min_finite_final = float(np.min(final_inventory[finite_indices])) if finite_indices.size else math.inf

    active_actions: list[dict[str, Any]] = []
    for i, amount in enumerate(z):
        if amount <= active_eps:
            continue
        key = row_keys[i]
        node = transformed_nodes[key]
        item: dict[str, Any] = {
            'action_key': key, 'total_amount': float(amount),
            'node_type': node.node_type, 'name': node.name,
            'synthetic': bool(node.synthetic), 'source': node.source,
            'coproduct': bool(node.coproduct),
            'normalized_moments': [float(m[i]) for m in moments],
        }
        frac = float(moments[1][i] / amount) if moment_order >= 1 and amount > 0 else 0.0
        frac = min(1.0, max(0.0, frac))
        item['remaining_fraction_moment_1'] = frac
        item['mean_time_seconds'] = float(time_seconds * (1.0 - frac))
        active_actions.append(item)
    active_actions.sort(key=lambda item: item['total_amount'], reverse=True)

    positive_final: list[dict[str, Any]] = []
    depleted_final: list[dict[str, Any]] = []
    for i in finite_indices:
        value = float(final_inventory[int(i)])
        key = col_keys[int(i)]
        if value > active_eps or key in {goal_key, character_key}:
            positive_final.append({'material_key': key, 'final_amount': value})
        if value <= active_eps:
            depleted_final.append({'material_key': key, 'final_amount': value})
    positive_final.sort(key=lambda item: item['final_amount'], reverse=True)

    capacity_diagnostics: list[dict[str, Any]] = []
    for j in finite_capacity_indices:
        jj = int(j)
        total_usage_fraction = float((C.getrow(jj) @ z)[0] / time_seconds)
        average_available = float(x0[jj] + (N.getrow(jj) @ moments[1])[0])
        capacity_diagnostics.append({
            'material_key': col_keys[jj],
            'normalized_total_capacity_usage': total_usage_fraction,
            'normalized_average_available': average_available,
            'moment_0_slack': average_available - total_usage_fraction,
        })
    capacity_diagnostics.sort(key=lambda item: item['normalized_total_capacity_usage'], reverse=True)

    tech_diagnostics: list[dict[str, Any]] = []
    for tech in tech_names:
        ai = tech_action_index[tech]
        activation = float(z[ai])
        item = {
            'technology': tech,
            'fractional_activation': activation,
            'direct_science_costs': tech_info.get('direct_costs', {}).get(tech, {}),
            'research_moments': [float(m[ai]) for m in moments],
            'completion_moments': [float(y[h_index(tech,k)]) for k in range(1, moment_order+1)],
        }
        if activation > active_eps:
            s1 = float(y[h_index(tech,1)] / activation)
            s1 = min(1.0, max(0.0, s1))
            item['relaxed_completion_time_proxy_seconds'] = float(time_seconds * (1.0 - s1))
        tech_diagnostics.append(item)
    tech_diagnostics.sort(key=lambda item: item['fractional_activation'], reverse=True)

    output.update({
        'objective_goal_final_amount': goal_final,
        'objective_goal_net_production': float(goal_final - x0[goal_index]),
        'character_final_amount': float(final_inventory[character_index]),
        'minimum_finite_final_inventory': min_finite_final,
        'active_action_count': len(active_actions), 'active_actions': active_actions,
        'positive_finite_final_inventory': positive_final,
        'depleted_finite_materials': depleted_final,
        'total_action_l1': float(np.sum(z)),
        'capacity_diagnostics': capacity_diagnostics,
        'technology_diagnostics': tech_diagnostics,
    })
    if character_index in set(int(i) for i in finite_capacity_indices):
        char_usage = float((C.getrow(character_index) @ z)[0] / time_seconds)
        char_available = float(x0[character_index] + (N.getrow(character_index) @ moments[1])[0])
        output['character_capacity'] = {
            'normalized_total_usage': char_usage,
            'normalized_average_available': char_available,
            'moment_0_slack': char_available - char_usage,
            'seconds_used': char_usage * time_seconds,
            'seconds_available_if_no_character_production': time_seconds,
        }

    ineqlin = getattr(result, 'ineqlin', None)
    if ineqlin is not None and getattr(ineqlin, 'marginals', None) is not None:
        # Convert marginals from the row-scaled LP back to the original
        # inequality normalization: lambda_original = R * lambda_scaled.
        marginals = row_scale * np.asarray(ineqlin.marginals, dtype=float)
        group_duals = []
        for group in constraint_groups:
            lo = int(group['row_start']); hi = int(group['row_stop_exclusive'])
            values = marginals[lo:hi]
            max_abs = float(np.max(np.abs(values))) if values.size else 0.0
            if max_abs > active_eps:
                group_duals.append({'name': group['name'], 'max_abs_minimization_marginal': max_abs})
        output['active_constraint_group_duals'] = group_duals

    output['_lp_internal'] = {
        'A_ub': A_ub, 'b_ub': b_ub, 'objective': c,
        'A_ub_scaled': A_solve, 'b_ub_scaled': b_solve, 'objective_scaled': c_solve,
        'row_scale': row_scale, 'column_scale': column_scale,
        'finite_indices': finite_indices,
        'finite_capacity_indices': finite_capacity_indices,
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
        "--solve-mode",
        choices=["maximize", "feasibility"],
        default="maximize",
        help=(
            "maximize computes the exact relaxed maximum (default). feasibility "
            "only asks whether --goal-amount is reachable and is often much faster "
            "for lower-bound checks."
        ),
    )
    parser.add_argument(
        "--heartbeat-seconds",
        type=float,
        default=30.0,
        help=(
            "While HiGHS is running, print a still-solving heartbeat this often; "
            "use 0 to disable (default 30)."
        ),
    )
    parser.add_argument(
        "--solver-log",
        action="store_true",
        help="Show HiGHS presolve/iteration output in addition to heartbeats",
    )
    parser.add_argument(
        "--solver-time-limit",
        type=float,
        default=None,
        help="Optional HiGHS time limit in seconds",
    )
    parser.add_argument(
        "--lp-scaling",
        choices=["none", "row", "row-column"],
        default="row-column",
        help=(
            "Explicit LP equilibration before HiGHS (default row-column). "
            "row normalizes each inequality by its largest coefficient/RHS; "
            "row-column then mildly equilibrates poorly scaled variable columns. "
            "This is an exact positive diagonal change of units, not a relaxation."
        ),
    )
    parser.add_argument(
        "--no-goal-prune",
        action="store_true",
        help="Disable quantitative ancestor pruning to the selected goal",
    )
    parser.add_argument(
        "--no-tech-timing",
        action="store_true",
        help=(
            "Disable mandatory goal-technology cone costs and timing constraints; "
            "useful for comparison with v6 behavior."
        ),
    )
    parser.add_argument(
        "--tech-big-m",
        type=float,
        default=None,
        help=(
            "Deprecated in v10 and ignored. The required-goal-recipe split removes "
            "the technology big-M pre-solve entirely."
        ),
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
    if args.tech_big_m is not None:
        print("WARNING: --tech-big-m is deprecated and ignored in v10; no big-M solve is used.", flush=True)

    if not math.isfinite(args.time_seconds) or args.time_seconds <= 0.0:
        raise ValueError("--time-seconds must be finite and > 0")
    if not math.isfinite(args.goal_amount) or args.goal_amount <= 0.0:
        raise ValueError("--goal-amount must be finite and > 0")
    if args.moment_order < 1:
        raise ValueError("--moment-order must be >= 1")
    if not math.isfinite(args.active_eps) or args.active_eps < 0.0:
        raise ValueError("--active-eps must be finite and >= 0")
    if not math.isfinite(args.heartbeat_seconds) or args.heartbeat_seconds < 0.0:
        raise ValueError("--heartbeat-seconds must be finite and >= 0")
    if args.solver_time_limit is not None and (
        not math.isfinite(args.solver_time_limit) or args.solver_time_limit <= 0.0
    ):
        raise ValueError("--solver-time-limit must be finite and > 0")
    if args.tech_big_m is not None and (
        not math.isfinite(args.tech_big_m) or args.tech_big_m <= 0.0
    ):
        raise ValueError("--tech-big-m must be finite and > 0")

    goal_key = f"item: {args.goal}"
    character_key = "entity: character"

    total_start = time.perf_counter()
    phase_timings: dict[str, float] = {}

    phase_start = time.perf_counter()
    print("Parsing staged graph log...", flush=True)
    snapshots, graph_refs = parse_log(args.input)
    snapshot = _resolve_single_stage(args.stage, snapshots)
    phase_timings["index_log"] = time.perf_counter() - phase_start
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

    phase_start = time.perf_counter()
    graph_payload = read_graph_payload(args.input, graph_ref)
    all_nodes, all_edges = parse_full_graph(graph_payload)
    del graph_payload
    phase_timings["parse_graph"] = time.perf_counter() - phase_start

    tech_enabled = not args.no_tech_timing
    tech_cone_costs: dict[str, dict[str, float]] = {}
    tech_direct_costs: dict[str, dict[str, float]] = {}
    tech_prereqs: dict[str, set[str]] = {}
    tech_ancestors: dict[str, set[str]] = {}
    if tech_enabled:
        phase_start = time.perf_counter()
        tech_cone_costs = parse_tech_cone_costs(args.input)
        if not tech_cone_costs:
            print(
                "WARNING: no TECH CONE COSTS section found; technology timing disabled",
                flush=True,
            )
            tech_enabled = False
        else:
            tech_prereqs = technology_prerequisite_map(all_nodes, all_edges)
            tech_direct_costs, tech_ancestors = recover_direct_technology_costs(
                tech_cone_costs, tech_prereqs
            )
            print(
                f"Parsed {len(tech_cone_costs):,} technology cone-cost record(s); "
                "recovered direct science costs by prerequisite inversion",
                flush=True,
            )
        phase_timings["parse_technology_costs"] = time.perf_counter() - phase_start

    infinite_keys, infinite_sources = detect_autoplaced_entity_keys(
        snapshot=snapshot,
        all_nodes=all_nodes,
        all_edges=all_edges,
        character_key=character_key,
    )

    phase_start = time.perf_counter()
    stage_nodes, stage_edges, extraction_meta = extract_stage_graph(
        snapshot, all_nodes, all_edges
    )
    phase_timings["extract_stage"] = time.perf_counter() - phase_start

    phase_start = time.perf_counter()
    recipe_to_tech_all, ambiguous_recipe_unlocks = unique_recipe_unlock_technologies(
        stage_nodes, stage_edges
    )
    goal_unlock_tech: str | None = None
    modeled_techs: set[str] = set()
    if tech_enabled:
        goal_unlock_tech = recipe_to_tech_all.get(args.goal)
        if goal_unlock_tech is None:
            print(
                f"WARNING: recipe {args.goal!r} does not have exactly one pure technology "
                "unlock path in this stage; mandatory technology modeling disabled",
                flush=True,
            )
        else:
            modeled_techs = {goal_unlock_tech}
            modeled_techs.update(tech_ancestors.get(goal_unlock_tech, set()))

    goal_recipe_requirement: dict[str, Any] | None = None
    if tech_enabled and modeled_techs:
        if args.solve_mode != "feasibility":
            raise RuntimeError(
                "v10's no-big-M technology timing is designed for --solve-mode feasibility. "
                "Use feasibility for rigorous lower-bound checks, or pass --no-tech-timing "
                "for maximize mode."
            )
        goal_recipe_requirement = infer_required_named_goal_recipe_runs(
            stage_nodes, stage_edges, args.goal, args.goal_amount
        )
        print(
            f"Required goal-recipe split: {goal_recipe_requirement['required_runs']:.9g} "
            f"execution(s) of recipe: {args.goal} at proven yield "
            f"{goal_recipe_requirement['yield_per_run']:.9g} per execution; no big-M needed.",
            flush=True,
        )

    if args.no_goal_prune:
        goal_prune_meta = {
            "enabled": False,
            "goal_key": goal_key,
            "nodes_before": len(stage_nodes),
            "nodes_after": len(stage_nodes),
            "edges_before": len(stage_edges),
            "edges_after": len(stage_edges),
            "nodes_removed": 0,
            "edges_removed": 0,
            "technology_scope": "mandatory goal unlock plus ancestors",
        }
    elif tech_enabled and modeled_techs:
        stage_nodes, stage_edges, goal_prune_meta = (
            mandatory_goal_technology_quantitative_prune(
                stage_nodes, stage_edges, goal_key, modeled_techs, tech_direct_costs
            )
        )
    else:
        stage_nodes, stage_edges, goal_prune_meta = prune_stage_to_goal_quantitative(
            stage_nodes, stage_edges, goal_key
        )
    phase_timings["goal_prune"] = time.perf_counter() - phase_start
    if goal_prune_meta["enabled"]:
        print(
            f"Goal pruning kept {goal_prune_meta['nodes_after']:,}/"
            f"{goal_prune_meta['nodes_before']:,} nodes and "
            f"{goal_prune_meta['edges_after']:,}/"
            f"{goal_prune_meta['edges_before']:,} quantitative edges",
            flush=True,
        )
    if tech_enabled:
        if goal_unlock_tech is not None:
            print(
                f"Mandatory goal technology: {goal_unlock_tech}; charging full prerequisite "
                f"cone of {len(modeled_techs):,} tech(s). Optional technology unlocks are left free.",
                flush=True,
            )
        print(
            f"Detected {len(recipe_to_tech_all):,} uniquely tech-gated recipe(s) total "
            f"({len(ambiguous_recipe_unlocks):,} ambiguous/alternative unlocks).",
            flush=True,
        )

    phase_start = time.perf_counter()
    stage_nodes, stage_edges, used_payback_subdivision_meta = (
        subdivide_used_payback_same_op_edges(stage_nodes, stage_edges)
    )
    ordinary_edges, capacity_specs, payback_meta = split_used_payback_capacity_edges(
        stage_nodes, stage_edges
    )
    payback_meta["pre_capacity_subdivision"] = used_payback_subdivision_meta
    print(
        f"Recovered {payback_meta['capacity_edge_count']} used_payback edge(s) "
        "as actual capacity durations",
        flush=True,
    )
    transformed_nodes, transformed_edges, transform_meta = make_bipartite(
        stage_nodes,
        ordinary_edges,
        zero_free_excluded_or_keys=(set(infinite_keys) | {character_key}),
        reify_cost_or_nodes=False,
    )
    S, _b_traveler, _b_slot, row_keys, col_keys = build_matrix(
        transformed_nodes, transformed_edges
    )
    C = build_capacity_matrix(capacity_specs, row_keys, col_keys)
    tech_info: dict[str, Any] = {
        "technology_names": [], "technology_action_index": {},
        "recipe_constraints": [], "prerequisite_pairs": [], "direct_costs": {},
    }
    if tech_enabled and modeled_techs:
        goal_recipe_gate = ({args.goal: goal_unlock_tech} if goal_unlock_tech is not None else {})
        S, C, row_keys, transformed_nodes, tech_info = augment_matrices_with_technology_research(
            S, C, list(row_keys), list(col_keys), transformed_nodes, modeled_techs,
            tech_direct_costs, tech_prereqs, goal_recipe_gate,
        )
        if goal_recipe_requirement is None or goal_unlock_tech is None:
            raise RuntimeError('Internal v10 error: missing required goal recipe metadata')
        S, C, row_keys, transformed_nodes, tech_info = augment_with_required_goal_recipe_copy(
            S, C, list(row_keys), transformed_nodes, args.goal,
            float(goal_recipe_requirement['required_runs']), goal_unlock_tech,
            tech_info, goal_recipe_requirement,
        )
    phase_timings["normalize_and_build_matrices"] = time.perf_counter() - phase_start

    present_infinite_keys = {key for key in infinite_keys if key in set(col_keys)}
    missing_infinite_keys = sorted(infinite_keys - present_infinite_keys)

    print(
        f"Normalized S={S.shape[0]} actions x {S.shape[1]} materials, "
        f"nnz={S.nnz}; capacity nnz={C.nnz}; "
        f"autoplaced/infinite entities={len(present_infinite_keys)}; "
        f"technology research actions={len(tech_info.get('technology_names', []))}",
        flush=True,
    )
    if missing_infinite_keys:
        print(
            f"WARNING: {len(missing_infinite_keys)} detected infinite entity key(s) "
            "did not survive as material coordinates; ignoring them",
            flush=True,
        )

    if args.output.exists():
        try:
            previous = json.loads(args.output.read_text(encoding="utf-8"))
            if (
                previous.get("stage_index") == snapshot.stage_index
                and previous.get("goal_key") == goal_key
                and previous.get("moment_order") == args.moment_order
                and previous.get("method") == args.method
                and previous.get("solve_mode") == args.solve_mode
                and isinstance(previous.get("solve_elapsed_seconds"), (int, float))
            ):
                print(
                    "Previous matching solve took "
                    f"{_format_elapsed(float(previous['solve_elapsed_seconds']))}; "
                    "that is the best rough ETA for this run.",
                    flush=True,
                )
        except Exception:
            pass

    phase_start = time.perf_counter()
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
        solve_mode=args.solve_mode,
        goal_amount=args.goal_amount,
        heartbeat_seconds=args.heartbeat_seconds,
        solver_log=args.solver_log,
        solver_time_limit=args.solver_time_limit,
        lp_scaling=args.lp_scaling,
        tech_info=tech_info,
    )
    phase_timings["build_and_solve_lp"] = time.perf_counter() - phase_start

    result.update(
        {
            "format": "propertyrandomizer-moment-growth-lp-v10",
            "stage_index": snapshot.stage_index,
            "stage_name": snapshot.stage_name,
            "target_hint": snapshot.target_hint,
            "graph_source": graph_source,
            "goal_item_name": args.goal,
            "goal_amount_requested": float(args.goal_amount),
            "time_seconds": float(args.time_seconds),
            "lp_scaling_mode": args.lp_scaling,
            "time_seconds_role": (
                "active: used_payback edges are recovered as actual-duration "
                "capacity requirements; delta appears directly in moment constraints"
            ),
            "moment_order": int(args.moment_order),
            "solve_mode": args.solve_mode,
            "method": args.method,
            "goal_pruning": goal_prune_meta,
            "phase_timings_seconds": phase_timings,
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
            "technology_model": {
                "enabled": bool(tech_enabled),
                "cone_cost_record_count": len(tech_cone_costs),
                "modeled_technology_count": len(modeled_techs),
                "mandatory_goal_unlock_technology": goal_unlock_tech,
                "mandatory_technology_cone": sorted(modeled_techs),
                "optional_technology_policy": "ignored/free in optimistic relaxation",
                "unique_recipe_unlock_count": len(recipe_to_tech_all),
                "ambiguous_or_alternative_recipe_unlock_count": len(ambiguous_recipe_unlocks),
                "ambiguous_or_alternative_recipe_unlocks": ambiguous_recipe_unlocks,
                "direct_science_costs": tech_info.get("direct_costs", {}),
                "required_goal_recipe": tech_info.get("required_goal_recipe"),
            },
        }
    )

    if args.solve_mode == "feasibility":
        if result["status"] == "infeasible":
            result["lower_bound_test"] = {
                "proved": True,
                "interpretation": (
                    f"Even the optimistic relaxation cannot reach "
                    f"{args.goal_amount:.17g} {goal_key} by {args.time_seconds:g}s; "
                    "therefore the real game requires more time."
                ),
            }
        elif result["status"] == "optimal":
            feasible_amount = float(result["objective_goal_final_amount"])
            result["lower_bound_test"] = {
                "proved": False,
                "interpretation": (
                    f"The optimistic relaxation found a feasible plan reaching at least "
                    f"{args.goal_amount:.17g} {goal_key} by {args.time_seconds:g}s "
                    f"(reported plan ends with {feasible_amount:.17g}); this candidate "
                    "time is inconclusive."
                ),
            }
        else:
            result["lower_bound_test"] = {
                "proved": False,
                "interpretation": (
                    "The feasibility LP did not return a decisive feasible/infeasible "
                    "answer; no lower-bound claim is made."
                ),
            }
    elif result["status"] == "optimal":
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

    phase_timings["total_before_write"] = time.perf_counter() - total_start
    result["phase_timings_seconds"] = phase_timings
    result["total_elapsed_seconds"] = float(time.perf_counter() - total_start)

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
            save_npz(args.save_lp_dir / "A-ub-scaled.npz", lp_internal["A_ub_scaled"])
            np.save(args.save_lp_dir / "b-ub-scaled.npy", lp_internal["b_ub_scaled"])
            np.save(args.save_lp_dir / "objective-scaled.npy", lp_internal["objective_scaled"])
            np.save(args.save_lp_dir / "row-scale.npy", lp_internal["row_scale"])
            np.save(args.save_lp_dir / "column-scale.npy", lp_internal["column_scale"])
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
        if args.solve_mode == "maximize":
            print(
                f"Relaxed maximum {goal_key} by {args.time_seconds:g}s = "
                f"{result['objective_goal_final_amount']:.17g}",
                flush=True,
            )
        else:
            print(
                f"Feasible relaxed plan ends with {goal_key} = "
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
