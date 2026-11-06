# Project Memory

> Source of truth for onboarding config and project-wide facts. Other state files link here; do not duplicate long prose.

## Config

| Key | Value |
|-----|-------|
| docs_path | docs/onboarding |
| source_roots | ECommerce/ |
| layout | single-repo |
| stack | C# / .NET 8, ASP.NET Core MVC (Razor views), EF Core 8, SQL Server, ASP.NET Core Identity, Stripe, Bootstrap |
| initialized | 2026-11-06 |

## Project summary

Single-project ASP.NET Core e-commerce web application. Users register and sign in with ASP.NET Core Identity, browse and manage products, and check out through Stripe. Data access goes through EF Core against SQL Server, wrapped in Repository + Unit of Work abstractions wired up with dependency injection.

## Conventions

- **Data access:** Repository pattern (`ECommerce/RepositoryServices/`) + Unit of Work (`ECommerce/UnitOfWorkRepo/`). Controllers are expected to go through these rather than touching `DbContext` directly.
- **Composition root:** `ECommerce/Program.cs` — DI, middleware, and route registration.
- **Schema changes:** EF Core migrations in `ECommerce/Migrations/` (no manual DDL).
- **Configuration:** `ECommerce/appsettings.json`, overridden by `appsettings.Development.json`.
- **Style:** implicit usings and nullable reference types are enabled (`ECommerce.csproj`).

## Key contacts & resources

- [README.md](../../README.md) — stack and feature list.
- Per-unit docs: [repos/ecommerce/overview.md](repos/ecommerce/overview.md)

## Notes

- The solution contains a single web project; there is no test project as of initialization.
- README describes the frontend as "Razor Pages", but the layout (`Controllers/` + `Views/`) is MVC with Razor views. Tracked as Q-001 in [open-questions.md](open-questions.md).
- `Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter` is referenced in the `.csproj`, so some UI may use Blazor QuickGrid components; unverified.
