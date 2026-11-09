# Repositories Overview

> Index of discovered repos/modules. One row per unit; details live in `repos/<slug>/`.

| Slug | Name | Path | Stack | Status | Docs |
|------|------|------|-------|--------|------|
| ecommerce | ECommerce | ECommerce/ | C# / .NET 8, ASP.NET Core MVC, EF Core 8, SQL Server | verified (Tiers 1–3, 5) | [overview](repos/ecommerce/overview.md) |

## Layout notes

Single-repo layout. `ECommerce.sln` at the root references exactly one project, `ECommerce/ECommerce.csproj` (`Microsoft.NET.Sdk.Web`). No workspace tooling (no `pnpm-workspace.yaml`, `nx.json`, `go.work`, or similar).

## Discovery log

| Date | Action |
|------|--------|
| 2026-11-06 | Initial discovery via /start |
| 2026-11-09 | False stack claims corrected; movie + cart flows traced; deployment documented in root README |
