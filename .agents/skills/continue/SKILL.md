---
name: continue
description: Pick the next highest-priority unexplored area from onboarding audit tiers and explore one bounded domain. Use for codebase exploration loops, continuing onboarding, next steps on a new project, or when the user runs /continue.
disable-model-invocation: true
---

# Continue Onboarding

Slash trigger: `/continue`

Resume the onboarding loop by exploring **one** bounded area, then updating state files so the next session can continue without a full re-scan.

## Hard rules

- MUST read state files before touching source code.
- MUST explore exactly ONE repo/module/domain per invocation.
- MUST update `progress.md` and relevant per-repo docs after exploration.
- NEVER scan the entire codebase.
- NEVER duplicate content across state files — each file has one role.
- If `docs/onboarding/` is missing, tell the user to run `/start` first.

## Required reads (in order)

1. `docs/onboarding/project-memory.md` — config, source roots, layout
2. `docs/onboarding/onboarding-audit.md` — tiers and gaps
3. `docs/onboarding/progress.md` — what was already explored
4. `docs/onboarding/open-questions.md` — only if the chosen area has blocked items

Max 4 state files. Do not read all per-repo docs upfront.

## Pick next area

1. From `onboarding-audit.md`, find the highest-priority tier with unexplored or incomplete items.
2. Skip Tier 7 (DevOps/infrastructure) unless user explicitly provided access or asked to explore it.
3. If user named a specific area, use that instead (still one area only).
4. If all tiers complete, suggest `/learn` on a weak area or `/audit` for refresh.

## Exploration scope (one area)

Within the chosen repo/module:
- Read entry points and 5–15 files max directly related to the area
- Follow imports/calls one level deep only
- Use `project-memory.md` `source_roots` to bound paths

Forbidden: recursive full-tree walks, reading unrelated modules, generating ERDs.

## Write-back

Update:
- `progress.md` — new session entry: date, area explored, key findings, next suggested area
- `onboarding-audit.md` — mark explored items, adjust completion % if applicable
- Relevant files under `docs/onboarding/repos/<slug>/` — fill sections for the explored domain only
- `open-questions.md` — add new blockers; remove resolved ones

Do not rewrite unrelated per-repo docs.

## Teaching summary (required)

End with a concise summary for the human:
- What area was explored
- 3–5 key findings with file paths
- What remains in this tier
- Suggested next `/continue` target

## Token budget

- 2–4 state files read
- 5–15 source files read
- 1 bounded domain explored
- Stop after write-back and summary
