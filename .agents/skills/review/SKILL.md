---
name: review
description: Reviews code changes for patterns, architecture, error handling, edge cases, backward compatibility, and test impact. Use when the user invokes /review or asks to review changes, diffs, or work in progress before merge.
disable-model-invocation: true
---

# Review Work

Slash trigger: `/review`

Review all code changes before merge. Provide actionable findings; do not modify code unless the user explicitly asks for fixes.

## Hard rules

- MUST read `docs/onboarding/project-memory.md` for architecture and convention context when available.
- MUST inspect the full diff before reviewing.
- MUST NOT modify code unless the user explicitly asks for fixes.
- Read only files needed to understand the change and its surroundings — no full-repo scan.

## Gather context

1. Read `docs/onboarding/project-memory.md` (if exists).
2. Inspect diff: `git diff`, staged changes, or branch diff vs base.
3. Read surrounding files only when needed for pattern or architecture context.

If onboarding not initialized, review using repo conventions from changed files and README only.

## Check

- Existing project patterns and naming conventions
- Architecture compliance (module boundaries, layering)
- Error handling and logging
- Edge cases (null/empty inputs, permissions, concurrency)
- Backward compatibility (API, schema, config, clients)
- Tests affected or missing

## Output format

```markdown
## Summary
[One-paragraph overview of what changed and overall assessment]

## Findings

### Existing project patterns
[Does the change match conventions in the affected area?]

### Architecture compliance
[Does it fit service boundaries and layering documented in onboarding docs?]

### Error handling
[Are failures handled, logged, and surfaced appropriately?]

### Edge cases
[Null/empty inputs, permissions, concurrency, etc.]

### Backward compatibility
[API, schema, config, or client breakage risk]

### Tests affected
[What should be added, updated, or run; gaps in coverage]

## Improvement suggestions
[Actionable items ordered by priority]
```

Severity labels:

- **Critical**: Must fix before merge
- **Suggestion**: Consider improving
- **Nice to have**: Optional enhancement

## After review

If new architectural knowledge emerged, suggest `/update-docs` to capture it in onboarding state files.
