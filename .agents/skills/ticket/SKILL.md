---
name: ticket
description: Analyzes tickets for business requirements, affected repos/modules, root cause, and implementation planning without writing code. Use when the user invokes /ticket, pastes a Jira or Linear ticket, or asks for ticket analysis on an onboarded codebase.
disable-model-invocation: true
---

# Ticket Analysis

Slash trigger: `/ticket`

Analyze a ticket (Jira, Linear, GitHub issue, or pasted description) for requirements, impact, and implementation plan. Do NOT write code.

## Hard rules

- MUST read onboarding state files before exploring source code.
- MUST NOT write or modify code — analysis and planning only.
- NEVER scan the entire codebase — inspect only repos/modules/files relevant to the ticket.
- If `docs/onboarding/` is missing, tell the user to run `/start` first.

## Required reads (in order)

All paths under `docs/onboarding/` (or configured `docs_path`):

1. `project-memory.md` — stack, conventions, source roots
2. `repositories-overview.md` — repo/module index
3. Relevant `repos/<slug>/overview.md`, `architecture.md`, or `request-flow.md` for suspected areas only

Max 4 state files before touching source code.

## Input

User provides one of:
- Ticket ID + paste/description
- Full ticket text
- Link to issue (read description if accessible; otherwise ask user to paste)

## Analysis procedure

1. Parse ticket: summary, acceptance criteria, steps to reproduce (if bug), labels/components.
2. Map ticket to repos/modules using `repositories-overview.md` and `source_roots`.
3. Read only required source files to confirm existing behavior (bounded — max 10–15 files).
4. Produce structured analysis — no code.

## Output format

```markdown
## 1. Business requirement
[What the ticket is asking for, in business terms]

## 2. Affected repositories
[List repos/modules that need changes; note areas ruled out]

## 3. Affected modules
[Specific modules, routers, services, or components per repo]

## 4. Existing behavior
[What the system does today in the relevant area — cite file paths]

## 5. Root cause analysis
[For bugs: why it fails; for features: gap between current and desired state]

## 6. Implementation plan
[Ordered steps per affected repo/module; no code]

## 7. Risk assessment
[Breaking changes, migrations, performance, auth, side effects]

## 8. Suggested next steps
[/learn on affected module, /continue to document area, or proceed to implementation]
```

## Token budget

- 2–4 state files read
- 10–15 source files max for verification
- Stop after structured analysis
