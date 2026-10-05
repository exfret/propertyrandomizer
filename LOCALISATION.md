# Translating the mod

The English catalogue is in `locale/en/core.cfg` and `locale/en/locale.cfg`.
Copy these files into `locale/<language-code>/` and translate the values after
`=`. Keep section names and keys unchanged. The layout and lookup syntax follow
[Factorio’s localisation tutorial](https://wiki.factorio.com/Tutorial:Localisation).

`core.cfg` covers the main panel, dependency explorer, messages, warnings,
randomized descriptions and generated prototype names. `locale.cfg` retains the
existing settings, randomization labels and customizer catalogue. Individual customizer names use the
`propertyrandomizer-randomization-name` section; its controls and help use
`propertyrandomizer-customizer`. Invalid imports use the localized warning
catalogue, while preserving English diagnostics for logs and existing callers.

Preserve `__1__`, `__2__`, and other numbered parameters, but move them wherever
the grammar needs them. They can stand for translated prototype names, counts,
colors or technical identifiers. Preserve rich-text markup such as `[color=…]`,
`[font=…]` and `[img=…]`, the control placeholders `__CONTROL__…__`, and `\n`
where a line break is intended. Leading spaces in tooltip entries separate the
label from the numerical percentage. Recipe-prefix keys retain the original
English choices, including spaces; translate only their values.

Prototype names still use the existing rules in `lib/locale.lua`. Generated
names wrap those resolved names as parameters; translators can reorder the full
phrase. Numerical annotations accept LocalisedStrings for their addons. Shared
warning parsing keeps English diagnostic strings for existing customizer callers
and provides a parallel `localised_warnings` list for the main panel. Logs remain
English for diagnosis. Override syntax, graph identities and prototype IDs remain
literal technical strings. Unrecognized extension node types fall back to their
technical identifiers.

Explorer selectors store canonical graph keys independently of their captions.
Customizer selectors likewise keep override IDs separate from localized names;
search accepts translated names as well as technical IDs.
Their search also matches per-player translations as they arrive, while retaining
search by technical ID. Latin ASCII case is ignored; other scripts currently use
literal substring matching. Caches reset when the graph is rebuilt or the player
changes locale.

Checks: `lua lib/test-localisation.lua`, `lua lib/test-customization.lua`, `lua scripts/test-customizer.lua`, and
`lua scripts/test-explorer-localisation.lua`. The localisation regression checks table
addons, parameter/nesting limits, warning compatibility, translated searches,
failed translations and stale results. Use `python3 dev/run-tests.py` for startup
and runtime checks. For visual QA, use a locale with expanded strings and check
the Home and Explorer tabs, filtered selections, context tooltips and the
Derandomizer; home labels and the explorer introduction wrap to the panel width.

The normal `dev/run-tests.py` runner checks the localization catalogue, runs
negative tests for the guard, and runs the standalone GUI/localization tests
against its snapshot before launching Factorio. This also applies to `--staged`.
Pre-commit audits the staged catalogue and Lua sources. For quick checks, run
`python3 dev/check-localisation.py` and `python3 dev/test-localisation.py`.

The guard rejects literal prose in captions, tooltips, GUI choice lists, chat
prints, prototype names/descriptions, and label-helper calls. It also rejects
missing mod-owned literal locale keys and duplicate English keys. Locale
parameters can contain technical IDs; logs, override syntax, test fixtures and
inactive legacy modules are excluded. Static checks do not infer arbitrary
variable/function data flow. The customizer GUI tests cover that gap for every
current target, every advertised tuning choice, all import-error categories and
per-player translated search. Adding a numerical target or tuning value without
its English locale entry fails those tests.
