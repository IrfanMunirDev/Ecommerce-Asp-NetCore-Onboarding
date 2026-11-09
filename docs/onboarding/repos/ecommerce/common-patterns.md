# ECommerce — Common Patterns

> Conventions a new developer must know to work in this unit.

## Code organization

- MVC: `Controllers/` handle requests, `Views/` holds Razor templates, `Models/` holds entities.
- Data access is expected to live behind `RepositoryServices/` + `UnitOfWorkRepo/`, not in controllers.
- Schema changes only via `Migrations/` (`dotnet ef migrations add <Name>`).
- Note the lowercase `data/` folder — inconsistent with the PascalCase folders around it.

## Naming conventions

<!-- fill: confirm controller/model/repository naming once code is read -->

## Testing patterns

No test project is present in the solution. Verification is manual (`dotnet run` and a browser) for now, and the GitLab pipeline has no `test` stage. Adding `dotnet test` to CI is a prerequisite for gating merges on requirements — see the root README §10.

## Error & logging patterns

<!-- fill: standard approaches (middleware, ILogger usage, toast/ModelState) -->

## Configuration

- `appsettings.json` — base config
- `appsettings.Development.json` — local overrides
- The only secret is the DB connection string. `appsettings.json` ships it empty; development uses LocalDB with `Trusted_Connection=True`, and production supplies `ConnectionStrings__DefaultConnection` as a site environment variable on MonsterASP. Never commit a real connection string.
- No Stripe keys exist — there is no payment integration (Q-002 resolved).

## Anti-patterns to avoid

- Reaching for `DbContext` directly in controllers instead of the Unit of Work.
- Adding EF migrations by hand-editing the database instead of generating migrations.
- Putting secrets in committed `appsettings*.json`.

<!-- fill: add footguns discovered during /audit -->
