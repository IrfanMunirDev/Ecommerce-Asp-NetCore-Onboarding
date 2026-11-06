---
name: start
description: Bootstrap docs/onboarding/ state files on any codebase for zero-knowledge onboarding. Use when starting onboarding, setting up a new project, bootstrapping documentation, or when the user runs /start on an unknown repo.
disable-model-invocation: true
---

# Start Onboarding

Slash trigger: `/start`

Bootstrap persistent onboarding state and install the Project-Knowledge-First rule in the target repository so later slash commands and everyday agent work can resume without re-scanning the whole codebase.

## Hard rules

- MUST create `docs/onboarding/` (or path from existing `project-memory.md` if present).
- MUST install `.cursor/rules/project-knowledge-first.mdc` from the bundled rule in this skill directory.
- MUST detect stack and repo layout before writing files — never assume monorepo or single-repo.
- NEVER scan the entire codebase — use manifest-based discovery only in this invocation.
- NEVER hardcode project-specific paths, repo names, or business domains.
- Read at most 1 existing state file if `docs/onboarding/project-memory.md` already exists.

## Bundled assets (installed with this skill)

Templates and rules ship inside this skill folder. Resolve paths relative to this skill's install location:

| Bundled path | Purpose |
|--------------|---------|
| `templates/` | State file scaffolds for `docs/onboarding/` |
| `templates/per-repo/` | Six-file doc set per discovered repo/module |
| `rules/project-knowledge-first.mdc` | Always-on Cursor rule for doc-first workflow |

Typical install locations:
- Cursor: `.cursor/skills/start/` or `.agents/skills/start/`
- Other agents: `.agents/skills/start/`

If bundled templates are not found, use the inline scaffolds in the "Fallback scaffolds" section below.

## Stop conditions

Stop after:
1. State directory exists with all five core files seeded from bundled templates.
2. `project-memory.md` lists detected repos/modules, stack, and source roots.
3. `repositories-overview.md` has one row per discovered unit.
4. `.cursor/rules/project-knowledge-first.mdc` exists (created or already present).
5. User receives a short summary of what was detected and suggested next command (`/audit`).

Do not explore source code beyond manifests and top-level directory listing.

## Discovery procedure

1. Check for existing `docs/onboarding/project-memory.md`. If found, read it and honor `docs_path` and `source_roots` overrides.
2. Detect layout (use first match):
   - **Monorepo signals:** `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, root `package.json` workspaces, `go.work`, `Cargo.toml` workspace
   - **Multi-repo signals:** multiple top-level apps each with own manifest (`package.json`, `go.mod`, `pyproject.toml`, `Gemfile`, `Cargo.toml`)
   - **Single-repo:** one manifest at root
3. List top-level directories (max depth 1). Skip `.git`, `node_modules`, `vendor`, `dist`, `build`, `.cursor`.
4. Detect stack from manifests (language, framework, package manager).
5. Identify likely entry points: `main.go`, `src/index.ts`, `app/main.py`, `config/routes.rb`, etc. — record paths only, do not read file contents unless ≤3 obvious entry files.

## Files to create

Copy from bundled `templates/` into `docs/onboarding/` (or configured `docs_path`):

| File | Purpose |
|------|---------|
| `project-memory.md` | Source of truth: config, detected stack, source roots |
| `progress.md` | Empty session log with init entry |
| `onboarding-audit.md` | Skeleton tiers, 0% completion |
| `open-questions.md` | Empty blocked-items list |
| `repositories-overview.md` | Table of discovered repos/modules |

For each discovered repo/module, create `docs/onboarding/repos/<slug>/` with six stub files from bundled `templates/per-repo/`:
`overview.md`, `architecture.md`, `request-flow.md`, `common-patterns.md`, `integrations.md`, `important-files.md`

## Install Project-Knowledge-First rule

1. Locate bundled rule: `rules/project-knowledge-first.mdc` in this skill's directory.
2. Create `.cursor/rules/` in the target repo if missing.
3. Copy to `.cursor/rules/project-knowledge-first.mdc`.
4. If the file already exists, do not overwrite — report that it is already installed.

This rule sets `alwaysApply: true` so every agent session reads onboarding docs before analyzing code.

## project-memory.md seed content

Fill the template and include these config keys:

```markdown
## Config
- docs_path: docs/onboarding
- source_roots: [auto-detected paths]
- layout: monorepo | multi-repo | single-repo
- stack: [detected languages/frameworks]
- initialized: [ISO date]
```

Also add an init entry to `progress.md` with today's date and detected layout.

## Output to user

Provide:
- Detected layout and stack
- List of repos/modules found
- Onboarding files created
- Rule installed: `.cursor/rules/project-knowledge-first.mdc` (or already present)
- Recommended next step: run `/audit` for gap analysis

## Token budget

- Max 1 state file read
- Max 10 manifest/top-level directory operations
- No deep source exploration in `/start`

## Fallback scaffolds

Use only if bundled `templates/` cannot be read. Create minimal files with section headers and `<!-- fill -->` placeholders matching the repo-root template structure.
