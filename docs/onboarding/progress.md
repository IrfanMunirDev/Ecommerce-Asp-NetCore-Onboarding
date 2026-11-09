# Onboarding Progress

> Session log and resume pointer. `/continue` reads this first to avoid re-exploring completed areas.

## Current focus

Tier 4 patterns (`common-patterns.md`) and Tier 6 by-task index (`important-files.md`). After
that, create the test project so the GitLab pipeline can gate merges on failing tests.

## Session log

| Date | Area | Summary | Next |
|------|------|---------|------|
| 2026-11-06 | Bootstrap | `/start` detected a single-repo .NET 8 MVC app under `ECommerce/`; seeded state files and per-unit stubs | `/audit` |
| 2026-11-07 | Audit | Scored Tiers 1–6 at **38%** overall. Spot-checks disproved three stated integrations and relocated the `DbContext`. Q-001/Q-002/Q-003 resolved. | Fix Tier 1, then `/continue` Tier 3 |
| 2026-11-09 | Docs | Rewrote `README.md` (app, agent rules/commands/skills, GitLab CI/CD, MonsterASP hosting + diagnostics, GitLab primer, ticket roadmap). Fixed the Tier 1/2/3/5 claims in the state files; traced movie + cart flows with `file:line`; corrected the cart description (rows are persisted, not session-only). Re-audited at **74%**. | `/continue` Tier 4, then Tier 6 |

## Completed areas

- Repository layout and stack detection (manifests + top-level directory listing only)
- Tier scoring and first code spot-check (`/audit`, 2026-11-07)

## Handoff notes

- Only `Program.cs`, `ECommerce.csproj`, `OrdersController.cs`, `MoviesController.Filter`/`Index`, `ShoppingCart.cs`, `EcommerceContext.cs`, `README.md` and the onboarding docs have been read. CRUD actions, repositories internals and views are unexplored.
- **The README was unreliable** as a spec: it claimed Razor Pages, ASP.NET Core Identity, and Stripe. It has been rewritten against the source; the correction table is at its top.
- The app is a **cinema ticketing** domain (Actors, Cinemas, Movies, Producers, Orders), not a generic store.
- `AGENTS.md` is the single source of the doc-first workflow, read by both Cursor and OpenCode. Cursor-specific scoping lives in `.cursor/rules/` (globs / description / manual), not a duplicate always-on rule.
- Deployment knowledge (GitLab variables, SFTP layout, MonsterASP environment variables, the connection-string failure mode) is documented in `README.md` §7–§8 — read that before touching `.gitlab-ci.yml` or the hosting panel.
