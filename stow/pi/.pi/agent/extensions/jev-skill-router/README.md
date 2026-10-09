# Jev skill router

Observe-only skill routing for Pi.

On each substantive, non-queued prompt the extension:

1. reads the TypeSafe API key from 1Password once per Pi runtime
2. builds a routing catalog from model-invoked skills under `~/skills/skills`
3. asks `typesafe/jev-latest` which skill best fits
4. shows `Jev → <skill> <confidence>` in the status area
5. logs the recommendation and later `SKILL.md` reads to `$XDG_STATE_HOME/pi/jev-skill-router.jsonl`

The extension does not inject, invoke, or enable a skill. Telemetry stores a prompt hash and length-independent routing metadata, never prompt text or credentials.

Environment overrides:

- `PI_JEV_API_KEY_REF`: 1Password secret reference
- `PI_SKILLS_ROOT`: skill catalog root
- `TYPESAFE_API_KEY`: bypasses the 1Password lookup

Run `/jev-status` to inspect the current catalog size and latest recommendation.
