#!/usr/bin/env python3
# Recolored sprite sheets for duplicated entities (lib/dupe.lua)
#
# Duplicates of the entities in dev/dupe-entities.txt get their own copies of every body sheet and icon, recolored
# offline (Factorio's own tint washes a sprite out, so the recolor is done on the pixels instead). The recolor goes
# through a mask of the machine's painted parts, chosen per entity in that file: pixels near the paint hue that are
# clearly paint (saturated and bright enough) seed the mask, the mask grows through the connected pixels of the same
# hue that are duller or in shadow, and then it is filled by panel rather than by pixel: wherever paint pixels are
# dense, the highlights, rivets and weathering between them count as paint too, a closing bridges the remaining gaps,
# specks are dropped, holes filled and the edge feathered a pixel. So a painted panel is tinted whole with a clean
# edge while rust streaks, grey metal, concrete and glass stay. Inside the mask each pixel becomes mostly its
# brightness times the dupe's color. The dupe colors are chosen per machine in the same file (what makes sense next
# to the original and its relatives; never a blue, since a blue machine reads as frozen). Icons go through the same
# rule, so they match the building. A machine with no paint at all (grey plates, rust, dark floors) says "grey" instead:
# then its light, unsaturated metal plates are the mask, the way vanilla's own turret and vehicle masks cover the
# housing plates, and rust and shadow stay. "whole" colorizes the whole sprite and is only a fallback.
# The copies go to graphics/dupes/<n>/... mirroring the original path, and lib/dupe-graphics-manifest.lua lists which
# originals have copies, so dupe.lua can swap filenames without knowing anything about the entities.
#
# Items (dev/dupe-items.txt: modules, fuels, guns, ammo, armor, equipment items) go through the same rule with their icons,
# their belt pictures, the icons of the recipes that make them, the grid sprite of the equipment they place and, for an
# armor, the character's animation sheets for it (lib/dupe.lua copies those animations for the armor's dupe). How many
# dupes a thing gets is its line's dupes= list (one color, one dupe; without the list, every number up to --dupes).
#
# Planets (dev/dupe-planets.txt) are copied whole by lib/dupe-planets.lua, so their line uses the rotate mode: every pixel's
# hue turned by the given degrees, on the planet's icon, its star map icon and the image of the technology discovering it.
# A planet copy's science packs are item lines like any other (they're only copied along with their planet).
# An item line's split=side colors only the right half of the mask (by area, in each mip level of an icon sheet), so the left
# half keeps the original's color: a science pack copy shows its original's color and its own side by side (split=layer
# colors the bottom half instead).
# A planet line's tints= list makes more rotations of the same images, one per angle, at graphics/dupes/tint-<degrees>/...:
# lib/planet-tints.lua gives every planet but the starting one a random one of them. They're listed per original path in
# their own manifest, lib/planet-tint-manifest.lua, written from what's on disk whenever a line with tints= is generated.
#
# Which sheets are "body" comes from a data.raw dump (dev/run-tests.py --dump-data writes one per run): every PNG
# reachable from the entity prototype except shadows, glows, lights, layers the game tints at runtime (force/player,
# recipe, module colors), and the tables listed in SKIP_KEYS (shared pipe covers, connectors, reflections, remnants,
# fluid and smoke layers). Where a runtime-tinted layer shares a sheet with the body (spider legs keep their mask rows in
# the same file), its rectangle keeps the original pixels. Spider vehicles also bring their spider-leg prototypes, and
# every entity brings the icons of the items that place it.
#
# The graphics are never committed (the repo is public; the sheets are the game's), so graphics/dupes/ is gitignored.
# Generate them before a release: dev/release-files.py ships the folder even though git ignores it.
#
# Usage:
#   dev/make-dupe-graphics.py --dump PATH/data-raw-dump.json [--dupes 3] [--entities dev/dupe-entities.txt]
#       [--items dev/dupe-items.txt] [--planets dev/dupe-planets.txt] [--jobs 4] [--only NAME ...] [--preview DIR] [--list]
#   The dump should come from a run with the dupes off and the mods whose entities are listed (Space Age for the full list).
#   --preview writes one image per entity (icon and main sheets: original, then each dupe) to look the settings over.
#   --inspect writes one image per entity with the mask itself drawn (magenta over grey) next to the original and dupe 2,
#       at double size, to see where the tint lands; use it when tuning a line of dev/dupe-entities.txt.

import argparse
import concurrent.futures
import json
import math
import os
import re
import sys

