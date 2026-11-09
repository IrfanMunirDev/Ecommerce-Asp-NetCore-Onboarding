# ECommerce — Integrations

> External systems, APIs, and cross-service boundaries.

## Outbound

| Service | Purpose | Config | Key files |
|---------|---------|--------|-----------|
| SQL Server (LocalDB locally, MonsterASP SQL Server in production) | Primary datastore via EF Core 8 | `ConnectionStrings:DefaultConnection`; dev value in `appsettings.Development.json`, production value from the site environment variable `ConnectionStrings__DefaultConnection` | `Models/EcommerceContext.cs`, `Migrations/` |
| MonsterASP SFTP (CI only) | Uploads the published build during a GitLab deploy job | `FTP_HOST`, `FTP_PORT`, `FTP_USER`, `FTP_PASSWORD`, `SITE_URL` as GitLab CI/CD variables | `.gitlab-ci.yml`, `deploy/monsterasp-deploy.sh` |

There is **no Stripe, no payment provider, no mail provider, no HTTP API client**. The
original README claimed Stripe integration; a repo-wide search for `Stripe` returns zero
matches in `.cs`, `.cshtml`, `.json` and `.csproj` files.

## Inbound

| Source | Purpose | Entry point |
|--------|---------|-------------|
| Browser | MVC form/GET requests | `Controllers/` (all anonymous) |
| GitLab pipeline | Build, publish, deploy | `.gitlab-ci.yml` |

No webhooks, no callbacks, no scheduled jobs.

## Auth & secrets

- **No authentication exists.** Nothing calls `AddIdentity`, there is no `IdentityDbContext`
  and no Account controller. `UseAuthorization()` is in the pipeline but no endpoint
  requires it. Any "login" or "register" flow you remember from the README does not exist.
- **Secrets:** the database connection string is the only secret. It is never committed —
  `appsettings.json` ships `"DefaultConnection": ""`, and production supplies the value via
  the MonsterASP environment variable. Dev uses LocalDB with `Trusted_Connection=True`, so
  no password is stored locally.
- GitLab deployment credentials live only in CI/CD variables (`FTP_PASSWORD` masked).

## Events & messaging

None. No queues, webhooks, pub/sub, or background workers.

## Local development

- Requires SQL Server LocalDB (or edit `appsettings.Development.json` to point elsewhere).
- Schema is applied automatically at startup (`db.Database.Migrate()`), or manually with
  `dotnet ef database update` from `ECommerce/`.
- No external service or API key is needed to run the app end to end.
