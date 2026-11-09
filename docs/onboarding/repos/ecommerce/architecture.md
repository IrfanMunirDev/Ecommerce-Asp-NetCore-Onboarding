# ECommerce — Architecture

> Structural design: layers, components, and dependencies.

## High-level diagram

```
Browser
  │  HTTP (no auth: every endpoint is anonymous)
  ▼
ASP.NET Core MVC  (Controllers/ + Views/)
  │
  ├── ShoppingCart  (data/Cart/)  ── session GUID + direct DbContext access
  │
  ├── IUnitOfWork  (UnitOfWorkRepo/)
  │        │
  │        ▼
  │   IgenericRepository<T>  (RepositoryServices/)
  │        │
  │        ▼
  │   EcommerceContext  (Models/)  ──► SQL Server
  │
  └── ISession (in-memory, default)  ── holds CartId only
```

There is no Identity block and no Stripe block. Both were claimed by the original README
and neither exists.

## Layers / components

| Component | Path | Responsibility |
|-----------|------|----------------|
| Entry point | `ECommerce/Program.cs` | Host, DI registration, middleware, startup migrations |
| Controllers | `ECommerce/Controllers/` | HTTP request handling (6 controllers) |
| Views | `ECommerce/Views/` | Razor templates (31 files) |
| View component | `ECommerce/ViewComponents/` | `ShoppingCartSummary` (cart badge) |
| Models | `ECommerce/Models/` | Entities **and** `EcommerceContext` |
| Data | `ECommerce/data/` | Cart, view models, `MovieCategory` enum — **no DbContext** |
| Repositories | `ECommerce/RepositoryServices/` | `IgenericRepository<T>` / `genericRepository<T>` |
| Unit of work | `ECommerce/UnitOfWorkRepo/` | `IUnitOfWork` / `UnitOfWorkClass`, exposes per-entity repositories |
| Migrations | `ECommerce/Migrations/` | Six migrations + model snapshot |
| Static assets | `ECommerce/wwwroot/` | CSS, JS, vendored libs, images |

## Dependencies

### Internal

Single project — folders only. The intended direction is
`Controllers → IUnitOfWork → IgenericRepository<T> → EcommerceContext → SQL Server`.

`ShoppingCart` is the **one deviation**: it receives `EcommerceContext` directly and
queries `context.shoppingCartItems` instead of going through the unit of work. Nothing else
bypasses the repositories.

### External

- SQL Server only, via `Microsoft.EntityFrameworkCore.SqlServer`.
- No payment provider, mail provider, cache, queue, or third-party HTTP API.

## Startup sequence

`Program.cs`:

1. `AddControllersWithViews()`
2. `AddDbContext<EcommerceContext>` using `ConnectionStrings:DefaultConnection`
3. `AddScoped(typeof(IgenericRepository<>), typeof(genericRepository<>))` — line 23
4. `AddScoped<IUnitOfWork, UnitOfWorkClass>()` — line 24
5. `AddSingleton<IHttpContextAccessor, HttpContextAccessor>()` — line 26
6. `AddScoped(sc => ShoppingCart.GetShoppingCart(sc))` — line 27
7. `AddSession()` — line 28
8. `db.Database.Migrate()` inside a service scope — lines 32–36

Step 8 is why a bad production connection string surfaces as a **request-time** failure
rather than a deploy-time one. See the deployment section of the root `README.md`.

## Key design decisions

- Repository + Unit of Work keep `DbContext` out of controllers.
- Session holds only the cart identifier; cart contents are durable rows in the database.
- Nullable reference types and implicit usings are enabled project-wide.
- Errors: `UseExceptionHandler("/Home/Error")` outside Development.

## Known deviations

| Deviation | Detail |
|-----------|--------|
| Cart bypasses UoW | `ShoppingCart` uses `EcommerceContext` directly |
| No auth layer | `UseAuthorization()` is registered but nothing is `[Authorize]`d |
| Unused package | `Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter` 8.0.4 |
| Duplicate views | `Views/Producer/` and `Views/Producers/` both exist |
