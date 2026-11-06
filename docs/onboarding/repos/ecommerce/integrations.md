# ECommerce — Integrations

> External systems, APIs, and cross-service boundaries.

## Outbound

| Service | Purpose | Config | Key files |
|---------|---------|--------|-----------|
| SQL Server | Primary datastore (EF Core) | Connection string in `appsettings*.json` | `ECommerce/data/`, `ECommerce/Migrations/` |
| Stripe | Payment processing (per README) | <!-- fill: keys location — see Q-002 --> | <!-- fill: not yet located --> |

## Inbound

| Source | Purpose | Entry point |
|--------|---------|-------------|
| Browser | MVC requests | `ECommerce/Controllers/` |

## Auth & secrets

ASP.NET Core Identity for users/roles. Secret handling for the DB connection string and Stripe keys is unverified — confirm whether `dotnet user-secrets`, environment variables, or committed config is used.

## Events & messaging

None observed. No queues, webhooks, or pub/sub at top level.

<!-- fill: verify whether Stripe webhooks are handled -->

## Local development

- Requires a reachable SQL Server instance and an updated connection string.
- Apply schema with `dotnet ef database update` from `ECommerce/`.
- Stripe keys (test mode) needed for checkout flows.

<!-- fill: note any mocks/stubs available for running without Stripe -->
