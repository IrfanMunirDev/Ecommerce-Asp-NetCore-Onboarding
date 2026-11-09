# ECommerce — Overview

> High-level purpose of this repo or module. Keep to 1–2 screens.

## Purpose

A **cinema ticketing** web application served as a single ASP.NET Core MVC app. Visitors
browse movies and cinemas, filter the catalogue, view cast and producer details, and add
tickets to a shopping cart. Staff-style CRUD screens manage movies, cinemas, actors and
producers.

There is **no authentication and no payment integration**. Despite what the original
README claimed, no `Identity` and no `Stripe` code exists in this repository.

## Tech stack

- C# / .NET 8 (`Microsoft.NET.Sdk.Web`, nullable + implicit usings enabled)
- ASP.NET Core MVC with Razor views (31 `.cshtml` files, 6 controllers)
- Entity Framework Core 8 + SQL Server (`Microsoft.EntityFrameworkCore.SqlServer` 8.0.3)
- Repository pattern + Unit of Work, wired with dependency injection
- Cart identified by a GUID in `ISession`; cart rows persisted in `shoppingCartItems`
- Bootstrap, jQuery, jQuery Validation vendored under `wwwroot/lib/`

## Boundaries

- Owns: HTTP endpoints, Razor views, domain models, data access, session cart.
- Delegates: persistence to SQL Server. Nothing else external — no mail, no payments, no
  APIs, no queues.

## Entry points

- `Program.cs` — host, DI container, middleware pipeline, startup migrations
- `Controllers/` — six MVC controllers; route table in
  [request-flow.md](request-flow.md#route-table)
- `Models/EcommerceContext.cs` — the `DbContext` (note: **not** in `data/`)
- `Migrations/` — six EF Core migrations, applied automatically at startup

## Related units

None — single-project solution. See [../../repositories-overview.md](../../repositories-overview.md).

## Verified facts

| Fact | Evidence |
|------|----------|
| MVC, not Razor Pages | `AddControllersWithViews()` in `Program.cs`; `Views/` folder |
| Repository + UoW registered in DI | `Program.cs:23-24` |
| Cart is session-identified, database-backed | `data/Cart/ShoppingCart.cs` |
| No `AddIdentity`, no `IdentityDbContext`, no Account controller | `Program.cs`, `Controllers/` |
| Zero `Stripe` references | repo-wide search |
| No test project | `ECommerce.sln` |
