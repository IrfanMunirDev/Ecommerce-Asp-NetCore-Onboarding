# Onboarding Audit

> Gap analysis and completion tracking. `/audit` owns this file; other skills read it for priorities.

Last audited: 2026-11-09 (documentation pass that rewrote `README.md` and corrected Tiers 1–3, 5, 7)

## Overall completion

**74%**

Formula: average of Tier 1–6 scores = (90 + 85 + 85 + 50 + 90 + 45) / 6.
Tier 7 is reported separately: it is now **documented** from the pipeline files and account
facts, but not verified against live GitLab/MonsterASP access.

## Tier scores

| Tier | Focus | Score | Status | Top gaps |
|------|-------|-------|--------|----------|
| 1 | Project overview | 90 | good | — |
| 2 | Architecture | 85 | good | cart's direct `DbContext` use now documented; no deployment diagram |
| 3 | Request/data flow | 85 | good | only movie + cart flows traced; CRUD screens summarised, not traced |
| 4 | Patterns & conventions | 50 | partial | `common-patterns.md` naming/error/logging sections still unfilled |
| 5 | Integrations | 90 | good | — |
| 6 | Important files index | 45 | partial | `important-files.md` by-task sections empty; controller map now lives in README + request-flow |
| 7 | DevOps & deployment | — | documented | written from `.gitlab-ci.yml`, `deploy/`, and account facts; no live verification |

## Verified corrections

All five original corrections have been applied. Kept here as a record so the same claims
are not reintroduced.

| Original claim | Reality | Status |
|---|---|---|
| ASP.NET Core Identity handles auth | **Not implemented.** Every `Identity` match is a SQL Server `IDENTITY` column inside EF migrations. | fixed in README, project-memory, overview, architecture, integrations |
| Stripe processes payments | **Not implemented.** Zero `Stripe` references. | fixed in README, project-memory, overview, architecture, integrations |
| `DbContext` lives in `data/` | It lives at `Models/EcommerceContext.cs`. `data/` holds only `MovieCategory.cs`, `ViewModels/`, `Cart/`. | fixed in architecture + README |
| Generic "product / order" e-commerce | Cinema ticketing: Actors, Cinemas, Movies, Producers, Orders. | fixed everywhere |
| Checkout / payment is the primary flow | No checkout or payment action exists. `OrdersController` only does cart operations. | replaced in request-flow with the verified cart trace |

## One further correction found during this pass

| Claim | Reality |
|---|---|
| "Cart lives in session" (in-memory only) | Only the **cart GUID** lives in session (`CartId`). Cart items are rows in `shoppingCartItems`, queried through `EcommerceContext`. `ShoppingCart` is the single type that bypasses the unit of work. |

## Confirmed by spot-check

- Movie filter path: `MoviesController.Filter` → `IUnitOfWork.Movies.FilterByName` → includes `Cinema`, `Producer` → reuses the `Index` view
- Cart path: `OrdersController` (`ShoppingCart` :21, `AddItemToCart` :37, `RemoveItemFCart` :51) → `ShoppingCart` → `EcommerceContext.shoppingCartItems`
- Cart ID: `session.GetString("CartId") ?? Guid.NewGuid()`, written back to session
- Repository + Unit of Work wired in DI — `Program.cs:23-24`; session + cart factory — `Program.cs:26-28`
- Startup migrations — `Program.cs:32-36` (`db.Database.Migrate()`)
- SQL Server through EF Core 8 — `ECommerce.csproj`, `appsettings*.json`
- Six migrations, 6 controllers, 31 views, 10 model files
- No test project in the solution
- Pipeline: build → publish (`win-x86`, framework-dependent, artifact 1 week) → manual deploy on default branch via lftp/SFTP with `app_offline.htm` and a `SITE_URL` health check

## Prioritized gaps

1. **Tier 4 — `common-patterns.md`.** Naming, error handling and logging sections are still empty. Worth one `/continue` pass over `Controllers/` and `RepositoryServices/`.
2. **Tier 6 — `important-files.md`.** The by-task index ("I want to change X → open Y") is empty. The route table in `request-flow.md` covers part of it; the by-task list does not exist.
3. **No test project.** This is the blocker for the ticket-driven workflow in the root README §10: without `dotnet test`, a pipeline cannot fail on unmet requirements.
4. **OpenCode command coverage.** 3 of 10 skills are exposed as `/commands`.
5. **Tier 7 live verification.** The deployment docs have not been checked against a real pipeline run by an agent.

## Recommended next

`/continue` targeting **Tier 4** (`common-patterns.md`), then **Tier 6** (`important-files.md`).
After that, add the test project so CI can gate merges.
