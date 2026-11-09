# ECommerce — Request Flow

> Trace the real paths end-to-end. Everything below is verified against source; the
> previous version of this file hypothesised a checkout/payment flow that does not exist.

## Route table

Default route: `{controller=Home}/{action=Index}/{id?}` (`Program.cs`).

| Controller | Actions | File |
|-----------|---------|------|
| `HomeController` | `Index`, `Error` | `Controllers/HomeController.cs` |
| `MoviesController` | `Index`, `Filter(searchData)`, `Details(id)`, `Create`, `Edit(id)`, `Delete(id)`, `DeleteConfirmed(id)` | `Controllers/MoviesController.cs` |
| `CinemasController` | `Index`, `Details(id)`, `Create`, `Edit(id)`, `Delete(id)`, `DeleteConfirmed(id)` | `Controllers/CinemasController.cs` |
| `ProducersController` | `Index`, `Details(id)`, `Create`, `Edit(id)`, `Delete(id)`, `DeleteConfirmed(id)` | `Controllers/ProducersController.cs` |
| `ActorsController` | `Index`, `Create`, `Details(id)`, `Edit(id)`, `Delete(id)` | `Controllers/ActorsController.cs` |
| `OrdersController` | `ShoppingCart`, `AddItemToCart(id)`, `RemoveItemFCart(id)` | `Controllers/OrdersController.cs` |

There is no checkout, no payment, and no order-placement action anywhere.

## Primary flow 1: browse and filter movies

```
GET /Movies
  1. MoviesController.Index()                          Controllers/MoviesController.cs:51
  2. includeRelated = { "Cinema", "Producer" }
  3. unitOfWork.Movies.GetAllAsync(includeRelated)     → genericRepository<T>
  4. → EcommerceContext → SQL Server (Movies joined to Cinemas, Producers)
  5. View(movies)                                      Views/Movies/Index.cshtml

GET /Movies/Filter?searchData=dune
  1. MoviesController.Filter(string searchData)        Controllers/MoviesController.cs:33
  2. if searchData is empty → GetAllAsync → View("Index", all)
  3. else unitOfWork.Movies.FilterByName(...)
       predicate: Name.Contains(searchData) || Description.Contains(searchData)
  4. View("Index", filteredMovies)   ← reuses the Index template
```

## Primary flow 2: shopping cart (the only "order" flow that exists)

Cart identity is a GUID stored in session. Cart **rows** are persisted in SQL Server.

```
GET /Orders/ShoppingCart
  1. OrdersController.ShoppingCart()                   Controllers/OrdersController.cs:21
  2. shoppingCart.GetShoppingCartItems()
       → EcommerceContext.shoppingCartItems
           .Where(i => i.ShoppingCardId == ShoppingCartId)
           .Include(n => n.Movie)                      data/Cart/ShoppingCart.cs
  3. shoppingCart.GetShoppingCartTotal()
       → SUM(Movie.Price * Amount) for the same CartId
  4. new ShoppingCartVM { ShoppingCardTotal, ShoppingCart }
  5. View(response)                                    Views/Orders/ShoppingCart.cshtml

GET /Orders/AddItemToCart/{id}
  1. OrdersController.AddItemToCart(int id)            Controllers/OrdersController.cs:37
  2. unitOfWork.Movies.GetByIdAsync(id)
  3. shoppingCart.AddItemToCart(movie)
       existing row for (movie, CartId)?  → Amount++  : insert Amount = 1
       then context.SaveChanges()
  4. RedirectToAction(nameof(ShoppingCart))

GET /Orders/RemoveItemFCart/{id}
  1. OrdersController.RemoveItemFCart(int id)           Controllers/OrdersController.cs:51
  2. unitOfWork.Movies.GetByIdAsync(id)
  3. shoppingCart.RemoveItemFromCart(movie)
       Amount > 1 ? Amount--  :  remove the row
       then context.SaveChanges()
  4. RedirectToAction(nameof(ShoppingCart))
```

### Where the cart ID comes from

`ShoppingCart.GetShoppingCart(IServiceProvider)` (`data/Cart/ShoppingCart.cs`):

1. Read `ISession` from `IHttpContextAccessor`.
2. `cartId = session.GetString("CartId") ?? Guid.NewGuid().ToString()`.
3. Write it back to the session.
4. Return `new ShoppingCart(context) { ShoppingCartId = cartId }`.

Consequences worth knowing before changing cart code:

- Session storage is the default in-memory provider (`AddSession()`), so an app restart
  loses the GUID → the next visit gets a new cart, and old rows stay orphaned in
  `shoppingCartItems`.
- Nothing ties a cart to a user; there is no user. Two browsers are two carts.
- `ShoppingCart` queries `EcommerceContext` directly and is the only type that bypasses
  `IUnitOfWork`.

## Alternate flows

- **CRUD screens** (`Movies`, `Cinemas`, `Producers`, `Actors`): `Index` → `Details` →
  `Create`/`Edit`/`Delete` → delete POST, all through `IUnitOfWork`, all returning `View()`
  or `RedirectToAction()`.
  - Every mutation is `[HttpPost]`; deletes expose a GET `Delete(id)` for the confirmation
    page and a POST that reuses the URL via `[HttpPost, ActionName("Delete")]`
    (`DeleteConfirmed`). `ActorsController` instead posts to `Delete(int id, IFormCollection)`.
  - `[ValidateAntiForgeryToken]` is on the POST actions of `Movies`, `Cinemas` and
    `Producers`, but **not** on `ActorsController` — a real gap, not a doc error.
  - Search is not a form post: a jQuery handler binds to `#searchInput` and issues
    `GET /Movies/Filter?searchData=...`, replacing `.container` with the returned HTML.
    That handler lives in a `@section Scripts` block *inside* `_Layout.cshtml` (line 70),
    after `</body>`, while `RenderSectionAsync("Scripts")` runs earlier (line 68). Sections
    are meant to be defined by views, so the block is likely never rendered and the live
    search may not fire. Unverified in a browser.
- **Cart badge:** `ViewComponents/ShoppingCartSummary` (`data/ViewComponents/`) renders in
  the layout and calls the same `ShoppingCart` to show the item count.

## Error handling

- Development: developer exception page (default).
- Non-development: `UseExceptionHandler("/Home/Error")` → `Views/Shared/Error.cshtml`.
- No structured logging, no `try/catch` in controllers, no global filters. EF exceptions
  propagate to the handler (or to the startup crash if raised during `Migrate()`).

## Data touchpoints

| Step | Store | Operation |
|------|-------|-----------|
| Movie list / filter | SQL Server via EF Core | Read (`Movies` + `Cinemas` + `Producers`) |
| Movie details | SQL Server via EF Core | Read (+ actors via `ActorMovies`) |
| Add / remove cart item | SQL Server via EF Core | Read + Write (`shoppingCartItems`) |
| Cart total | SQL Server via EF Core | Read + aggregate |
| CRUD screens | SQL Server via EF Core | Read / Insert / Update / Delete |

## Not implemented (do not go looking for it)

- Authentication or a signed-in user
- Checkout, order creation from a cart, payment, confirmation email
- `Order`/`OrderItem` are modelled and migrated, but **no controller writes them**
