---
name: learn
description: Deep-dive one module or domain in mentor mode with file pointers and teaching summary. Use when learning architecture, understanding a codebase area, mentor-style onboarding, or when the user runs /learn.
disable-model-invocation: true
---

# Learn Module

Slash trigger: `/learn`

Act as a mentor: deep-dive **one** module or domain the user specifies (or the weakest area from the audit), explain how it works, and point to the exact files to read.

## Hard rules

- MUST read state files before exploring code.
- MUST focus on exactly ONE module/domain per invocation.
- MUST end with a teaching summary and file pointer list.
- NEVER scan the entire codebase.
- If no module specified, pick the lowest-scoring area from `onboarding-audit.md` or ask the user to name one.
- If `docs/onboarding/` is missing, tell the user to run `/start` first.

## Required reads

1. `docs/onboarding/project-memory.md`
2. `docs/onboarding/onboarding-audit.md` — to pick or validate the module
3. Existing per-repo doc for the target module (if any) — do not read other per-repo docs

## Mentor procedure

1. Confirm the module/domain scope with the user if ambiguous.
2. Read entry points for that module only (from `important-files.md` or discovery).
3. Read 8–20 files max within the module boundary.
4. Trace one primary flow (e.g., request → handler → service → storage) — do not branch into unrelated modules.
5. Update the relevant per-repo docs with learned content (especially `architecture.md`, `request-flow.md`, `important-files.md`).
6. Append a brief entry to `progress.md`.

## Teaching summary format

```markdown
## Module: [name]

### What it does
[2–3 sentences]

### How it fits
[Relationship to rest of system]

### Key files
| File | Role |
|------|------|
| path/to/file | ... |

### Primary flow
[Step-by-step narrative with file refs]

### Conventions to know
[Bullets]

### What to explore next
[Suggested follow-up module or /continue target]
```

## Token budget

- 2–3 state files read
- 8–20 source files in one module
- Stop after teaching summary and doc updates
