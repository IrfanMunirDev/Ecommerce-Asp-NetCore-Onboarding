# Onboarding Progress

> Session log and resume pointer. `/continue` reads this first to avoid re-exploring completed areas.

## Current focus

Fix the Tier 1 false stack claims (Identity, Stripe, domain), then run `/continue` targeting Tier 3 to trace the real cart flow.

## Session log

| Date | Area | Summary | Next |
|------|------|---------|------|
| 2026-11-06 | Bootstrap | `/start` detected a single-repo .NET 8 MVC app under `ECommerce/`; seeded state files and per-unit stubs | `/audit` |
| 2026-11-07 | Audit | Scored Tiers 1–6 at **38%** overall. Spot-checks disproved three stated integrations and relocated the `DbContext`. Q-001/Q-002/Q-003 resolved. | Fix Tier 1, then `/continue` Tier 3 |

## Completed areas

- Repository layout and stack detection (manifests + top-level directory listing only)
- Tier scoring and first code spot-check (`/audit`, 2026-11-07)

## Handoff notes

- Only `Program.cs`, `ECommerce.csproj`, `OrdersController.cs`, `EcommerceContext.cs`, the 6 per-repo docs, and `README.md` have been read. Controller internals beyond `OrdersController` are unexplored.
- **The README is unreliable** as a spec: it claims Razor Pages, ASP.NET Core Identity, and Stripe. None are implemented. See the corrections table in `onboarding-audit.md`.
- The app is a **cinema ticketing** domain (Actors, Cinemas, Movies, Producers, Orders), not a generic store.
- `AGENTS.md` is the single source of the doc-first workflow, read by both Cursor and OpenCode. Cursor-specific scoping lives in `.cursor/rules/` (globs / description / manual), not a duplicate always-on rule.