import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter, uniform_filter
from skimage.filters import apply_hysteresis_threshold
from skimage.morphology import binary_closing, disk, remove_small_holes, remove_small_objects

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME_DATA = "/Applications/factorio.app/Contents/data"
OUT_DIR = os.path.join(REPO, "graphics", "dupes")
MANIFEST = os.path.join(REPO, "lib", "dupe-graphics-manifest.lua")
TINT_MANIFEST = os.path.join(REPO, "lib", "planet-tint-manifest.lua")
# A planet tint's folder under OUT_DIR, by its hue rotation in degrees
TINT_FOLDER = "tint-{}"

# How much of a masked pixel becomes the dupe color (the rest keeps the original pixel): a highlight, not a coat
STRENGTH = 0.7
# Saturation of a dupe color given as a bare hue (a hue can also carry its own, as H/S); muted, not fluorescent
DUPE_SATURATION = 0.55
# The brightness-preserving scaling of a color stops here, so light pixels don't clip to neon
MAX_GAIN = 1.15
# Dupe colors when a line gives none: the two of these farthest from the paint hue (none is a blue: that reads as frozen)
PALETTE_HUES = (355.0, 30.0, 50.0, 130.0, 185.0)
# Mask parameters and their defaults (see dev/dupe-entities.txt)
PAINT_DEFAULTS = {"half": 25.0, "sat": 0.35, "val": 0.3, "low": None, "min": 40.0, "hole": 800.0, "smax": 0.18, "vmax": 0.97, "win": 9.0, "dens": 0.5, "close": 2.0, "strength": None}
# Feathering of the mask edge, in pixels
EDGE_SIGMA = 0.8
# How a line's split= halves the mask: the part right of (side) or below (layer) the line that halves its area
SPLITS = ("side", "layer")

# Layers the game colors itself, or that aren't the body
TINT_FLAGS = ("draw_as_shadow", "draw_as_glow", "draw_as_light", "apply_runtime_tint", "apply_recipe_tint", "apply_module_tint", "tint_as_overlay")
# Prototype tables that never hold the body (shared or effect graphics)
SKIP_KEYS = {
    "minable", "collision_box", "selection_box", "sound", "working_sound", "vehicle_impact_sound", "open_sound", "close_sound", "mined_sound",
    "damaged_trigger_effect", "corpse", "dying_explosion", "resistances", "water_reflection", "integration_patch", "circuit_connector",
    "created_effect", "remnants", "pipe_covers", "pipe_covers_frozen", "radius_visualisation_picture", "radius_visualisation_specification",
    "fluid_box", "output_fluid_box", "fluid_boxes", "energy_source", "pipe_picture", "pipe_picture_frozen", "pipe_connections", "heat_buffer",
    "smoke", "drilling_smoke", "fluid_wagon_connector_graphics", "connector_graphics", "charge_animation", "discharge_animation",
    "shooting_glow", "rising_glow", "light", "light_animation", "muzzle_animation", "rotate_animation", "integration", "decal",
    "satellite_animation", "rocket_glow_overlay_sprite", "rocket_shadow_overlay_sprite", "hole_light_sprite", "red_lights_back_sprites",
    "red_lights_front_sprites", "base_light", "crafting_light", "plant_mask", "spider_engine", "graphics_set_when_frozen",
}
# Any key containing one of these is skipped too (pipe flow textures, connection visualizations, window backgrounds, the thruster flame)
SKIP_KEY_PARTS = ("frozen", "shadow", "glow", "light", "smoke", "remnant", "reflection", "flow", "visualization", "window_background", "flame")
# A working visualisation (a table holding one of ANIMATION_KEYS) with one of these is an effect (smoke, dust, particles,
# fluid or status tints, scorch marks), not a body part
ANIMATION_KEYS = ("animation", "north_animation", "east_animation", "south_animation", "west_animation")
EFFECT_VISUALISATION_KEYS = ("apply_recipe_tint", "apply_tint", "synced_fadeout", "constant_speed", "effect", "mining_drill_scorch_mark", "light")
# Sheets named for an effect are left alone even when nothing in the prototype flags them (the foundry's smoke, for one)
EFFECT_WORDS = ("smoke", "dust", "particle", "particles", "fire", "flame", "spark", "sparks", "glow", "light", "lights", "shadow", "mask", "reflection", "uv")
# Types under which an entity name may also name something that isn't the entity
NOT_ENTITY_TYPES = {"item", "recipe", "technology", "item-with-entity-data", "ammo", "capsule", "gun", "tile", "virtual-signal", "tool", "module", "armor"}


