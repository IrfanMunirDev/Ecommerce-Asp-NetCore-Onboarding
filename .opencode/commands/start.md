---
description: Bootstrap docs/onboarding state for this repo
agent: build
---

Run the project-onboarding **start** skill.

1. Read `.agents/skills/start/SKILL.md` and follow it exactly.
2. Resolve its bundled assets relative to that directory: `templates/` for the
   state files and per-repo stubs, `rules/` for the Cursor rule.
3. Treat the repository root as the target. Do not scan source code beyond
   manifests and a top-level directory listing.
4. If `docs/onboarding/project-memory.md` already exists, read it first and honor
   its `docs_path` and `source_roots`, then resume instead of overwriting.

$ARGUMENTS
