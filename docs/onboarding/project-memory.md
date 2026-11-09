# Project Memory

> Source of truth for onboarding config and project-wide facts. Other state files link here; do not duplicate long prose.

## Config

| Key | Value |
|-----|-------|
| docs_path | docs/onboarding |
| source_roots | ECommerce/ |
| layout | single-repo |
| stack | C# / .NET 8, ASP.NET Core MVC (Razor views), EF Core 8, SQL Server, Bootstrap |
| initialized | 2026-11-06 |

## Project summary

Single-project ASP.NET Core MVC **cinema ticketing** application. Visitors browse and filter movies, inspect cinemas, cast and producers, and add tickets to a cart. Data access goes through EF Core against SQL Server, wrapped in Repository + Unit of Work abstractions wired up with dependency injection.

There is **no authentication and no payment integration** — both were advertised by the original README and neither is implemented. Orders are modelled but never written from a controller; the only order-related flow is the cart.

## Conventions

- **Data access:** Repository pattern (`ECommerce/RepositoryServices/`) + Unit of Work (`ECommerce/UnitOfWorkRepo/`). Controllers are expected to go through these rather than touching `DbContext` directly.
- **Composition root:** `ECommerce/Program.cs` — DI, middleware, and route registration.
- **Schema changes:** EF Core migrations in `ECommerce/Migrations/` (no manual DDL).
- **Configuration:** `ECommerce/appsettings.json`, overridden by `appsettings.Development.json`. Production supplies `ConnectionStrings__DefaultConnection` as a site environment variable; the base `appsettings.json` value is intentionally empty.
- **Deployment:** `.gitlab-ci.yml` (build → publish → deploy) uploads a win-x86 framework-dependent build to MonsterASP over SFTP. Full procedure and diagnostics in the root `README.md`.
- **Style:** implicit usings and nullable reference types are enabled (`ECommerce.csproj`).

## Key contacts & resources

- [README.md](../../README.md) — stack and feature list.
- Per-unit docs: [repos/ecommerce/overview.md](repos/ecommerce/overview.md)

## Notes

- The solution contains a single web project; there is no test project as of initialization.
- The original README described the frontend as "Razor Pages" and claimed Identity + Stripe. All three are wrong; `README.md` has been rewritten against the source and the correction table lives at its top.
- `Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter` is referenced in the `.csproj` but **no QuickGrid component exists** — the package is unused.
- The cart is identified by a GUID in `ISession` (`CartId`) and its items are persisted in `shoppingCartItems`; `ShoppingCart` is the only type that talks to `EcommerceContext` directly.