def parse_list(path, kind):
    """name -> {"kind": "entity"/"item", "mode": "paint"/"grey"/"whole", "hues": [..], "dupes": [(hue, sat)..], "tints": [degrees..], mask parameters} in file order"""
    entries = {}
    with open(path) as f:
        for number, line in enumerate(f, 1):
            line = line.split("#", 1)[0].strip()
            if not line:
                continue
            parts = line.split()
            name = parts[0]
            params = dict(PAINT_DEFAULTS)
            params["kind"] = kind
            params["mode"] = "paint"
            params["hues"] = []
            params["dupes"] = []
            params["tints"] = []
            params["split"] = None
            for part in parts[1:]:
                if part in ("whole", "grey", "rotate"):
                    params["mode"] = part
                    continue
                key, _, value = part.partition("=")
                if key == "hue":
                    params["hues"] = [float(v) for v in value.split(",")]
                elif key == "dupes":
                    for token in value.split(","):
                        hue, _, sat = token.partition("/")
                        params["dupes"].append((float(hue), float(sat) if sat else DUPE_SATURATION))
                elif key == "tints":
                    params["tints"] = [int(v) for v in value.split(",")]
                elif key == "split" and value in SPLITS:
                    params["split"] = value
                elif key in PAINT_DEFAULTS and value != "":
                    params[key] = float(value)
                else:
                    sys.exit(f"{path}:{number}: expected whole, grey, rotate, hue=H[,H2], dupes=H[/S],H[/S], tints=D[,D2], split=side|layer, or a mask parameter ({', '.join(PAINT_DEFAULTS)}), not {part}")
            if params["mode"] == "paint" and not params["hues"]:
                sys.exit(f"{path}:{number}: {name} needs hue= (or whole)")
            if params["mode"] == "rotate" and not params["dupes"]:
                sys.exit(f"{path}:{number}: {name} needs dupes= with each dupe's hue rotation in degrees")
            if params["tints"] and params["mode"] != "rotate":
                sys.exit(f"{path}:{number}: {name} has tints=, which only a rotate line (a planet) takes")
            if params["split"] is not None and params["mode"] == "rotate":
                sys.exit(f"{path}:{number}: {name} has split=, which a rotate line (a planet) can't take")
            if params["low"] is None:
                params["low"] = max(0.1, params["sat"] * 0.5)
            if params["strength"] is None:
                params["strength"] = STRENGTH
            entries[name] = params
    return entries


def resolve(filename):
    m = re.match(r"__([^_]+(?:-[^_]+)*)__/(.*)", filename)
    if m is None:
        return None, None
    return m.group(1), m.group(2)


def source_path(filename):
    mod, rest = resolve(filename)
    if mod is None:
        return None
    path = os.path.join(GAME_DATA, mod, rest)
    return path if os.path.exists(path) else None


def sprite_filenames(sprite):
    if "filename" in sprite:
        names = [sprite["filename"]]
    elif "filenames" in sprite:
        names = list(sprite["filenames"])
    elif "stripes" in sprite:
        names = [stripe["filename"] for stripe in sprite["stripes"]]
    else:
        names = []
    # Sounds have a filename too
    return [name for name in names if isinstance(name, str) and name.lower().endswith(".png")]


def is_effect_sheet(filename):
    base = os.path.basename(filename).lower()
    words = re.split(r"[^a-z]+", base[:-len(".png")])
    return any(word in EFFECT_WORDS for word in words)


def sprite_rect(sprite):
    """(x, y, width, height) of the part of the sheet this sprite draws, or None when unknown"""
    if "stripes" in sprite:
        return None
    width, height = sprite.get("width"), sprite.get("height")
    size = sprite.get("size")
    if isinstance(size, list):
        width, height = size
    elif size is not None:
        width = height = size
    if width is None or height is None:
        return None
    frames = (sprite.get("frame_count") or 1) * (sprite.get("direction_count") or 1) * (sprite.get("variation_count") or 1)
    line_length = sprite.get("line_length") or frames
    columns = max(1, min(frames, line_length))
    rows = max(1, math.ceil(frames / columns))
    return (int(sprite.get("x") or 0), int(sprite.get("y") or 0), int(width * columns), int(height * rows))


def collect(value, files, protected):
    """Every body sprite filename reachable from value; runtime-tinted rectangles per filename into protected"""
    if isinstance(value, dict):
        if any(k in value for k in ("filename", "filenames", "stripes")):
            names = sprite_filenames(value)
            if value.get("apply_runtime_tint"):
                rect = sprite_rect(value)
                if rect is not None:
                    for name in names:
                        protected.setdefault(name, []).append(rect)
                return
            # A layer with its own tint is an effect (smoke, heat glow) rather than the body
            if any(value.get(flag) for flag in TINT_FLAGS) or value.get("tint") is not None:
                return
            files.update(name for name in names if not is_effect_sheet(name))
            return
        if "type" not in value and any(key in value for key in ANIMATION_KEYS) and any(key in value for key in EFFECT_VISUALISATION_KEYS):
            return
        for k, v in value.items():
            k = str(k)
            if k in SKIP_KEYS or any(part in k for part in SKIP_KEY_PARTS):
                continue
            collect(v, files, protected)
    elif isinstance(value, list):
        for v in value:
            collect(v, files, protected)


