# Cinetix — Cinema Ticketing on ASP.NET Core MVC

A single-project .NET 8 web application for browsing movies and cinemas, filtering the
catalogue, and putting tickets in a session-backed shopping cart.

This README is the entry point for both **humans** and **AI agents**. It documents:

| Part | What it covers |
|------|----------------|
| [1–5](#1-what-this-project-is) | The app, its real stack, routes, and how to run it locally |
| [6](#6-part-a--agents-rules-commands-and-skills) | How Cursor rules, OpenCode commands and skills are set up — and why |
| [7](#7-part-b--git-github-and-gitlab) | Moving the repo to GitLab, pipelines, CI/CD variables, deploying |
| [8](#8-part-c--monsterasp-hosting) | MonsterASP: SFTP, database, environment variables, log diagnostics |
| [9](#9-part-d--gitlab-for-beginners) | A short GitLab primer for anyone new to it |
| [10](#10-part-e--roadmap-from-tickets-to-agents) | Where this is heading: agents that pick up GitLab tickets |

> **Read the corrections table below before trusting any older doc.** The original
> README of this project advertised features that were never implemented.

## Corrections: what the old README claimed vs what exists

| Old claim | Reality | Evidence |
|-----------|---------|----------|
| "Security: ASP.NET Core Identity" | **Not implemented.** No `IdentityDbContext`, no `AddIdentity`, no account controller. Every `Identity` hit in the repo is a SQL Server `IDENTITY` column inside EF migrations. | `ECommerce/Program.cs`, `ECommerce/Controllers/` |
| "Integration with stripe payment" | **Not implemented.** Zero `Stripe` references in any `.cs`, `.cshtml`, `.json` or `.csproj`. | repo-wide search |
| "Razor Pages" frontend | It is **MVC with Razor views**: controllers return `View()`, templates live in `Views/`. | `Controllers/` + `Views/` |
| "Payment Processing", "checkout" | There is **no checkout and no order placement**. `OrdersController` only manages a cart. | `Controllers/OrdersController.cs` |
| Generic "product / order" store | It is a **cinema ticketing** domain: actors, cinemas, movies, producers, orders. | `Models/` |

Those errors are mirrored in `docs/onboarding/` and are being corrected there too.
Everything else in this README is verified against the source.

---

## 1. What this project is

- **Domain:** a cinema box office. You browse films, filter them, see which cinema and
  producer they belong to, and add tickets to a cart.
- **Shape:** one ASP.NET Core MVC web app, server-rendered Razor views, EF Core over
  SQL Server, and a shopping cart identified by a GUID stored in session, with the cart
  items themselves persisted in the database.
- **Not present (yet):** authentication, payments, checkout, order confirmation,
  an admin area, and any test project.

What **does** exist: list movies, view a movie's details and cast, manage
actor/cinema/producer records, add a movie to the cart, decrement/remove it, and see the
cart total. A `Movies/Filter` action matches `Name` **or** `Description` (not genre) and
re-renders the `Index` view; the search box that calls it is wired in the layout's script
section, which has a placement problem that probably stops it running — see
[rough edges](#11-known-rough-edges).

---

## 2. Verified stack

| Layer | Technology | Where |
|-------|-----------|-------|
| Language / runtime | C# on .NET 8 (`net8.0`) | `ECommerce/ECommerce.csproj` |
| Web framework | ASP.NET Core MVC (`AddControllersWithViews`) | `Program.cs` |
| Views | Razor `.cshtml` (31 views) | `ECommerce/Views/` |
| ORM | EF Core 8.0.3 (`Microsoft.EntityFrameworkCore.SqlServer`) | `ECommerce.csproj` |
| Database | SQL Server (LocalDB locally, SQL Server on MonsterASP) | `appsettings*.json` |
| Schema | 6 EF Core migrations, applied at startup | `ECommerce/Migrations/` |
| Data access | Repository pattern + Unit of Work + DI | `RepositoryServices/`, `UnitOfWorkRepo/` |
| Cart state | `ISession` holds a cart GUID (`CartId`); items are rows in `shoppingCartItems` | `data/Cart/ShoppingCart.cs` |
| CSS/JS | Bootstrap, jQuery, jQuery Validation (vendored) | `ECommerce/wwwroot/lib/` |
| Build config | Nullable reference types + implicit usings enabled | `ECommerce.csproj` |

**NuGet packages** (`ECommerce.csproj`):

- `Microsoft.EntityFrameworkCore.SqlServer` 8.0.3 — provider
- `Microsoft.EntityFrameworkCore.Design` 8.0.3 — `dotnet ef` support
- `Microsoft.EntityFrameworkCore.Tools` 8.0.3 — tooling
- `Microsoft.VisualStudio.Web.CodeGeneration.Design` 8.0.2 — scaffolding
- `Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter` 8.0.4 —
  referenced but **not used** (see [rough edges](#11-known-rough-edges))

Deliberately **not** present: ASP.NET Core Identity, Stripe, any payment SDK, any test
framework, `dotnet user-secrets` usage, Docker.

---

## 3. How the code is laid out

```
ECommerce-Asp.NetCore-application/
├── ECommerce.sln                  # single solution
├── README.md                      # this file
├── AGENTS.md                      # agent instructions (Cursor + OpenCode)
├── .cursor/rules/                 # Cursor-only, scoped rules (.mdc)
├── .opencode/commands/            # OpenCode slash commands
├── .agents/skills/                # shared skills (SKILL.md each)
├── skills-lock.json               # pinned skill versions + hashes
├── .gitlab-ci.yml                 # build → publish → deploy
├── deploy/
│   ├── monsterasp-deploy.sh       # SFTP deploy + health check
│   └── app_offline.htm            # "site updating" page during deploy
├── docs/onboarding/               # agent onboarding state (read by agents first)
└── ECommerce/
    ├── Program.cs                 # composition root: DI, middleware, migrations
    ├── Controllers/               # 6 controllers
    ├── Models/                    # entities + EcommerceContext (DbContext)
    ├── Views/                     # 31 Razor templates
    ├── Migrations/                # 6 migrations + snapshot
    ├── RepositoryServices/        # genericRepository<T>
    ├── UnitOfWorkRepo/            # UnitOfWorkClass (IUnitOfWork)
    ├── Data/
    │   ├── Cart/                  # ShoppingCart (session-backed)
    │   ├── ViewModel/             # ShoppingCartVM
    │   └── MovieCategory.cs       # enum
    ├── ViewComponents/            # ShoppingCartSummary
    ├── wwwroot/                   # css, js, vendored libs, images
    └── appsettings*.json          # config
```

**Where the `DbContext` lives:** `ECommerce/Models/EcommerceContext.cs` — *not* in
`data/`. `data/` holds only the cart, view models, and the `MovieCategory` enum.

**Layering rule** (enforced by a Cursor rule, see [§6.2](#62-cursor-rules)):

```
Controller  →  IUnitOfWork  →  IgenericRepository<T>  →  EcommerceContext  →  SQL Server
```

Controllers must not touch `EcommerceContext` directly.

One deliberate exception: `ShoppingCart` takes `EcommerceContext` itself and queries
`shoppingCartItems` directly (`data/Cart/ShoppingCart.cs`), so the cart bypasses the unit
of work. It is the only place in the app that does.

**Domain model:**

| Entity | Relationships |
|--------|--------------|
| `Movie` | → `Cinema`, → `Producer`, ↔ `Actor` (many-to-many via `ActorMovies`) |
| `Actor` | ↔ `Movie` |
| `Cinema` | ← `Movie` |
| `Producer` | ← `Movie` |
| `Order` | → `OrderItem` (one-to-many) |
| `OrderItem` | → `Movie` |
| `ShoppingCartItem` | → `Movie`, `Amount`, `ShoppingCardId` (persisted in `shoppingCartItems`) |

---

## 4. Routes

The default route is `{controller=Home}/{action=Index}/{id?}` (`Program.cs`).
These are the actions that actually exist:

| Controller | Actions | Notes |
|-----------|---------|-------|
| `HomeController` | `Index`, `Error` | landing page |
| `MoviesController` | `Index`, `Filter(searchData)`, `Details(id)`, `Create`, `Edit(id)`, `Delete(id)`, `DeleteConfirmed(id)` | `Filter` is the search endpoint; `Create`/`Edit` accept `int[] selectedActors` |
| `CinemasController` | `Index`, `Details(id)`, `Create`, `Edit(id)`, `Delete(id)`, `DeleteConfirmed(id)` | |
| `ProducersController` | `Index`, `Details(id)`, `Create`, `Edit(id)`, `Delete(id)`, `DeleteConfirmed(id)` | |
| `ActorsController` | `Index`, `Create`, `Details(id)`, `Edit(id)`, `Delete(id)` | delete handles `IFormCollection` |
| `OrdersController` | `ShoppingCart`, `AddItemToCart(id)`, `RemoveItemFCart(id)` | **cart only** — no checkout |

There is no `[Authorize]` anywhere, because there is no authentication.

---

## 5. Run it locally

**Prerequisites:** .NET 8 SDK, SQL Server LocalDB (ships with Visual Studio, or use any
SQL Server instance), and `dotnet-ef` for migrations.

```bash
# 1. restore + build
dotnet build ECommerce.sln

# 2. run (development profile uses LocalDB)
dotnet run --project ECommerce/ECommerce.csproj
```

Then open the URL printed in the console (usually `https://localhost:7xxx`).

The development connection string is in `appsettings.Development.json`:

```
Server=(localdb)\MSSQLLocalDB;Database=Ecommerce;Encrypt=false;Trusted_Connection=True;TrustServerCertificate=True;
```

`appsettings.json` intentionally ships with `"DefaultConnection": ""` — production
supplies the real value as an environment variable (see [§8.3](#83-environment-variables)).
That is why a deployed site shows a database error until the variable is set.

**Schema:** `Program.cs` runs `db.Database.Migrate()` at startup, so the database is
created/updated automatically on first request. You can also do it manually:

```bash
cd ECommerce
dotnet ef migrations list
dotnet ef database update
```

**Adding a migration** — always from `ECommerce/`:

```bash
dotnet ef migrations add AddSomethingMeaningful
dotnet ef database update
```

Never edit a migration that has already been applied; add a new one.

---

## 6. Part A — Agents: rules, commands and skills

This repo is set up so that AI coding agents start from documentation instead of
re-scanning the whole codebase on every prompt. Three different mechanisms do that,
and they live in three different places on purpose.

### 6.1 The three layers

| Layer | Files | Loaded | Best for |
|-------|-------|--------|----------|
| **Instructions** | `AGENTS.md` | Always, by any AGENTS.md-aware agent (Cursor, OpenCode, …) | The doc-first workflow, repo facts, conventions |
| **Rules** | `.cursor/rules/*.mdc` | By Cursor, automatically or on demand | Scoped technical constraints (C#, EF migrations, release) |
| **Commands** | `.opencode/commands/*.md` | By OpenCode, when you type `/name` | A repeatable workflow you trigger explicitly |
| **Skills** | `.agents/skills/<name>/SKILL.md` | On demand, by name | The detailed procedure a command or an agent follows |

`AGENTS.md` is the **single source of truth** for the workflow. There is deliberately no
duplicate "always apply" Cursor rule repeating it, so the same text does not get loaded
twice and drift out of sync.

### 6.2 Cursor rules

Cursor rules are `.mdc` files with a small frontmatter block. There are four activation
modes, and this repo uses three of them:

| Mode | Frontmatter | Meaning |
|------|------------|---------|
| Always | `alwaysApply: true` | Injected into every request |
| Auto Attached | `globs: "**/*.cs"` | Attached when the files you touch match |
| Agent Requested | `description:` set, no globs | The agent decides it is relevant |
| Manual | `alwaysApply: false`, no description | Only when you reference it |

**Our rules:**

| File | Mode | What it enforces | Probe token |
|------|------|------------------|-------------|
| `csharp-conventions.mdc` | Auto Attached (`**/*.cs`) | .NET 8 idioms, `async`/`await` end to end, controllers never touch `DbContext`, naming, minimal diffs, no hardcoded secrets | `R-CS` |
| `ef-migrations.mdc` | Agent Requested | Migrations via `dotnet ef`, never edit an applied migration, entity + migration in one commit, review `Up`/`Down` | `R-EF` |
| `release-checklist.mdc` | Manual | Pre-release checks: build, pending migrations, no secrets in config, smoke test, docs refreshed | `R-REL` |

**Why the probe token matters.** Each rule ends with a line like
*"if asked which rules are currently active, include the token `R-CS`"*. Ask the agent
*"which rules are active?"* — if `R-CS` does not appear, the rule did not load. That is a
five-second way to debug rule configuration instead of guessing.

**Example — what `csharp-conventions.mdc` prevents:**

```csharp
// ✗ violates the rule: controller talks to the DbContext directly
public class MoviesController : Controller
{
    private readonly EcommerceContext _db;
    public MoviesController(EcommerceContext db) => _db = db;
    public async Task<IActionResult> Index() => View(await _db.Movies.ToListAsync());
}

// ✓ goes through the unit of work, as the rest of the app does
public class MoviesController : Controller
{
    private readonly IUnitOfWork _unitOfWork;
    public MoviesController(IUnitOfWork unitOfWork) => _unitOfWork = unitOfWork;
    public async Task<IActionResult> Index()
    {
        var movies = await _unitOfWork.Movies.GetAllAsync();
        return View(movies);
    }
}
```

**Add a new rule** — create `.cursor/rules/<kebab-name>.mdc`:

```markdown
---
description: Use when editing Razor views or layout files.
globs: "**/*.cshtml"
alwaysApply: false
---

# View Conventions

- Keep markup inside `Views/`; no inline SQL or data access in `.cshtml`.
- Use the existing Bootstrap classes; do not add a second CSS framework.
- Partial views live next to the view that renders them.

Diagnostics: if asked which rules are currently active, include the token `R-VIEW`.
```

Rules are cheap because they are short. Anything long belongs in a skill.

### 6.3 OpenCode commands

OpenCode reads `AGENTS.md` natively. On top of that, `.opencode/commands/` adds **slash
commands** — small entry points that load a skill and hand it the argument you typed.

**Anatomy of a command** (`.opencode/commands/start.md`):

```markdown
---
description: Bootstrap docs/onboarding state for this repo
agent: build
---

Run the project-onboarding **start** skill.

1. Read `.agents/skills/start/SKILL.md` and follow it exactly.
2. Resolve its bundled assets relative to that directory: `templates/` for the
   state files and per-repo stubs, `rules/` for the Cursor rule.
3. Treat the repository root as the target. Do not scan source code beyond
   manifests and a top-level directory listing.
4. If `docs/onboarding/project-memory.md` already exists, read it first and honor
   its `docs_path` and `source_roots`, then resume instead of overwriting.

$ARGUMENTS
```

Three parts do the work: the frontmatter (`description` shows in the command list,
`agent: build` says which agent runs it), the numbered procedure, and `$ARGUMENTS`,
which is replaced with whatever you typed after the command name.

**Our commands:**

| Command | What it does | Example |
|---------|--------------|---------|
| `/start` | Bootstraps `docs/onboarding/` and the knowledge-first rule. Safe to re-run: it resumes from `project-memory.md` instead of overwriting. | `/start` |
| `/audit` | Scores onboarding coverage by tier, writes `onboarding-audit.md`, lists prioritized gaps. | `/audit` |
| `/continue` | Explores **exactly one** bounded area and updates the state files. | `/continue` targeting the cart flow |

**Why commands exist at all.** You could just say "audit the docs" in chat. A command is
better because the procedure is fixed in the repo: every run reads the same skill, in the
same order, writes the same file. It is a prompt you no longer have to remember or retype.

**Add a new command** — create `.opencode/commands/<name>.md`:

```markdown
---
description: Run the test suite and summarise failures
agent: build
---

1. Run `dotnet test` from the repository root.
2. Group failures by test class.
3. Quote the first stack-trace line for each failure.
4. Do not change code unless asked.

$ARGUMENTS
```

### 6.4 Skills

A **skill** is the detailed procedure. A **command** is the button that runs it.
Skills live in `.agents/skills/<name>/SKILL.md` and start with YAML frontmatter:

```markdown
---
name: audit
description: Produce onboarding gap analysis with completion percentage and
  prioritized tiers. Use when auditing documentation coverage, measuring
  onboarding progress, finding codebase exploration gaps, or when the user runs /audit.
disable-model-invocation: true
---

# Audit Project
...
```

- `name` — what you call it.
- `description` — how the agent decides to reach for it. Write it as *when to use me*.
- `disable-model-invocation: true` — only run it when a human/command asks, never
  spontaneously. All ten skills here set it, because each one writes files.

**The ten skills:**

| Skill | Trigger | What it does | Example |
|-------|---------|--------------|---------|
| `start` | `/start` | Seeds `docs/onboarding/` (project memory, progress, repo stubs) and installs the knowledge-first rule | `/start` on a fresh clone |
| `audit` | `/audit` | Scores Tiers 1–6, writes the gap report | `/audit` after a doc change |
| `continue` | `/continue` | Explores one bounded area, updates state | `/continue` on request flow |
| `learn` | `/learn` | Mentor-mode deep dive of one module with file pointers | `/learn OrdersController` |
| `quick-ref` | `/quick-ref` | Answers "where is X?" from state files, no repo scan | `/quick-ref where is the cart total computed?` |
| `ticket` | `/ticket` | Analyses a ticket into requirements, impact and a plan — **no code** | paste a GitLab issue after `/ticket` |
| `review` | `/review` | Reviews a diff for patterns, errors, edge cases, compatibility | `/review` before opening an MR |
| `qa-review` | `/qa-review` | Checks the implementation against the ticket's requirements, reports coverage | `/qa-review #12` |
| `prepare-commits` | `/prepare-commits` | Groups local changes into commit-ready sets with messages | `/prepare-commits` |
| `update-docs` | `/update-docs` | Captures new knowledge into the state files | `/update-docs` after a fix |

**Skill anatomy that matters:** skills may ship bundled assets. `start`, for example,
carries `templates/` (the state-file stubs) and `rules/` (the Cursor rule it installs).
Paths inside a skill must be resolved **relative to the skill directory**, otherwise the
agent looks in the repo root and finds nothing.

**Version pinning.** `skills-lock.json` records where each skill came from
(`smusman437/project-onboarding`, GitHub) plus a SHA-256 of each `SKILL.md`. That makes
skill versions reproducible: if a skill behaves differently than last week, the hash tells
you whether the file changed. Re-installing from the lock file is the way to restore a
known-good set — never hand-edit a skill in place without bumping the hash.

**Add a skill + its command:**

```bash
mkdir -p .agents/skills/my-skill
# write .agents/skills/my-skill/SKILL.md with name/description frontmatter
# write .opencode/commands/my-skill.md with a one-line procedure that reads it
# add an entry to skills-lock.json (source, sourcePath, computedHash)
```

### 6.5 Why Cursor owns rules and OpenCode owns commands and skills

This split was a deliberate response to a real constraint.

| | Cursor | OpenCode |
|---|--------|----------|
| Instruction file | `AGENTS.md` | `AGENTS.md` |
| Rules | ✅ `.cursor/rules/*.mdc` | reads them as plain text |
| Commands | ❌ no command folder | ✅ `.opencode/commands/` |
| Skills | not a first-class concept | ✅ reads `.agents/skills/` |
| Context cost | rules sit in the prompt window | commands/skills load only when invoked |

The reasoning:

1. **Token budget.** Cursor keeps always-on rules in context on every request. Command and
   skill bodies are long procedures — ideal *not* to have always resident. OpenCode loads
   them only when a command or skill is invoked, so the heavy text stays off the hot path.
2. **Cursor's rules hit a ceiling.** Once a rule grows past a screen or two, it costs
   tokens on every turn and starts conflicting with the code in context. So Cursor rules
   here stay small and scoped (three files), and the long procedures moved to skills.
3. **OpenCode needs a commands folder.** It was not enough to have skills in `.agents/`;
   OpenCode looks for `.opencode/commands/` to expose them as slash commands. That is why
   the folder exists even though the procedures already lived in skills.
4. **One workflow, two readers.** Both tools read `AGENTS.md`, so the "read the docs first"
   contract is defined once. Cursor adds enforcement for C#/EF; OpenCode adds the verbs.

The practical rule of thumb:

- Repeated constraint that must always hold → **Cursor rule** (short).
- Repeatable multi-step procedure → **skill**.
- A verb you want to type → **OpenCode command** wrapping that skill.

### 6.6 Known gap in this setup

Only **3 of the 10 skills** have an OpenCode command wrapper (`start`, `audit`,
`continue`). The other seven (`learn`, `quick-ref`, `ticket`, `review`, `qa-review`,
`prepare-commits`, `update-docs`) can be invoked by naming the skill, but they do not
appear as `/commands`. Adding a wrapper is a five-line file — see the template in
[§6.3](#63-opencode-commands). Until then, treat the table in §6.4 as the reference for
what is available.

---

## 7. Part B — Git, GitHub and GitLab

### 7.1 The three remotes

```bash
git remote -v
```

| Remote | URL | Role |
|--------|-----|------|
| `upstream` | `github.com/Mahmoud23199/Ecommerce-Asp.NetCore-application` | the original project we did not write |
| `origin` | `github.com/IrfanMunirDev/Ecommerce-Asp-NetCore-Onboarding` | our GitHub fork: onboarding docs, agent setup |
| `gitlab` | `gitlab.com/comp1-group4930245/ecommerce-aspnet-core` | **the CI/CD and deployment home** |

The branch we work on everywhere is `master`. The GitLab project's **default branch
setting** also needs to be `master`, because the deploy job's rule compares against
`$CI_DEFAULT_BRANCH` — check *Settings → Repository → Default branch* if deploy never
becomes available.

The important consequence: **pushing to `origin` does not run a pipeline.** Only `gitlab`
does. If you want GitHub and GitLab to match, push to both:

```bash
git push origin master && git push gitlab master
```

### 7.2 How we moved the repository to GitLab

The short version: GitHub keeps the history and the fork relationship; GitLab becomes the
place where builds and deploys happen. Steps, in order:

1. **Create the GitLab project.** In the `comp1-group4930245` group, create an empty
   project named `ecommerce-aspnet-core`. Do **not** initialise it with a README — an
   initial commit makes the first push fail with unrelated histories.
2. **Add the remote** in the existing clone. Both remotes coexist; nothing is moved or
   copied by hand:

   ```bash
   git remote add gitlab https://gitlab.com/comp1-group4930245/ecommerce-aspnet-core.git
   git remote -v
   ```

3. **Push the existing history.** This uploads all branches and commits, not just files:

   ```bash
   git push -u gitlab master
   ```

   `-u` sets `gitlab/master` as the upstream of your local `master`, so later you can run
   plain `git push gitlab`.

4. **Check the default branch** in *Settings → Repository* is `master` (the pipeline's
   deploy rule compares against `$CI_DEFAULT_BRANCH`).
5. **Add the CI/CD variables** before the first deploy — see [§7.5](#75-cicd-variables).
6. **Let the first pipeline run** on push to `master`. Build and publish run
   automatically; deploy waits for a human.
7. **Deploy** by pressing the play button on the `deploy` job.

Commit `3b1f3bb` *"ci: add first GitLab pipeline (build)"* is where this happened in the
history — the pipeline came first, deployment was added later.

### 7.3 Branch and merge-request workflow as used here

The history shows the pattern this repo follows:

```
ci/gitlab-monsterasp-deploy   ──►  merge request  ──►  master
chore/audit-and-local-db      ──►  merge request  ──►  master
docs/onboarding-and-cursor-rules ──► merge request ──► master
```

Practical loop:

```bash
git switch -c ci/fix-deploy          # 1. branch off master
# ...edit...
git add -A && git commit -m "ci: fix SFTP deploy"   # 2. commit
git push -u gitlab ci/fix-deploy     # 3. push the branch (pipeline runs)
# 4. open a Merge Request in GitLab, review the pipeline, merge
git switch master && git pull gitlab master          # 5. sync locally
```

Merge requests are how GitLab runs a pipeline **before** the code reaches `master`, which
is exactly what a ticket-driven workflow needs later.

### 7.4 The pipeline explained

`.gitlab-ci.yml`, line by line:

```yaml
image: mcr.microsoft.com/dotnet/sdk:8.0     # every job starts in a .NET 8 SDK container

stages: [build, publish, deploy]            # jobs in a stage run in parallel;
                                            # next stage waits for the previous one

variables:
  NUGET_PACKAGES: "$CI_PROJECT_DIR/.nuget/packages"   # keep NuGet inside the project
                                                       # so it can be cached

cache:
  key: nuget
  paths:
    - .nuget/packages                       # reuse restored packages between pipelines
```

**Stage 1 — `build`**

```yaml
build:
  stage: build
  script:
    - dotnet restore
    - dotnet build --configuration Release --no-restore
```

Restore, then compile in Release. If this fails, nothing else runs — a compile error can
never reach production.

**Stage 2 — `publish`**

```yaml
publish:
  stage: publish
  needs: [build]
  script:
    - dotnet publish ECommerce/ECommerce.csproj --configuration Release \
        -r win-x86 --self-contained false -o publish
  artifacts:
    paths:
      - publish/
    expire_in: 1 week
```

- `-r win-x86` targets the 32-bit Windows runtime — this matters, because MonsterASP
  hosting runs the app as a Windows site.
- `--self-contained false` means the .NET 8 runtime must already be installed on the
  server. It is (see [§8.2](#82-runtime-settings)); a self-contained build would be far
  larger for no benefit here.
- `artifacts` hands the `publish/` folder to the deploy job and keeps it downloadable for
  a week from the pipeline page.

**Stage 3 — `deploy`**

```yaml
deploy:
  stage: deploy
  image: alpine:3.20
  needs: [publish]
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
  script:
    - apk add --no-cache lftp ca-certificates openssh-client
    - chmod +x deploy/monsterasp-deploy.sh
    - sh deploy/monsterasp-deploy.sh
  environment:
    name: production
    url: $SITE_URL
```

- A different, minimal image (`alpine`) because deploying needs `lftp`, not the .NET SDK.
- `rules` + `when: manual`: **only** on `master`, and **only** when someone presses play.
  Nobody can deploy by accident from a feature branch.
- `environment` registers a GitLab environment called `production` and links to
  `$SITE_URL`, so *Deployments → Environments* shows what is live.

### 7.5 CI/CD variables

The pipeline needs five variables. Set them in
**Settings → CI/CD → Variables → Add variable**:

| Variable | What it is | Masked | Protected | Example |
|----------|-----------|--------|-----------|---------|
| `FTP_HOST` | MonsterASP SFTP hostname | no | yes | `sftp.your-host.example` |
| `FTP_PORT` | SFTP port | no | yes | `2222` |
| `FTP_USER` | SFTP username | no | yes | `site-user` |
| `FTP_PASSWORD` | SFTP password | **yes** | yes | (secret) |
| `SITE_URL` | public site URL, used by the health check and the environment link | no | yes | `https://your-site.runasp.net` |

Rules of thumb:

- **Masked** keeps the value out of job logs. Always mask `FTP_PASSWORD`.
- **Protected** makes the variable available only to pipelines on protected branches/tags.
  If `deploy` fails with `FTP_HOST required`, the usual cause is a protected variable and
  an unprotected branch.
- The deploy script fails fast on any missing value:

  ```sh
  : "${FTP_HOST:?FTP_HOST required}"
  ```

  So a missing variable produces a clear message instead of a mysterious empty login.
- **Never put these values in the repo.** `.gitlab-ci.yml` and
  `deploy/monsterasp-deploy.sh` only reference them by name.

### 7.6 Running the pipeline

| What you want | How |
|---------------|-----|
| Build + publish on a branch | push the branch — runs automatically |
| Deploy to production | *Build → Pipelines →* the `master` pipeline *→* press ▶ on `deploy` |
| Re-run a failed job | open the job *→* **Retry** |
| Run a whole pipeline again | *Pipelines →* **Run pipeline**, pick the branch |
| Download the published build | the `publish` job *→* **Browse / Download artifacts** |
| See what is deployed | *Deployments → Environments → production* |

Typical end-to-end run for this repo:

```
push to master
   └─ build      (≈1 min)   dotnet restore + Release build
      └─ publish (≈1 min)   win-x86 framework-dependent publish → artifact
         └─ deploy (manual) lftp SFTP upload + health check
```

### 7.7 What the deploy script actually does

`deploy/monsterasp-deploy.sh` is the part that touches the server. In order:

1. **Validate inputs.** `FTP_HOST`, `FTP_PORT`, `FTP_USER`, `FTP_PASSWORD` must exist, or
   the script exits immediately.
2. **Upload `app_offline.htm`** to `/wwwroot/`. ASP.NET Core (and IIS) serves this file and
   takes the app offline while files are being replaced, so users see "Updating…" instead
   of a half-broken site.
3. **Mirror the build.** `mirror -R --delete --parallel=2 --exclude app_offline.htm
   publish/ /wwwroot/` uploads only what changed and **deletes** remote files that no
   longer exist in the build. Without `--delete`, removed views and old DLLs pile up and
   cause strange runtime errors.
4. **Remove `app_offline.htm`**, bringing the site back up.
5. **Health check.** If `SITE_URL` is set, the script requests it up to 10 times, 5 s
   apart. Success prints `Health check OK`. Failure is reported but **does not fail the
   job** — a slow cold start is not a bad deploy.

lftp tuning in the script: `sftp:auto-confirm yes` (no host-key prompt in CI),
`net:max-retries 2`, `net:timeout 20`. If `lftp` exits non-zero the script prints
`SFTP deploy failed` and exits 1, which fails the job.

### 7.8 Pipeline troubleshooting — the fixes we actually made

| Symptom | Cause | Fix (commit) |
|---------|-------|--------------|
| Only a build ran, nothing deployed | pipeline started as build-only | added `publish` + `deploy` (`3b1f3bb` → `4e4bfc5`) |
| Slow pipelines, packages downloaded every run | no NuGet cache | `NUGET_PACKAGES` inside `$CI_PROJECT_DIR` + cache key `nuget` (`1008da5`) |
| Deploy job failed before uploading | `alpine` has no SSH/SFTP client | `apk add lftp ca-certificates openssh-client` (`b52789a`) |
| Deploy reported success while upload failed | `lftp` errors were swallowed | explicit `if ! lftp … then exit 1` (`b52789a`) |
| `FTP_HOST required` immediately | variable missing, or protected variable on an unprotected branch | add the variable / push to `master` |
| Site shows a database error after deploy | connection string variable not set on MonsterASP | [§8.7](#87-diagnostics-the-connection-string-bug) |

More general checks:

```bash
# is the file even there? (run inside the job, or trust the log)
ls -la deploy/
# variables visible to a job (never print values)
env | grep -E '^(FTP_HOST|FTP_PORT|FTP_USER|SITE_URL)=' | cut -d= -f1
```

---

## 8. Part C — MonsterASP hosting

MonsterASP is a Windows shared host. We use it for the database and the website; GitLab
CI does the file copying over SFTP.

### 8.1 What we provisioned

| Piece | What we chose |
|-------|--------------|
| Hosting type | Windows hosting with ASP.NET Core support |
| Website | one site, served from `/wwwroot` |
| Public URL | a free MonsterASP subdomain, e.g. `https://your-site.runasp.net` |
| Database | **SQL Server**, created from the hosting panel |
| Access | SFTP account for file upload (used by CI), panel login for settings |

### 8.2 Runtime settings

In the panel: **Website → .NET Runtime / Application Settings**.

- Set the runtime to **ASP.NET Core 8** (matches `net8.0` and the framework-dependent
  publish in §7.4). If the server only offers an older runtime, the site fails at startup
  with a framework-resolution error.
- The application root is the folder that contains `ECommerce.dll` — `/wwwroot` in our SFTP
  layout, which is why the deploy script mirrors into `/wwwroot/`.
- No custom `web.config` is maintained in source: publishing generates it, and IIS needs
  it to hand requests to `ECommerce.dll`.

### 8.3 Environment variables

In the panel: **Website → Environment Variables**. Two variables matter:

| Name | Value | Why |
|------|-------|-----|
| `ConnectionStrings__DefaultConnection` | the SQL Server connection string from the panel | supplies the empty `DefaultConnection` in `appsettings.json` |
| `ASPNETCORE_ENVIRONMENT` | `Production` | selects the production behaviour (the custom error page in `Program.cs`) |

**The double underscore is not a typo.** ASP.NET Core maps environment variables onto
configuration keys by replacing `:` with `__`. `ConnectionStrings:DefaultConnection` in
JSON becomes `ConnectionStrings__DefaultConnection` in the environment. A single
underscore (`ConnectionStrings_DefaultConnection`) does **not** bind, and the app keeps
the empty string from `appsettings.json`.

A connection string for MonsterASP's SQL Server looks like:

```
Server=<host-from-panel>;Database=<db-name>;User Id=<db-user>;Password=<db-password>;Encrypt=True;TrustServerCertificate=True;
```

Take the host, database, user and password from the database section of the panel — do
not guess them, and never commit them.

**Why the app starts but the database fails:** `appsettings.json` ships
`"DefaultConnection": ""` on purpose, so no secret is in git. Because `Program.cs` calls
`db.Database.Migrate()` during startup, a missing or wrong connection string throws during
the first request — not at file-copy time. The deploy can therefore be green while the
site is broken. That is the failure we hit and diagnosed below.

### 8.4 Database

1. In the panel, create a **SQL Server** database and note the host, database name, user
   and password it gives you.
2. Put those into `ConnectionStrings__DefaultConnection` (§8.3) — not into
   `appsettings.json`.
3. Let the app create the schema: `db.Database.Migrate()` in `Program.cs` applies the six
   migrations on first request.
4. Verify the tables exist (the panel's database tools, or any SQL client) —
   `Movies`, `Cinemas`, `Actors`, `Producers`, `Orders`, `OrderItems`, `ShoppingCartItem`,
   `ActorMovies`, `__EFMigrationsHistory`.
5. Local and production databases are **separate**. LocalDB data does not travel with a
   deploy; only the schema (migrations) does.

> If you ever need to run migrations without starting the site, use the connection string
> from the panel locally with `dotnet ef database update --connection "…"`. Do not paste
> production credentials into a tracked file.

### 8.5 SFTP settings

In the panel: **Website → FTP / SFTP accounts**. You need four values, which map 1:1 to
the GitLab variables in §7.5:

| Panel value | GitLab variable |
|-------------|-----------------|
| SFTP host | `FTP_HOST` |
| SFTP port (often not 22 on shared hosts) | `FTP_PORT` |
| username | `FTP_USER` |
| password | `FTP_PASSWORD` |

Notes that save time:

- Use the **SFTP** port from the panel, not 21 (that is plain FTP). The script connects to
  `sftp://$FTP_HOST:$FTP_PORT`.
- The upload target is `/wwwroot/`. If the account is chrooted, the same path is still
  correct from the account's perspective.
- Test the credentials before blaming CI:

  ```bash
  lftp -u "$FTP_USER","$FTP_PASSWORD" "sftp://$FTP_HOST:$FTP_PORT" -e "ls /wwwroot; bye"
  ```

### 8.6 Manual deploy (when you cannot use the pipeline)

Useful for the first upload, or when GitLab is unavailable. In FileZilla (or WinSCP):
connect with the same SFTP values, then upload the **contents** of `publish/` into
`/wwwroot/`, overwriting. Mirror the same steps as the script: upload `app_offline.htm`
first, replace files, delete `app_offline.htm` last.

Verify afterwards: the site loads, `/Movies` lists films, and the cart works.

### 8.7 Diagnostics: the connection string bug

This is the concrete debugging story behind "why does the deployed site throw a database
error when the pipeline is green?".

**Symptom.** After the first successful SFTP deploy, the site responded but every page that
touched data failed. The deploy job itself was green, because copying files is not the same
as running the app.

**Where the log is.** In the MonsterASP panel, the site's **Logs / Diagnostics** view (the
per-site log, not the GitLab job log). ASP.NET Core writes startup exceptions and unhandled
request exceptions there under the site's `stdout`/error log.

**What it showed.** A SQL Server connection/login error during startup — the app was trying
to open a connection with an empty or wrong connection string, raised from
`db.Database.Migrate()` in `Program.cs`.

**Why.** Two things combined:

1. `appsettings.json` deliberately has `"DefaultConnection": ""` (secrets never in git).
2. The environment variable on the site did not supply a usable value — it was missing or
   named incorrectly.

**The fix.** Set `ConnectionStrings__DefaultConnection` in **Website → Environment
Variables** with the double underscore, using the credentials from the database section of
the panel, then restart the site (stop/start the app pool or recycle) so the new value is
read.

**How to avoid repeating it** — a five-step checklist after any hosting change:

1. `appsettings.json` still has an empty `DefaultConnection` (it should).
2. The site has `ConnectionStrings__DefaultConnection` set, with `__` not `_`.
3. The value includes `Encrypt=True;TrustServerCertificate=True;` for shared SQL Server.
4. Restart the site after changing any environment variable.
5. Load a page that hits the database (e.g. `/Movies`), not just `/`.

**Reading logs like a beginner.** Open the log, search for the first `Exception` or
`fail:` line (not the last), and read the message before the stack trace. In .NET, the
top-level message usually names the exact thing that is wrong — "Login failed for user",
"network-related or instance-specific error", "invalid value for keyword 'server'". Fix
one line, redeploy or restart, check again. Logs are append-only, so note the timestamp of
the request you just made to find its entry.

### 8.8 Post-deploy smoke test

Run through this after every deploy:

1. `/` loads (home page, static assets, CSS visible).
2. `/Movies` lists movies — proves the database and migrations are alive.
3. Filtering from the movies page returns results.
4. Add to cart, open the cart, remove from cart — proves session state works.
5. Any page that should 404 does 404, and errors show the friendly page rather than a
   stack trace (`ASPNETCORE_ENVIRONMENT=Production`).

---

## 9. Part D — GitLab for beginners

A minimal mental model. Everything else is a detail.

```
Group (comp1-group4930245)
└── Project (ecommerce-aspnet-core)   ← one repo, one pipeline config, one issue tracker
    ├── Repository (branches, commits, tags)
    ├── Merge requests   (propose a branch → master, review, merge)
    ├── Pipelines        (build → publish → deploy, defined in .gitlab-ci.yml)
    │   └── Jobs         (one script block each; logs live here)
    ├── CI/CD variables  (secrets and config injected into jobs)
    ├── Environments     (production; what is deployed where)
    └── Issues           (tickets, labels, boards, milestones)
```

**Glossary**

| Term | Meaning in one line |
|------|--------------------|
| Project | A repo plus its pipeline, issues and settings |
| Branch | A movable pointer to a line of commits |
| Merge request (MR) | "Please merge this branch" + review + pipeline result |
| Pipeline | All the jobs triggered by one push or one click |
| Stage | A group of jobs that must finish before the next stage starts |
| Job | One script, one container, one log |
| Runner | The machine that executes jobs (GitLab-hosted here) |
| Artifact | Files a job produces and passes on (`publish/`) |
| Cache | Files kept between pipelines to speed them up (NuGet) |
| CI/CD variable | A key/value injected into jobs; where secrets live |
| Environment | A named deployment target (`production`) |
| Protected branch | A branch with extra rules (`master`) |
| Protected variable | A variable visible only to protected branches |

**Twelve commands that cover daily work**

```bash
# inspecting
git status                     # what changed
git log --oneline -10          # recent commits
git remote -v                  # where this repo points
git branch -a                  # local + remote branches

# working
git switch -c feat/cart-total  # new branch
git add -p                     # stage deliberately
git commit -m "feat: show cart total"
git push -u gitlab feat/cart-total

# syncing
git pull gitlab master         # bring master down
git switch master
git push origin master         # mirror to GitHub

# undoing (before push)
git restore <file>             # discard local edits
git commit --amend             # fix the last commit message
```

**Five mistakes beginners make here**

1. Pushing to `origin` and expecting a deploy. Only `gitlab` runs pipelines.
2. Creating the GitLab project with a README, then getting "unrelated histories" on push.
   Fix: `git pull --allow-unrelated-histories`, or start from an empty project.
3. Editing a secret into `appsettings.json` "just to test". The file is tracked; use the
   panel variable or `dotnet user-secrets`.
4. Making `FTP_PASSWORD` visible or unprotected. Mask it, protect it.
5. Deleting a remote file manually on the server. The next deploy mirrors with `--delete`
   and removes anything not in the build anyway — change the source, not the server.

---

## 10. Part E — Roadmap: from tickets to agents

Long-term goal: **a GitLab issue becomes the unit of work**, and an agent picks it up,
implements it, tests run in CI, and the pipeline refuses to merge when the ticket's
requirements are not met.

Today the repo has the workflow *documentation* for that, but not the enforcement. Here is
the honest gap list and the path.

### 10.1 What exists already

| Piece | Status |
|-------|--------|
| `AGENTS.md` doc-first contract | ✅ in place |
| Cursor rules for C# and EF | ✅ in place |
| Skills for ticket analysis, review, QA review | ✅ in place (`ticket`, `review`, `qa-review`) |
| `.gitlab-ci.yml` build → publish → deploy | ✅ in place |
| Merge requests | ✅ used |
| A test project | ❌ does not exist |
| A test stage in the pipeline | ❌ does not exist |
| Issue templates / labels | ❌ not defined |
| Requirement-to-test traceability | ❌ not defined |

### 10.2 The loop we are building toward

```
GitLab issue (ticket)
   │  /ticket  → requirements, affected files, plan (no code)
   ▼
agent implements on a branch
   │  /review  → self-review the diff
   ▼
push → pipeline: build → test
   │        ├─ any test fails → pipeline red → merge blocked
   │        └─ green
   ▼
/qa-review #<issue>  → checks the diff against acceptance criteria, reports coverage
   │
   ▼
merge request → human approves → deploy (manual)
```

Each step already has a verb; what is missing is the machinery that makes a red pipeline
truly blocking and a QA review mandatory.

### 10.3 Issue template (paste into GitLab → Issues → New issue description)

```markdown
## Context
Why this exists. Link the module docs: docs/onboarding/repos/ecommerce/...

## Acceptance criteria
- [ ] When I open /Movies and type "dune", only matching films are listed
- [ ] The filter is case-insensitive
- [ ] An empty search shows all movies

## Out of scope
Anything not listed above.

## Affected area
MoviesController, Views/Movies/Index.cshtml, repositories

## Definition of Done
- [ ] Build passes
- [ ] New/updated tests pass in CI
- [ ] No migration edited after being applied
- [ ] docs/onboarding updated if behaviour or architecture changed
```

The acceptance criteria are the contract the QA step checks against. Vague tickets cannot
be verified, so they cannot gate a merge.

### 10.4 Labels to create

| Label | Meaning |
|-------|---------|
| `status::ready` | specified, safe for an agent to start |
| `status::in-progress` | a branch exists |
| `status::review` | MR open |
| `status::blocked` | waiting on a human decision |
| `area::controllers`, `area::views`, `area::data`, `area::ci` | where the change lands |
| `agent::ok` | well-specified enough for an agent to complete unattended |
| `size::s` / `size::m` / `size::l` | scope, used to pick what an agent takes next |

`agent::ok` is the important one: a ticket only becomes agent work when it has measurable
acceptance criteria, a bounded area, and no open product questions.

### 10.5 Target pipeline with tests

This is **not** what runs today — it is the shape to aim for once a test project exists.
`dotnet test` returns a non-zero exit code on failure, which fails the job, which fails the
pipeline, which blocks the merge request.

```yaml
stages: [build, test, publish, deploy]

test:
  stage: test
  needs: [build]
  script:
    - dotnet test --configuration Release --no-build \
        --logger "trx;LogFileName=results.trx"
  artifacts:
    when: always
    reports:
      junit: "**/results.trx"      # shows test results on the MR page
    paths:
      - "**/results.trx"
```

Enable *Settings → Merge requests → Pipelines must succeed* so a red pipeline stops the
merge. Merge requests then become the gate, not a habit.

### 10.6 Where to start (smallest useful steps)

1. **Create the test project.** `dotnet new xunit -o ECommerce.Tests`, add it to the
   solution, reference `ECommerce`, and write one test for an existing repository method.
   Without this, none of the gating can exist.
2. **Add the `test` stage** and turn on "pipelines must succeed".
3. **Create the labels and the issue template** so tickets start being verifiable.
4. **Wrap the remaining skills as commands** (`/ticket`, `/review`, `/qa-review`) — see
   §6.6.
5. **Try one ticket end to end** with a human watching: `/ticket` → implement →
   `/review` → push → green pipeline → `/qa-review` → merge.
6. Only then let an agent take an `agent::ok` ticket unattended, and keep the manual deploy
   gate.

### 10.7 Guardrails for autonomous agents

- One ticket, one branch, one merge request. Never let an agent push to `master`.
- Deploy stays manual until the test stage has been stable for a while.
- An agent may not edit applied migrations, `.gitlab-ci.yml`, or environment variables
  without a human — those are the three ways a small mistake becomes an outage.
- Every agent MR must state which acceptance criteria it believes it met, so QA has
  something concrete to check.
- If a ticket requires a product decision, it is not `agent::ok`. Move it to
  `status::blocked` and ask.

---

## 11. Known rough edges

Documented so nobody "fixes" them by accident or is surprised by them:

| Item | Detail |
|------|--------|
| Unused package | `Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter` is referenced but no QuickGrid component exists |
| Duplicate view folders | `Views/Producer/` and `Views/Producers/` both exist; the controller renders `Producers` |
| `@section Scripts` in the layout | `Views/Shared/_Layout.cshtml:70` *defines* a `Scripts` section (the AJAX movie-search wiring) after `</body>`, instead of relying on views to define it. `RenderSectionAsync("Scripts")` is called on line 68, before it, so that block is almost certainly never emitted and the live-search box does nothing. Not confirmed in a browser. |
| Filter matches two fields only | `Movies/Filter` matches `Name` or `Description`; `MovieCategory` is stored but not searched |
| No test project | any change is verified manually; see §10 |
| Cart identity is session-scoped | items persist in `shoppingCartItems` against a GUID in `ISession`; with the default in-memory session store a restart hands out a new GUID, so the old cart looks empty and its rows are orphaned. The cart is also not tied to a user, because there is no authentication. |
| Cart bypasses the unit of work | `ShoppingCart` uses `EcommerceContext` directly instead of `IUnitOfWork`/repositories |
| Anti-forgery gap | `Movies`, `Cinemas` and `Producers` POST actions carry `[ValidateAntiForgeryToken]`; **`ActorsController` posts do not** |
| `ShoppingCardId` spelling | the column/property is `ShoppingCardId` ("Card", not "Cart") and is used consistently |
| Unused `Order.UserId` | the column exists with no authentication to populate it |
| `Program.cs` runs migrations at startup | convenient, but it means a bad connection string fails at first request, not at deploy time (§8.7) |

---

## 12. Docs index

Agent onboarding state — read these before analysing code:

| Document | Purpose |
|----------|---------|
| [`docs/onboarding/project-memory.md`](docs/onboarding/project-memory.md) | source of truth for config, stack, source roots, conventions |
| [`docs/onboarding/progress.md`](docs/onboarding/progress.md) | current focus, session log, handoff notes |
| [`docs/onboarding/repositories-overview.md`](docs/onboarding/repositories-overview.md) | units in this repo |
| [`docs/onboarding/onboarding-audit.md`](docs/onboarding/onboarding-audit.md) | coverage scores and prioritized gaps |
| [`docs/onboarding/open-questions.md`](docs/onboarding/open-questions.md) | known unknowns |
| [`docs/onboarding/repos/ecommerce/`](docs/onboarding/repos/ecommerce/) | overview, architecture, request flow, patterns, integrations, files |

Agent configuration:

| Path | Purpose |
|------|---------|
| `AGENTS.md` | shared instructions for every AGENTS.md-aware agent |
| `.cursor/rules/` | scoped Cursor rules |
| `.opencode/commands/` | OpenCode slash commands |
| `.agents/skills/` | skill procedures |
| `skills-lock.json` | pinned skill versions |

---

## 13. Glossary

| Term | Meaning |
|------|---------|
| **MVC** | Model–View–Controller: controller handles a request, returns a view |
| **Razor view** | `.cshtml` template mixing HTML and C# |
| **EF Core** | .NET's ORM; maps C# classes to tables |
| **Migration** | A versioned, generated schema change |
| **DbContext** | The EF Core session object; here `EcommerceContext` |
| **Repository pattern** | A class that wraps data access behind an interface |
| **Unit of Work** | One object exposing several repositories with a shared transaction |
| **DI** | Dependency injection: the framework supplies dependencies |
| **Session** | Per-browser server-side state; used to hold the cart |
| **SFTP** | SSH file transfer, used to upload the build |
| **Health check** | An HTTP request after deploy to confirm the site answers |
| **Pipeline / job / stage** | GitLab CI: a run / a script / a group of jobs |
| **CI/CD variable** | Config injected into jobs; where secrets live |
| **Merge request** | GitLab's pull request |
| **Artifact** | Build output passed between jobs |

---

*Last verified against the source on 2026-11-09. If a fact here disagrees with the code,
the code wins — update this README and `docs/onboarding/` in the same commit.*
