# AGENTS.md

Shared agent instructions for this repository. Read by OpenCode, Cursor, and other
AGENTS.md-aware agents. This is the single source of the doc-first workflow — there
is deliberately no duplicate always-on rule under `.cursor/rules/`. Cursor-only
scoping (globs, agent-requested, manual) lives there instead.

## Project knowledge first

Before analyzing code or proposing changes:

1. Read the onboarding docs, in this order:
   - `docs/onboarding/project-memory.md` — config, stack, source roots, conventions
   - `docs/onboarding/progress.md` — current focus and handoff notes
   - `docs/onboarding/repositories-overview.md` — units in this repo
2. For work inside a unit, read `docs/onboarding/repos/<slug>/` next. Start with
   `overview.md` and `important-files.md`.
3. Only then open source files. Scope to the module the task touches; do not scan
   the whole workspace unless asked.
4. Check `docs/onboarding/open-questions.md` for known unknowns before assuming.

## Before implementing

- Explain the current behavior.
- Name the affected unit(s) and files.
- Give a short implementation plan and call out risks.
- Follow existing patterns in the codebase; prefer the smallest change that works.

## After implementing

- Review your own diff.
- Update onboarding docs if you learned something durable (architecture, flow,
  conventions). Don't duplicate facts across state files — `project-memory.md` is
  the source of truth.
- Move answered items out of `open-questions.md`.

## Repo facts

- Single solution, one web project: `ECommerce/ECommerce.csproj`.
- .NET 8 ASP.NET Core MVC, EF Core 8, SQL Server, ASP.NET Core Identity.
- Data access is expected to go through `RepositoryServices/` + `UnitOfWorkRepo/`.
- No test project exists yet.

## Token discipline

Keep context small. These docs exist so agents don't re-scan the repo. Prefer
targeted reads over broad greps, and never dump whole directories into context.
