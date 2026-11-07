# Open Questions

> Blocked items and unanswered questions. Remove entries when resolved; do not store durable facts here.

| ID | Area | Question | Blocker | Added |
|----|------|----------|---------|-------|
| — | — | No open questions | — | — |

## Resolved

| ID | Question | Resolution | Date |
|----|----------|------------|------|
| Q-001 | README says "Razor Pages", but the repo has `Controllers/` + `Views/`. Which is authoritative? | **MVC is authoritative.** 6 controllers and 31 `.cshtml` views under `Views/`; no `.cshtml` page models. The README wording is inaccurate. | 2026-11-07 |
| Q-002 | Where is the Stripe integration implemented, and how are keys supplied? | **There is no Stripe integration.** Zero `Stripe` references across `.cs`, `.cshtml`, `.json`, and `.csproj`. Nothing to configure. The README claim is false. | 2026-11-07 |
| Q-003 | Is `QuickGrid.EntityFrameworkAdapter` actually used? | **No.** Zero `QuickGrid` references in source or views, no `AddQuickGrid` registration, no `.razor` files. The package reference is dead weight. | 2026-11-07 |
