# Onboarding Progress

> Session log and resume pointer. `/continue` reads this first to avoid re-exploring completed areas.

## Current focus

Run `/audit` to score the tiers, then fill `repos/ecommerce/architecture.md` and `repos/ecommerce/request-flow.md`.

## Session log

| Date | Area | Summary | Next |
|------|------|---------|------|
| 2026-11-06 | Bootstrap | `/start` detected a single-repo .NET 8 MVC app under `ECommerce/`; seeded state files and per-unit stubs | `/audit` |

## Completed areas

- Repository layout and stack detection (manifests + top-level directory listing only)

## Handoff notes

- Only `ECommerce/Program.cs`, `ECommerce/ECommerce.csproj`, and `README.md` have been read. No source internals explored yet.
- Stripe integration is claimed in the README; its implementation location is not yet verified.
- `AGENTS.md` is the single source of the doc-first workflow, read by both Cursor and OpenCode. Cursor-specific scoping lives in `.cursor/rules/` (globs / description / manual), not a duplicate always-on rule.
