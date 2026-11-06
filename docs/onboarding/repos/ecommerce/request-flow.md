# ECommerce — Request Flow

> Trace one primary path end-to-end (HTTP, CLI, event, or job).

## Primary flow: checkout / payment

```
<!-- fill: step-by-step with file:line references — currently a hypothesis -->
1. Entry:        GET/POST on a checkout route in ECommerce/Controllers/
2. Auth check:   ASP.NET Core Identity (attribute or policy — confirm)
3. Validation:   model binding + DataAnnotations (confirm)
4. Data:         Controller → UnitOfWorkRepo/ → RepositoryServices/ → data/DbContext
5. Payment:      Stripe API call (location unknown — see Q-002)
6. Response:     redirect / view in ECommerce/Views/
```

## Alternate flows

<!-- fill: product listing, product CRUD, registration/login -->

## Error handling

<!-- fill: where errors are caught, logged, returned -->

## Data touchpoints

| Step | Store/API | Operation |
|------|-----------|-----------|
| Product lookup | SQL Server via EF Core | Read |
| Order creation | SQL Server via EF Core | Write |
| Payment | Stripe | Create charge / session |

<!-- fill: replace the hypothesis above with a verified trace once Controllers/ is read -->