def icon_filenames(prototype):
    acc = set()
    for key in ("icon", "dark_background_icon"):
        if prototype.get(key):
            acc.add(prototype[key])
        for icon in prototype.get(key + "s") or []:
            if icon.get("icon"):
                acc.add(icon["icon"])
    return acc


def find_entity(raw, name):
    found = None
    for type_name, prototypes in raw.items():
        if type_name in NOT_ENTITY_TYPES or not isinstance(prototypes, dict):
            continue
        prototype = prototypes.get(name)
        if isinstance(prototype, dict) and prototype.get("type") == type_name:
            found = prototype
    return found


def placing_items(raw, entity_name):
    for type_name, prototypes in raw.items():
        if not isinstance(prototypes, dict):
            continue
        for item in prototypes.values():
            if isinstance(item, dict) and item.get("place_result") == entity_name:
                yield item


def find_named(raw, name, field):
    """The prototype of this name that has the field: every item has a stack_size, every equipment a shape"""
    for type_name, prototypes in raw.items():
        if not isinstance(prototypes, dict):
            continue
        prototype = prototypes.get(name)
        if isinstance(prototype, dict) and prototype.get("type") == type_name and field in prototype:
            return prototype
    return None


def main_product(recipe):
    """The recipe's main product: main_product when given, else its only result"""
    if recipe.get("main_product") is not None:
        return recipe["main_product"] or None
    results = recipe.get("results") or []
    if len(results) == 1:
        return results[0].get("name")
    return None


def item_recipes(raw, item_name):
    """The recipes (not hidden) whose main product is the item: lib/dupe.lua duplicates them along with it"""
    return [recipe for recipe in raw.get("recipe", {}).values() if not recipe.get("hidden") and main_product(recipe) == item_name]


def gather_entity(raw, name, protected):
    """An entity's body sheets and icons, the icons of the items that place it and, for a spider vehicle, its legs' sheets"""
    entity = find_entity(raw, name)
    if entity is None:
        return None
    files = set()
    collect(entity, files, protected)
    files |= icon_filenames(entity)
    for item in placing_items(raw, name):
        files |= icon_filenames(item)
    if entity.get("type") == "spider-vehicle":
        legs = entity.get("spider_engine", {}).get("legs") or []
        if isinstance(legs, dict):
            legs = [legs]
        for leg_spec in legs:
            leg = raw.get("spider-leg", {}).get(leg_spec.get("leg"))
            if leg is not None:
                collect(leg, files, protected)
    return files


def gather_item(raw, name, protected):
    """An item's icons and belt pictures, the icons of the recipes that make it, the grid sprite of the equipment it places
    and, for an armor, the sheets of the character's animations for it"""
    item = find_named(raw, name, "stack_size")
    if item is None:
        return None
    files = icon_filenames(item)
    collect(item.get("pictures"), files, protected)
    for recipe in item_recipes(raw, name):
        files |= icon_filenames(recipe)
    if item.get("place_as_equipment_result"):
        equipment = find_named(raw, item["place_as_equipment_result"], "shape")
        if equipment is not None:
            collect(equipment.get("sprite"), files, protected)
    for character in raw.get("character", {}).values():
        for animation in character.get("animations") or []:
            if name in (animation.get("armors") or []):
                collect(animation, files, protected)
    return files


def gather_planet(raw, name, protected):
    """A planet's icons and star map icons, and the icons of the technologies discovering it (not the constant overlay they share)"""
    planet = raw.get("planet", {}).get(name)
    if planet is None:
        return None
    files = icon_filenames(planet)
    if planet.get("starmap_icon"):
        files.add(planet["starmap_icon"])
    for icon in planet.get("starmap_icons") or []:
        if icon.get("icon"):
            files.add(icon["icon"])
    for tech in raw.get("technology", {}).values():
        for effect in tech.get("effects") or []:
            if effect.get("type") == "unlock-space-location" and effect.get("space_location") == name:
                files |= {f for f in icon_filenames(tech) if "/constants/" not in f}
    return files


GATHERERS = {"entity": gather_entity, "item": gather_item, "planet": gather_planet}


def gather(raw, entries):
    """(name -> set of original filenames (sheets and icons), filename -> protected rectangles)"""
    per_name = {}
    protected = {}
    for name, params in entries.items():
        files = GATHERERS[params["kind"]](raw, name, protected)
        if files is None:
            print("not in the dump, skipped:", name, file=sys.stderr)
            continue
        per_name[name] = files
    return per_name, protected


# Color math on float32 arrays in [0, 1]

