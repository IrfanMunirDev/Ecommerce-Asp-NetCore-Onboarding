---
name: prepare-commits
description: Analyzes git changes and proposes commit groups with messages and file lists before push. Use when the user invokes /prepare-commits, asks for commit message help, wants to group changes into commits, or is ready to commit and push.
disable-model-invocation: true
---

# Prepare Commits

Slash trigger: `/prepare-commits`

Analyze all local changes and return commit-ready groups with messages and file lists. The user selects which group to commit; do not commit or push unless explicitly asked.

## Hard rules

- MUST analyze all changes before proposing commits.
- MUST NOT modify source code during this workflow.
- NEVER run `git commit` or `git push` unless the user explicitly asks in that turn.
- NEVER update git config.
- NEVER use `--no-verify` unless the user explicitly requests it.
- NEVER amend unless the user explicitly requests it AND amend preconditions are met (HEAD commit by this session, not pushed).
- NEVER include unrelated files in a commit group.
- NEVER commit files that likely contain secrets — warn instead (`.env`, keys, tokens).

## Gather git state (run in parallel)

- `git status --short`
- `git diff` (unstaged changes)
- `git diff --cached` (staged changes)
- `git log -5 --oneline` (match commit message style)

If the user specifies a base branch, also run `git diff <base>...HEAD`.

## Analyze changes

- Read changed files only as needed to understand what changed
- Group by logical concern: feature, fix, docs, refactor, test, chore
- Split into **multiple commits** when changes are unrelated (e.g. docs + feature code)
- Keep tightly related files in the same commit

## Return commit plan (no git write actions yet)

Propose one or more commit groups. Each group MUST include:

- Commit title and message (1–2 sentences, focus on **why**)
- Full file paths in that group
- One-line summary per file explaining what changed
- Ready-to-run `git add` command
- Ready-to-run `git commit` command using HEREDOC format

If only one commit is appropriate, say so and explain why.

## Wait for user selection

After showing the plan, ask which commit group to apply (e.g. "Commit group 1" or specific files).

Only after explicit approval:

1. Stage the selected files with `git add`
2. Create the commit with the proposed message
3. Run `git status` to confirm success

Repeat for remaining groups if the user wants more commits. Push only if the user explicitly asks.

## Output format

```markdown
## Change Analysis
[Short overview: total files changed, main themes, whether one or multiple commits are recommended]

## Proposed Commits

### Commit 1: <short title>
**Why:** <one sentence explaining the purpose>

**Files:**
- `path/to/fileA` — <what changed in this file>
- `path/to/fileB` — <what changed in this file>

**Stage:**
git add path/to/fileA path/to/fileB

**Commit:**
git commit -m "$(cat <<'EOF'
<commit message>

EOF
)"
```

## When user says "commit group N" or "commit these files"

1. Stage only the files in that group
2. Commit with the proposed message (HEREDOC format)
3. Show `git status` after commit
4. Remind user of remaining uncommitted groups if any

## When user says "push"

1. Confirm branch and remote status (`git status`, `git log origin/HEAD..HEAD` if tracking exists)
2. Push only with explicit user request
3. Do not force-push to main/master unless explicitly requested (warn if so)
