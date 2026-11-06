---
name: audit
description: Produce onboarding gap analysis with completion percentage and prioritized tiers. Use when auditing documentation coverage, measuring onboarding progress, finding codebase exploration gaps, or when the user runs /audit.
disable-model-invocation: true
---

# Audit Project

Slash trigger: `/audit`

Analyze onboarding documentation coverage and produce a prioritized gap report with completion percentage.

## Hard rules

- MUST read state files before exploring code.
- MUST write results to `onboarding-audit.md`.
- NEVER scan the entire codebase — sample and spot-check only.
- NEVER duplicate long prose into audit file — use tier tables and gap bullets.
- If `docs/onboarding/` is missing, tell the user to run `/start` first.

## Required reads

1. `docs/onboarding/project-memory.md`
2. `docs/onboarding/progress.md`
3. `docs/onboarding/repositories-overview.md`
4. Skim existing per-repo docs under `docs/onboarding/repos/` (headers and fill status only — not full content)

## Audit tiers

Score each tier 0–100% based on documentation completeness in state files (not guesswork from code alone):

| Tier | Focus | Check |
|------|-------|-------|
| 1 | Project overview | `repositories-overview.md`, root README, `project-memory.md` |
| 2 | Architecture | per-repo `architecture.md` files |
| 3 | Request/data flow | per-repo `request-flow.md` files |
| 4 | Patterns & conventions | per-repo `common-patterns.md` files |
| 5 | Integrations | per-repo `integrations.md`, external services |
| 6 | Important files index | per-repo `important-files.md` |
| 7 | DevOps & deployment | mark **skipped** unless user has access |

Spot-check code only when doc claims need verification (max 5–10 files total).

## Completion calculation

```
overall_completion = average of tiers 1–6 (exclude Tier 7 from denominator unless explored)
```

Document formula and per-tier scores in `onboarding-audit.md`.

## Write onboarding-audit.md

Include:
- `Last audited:` ISO date
- Overall completion %
- Per-tier table: tier, score, status, top gaps
- Prioritized gap list (highest ROI first)
- Recommended next `/continue` target

## Output to user

Provide:
- Overall completion %
- Top 3 gaps
- Recommended next command: `/continue` with suggested area

## Token budget

- 4 state files max
- Skim per-repo doc headers only
- 5–10 source files for spot-checks if needed
- Stop after audit file is written