def rgb_to_hsv(rgb):
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mx = rgb.max(-1)
    mn = rgb.min(-1)
    d = mx - mn
    h = np.zeros_like(mx)
    has = d > 1e-6
    rm = has & (mx == r)
    gm = has & (mx == g) & ~rm
    bm = has & ~rm & ~gm
    h[rm] = ((g - b)[rm] / d[rm]) % 6
    h[gm] = (b - r)[gm] / d[gm] + 2
    h[bm] = (r - g)[bm] / d[bm] + 4
    s = np.where(mx > 1e-6, d / np.maximum(mx, 1e-6), 0).astype(np.float32)
    return h * 60, s, mx


def hsv_to_rgb(h, s, v):
    h6 = (h % 360) / 60
    i = np.floor(h6).astype(int) % 6
    f = h6 - np.floor(h6)
    p = v * (1 - s)
    q = v * (1 - s * f)
    t = v * (1 - s * (1 - f))
    r = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [v, q, p, p, t, v])
    g = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [t, v, v, q, p, p])
    b = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [p, p, t, v, v, q])
    return np.stack([r, g, b], -1).astype(np.float32)


def luminance(rgb):
    return 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]


def colorize(rgba, color, weight, strength=STRENGTH):
    """Each pixel becomes its brightness times the color, by weight (0..1 per pixel) and strength"""
    tint = np.array(color, dtype=np.float32)
    # Scale the color so a grey keeps its brightness, but not so far that light pixels clip to neon
    tint = tint / max(float(luminance(tint)), 1e-6)
    tint = tint * min(1.0, MAX_GAIN / float(tint.max()))
    colored = np.clip(luminance(rgba[..., :3])[..., None] * tint, 0, 1)
    w = (weight * strength)[..., None]
    out = rgba.copy()
    out[..., :3] = rgba[..., :3] * (1 - w) + colored * w
    return out


def hue_distances(h, hues):
    distance = np.full(h.shape, 360.0, dtype=np.float32)
    for hue in hues:
        distance = np.minimum(distance, np.abs(((h - hue + 180) % 360) - 180))
    return distance


def paint_mask(rgba, params):
    """The painted parts (or, in grey mode, the light metal plates) as a 0..1 weight per pixel (see the top of the file)"""
    h, s, v = rgb_to_hsv(rgba[..., :3])
    opaque = rgba[..., 3] > 0.5
    if params["mode"] == "grey":
        strong = opaque & (s <= params["smax"]) & (v >= params["val"]) & (v <= params["vmax"])
        weak = opaque & (s <= params["smax"] + 0.12) & (v >= params["val"] * 0.6)
    else:
        distance = hue_distances(h, params["hues"])
        strong = opaque & (distance <= params["half"] * 0.75) & (s >= params["sat"]) & (v >= params["val"])
        weak = opaque & (distance <= params["half"]) & (s >= params["low"]) & (v >= 0.1)
    if not strong.any():
        return np.zeros(rgba.shape[:2], dtype=np.float32)
    mask = apply_hysteresis_threshold(strong.astype(np.uint8) * 2 + weak.astype(np.uint8), 0.5, 1.5)
    # Fill by panel: where the grown mask is dense, the highlights, rivets and weathering between its pixels are paint too
    small = max(rgba.shape[0], rgba.shape[1]) <= 128
    window = 3 if small else int(params["win"])
    if window > 1:
        density = uniform_filter(mask.astype(np.float32), size=window, mode="constant")
        mask = mask | ((density >= params["dens"]) & opaque)
    radius = 1 if small else int(params["close"])
    if radius > 0:
        mask = binary_closing(mask, disk(radius)) & (rgba[..., 3] > 0)
    mask = remove_small_objects(mask, min_size=int(params["min"]))
    mask = remove_small_holes(mask, area_threshold=int(params["hole"]))
    weight = gaussian_filter(mask.astype(np.float32), EDGE_SIGMA)
    return np.clip(weight, 0, 1) * (rgba[..., 3] > 0)


def base_hue(params):
    return params["hues"][0] if params["hues"] else 30.0


def hue_distance(a, b):
    return abs(((a - b + 180) % 360) - 180)


def dupe_colors(params, dupe_numbers):
    """dupe number -> (hue, saturation): the line's own list, else the palette hues farthest from the paint hue"""
    chosen = list(params["dupes"])
    if len(chosen) < len(dupe_numbers):
        origin = base_hue(params)
        for hue in sorted(PALETTE_HUES, key=lambda h: -min([hue_distance(h, origin)] + [hue_distance(h, c[0]) for c in chosen])):
            if len(chosen) >= len(dupe_numbers):
                break
            if all(hue_distance(hue, c[0]) >= 40 for c in chosen):
                chosen.append((hue, DUPE_SATURATION))
    return {n: chosen[i] for i, n in enumerate(dupe_numbers)}


