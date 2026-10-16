#!/usr/bin/env python3
"""Instrument a frozen source folder, never the working tree, for recipe search diagnosis.

Usage: test-recipe-search.py SOURCE DEST
Run DEST through dev/run-tests.py; RECIPESEARCH JSON lines include candidate pools,
per-search workload, stopping reasons, and the slowest amount fit with replay inputs.
Use a separate uninstrumented copy for instruction benchmarks.
"""
from pathlib import Path
import argparse
from collections import Counter
import json
import re
import shutil

REPO = Path(__file__).resolve().parents[2]


def summarize(folder):
    text = (folder / "create.log").read_text()
    searches = [json.loads(line.split("RECIPESEARCH ", 1)[1])
                for line in text.splitlines() if "RECIPESEARCH " in line]
    for row in searches:
        if row["fits"] == 0 and isinstance(row["result"], dict):
            row["stop"] = "kept-only"
    counters = ("fits", "rounds", "coordinate_optimizations", "point_evaluations", "cost_evaluations",
                "proposals", "duplicate_proposals", "duplicate_amounts", "candidate_attempts", "accepted_swaps")
    return {
        "folder": str(folder),
        "attempts": len(re.findall(r"PROFILE unified attempt \d+", text)),
        "totals": {key: sum(row.get(key, 0) for row in searches) for key in counters},
        "search_stops": dict(Counter(row["stop"] for row in searches)),
        "fit_stops": dict(sum((Counter(row["stops"]) for row in searches), Counter())),
        "quality_lines": [line.split("RECIPESTATS ", 1)[1] for line in text.splitlines() if "RECIPESTATS " in line],
        "fallbacks": [int(value) for value in re.findall(r"(\d+) recipes fell back to vanilla ingredients", text)],
        "unified": re.findall(r"UNIFIEDCHECK verdict: (\w+)", text),
        "mechanics": re.findall(r"MECHCHECK verdict: (\w+)", text),
        "searches": searches,
    }


def instrument(source, dest):
    shutil.copytree(source, dest)
    probe = Path("dev/experiments/test-recipe-search-probe.lua")
    (dest / probe).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(REPO / probe, dest / probe)
    path = dest / "src/legacy/randomizations/recipe-cost.lua"
    text = path.read_text()

    def replace(old, new):
        nonlocal text
        if text.count(old) != 1:
            raise ValueError(f"Expected one anchor: {old!r}, got {text.count(old)}")
        text = text.replace(old, new)

    text = 'local probe = require("dev/experiments/test-recipe-search-probe")\n' + text
    replace("local function calculate_points(old_recipe_costs, new_recipe_costs, extra_params)",
            "local function calculate_points(old_recipe_costs, new_recipe_costs, extra_params)\n    probe.points()")
    replace("local function optimize_single_ing(old_recipe_costs, material_to_costs, all_ings, ing_ind, extra_params)",
            "local function optimize_single_ing(old_recipe_costs, material_to_costs, all_ings, ing_ind, extra_params)\n    probe.single()")
    replace("    return function(amount)\n", "    return function(amount)\n        probe.amount(amount)\n")
    replace("local function calculate_optimal_amounts(old_recipe_costs, material_to_costs, proposed_ings, num_ings_to_find, extra_params)",
            "local function calculate_optimal_amounts(old_recipe_costs, material_to_costs, proposed_ings, num_ings_to_find, extra_params)\n    probe.fit_begin(old_recipe_costs, material_to_costs, proposed_ings, num_ings_to_find, extra_params)")
    replace("        return optimization_info.best_points", "        probe.fit_end(optimization_info.best_points, proposed_ings, 'single')\n        return optimization_info.best_points")
    if "        local new_proposals = {}" in text:
        replace("        local new_proposals = {}", "        probe.round()\n        local new_proposals = {}")
    else:
        replace("        local evaluated = {}", "        probe.round()\n        local evaluated = {}")
    replace('            local ing_ind = rng.int("recipe-ingredients-calculate-optimal-amounts", num_ings_to_find)',
            '            local ing_ind = rng.int("recipe-ingredients-calculate-optimal-amounts", num_ings_to_find)\n            probe.proposal(ing_ind)')
    replace("        -- If we've optimized to within a very small point difference I think that's good enough",
            "        probe.round_end(curr_points, new_points, allocated_amounts, proposed_ings)\n        -- If we've optimized to within a very small point difference I think that's good enough")
    replace("            break\n        end\n\n        curr_points = new_points", "            probe.fit_end(new_points, proposed_ings, num_failed_attempts >= constants.max_num_failed_attempts_ing_search and 'limit' or 'converged')\n            break\n        end\n\n        curr_points = new_points")
    replace("    -- The forms of the slots to fill", "    probe.begin_search(potential_ings, num_ings_to_find, old_recipe_costs, material_to_costs, extra_params)\n    -- The forms of the slots to fill")
    replace("        return {ings = extra_params.unrandomized_ings, points = 0, inds = {}}",
            "        local result = {ings = extra_params.unrandomized_ings, points = 0, inds = {}}\n        probe.finish_search(result)\n        return result")
    replace("            return new_ing_ind", "            probe.stop('no-candidate')\n            probe.finish_search(new_ing_ind)\n            return new_ing_ind")
    replace("            num_tried = num_tried + 1", "            num_tried = num_tried + 1\n            probe.candidate()")
    replace("                        -- Do the swap", "                        probe.accepted()\n                        -- Do the swap")
    replace("        if num_tried - last_progress >= constants.ing_search_stall_candidates then\n            break",
            "        if num_tried - last_progress >= constants.ing_search_stall_candidates then\n            probe.stop('stall')\n            break")
    replace("            if curr_ings_points <= constants.target_cost_threshold then\n                break",
            "            if curr_ings_points <= constants.target_cost_threshold then\n                probe.stop('threshold')\n                break")
    replace("    return {ings = curr_ings, points = curr_ings_points, inds = curr_ing_inds}",
            "    local result = {ings = curr_ings, points = curr_ings_points, inds = curr_ing_inds}\n    probe.finish_search(result)\n    return result")
    path.write_text(text)
    path = dest / "src/randomizations/unified/handlers/recipe-ingredients.lua"
    text = path.read_text()
    anchor = "                local function search(ings, forms)"
    assert text.count(anchor) == 1
    text = text.replace(anchor, anchor + "\n                    probe.recipe = dependent_recipe.name\n                    probe.slot = slot_recipe.name")
    path.write_text('local probe = require("dev/experiments/test-recipe-search-probe")\n' + text)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, nargs="?")
    parser.add_argument("dest", type=Path, nargs="?")
    parser.add_argument("--summarize", type=Path, metavar="RUN_FOLDER", help="extract diagnostic JSON from create.log")
    args = parser.parse_args()
    if args.summarize is not None:
        print(json.dumps(summarize(args.summarize), indent=2))
        raise SystemExit(0)
    if args.source is None or args.dest is None:
        parser.error("Provide SOURCE and DEST, or --summarize RUN_FOLDER")
    if args.source.resolve().is_relative_to(REPO) or args.dest.resolve().is_relative_to(REPO):
        parser.error("Use frozen copies, not the working tree")
    if args.dest.resolve().is_relative_to(args.source.resolve()):
        parser.error("DEST must be outside SOURCE")
    instrument(args.source, args.dest)
