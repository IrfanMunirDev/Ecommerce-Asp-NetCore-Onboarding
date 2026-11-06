# Onboarding Audit

> Gap analysis and completion tracking. `/audit` owns this file; other skills read it for priorities.

Last audited: 2026-11-06 (bootstrap only — not yet audited)

## Overall completion

**0%**

Formula: average of Tier 1–6 scores (Tier 7 excluded unless explored).

## Tier scores

| Tier | Focus | Score | Status | Top gaps |
|------|-------|-------|--------|----------|
| 1 | Project overview | 0 | not started | Only README + manifests read |
| 2 | Architecture | 0 | not started | Layering unverified; no diagram |
| 3 | Request/data flow | 0 | not started | No end-to-end trace |
| 4 | Patterns & conventions | 0 | not started | Repo/UoW usage unverified in code |
| 5 | Integrations | 0 | not started | Stripe + SQL Server config unread |
| 6 | Important files index | 0 | not started | Start-here map incomplete |
| 7 | DevOps & deployment | — | skipped | requires access |

## Prioritized gaps

1. Tier 2 — confirm actual layering and where `DbContext` is registered in `Program.cs`.
2. Tier 3 — trace one full request (e.g. product listing → checkout) with file references.
3. Tier 5 — locate Stripe payment code and the secrets/configuration path.

## Recommended next

`/audit`, then `/continue` targeting Tier 2 (architecture).