def entry_numbers(params, default_numbers):
    """The dupe numbers a line gets: one per color in its dupes= list, else the default"""
    if params["dupes"]:
        return list(range(2, 2 + len(params["dupes"])))
    return list(default_numbers)


def dupe_color(color):
    hue, sat = color
    rgb = hsv_to_rgb(np.array([hue], dtype=np.float32), np.array([sat], dtype=np.float32), np.array([1.0], dtype=np.float32))[0]
    return tuple(float(c) for c in rgb)


def hue_rotate(rgba, degrees):
    """Every pixel's hue turned by degrees (a rotation about the grey axis, so greys stay grey): for planets, a whole other world rather than a painted part"""
    theta = math.radians(degrees)
    c, s = math.cos(theta), math.sin(theta)
    k = (1 - c) / 3
    r = math.sqrt(1 / 3) * s
    m = np.array([[c + k, k - r, k + r], [k + r, c + k, k - r], [k - r, k + r, c + k]], dtype=np.float32)
    out = rgba.copy()
    out[..., :3] = np.clip(rgba[..., :3] @ m.T, 0, 1)
    return out


def mip_blocks(width, height):
    """(x, size) of each mip level of an icon sheet, laid side by side at halving sizes (a sheet without mips is one block)"""
    if width <= height:
        return [(0, width)]
    blocks, x, size = [], 0, height
    while x < width and size >= 1:
        blocks.append((x, size))
        x += size
        size //= 2
    return blocks


def split_weight(weight, split):
    """The weight right of (side) or below (layer) the line that halves its area in each mip level, so the rest keeps the original's color"""
    out = np.zeros_like(weight)
    height, width = weight.shape
    for x0, size in mip_blocks(width, height):
        block = weight[:size, x0:x0 + size]
        if block.sum() <= 0:
            continue
        axis = 0 if split == "side" else 1
        totals = np.cumsum(block.sum(axis=axis))
        mid = int(np.searchsorted(totals, totals[-1] / 2))
        keep = np.zeros_like(block)
        if split == "side":
            keep[:, mid:] = 1
        else:
            keep[mid:, :] = 1
        out[:size, x0:x0 + size] = block * keep
    return out


def recolor(rgba, params, color, weight=None):
    if params["mode"] == "rotate":
        return hue_rotate(rgba, color[0])
    if params["mode"] == "whole":
        weight = np.ones(rgba.shape[:2], dtype=np.float32) * (rgba[..., 3] > 0)
    elif weight is None:
        weight = paint_mask(rgba, params)
    if params["split"] is not None:
        weight = split_weight(weight, params["split"])
    return colorize(rgba, dupe_color(color), weight, params["strength"])


def load_rgba(path):
    return (np.asarray(Image.open(path).convert("RGBA")).astype(np.float32) / 255)


def to_image(rgba):
    return Image.fromarray((np.clip(rgba, 0, 1) * 255).astype(np.uint8), "RGBA")


def save_sheet(rgba, out_path):
    """Writes the sheet and returns its size in bytes"""
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    image = to_image(rgba)
    # 256 colors is visually the same for these sheets and about a sixth of the size (vanilla ships palette PNGs too)
    image = image.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)
    image.save(out_path, optimize=True)
    return os.path.getsize(out_path)


def process(job):
    filename, params, colors, rects = job
    mod, rest = resolve(filename)
    rgba = load_rgba(source_path(filename))
    weight = paint_mask(rgba, params) if params["mode"] in ("paint", "grey") else None
    written = []
    for n, color in sorted(colors.items()):
        out = recolor(rgba, params, color, weight)
        for x, y, w, h in rects:
            out[y:y + h, x:x + w] = rgba[y:y + h, x:x + w]
        written.append(save_sheet(out, os.path.join(OUT_DIR, str(n), mod, rest)))
    # A planet's tints (see the header): the whole image turned by each angle
    for degrees in params["tints"]:
        written.append(save_sheet(hue_rotate(rgba, degrees), os.path.join(OUT_DIR, TINT_FOLDER.format(degrees), mod, rest)))
    return filename, written


def most_painted(sheets, params, count):
    """The sheets with the most masked pixels (judged on thumbnails)"""
    def painted_pixels(f):
        image = Image.open(source_path(f)).convert("RGBA")
        image.thumbnail((512, 512))
        rgba = np.asarray(image).astype(np.float32) / 255
        return float(paint_mask(rgba, params).sum()) if params["mode"] in ("paint", "grey") else float((rgba[..., 3] > 0).sum())
    return sorted(sheets, key=painted_pixels, reverse=True)[:count]


