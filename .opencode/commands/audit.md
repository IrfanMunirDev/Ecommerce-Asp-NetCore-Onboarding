---
description: Audit onboarding docs and report completion by tier
agent: build
---

Run the project-onboarding **audit** skill.

1. Read `.agents/skills/audit/SKILL.md` and follow it exactly.
2. Read the state files before touching code:
   `docs/onboarding/project-memory.md`, `progress.md`, `repositories-overview.md`.
3. Skim per-repo docs by headers and fill status only — not full content.
4. Write the result to `docs/onboarding/onboarding-audit.md`.
5. If `docs/onboarding/` is missing, stop and tell me to run `/start` first.

Sample and spot-check; never scan the whole codebase.

$ARGUMENTS
