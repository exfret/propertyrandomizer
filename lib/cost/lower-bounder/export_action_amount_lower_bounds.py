#!/usr/bin/env python3
"""Export conservative action-amount lower bounds from a PropertyRandomizer log.

This is a deliberately player-informed lower-bound model for vanilla rocket launch.
It does NOT solve the large moment LP.  It parses the same graph/technology records
used by solve_staged_growth_lower_bound_v26.py, reverse-propagates unique
single-output recipes, applies the explicit oil/module assumptions below, and then
closes a simple machine-capacity feedback loop for a requested completion time.

The output is intended to provide q_0 lower bounds for the moment LP.
"""
from __future__ import annotations

import argparse
import importlib.util
import json
import math
import sys
from collections import defaultdict, deque
from pathlib import Path
from typing import Any

EPS = 1e-12


def load_solver_helpers(path: Path):
    spec = importlib.util.spec_from_file_location("_growth_solver_helpers", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load solver helper module from {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def fluid_base(name: str) -> str:
    return name.split(":", 1)[0].strip()


def build_recipe_specs(nodes, edges):
    incoming: dict[str, list[Any]] = defaultdict(list)
    outgoing: dict[str, list[Any]] = defaultdict(list)
    for edge in edges:
        incoming[edge.stop].append(edge)
        outgoing[edge.start].append(edge)

    def canonical_material(node) -> str | None:
        if node.node_type == "item":
            return f"item:{node.name}"
        if node.node_type in {"fluid", "fluid-temperature", "fluid-temperature-range"}:
            return f"fluid:{fluid_base(str(node.name))}"
        return None

    recipes: dict[str, dict[str, Any]] = {}
    for key, node in nodes.items():
        if node.node_type != "recipe" or not node.name:
            continue
        ingredients: dict[str, float] = defaultdict(float)
        category = None
        craft_time = None
        for edge in incoming.get(key, []):
            src = nodes.get(edge.start)
            if src is None:
                continue
            mat = canonical_material(src)
            if mat is not None and edge.amount_present and edge.amount > 0:
                ingredients[mat] += float(edge.amount)
            elif src.node_type == "recipe-category" and edge.amount_present:
                category = str(src.name)
                craft_time = float(edge.amount)

        products: dict[str, float] = defaultdict(float)
        for edge in outgoing.get(key, []):
            dst = nodes.get(edge.stop)
            if dst is None or not edge.amount_present or edge.amount <= 0:
                continue
            if dst.node_type == "item-craft":
                products[f"item:{dst.name}"] += float(edge.amount)
            elif dst.node_type == "fluid-craft-temperature":
                products[f"fluid:{fluid_base(str(dst.name))}"] += float(edge.amount)

        recipes[str(node.name)] = {
            "action_key": key,
            "ingredients": dict(ingredients),
            "products": dict(products),
            "category": category,
            "craft_time_seconds": craft_time,
        }
    return recipes


def calculate(log_path: Path, solver_path: Path, time_seconds: float) -> dict[str, Any]:
    solver = load_solver_helpers(solver_path)
    snapshots, graph_refs = solver.parse_log(log_path)
    snapshot = solver._resolve_single_stage("1", snapshots)
    graph_ref = graph_refs.get(snapshot.stage_index) or graph_refs.get(0)
    if graph_ref is None:
        raise RuntimeError("No GRAPH DUMP found")
    nodes, edges = solver.parse_full_graph(solver.read_graph_payload(log_path, graph_ref))

    cone_costs, tech_time_costs = solver.parse_tech_cone_costs_and_times(log_path)
    prereqs = solver.technology_prerequisite_map(nodes, edges)
    direct_costs, ancestors = solver.recover_direct_technology_costs(cone_costs, prereqs)
    if "rocket-silo" not in cone_costs:
        raise RuntimeError("No rocket-silo technology cone found")
    mandatory_techs = {"rocket-silo", *ancestors.get("rocket-silo", set())}
    science_pack_amounts = {
        k: float(v) for k, v in cone_costs["rocket-silo"].items()
    }
    total_lab_seconds = sum(float(tech_time_costs.get(t, 0.0)) for t in mandatory_techs)

    recipes = build_recipe_specs(nodes, edges)

    producer_candidates: dict[str, list[tuple[str, float]]] = defaultdict(list)
    for recipe_name, spec in recipes.items():
        # The generic rule is intentionally restricted to single-output recipes.
        if len(spec["products"]) == 1:
            material, yield_per_craft = next(iter(spec["products"].items()))
            if yield_per_craft > 0:
                producer_candidates[material].append((recipe_name, float(yield_per_craft)))

    # Player-informed exceptions/assumptions.
    producer_override = {
        "item:solid-fuel": "solid-fuel-from-light-oil",
    }
    special_oil_materials = {
        "fluid:petroleum-gas",
        "fluid:light-oil",
        "fluid:heavy-oil",
    }

    def chosen_producer(material: str) -> tuple[str, float] | None:
        if material in special_oil_materials:
            return None
        override = producer_override.get(material)
        if override is not None:
            spec = recipes[override]
            return override, float(spec["products"][material])
        candidates = producer_candidates.get(material, [])
        if len(candidates) == 1:
            return candidates[0]
        return None

    def reverse_propagate(
        seed_materials: dict[str, float],
        seed_recipes: dict[str, float] | None = None,
    ) -> tuple[dict[str, float], dict[str, float]]:
        demand: dict[str, float] = defaultdict(float)
        recipe_lb: dict[str, float] = defaultdict(float)
        queue: deque[str] = deque()
        for material, amount in seed_materials.items():
            if amount <= 0:
                continue
            demand[material] += float(amount)
            queue.append(material)
        for recipe_name, amount in (seed_recipes or {}).items():
            if amount <= recipe_lb[recipe_name]:
                continue
            recipe_lb[recipe_name] = float(amount)
            for material, ingredient_amount in recipes[recipe_name]["ingredients"].items():
                demand[material] += float(ingredient_amount) * float(amount)
                queue.append(material)

        while queue:
            material = queue.popleft()
            choice = chosen_producer(material)
            if choice is None:
                continue
            recipe_name, yield_per_craft = choice
            target = demand[material] / yield_per_craft
            if target <= recipe_lb[recipe_name] + EPS:
                continue
            delta = target - recipe_lb[recipe_name]
            recipe_lb[recipe_name] = target
            for ingredient, ingredient_amount in recipes[recipe_name]["ingredients"].items():
                demand[ingredient] += float(ingredient_amount) * delta
                queue.append(ingredient)
        return dict(demand), dict(recipe_lb)

    initial_materials = {
        f"item:{pack}": amount for pack, amount in science_pack_amounts.items()
    }
    initial_materials["item:rocket-silo"] = 1.0

    # Core module assumption: four prod-3s are treated as available/free only for
    # the rocket silo, and 72 rocket-part crafts are required.  No productivity is
    # credited anywhere else, and no speed modules are used.
    rocket_part_crafts = 72.0

    # Petroleum needed to produce the 75 chemical science packs in the
    # advanced-oil-processing cone, before AOP itself can be used.
    aop_chemical_science = float(
        cone_costs.get("advanced-oil-processing", {}).get("chemical-science-pack", 0.0)
    )
    pre_aop_demand, _ = reverse_propagate(
        {"item:chemical-science-pack": aop_chemical_science}
    )
    pre_aop_petroleum = float(pre_aop_demand.get("fluid:petroleum-gas", 0.0))
    basic_oil_crafts = pre_aop_petroleum / 45.0

    def add_oil_bounds(demand: dict[str, float], recipe_lb: dict[str, float]):
        petroleum = float(demand.get("fluid:petroleum-gas", 0.0))
        light = float(demand.get("fluid:light-oil", 0.0))
        heavy = float(demand.get("fluid:heavy-oil", 0.0))

        remaining_petroleum = max(0.0, petroleum - 45.0 * basic_oil_crafts)
        # One AOP craft gives 55 petroleum + 45 light + 25 heavy.  Grant free
        # cracking to make the bound optimistic: 25 heavy -> 18.75 light, then
        # 63.75 total light -> 42.5 petroleum, for 97.5 petroleum max/craft.
        aop_from_petroleum = remaining_petroleum / 97.5
        aop_from_light = light / 63.75
        aop_from_heavy = heavy / 25.0
        advanced_oil_crafts = max(aop_from_petroleum, aop_from_light, aop_from_heavy)

        recipe_lb["basic-oil-processing"] = max(
            recipe_lb.get("basic-oil-processing", 0.0), basic_oil_crafts
        )
        recipe_lb["advanced-oil-processing"] = max(
            recipe_lb.get("advanced-oil-processing", 0.0), advanced_oil_crafts
        )

        # These are actual mandatory inputs of the two oil-processing crafts.
        # We do not charge the hypothetical cracking water used only to derive
        # the optimistic maximum-petroleum yield.
        demand["fluid:crude-oil"] = demand.get("fluid:crude-oil", 0.0) + 100.0 * (
            basic_oil_crafts + advanced_oil_crafts
        )
        demand["fluid:water"] = demand.get("fluid:water", 0.0) + 50.0 * advanced_oil_crafts

        return {
            "petroleum_demand": petroleum,
            "light_oil_demand": light,
            "heavy_oil_demand": heavy,
            "pre_aop_petroleum_demand": pre_aop_petroleum,
            "basic_oil_processing_crafts": basic_oil_crafts,
            "advanced_oil_processing_crafts": advanced_oil_crafts,
            "advanced_bound_components": {
                "from_petroleum_after_full_cracking": aop_from_petroleum,
                "from_light_after_heavy_to_light": aop_from_light,
                "from_heavy_directly": aop_from_heavy,
            },
        }

    def build_from_machine_demands(machine_material_demands: dict[str, float]):
        seeds = dict(initial_materials)
        for material, amount in machine_material_demands.items():
            seeds[material] = seeds.get(material, 0.0) + float(amount)
        demand, recipe_lb = reverse_propagate(
            seeds, {"rocket-part": rocket_part_crafts}
        )
        oil_meta = add_oil_bounds(demand, recipe_lb)
        return demand, recipe_lb, oil_meta

    def category_workloads(recipe_lb: dict[str, float]) -> dict[str, float]:
        workloads: dict[str, float] = defaultdict(float)
        for recipe_name, amount in recipe_lb.items():
            spec = recipes.get(recipe_name)
            if spec is None:
                continue
            category = spec.get("category")
            craft_time = spec.get("craft_time_seconds")
            if category is None or craft_time is None:
                continue
            workloads[str(category)] += float(amount) * float(craft_time)
        return dict(workloads)

    def machine_needs(workloads: dict[str, float]) -> dict[str, float]:
        basic = float(workloads.get("crafting__0__0", 0.0))
        advanced = float(workloads.get("advanced-crafting__0__0", 0.0))
        fluid = sum(
            float(v) for k, v in workloads.items() if k.startswith("crafting-with-fluid__")
        )
        chemistry = sum(
            float(v) for k, v in workloads.items() if k.startswith("chemistry__")
        )
        oil = sum(
            float(v) for k, v in workloads.items() if k.startswith("oil-processing__")
        )
        smelting = sum(
            float(v) for k, v in workloads.items() if k.startswith("smelting__")
        )
        rocket = sum(
            float(v) for k, v in workloads.items() if k.startswith("rocket-building__")
        )

        # Character supplies at most one crafting-second/sec to basic crafting.
        # AM1 handles the remaining basic plus all advanced-crafting at speed 0.5.
        am1 = (max(0.0, basic - time_seconds) + advanced) / (0.5 * time_seconds)
        # All crafting-with-fluid goes to AM2 at base speed 0.75; AM3 is excluded.
        am2 = fluid / (0.75 * time_seconds)
        return {
            "assembling-machine-1": am1,
            "assembling-machine-2": am2,
            "chemical-plant": chemistry / time_seconds,
            "oil-refinery": oil / time_seconds,
            "stone-furnace": smelting / time_seconds,
            "rocket-silo": max(1.0, rocket / time_seconds),
            "lab": total_lab_seconds / time_seconds,
        }

    # First, export the time-independent reverse-demand lower bounds before
    # machine-construction feedback.
    base_demand, base_recipe_lb, base_oil_meta = build_from_machine_demands({})

    # Then monotonically close the machine-construction feedback loop.  This is
    # the least fixed point of the chosen piecewise-linear lower-bound model.
    machine_material_demands: dict[str, float] = {}
    iterations = 0
    for iterations in range(1, 501):
        demand, recipe_lb, oil_meta = build_from_machine_demands(machine_material_demands)
        workloads = category_workloads(recipe_lb)
        machines = machine_needs(workloads)
        new_demands = {f"item:{name}": amount for name, amount in machines.items()}
        # The initial seed already includes one rocket silo.
        new_demands["item:rocket-silo"] = max(0.0, machines["rocket-silo"] - 1.0)
        keys = set(machine_material_demands) | set(new_demands)
        max_change = max(
            (abs(new_demands.get(k, 0.0) - machine_material_demands.get(k, 0.0)) for k in keys),
            default=0.0,
        )
        machine_material_demands = new_demands
        if max_change <= 1e-10:
            break
    else:
        raise RuntimeError(
            "Machine-feedback iteration did not converge within 500 iterations; "
            "the requested time may be below this simplified model's growth threshold."
        )

    final_demand, final_recipe_lb, final_oil_meta = build_from_machine_demands(
        machine_material_demands
    )
    final_workloads = category_workloads(final_recipe_lb)
    final_machines = machine_needs(final_workloads)

    # Check the user's expectation that, on the actually demanded non-oil chain,
    # every craftable material has a unique single-output producer after the
    # solid-fuel override.
    ambiguous_required_materials = []
    terminal_resources = {}
    for material, amount in sorted(final_demand.items()):
        if amount <= EPS or material in special_oil_materials:
            continue
        if chosen_producer(material) is not None:
            continue
        candidates = producer_candidates.get(material, [])
        if candidates:
            ambiguous_required_materials.append(
                {
                    "material": material,
                    "amount": amount,
                    "single_output_producer_candidates": [r for r, _ in candidates],
                }
            )
        else:
            terminal_resources[material] = amount

    actions: dict[str, dict[str, Any]] = {}
    for recipe_name, amount in sorted(final_recipe_lb.items()):
        spec = recipes[recipe_name]
        actions[f"recipe: {recipe_name}"] = {
            "lower_bound": amount,
            "kind": "recipe",
            "time_dependent_via_machine_feedback": (
                amount > base_recipe_lb.get(recipe_name, 0.0) + 1e-9
                or recipe_name in final_machines
            ),
            "base_reverse_demand_lower_bound": base_recipe_lb.get(recipe_name, 0.0),
            "category": spec.get("category"),
            "craft_time_seconds": spec.get("craft_time_seconds"),
        }
    for machine_name, amount in sorted(final_machines.items()):
        actions[f"entity-build: {machine_name}"] = {
            "lower_bound": amount,
            "kind": "entity-build",
            "time_dependent_via_machine_feedback": True,
        }
    for tech in sorted(mandatory_techs):
        actions[f"technology-research: {tech}"] = {
            "lower_bound": 1.0,
            "kind": "technology-research",
            "time_dependent_via_machine_feedback": False,
        }
    actions["launch: "] = {
        "lower_bound": 1.0,
        "kind": "goal-action",
        "time_dependent_via_machine_feedback": False,
    }

    result = {
        "schema": "propertyrandomizer-action-amount-lower-bounds-v1",
        "source_log": str(log_path),
        "solver_helper": str(solver_path),
        "time_seconds": time_seconds,
        "goal": "launch: ",
        "assumptions": {
            "rocket_part_crafts": rocket_part_crafts,
            "productivity_modules": (
                "Only the rocket silo receives the productivity-3 benefit, represented "
                "directly by 72 rocket-part crafts. Module research/crafting cost is not charged."
            ),
            "speed_modules": "None; all machine speeds below are base speeds.",
            "lab_speed_bonuses": "Ignored; lab speed is fixed to 1 for this assumption set.",
            "solid_fuel": "All required solid fuel is made from light oil.",
            "coal_liquefaction": "Excluded / assumed unnecessary.",
            "generic_recipe_rule": (
                "Reverse-propagate only when the required material has exactly one "
                "single-output recipe producer."
            ),
            "oil_rule": (
                "Basic oil processing covers the petroleum needed for the 75 chemical "
                "science packs in the advanced-oil-processing cone. Remaining petroleum "
                "is lower-bounded using advanced oil processing with free complete cracking; "
                "light/heavy bounds are also checked and the maximum is used."
            ),
            "assembling_machine_assignment": (
                "Character (speed 1) may cover basic crafting only; AM1 (speed 0.5) covers "
                "remaining basic and all advanced-crafting; AM2 (speed 0.75) covers all "
                "crafting-with-fluid; AM3 is not used. This relies on the player assumption "
                "that AM2 is more expensive to make than 1.5 AM1s."
            ),
            "other_machine_speeds": (
                "Chemical plants, oil refineries, stone furnaces, rocket silo, and labs are "
                "treated at speed 1, with their category workloads assigned uniquely."
            ),
            "energy_and_mining_infrastructure": (
                "Not lower-bounded here; this exporter only closes crafting/research machine demand."
            ),
        },
        "technology": {
            "mandatory_technology_count": len(mandatory_techs),
            "science_pack_amounts": science_pack_amounts,
            "total_base_lab_seconds": total_lab_seconds,
            "advanced_oil_processing_chemical_science_in_cone": aop_chemical_science,
        },
        "oil": final_oil_meta,
        "machine_feedback": {
            "iterations": iterations,
            "machine_entity_build_lower_bounds": final_machines,
            "category_workload_seconds": final_workloads,
        },
        "base_reverse_demand_recipe_lower_bounds": dict(sorted(base_recipe_lb.items())),
        "final_recipe_lower_bounds": dict(sorted(final_recipe_lb.items())),
        "terminal_resource_demands": terminal_resources,
        "special_fluid_demands_before_oil_supply": {
            k: final_demand.get(k, 0.0) for k in sorted(special_oil_materials)
        },
        "ambiguous_required_materials": ambiguous_required_materials,
        "actions": actions,
        "notes": [
            "The base reverse-demand recipe bounds are time-independent under these assumptions.",
            "The final recipe bounds are NOT generally time-independent because machine construction is fed back into material/crafting demand.",
            "Consequently, a 60-minute export cannot be rescaled exactly to arbitrary times by multiplying machine counts by 3600/T; rerun this exporter with the desired --time-seconds.",
        ],
    }
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("log", type=Path)
    parser.add_argument(
        "--solver-script",
        type=Path,
        default=Path(__file__).with_name("solve_staged_growth_lower_bound_v26.py"),
        help="Solver script providing the tested graph/log parsing helpers.",
    )
    parser.add_argument("--time-seconds", type=float, default=3600.0)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("action-amount-lower-bounds.json"),
    )
    args = parser.parse_args()
    if not math.isfinite(args.time_seconds) or args.time_seconds <= 0:
        raise ValueError("--time-seconds must be finite and > 0")
    result = calculate(args.log, args.solver_script, args.time_seconds)
    args.output.write_text(json.dumps(result, indent=2, sort_keys=False) + "\n")
    print(f"Wrote {args.output}")
    print(
        "Machine lower bounds:",
        json.dumps(result["machine_feedback"]["machine_entity_build_lower_bounds"], indent=2),
    )
    print(
        f"Recipes={len(result['final_recipe_lower_bounds'])}; "
        f"ambiguous-required={len(result['ambiguous_required_materials'])}"
    )


if __name__ == "__main__":
    main()