def views(files, params, sheet_count):
    """(file, crop size, zoom) to show: the icons at 4x (their full-size mip), then the sheets with the most paint at 2x"""
    if params["mode"] == "rotate":
        # Planets: whole images, the small icons enlarged
        return [(f, 64, 4) if Image.open(source_path(f)).width <= 64 else (f, 512, 1) for f in files]
    icons = [f for f in files if "/icons/" in f]
    sheets = [f for f in files if "/icons/" not in f]
    return [(f, 64, 4) for f in icons[:4]] + [(f, 260, 2) for f in most_painted(sheets, params, sheet_count)]


def zoomed(rgba, zoom):
    image = to_image(rgba)
    return image.resize((image.width * zoom, image.height * zoom), Image.Resampling.NEAREST)


def save_rows(rows, path, gap):
    width = max(sum(im.width + gap for im in row) for row in rows)
    height = sum(max(im.height for im in row) + gap for row in rows)
    canvas = Image.new("RGBA", (width, height), (48, 48, 48, 255))
    y = 0
    for row in rows:
        x = 0
        for im in row:
            canvas.paste(im, (x, y), im)
            x += im.width + gap
        y += max(im.height for im in row) + gap
    os.makedirs(os.path.dirname(path), exist_ok=True)
    canvas.save(path)


def write_preview(name, files, params, colors, rects_by_file, out_dir):
    """Icons and the two sheets with the most colored parts, top-left corners: original, then each dupe, then each planet tint"""
    rows = []
    for f, crop_size, zoom in views(files, params, 2):
        rgba = load_rgba(source_path(f))
        crop = rgba[:min(rgba.shape[0], crop_size), :min(rgba.shape[1], crop_size)]
        variants = [crop]
        for n, color in sorted(colors.items()):
            out = recolor(rgba, params, color)
            for x, y, w, h in rects_by_file.get(f, []):
                out[y:y + h, x:x + w] = rgba[y:y + h, x:x + w]
            variants.append(out[:crop.shape[0], :crop.shape[1]])
        for degrees in params["tints"]:
            variants.append(hue_rotate(crop, degrees))
        rows.append([zoomed(v, zoom) for v in variants])
    if rows:
        save_rows(rows, os.path.join(out_dir, name + ".png"), 0)


def write_inspection(name, files, params, colors, rects_by_file, out_dir):
    """Icons and the sheet with the most paint: original, the mask (magenta over grey), dupe 2"""
    first_color = sorted(colors.items())[0][1]
    rows = []
    for f, crop_size, zoom in views(files, params, 1):
        rgba = load_rgba(source_path(f))
        rgba = rgba[:min(rgba.shape[0], crop_size), :min(rgba.shape[1], crop_size)]
        weight = paint_mask(rgba, params) if params["mode"] in ("paint", "grey") else np.ones(rgba.shape[:2], dtype=np.float32) * (rgba[..., 3] > 0)
        grey = luminance(rgba[..., :3])[..., None] * np.ones(3, dtype=np.float32) * 0.6 + 0.2
        shown = rgba.copy()
        shown[..., :3] = grey * (1 - weight[..., None]) + np.array([1.0, 0.1, 0.9], dtype=np.float32) * weight[..., None]
        dupe = recolor(rgba, params, first_color, weight)
        for x, y, w, h in rects_by_file.get(f, []):
            dupe[y:y + h, x:x + w] = rgba[y:y + h, x:x + w]
        rows.append([zoomed(v, zoom) for v in (rgba, shown, dupe)])
    if rows:
        save_rows(rows, os.path.join(out_dir, name + ".png"), 6)


def write_manifest(highest):
    lines = [
        "-- Generated by dev/make-dupe-graphics.py; don't edit",
        "-- Original sprite path -> the highest dupe number n with a copy at graphics/dupes/<n>/<same path> (every number from 2 up to it has one)",
        "return {",
        "    max_dupe = " + str(max(highest.values())) + ",",
        "    files = {",
    ]
    for filename in sorted(highest):
        lines.append("        [" + json.dumps(filename) + "] = " + str(highest[filename]) + ",")
    lines += ["    },", "}", ""]
    with open(MANIFEST, "w") as f:
        f.write("\n".join(lines))


