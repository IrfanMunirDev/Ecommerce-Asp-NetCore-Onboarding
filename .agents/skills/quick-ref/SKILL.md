---
name: quick-ref
description: Answer "where is X?" questions using onboarding state files without a full codebase scan. Use for quick lookups, finding files, onboarding cheat sheet, or when the user runs /quick-ref.
disable-model-invocation: true
---

# Quick Reference

Slash trigger: `/quick-ref`

Answer location and "where is X?" questions using persisted onboarding state — not a full repo scan.

## Hard rules

- MUST search state files first.
- MUST NOT scan the entire codebase unless state files have no answer and user confirms a targeted lookup.
- Read at most 4 state files before responding.
- If onboarding not initialized, tell user to run `/start`.

## Lookup order

1. `docs/onboarding/project-memory.md` — config, conventions, source roots
2. `docs/onboarding/repositories-overview.md` — repo/module index
3. Relevant `docs/onboarding/repos/<slug>/important-files.md`
4. Relevant `docs/onboarding/repos/<slug>/overview.md` or `architecture.md`

Use grep/search within `docs/onboarding/` before touching source code.

## If not found in state

1. Tell user the topic is not documented yet.
2. Suggest `/continue` or `/learn` to explore and document that area.
3. Only if user insists: do a **bounded** search (one directory from `source_roots`, max 5 files).

## Response format

```markdown
## Query: [user question]

**Answer:** [direct answer with paths]

**Source:** [state file(s) used]

**Related files:**
- `path/to/file` — [role]

**Not documented?** Run `/continue` to explore [suggested area].
```

## Token budget

- 2–4 state files
- 0 source files unless state is insufficient and user confirms
- Stop after formatted answer
