---
name: qa-review
description: Validates implementation against ticket requirements. Compares requirements with code changes, identifies completed items, missing functionality, regressions, and provides implementation coverage. Use when the user invokes /qa-review or asks whether a ticket has been fully implemented.
disable-model-invocation: true
---

# QA Review

Slash trigger: `/qa-review`

## Goal

Verify that the implementation satisfies the ticket requirements.

This is NOT a code quality review.
Focus only on requirement coverage, functional correctness, and implementation completeness.

## Hard rules

- MUST read ticket/requirements and inspect the diff before concluding.
- MUST map every finding back to a specific requirement.
- MUST NOT modify code unless explicitly requested.
- NEVER assume intent — mark complete only with evidence in code.
- If `docs/onboarding/` exists, read `project-memory.md` for repository context.

## Gather context

Before reviewing:

1. Read the ticket, issue, PR description, or user-provided requirements.
2. Read `docs/onboarding/project-memory.md` for repository context (if present).
3. Inspect the complete diff (`git diff`, staged changes, or branch diff vs base).
4. Read only the files necessary to verify the implemented functionality.
5. Review related tests when applicable.

## Validate

For every requirement:

- Is it implemented?
- Is it partially implemented?
- Is it missing?
- Is implementation correct?
- Are acceptance criteria satisfied?
- Are there regressions?
- Are edge scenarios covered?
- Do tests validate the requirement?

## Estimate coverage

Provide overall requirement coverage percentage and counts:

- Completed
- Partially complete
- Missing

## Output format

```markdown
# QA Review

## Overall Status

Requirement Coverage: **82%**

- ✅ Completed: 9
- 🟡 Partial: 1
- ❌ Missing: 1

---

## Requirement Checklist

| Requirement | Status | Evidence | Notes |
|-------------|--------|----------|-------|
| User can create project | ✅ Complete | ProjectController, ProjectService | Works as expected |
| User can archive project | 🟡 Partial | API implemented | UI missing |
| Email notification | ❌ Missing | None | Not found |

---

## Gaps

### Critical

- Missing email notification.
- Acceptance criterion #7 not implemented.

### Partial

- Archive flow exists but frontend cannot trigger it.

---

## Regression Risk

List any existing behavior that may have changed.

---

## Test Coverage

Requirements covered by tests:

- Requirement A ✅
- Requirement B ✅

Missing tests:

- Requirement C
- Permission scenarios
- Failure path

---

## Final Assessment

Ticket appears approximately **82% complete**.

The following acceptance criteria remain unmet:

1. ...
2. ...

The ticket should **not** be considered complete until these gaps are addressed.
```

## Review principles

- Base conclusions only on observable evidence.
- Map every finding back to a requirement.
- Distinguish between missing implementation and missing tests.
- Prefer requirement traceability over code quality commentary (use `/review` for code quality).
- Mention uncertainty explicitly when requirements are ambiguous.

## Related commands

- `/ticket` — analyze requirements before implementation (no code)
- `/review` — code quality, patterns, edge cases before merge
- `/update-docs` — capture new knowledge after work
