# ECommerce — Architecture

> Structural design: layers, components, and dependencies.

## High-level diagram

```
Browser
  │
  ▼
ASP.NET Core MVC  (Controllers/ + Views/)
  │
  ├── ASP.NET Core Identity  (authn/authz)
  ├── RepositoryServices/    (data access abstraction)
  │        │
  │        ▼
  │   UnitOfWorkRepo/        (transaction boundary)
  │        │
  │        ▼
  │   data/ (DbContext) ──► SQL Server
  │
  └── Stripe API (payment)
```

<!-- fill: verify this against Program.cs service registrations before trusting it -->

## Layers / components

| Component | Path | Responsibility |
|-----------|------|----------------|
| Entry point | `ECommerce/Program.cs` | Host, DI registration, middleware |
| Controllers | `ECommerce/Controllers/` | HTTP request handling |
| Views | `ECommerce/Views/` | Razor templates |
| Models | `ECommerce/Models/` | Entities and view models |
| Data | `ECommerce/data/` | `DbContext` / EF configuration |
| Repositories | `ECommerce/RepositoryServices/` | Repository pattern implementations |
| Unit of work | `ECommerce/UnitOfWorkRepo/` | Coordinates repositories and transactions |
| Migrations | `ECommerce/Migrations/` | Generated schema history |
| Static assets | `ECommerce/wwwroot/` | CSS, JS, libs |

## Dependencies

### Internal

Single project — folders only. `Controllers → UnitOfWork/Repositories → DbContext`.

### External

- SQL Server (EF Core provider `Microsoft.EntityFrameworkCore.SqlServer`)
- Stripe (README claim; not yet located)

## Key design decisions

- Repository + Unit of Work to keep `DbContext` out of controllers (README states this; verify in code).
- Nullable reference types and implicit usings enabled project-wide.

<!-- fill: note any deviation from the intended layering once code is audited -->
