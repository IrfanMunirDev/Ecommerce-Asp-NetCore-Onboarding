# Onboarding Audit

> Gap analysis and completion tracking. `/audit` owns this file; other skills read it for priorities.

Last audited: 2026-11-07

## Overall completion

**38%**

Formula: average of Tier 1–6 scores = (45 + 60 + 15 + 40 + 30 + 35) / 6.
Tier 7 excluded — no deployment access.

## Tier scores

| Tier | Focus | Score | Status | Top gaps |
|------|-------|-------|--------|----------|
| 1 | Project overview | 45 | partial | Domain misidentified; Identity + Stripe claimed but absent |
| 2 | Architecture | 60 | partial | Diagram + Repo/UoW verified; `DbContext` location wrong |
| 3 | Request/data flow | 15 | hypothesis only | Describes a checkout/payment flow that does not exist |
| 4 | Patterns & conventions | 40 | partial | Naming + error/logging sections unfilled |
| 5 | Integrations | 30 | partial | SQL Server right; Stripe + Identity fabricated |
| 6 | Important files index | 35 | partial | "Start here" OK; by-task sections empty; no controller map |
| 7 | DevOps & deployment | — | skipped | requires access |

## Verified corrections

These contradict the state files and must be fixed before they mislead another agent.

| Claim in docs | Reality | Evidence |
|---|---|---|
| ASP.NET Core Identity handles auth | **Not implemented.** Every `Identity` match (53) is a SQL Server `IDENTITY` column inside EF migrations. No `IdentityDbContext`, no `AddIdentity`, no Account controller. | `Program.cs`, `Controllers/` |
| Stripe processes payments | **Not implemented.** Zero `Stripe` references in `.cs`, `.cshtml`, `.json`, `.csproj`. | repo-wide grep |
| `DbContext` lives in `data/` | It lives at `Models/EcommerceContext.cs`. `data/` contains only `MovieCategory.cs`, an enum. | `Models/EcommerceContext.cs:5` |
| Generic "product / order" e-commerce | Cinema ticketing app: Actors, Cinemas, Movies, Producers, Orders | `Controllers/` |
| Checkout / payment is the primary flow | No payment or checkout action exists; `OrdersController` only does cart operations | `Controllers/OrdersController.cs:21,37,51` |

## Confirmed by spot-check

- Repository + Unit of Work wired in DI: `AddScoped(typeof(IgenericRepository<>), typeof(genericRepository<>))` and `AddScoped<IUnitOfWork, UnitOfWorkClass>()` — `Program.cs:23-24`
- Cart is session-backed via `IHttpContextAccessor`: `AddScoped(sc => ShoppingCart.GetShoppingCart(sc))` — `Program.cs:27`
- SQL Server through EF Core 8 — `ECommerce.csproj`, `appsettings.json`
- No test project in the solution
- Scale: 38 `.cs`, 31 `.cshtml`, 6 controllers, 9 entity models

## Prioritized gaps

1. **Tier 1 — false stack claims.** `project-memory.md` and `overview.md` assert Identity and Stripe. Every agent reads these first, so this is the cheapest, highest-ROI fix in the repo.
2. **Tier 3 — the traced flow does not exist.** `request-flow.md` hypothesises a checkout/payment path. The real path is cart-only: `OrdersController` → `ShoppingCart` → `IUnitOfWork` → `EcommerceContext` → SQL Server.
3. **Tier 2 — wrong `DbContext` path.** `architecture.md` points at `data/`; the context is in `Models/`. The layering claim itself is now verified.
4. **Tier 6 — index missing the real entry points.** No controller list, no pointers to `UnitOfWorkClass`, `genericRepository`, `EcommerceContext`, or `ShoppingCart`.
5. **Tier 5 — integrations file describes software that is not installed.** Rewrite to SQL Server only.

## Recommended next

`/continue` targeting **Tier 3 (request/data flow)** — trace the cart path end to end and replace the phantom checkout hypothesis with a verified `file:line` trace.

Fix the Tier 1 corrections first; they are a five-minute edit and they invalidate advice from every other doc.
