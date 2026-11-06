---
name: update-docs
description: Capture new knowledge into onboarding state files after completing work. Use when updating project memory, recording discoveries, post-task documentation, or when the user runs /update-docs.
disable-model-invocation: true
---

# Update Docs

Slash trigger: `/update-docs`

Capture **new** knowledge from the current session into onboarding state files. Do not re-explore the codebase unless a fact needs verification.

## Hard rules

- MUST read relevant state files before writing.
- MUST only add or update information that is new or changed — never rewrite entire files unnecessarily.
- NEVER duplicate the same fact across multiple state files.
- NEVER trigger a full codebase scan.
- If `docs/onboarding/` is missing, tell the user to run `/start` first.

## State file roles (write to the correct file only)

| File | Write here when... |
|------|-------------------|
| `project-memory.md` | Stack, config, conventions, or project-wide facts change |
| `progress.md` | Session work completed, area explored, or handoff note needed |
| `onboarding-audit.md` | Gap closed, tier score should change, item completed |
| `open-questions.md` | Blocker found or resolved |
| `repositories-overview.md` | New repo/module discovered or renamed |
| `repos/<slug>/*.md` | Domain-specific detail (architecture, flows, patterns, etc.) |

## Procedure

1. Ask user what was learned or infer from conversation context.
2. Read only the state files you will modify (max 4).
3. Apply minimal edits: append to progress, patch relevant sections, mark audit items done.
4. If a claim needs verification, read ≤3 source files — not a broad scan.
5. Summarize what was updated and which files changed.

## What NOT to do

- Do not regenerate all docs from scratch
- Do not copy conversation verbatim — distill durable facts
- Do not move Tier 7 content into Tier 1–6 without user confirmation

## Output to user

List:
- Files updated
- Facts captured (bullets)
- Suggested follow-up: `/audit` if major gaps closed, or `/continue` for next area