def write_tint_manifest():
    """The planet tints on disk (every graphics/dupes/tint-<degrees>/ folder), per original path; returns how many paths"""
    tints = {}
    pattern = re.compile("^" + TINT_FOLDER.format(r"(\d+)") + "$")
    for folder in sorted(os.listdir(OUT_DIR)):
        match = pattern.match(folder)
        if match is None:
            continue
        root = os.path.join(OUT_DIR, folder)
        for directory, _, names in os.walk(root):
            for file_name in names:
                if not file_name.endswith(".png"):
                    continue
                mod, _, rest = os.path.relpath(os.path.join(directory, file_name), root).replace(os.sep, "/").partition("/")
                tints.setdefault("__" + mod + "__/" + rest, []).append(int(match.group(1)))
    lines = [
        "-- Generated by dev/make-dupe-graphics.py; don't edit",
        "-- Original sprite path -> the hue rotations in degrees with a tinted copy at graphics/dupes/tint-<degrees>/<same path> (lib/planet-tints.lua)",
        "return {",
        "    files = {",
    ]
    for filename in sorted(tints):
        lines.append("        [" + json.dumps(filename) + "] = {" + ", ".join(str(d) for d in sorted(tints[filename])) + "},")
    lines += ["    },", "}", ""]
    with open(TINT_MANIFEST, "w") as f:
        f.write("\n".join(lines))
    return len(tints)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dump", required=True, help="data-raw-dump.json from a run with the dupes off")
    parser.add_argument("--entities", default=os.path.join(REPO, "dev", "dupe-entities.txt"))
    parser.add_argument("--items", default=os.path.join(REPO, "dev", "dupe-items.txt"))
    parser.add_argument("--planets", default=os.path.join(REPO, "dev", "dupe-planets.txt"))
    parser.add_argument("--dupes", type=int, default=3, help="highest dupe number (2..N) for a line without dupes=; a line with dupes= gets one dupe per color")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--only", action="append", help="only these entities, items or planets (no manifest rewrite)")
    parser.add_argument("--preview", help="write a preview image per entity or item to this folder instead of generating")
    parser.add_argument("--inspect", help="write a mask inspection image per entity or item to this folder instead of generating")
    parser.add_argument("--list", action="store_true", help="print the sheets per entity or item and exit")
    args = parser.parse_args()

    entries = parse_list(args.entities, "entity")
    for path, kind in ((args.items, "item"), (args.planets, "planet")):
        for name, params in parse_list(path, kind).items():
            if name in entries:
                sys.exit(f"{name} is listed twice ({entries[name]['kind']} and {kind})")
            entries[name] = params
    if args.only:
        entries = {name: params for name, params in entries.items() if name in args.only}
    with open(args.dump) as f:
        raw = json.load(f)
    per_name, protected = gather(raw, entries)

    default_numbers = list(range(2, args.dupes + 1))
    owner = {}
    highest = {}
    colors = {}
    for name, files in per_name.items():
        params = entries[name]
        numbers = entry_numbers(params, default_numbers)
        present = sorted(f for f in files if source_path(f))
        missing = sorted(f for f in files if not source_path(f))
        size = sum(os.path.getsize(source_path(f)) for f in present)
        colors[name] = dupe_colors(params, numbers)
        print(f"{name} ({params['kind']}, {params['mode']}, dupes " + ", ".join(f"{n}: {c[0]:.0f}/{c[1]:.2f}" for n, c in sorted(colors[name].items())) + (", tints " + ",".join(str(d) for d in params["tints"]) if params["tints"] else "") + f"): {len(present)} files, {size / 1e6:.1f} MB" + (f", missing {len(missing)}" if missing else ""))
        if args.list:
            for f in present:
                print("   ", f, "(protected " + str(protected[f]) + ")" if f in protected else "")
            for f in missing:
                print("    MISSING", f)
        for f in present:
            if f in owner:
                if entries[owner[f]] != params:
                    print(f"  note: {f} is shared with {owner[f]}, recolored its way", file=sys.stderr)
            else:
                owner[f] = name
                highest[f] = max(numbers)
    if args.list:
        return

    if args.preview:
        for name, files in per_name.items():
            write_preview(name, sorted(f for f in files if source_path(f)), entries[name], colors[name], protected, args.preview)
        print("previews in", args.preview)
        return
    if args.inspect:
        for name, files in per_name.items():
            write_inspection(name, sorted(f for f in files if source_path(f)), entries[name], colors[name], protected, args.inspect)
        print("inspections in", args.inspect)
        return

    jobs = [(f, entries[owner[f]], colors[owner[f]], protected.get(f, [])) for f in sorted(owner)]
    total = 0
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.jobs) as pool:
        for i, (filename, sizes) in enumerate(pool.map(process, jobs), 1):
            total += sum(sizes)
            if i % 25 == 0 or i == len(jobs):
                print(f"  {i}/{len(jobs)} sheets, {total / 1e6:.1f} MB so far", flush=True)
    if not args.only:
        write_manifest(highest)
        print("manifest:", os.path.relpath(MANIFEST, REPO), len(highest), "files")
    # The tint manifest lists what's on disk, so a run with --only keeps it whole too
    if any(entries[name]["tints"] for name in per_name):
        print("tint manifest:", os.path.relpath(TINT_MANIFEST, REPO), write_tint_manifest(), "files")


if __name__ == "__main__":
    main()
