# ECommerce — Overview

> High-level purpose of this repo or module. Keep to 1–2 screens.

## Purpose

An e-commerce web application: identity/authentication, product and order management, and Stripe-based checkout, served as a single ASP.NET Core web app.

## Tech stack

- C# / .NET 8 (`Microsoft.NET.Sdk.Web`)
- ASP.NET Core MVC with Razor views
- Entity Framework Core 8 + SQL Server
- ASP.NET Core Identity
- Stripe (per README)
- Bootstrap, HTML/CSS/JS in `wwwroot/`

## Boundaries

- Owns: HTTP endpoints, Razor views, domain models, data access, payment calls.
- Delegates: everything external — SQL Server, Stripe.

## Entry points

- `Program.cs` — host, DI container, middleware pipeline
- `Controllers/` — MVC controllers (route table not yet mapped)
- `Migrations/` — EF Core schema history

## Related units

None — single-project solution. See [../repositories-overview.md](../repositories-overview.md).

<!-- fill: confirm the route table from Program.cs and list the main controllers -->
