---
description: Fix a GitHub/GitLab issue by number
argument-hint: Issue number (e.g., #123 or 123)
allowed-tools: ["Bash", "Read", "Edit", "Write", "Grep", "Glob", "Agent"]
---

# /fix-issue — Automated Issue Resolution

Fetch issue details and autonomously fix it.

## Steps

### 1. Parse issue number

- Extract issue number from `$ARGUMENTS`
- Support formats: `#123`, `123`, `issue-123`

### 2. Fetch issue details

Use `gh` CLI to get issue info:
```bash
gh issue view <number> --json title,body,labels,assignees
```

If `gh` not available, ask user to:
- Install GitHub CLI, or
- Paste the issue details manually

### 3. Understand the issue

- Read the issue title and description
- Identify the type: bug fix, feature request, refactor, etc.
- Extract acceptance criteria or requirements
- Note any mentioned files or code locations

### 4. Plan the fix

- Search for relevant code using Grep/Glob
- Read the files that need changes
- Create a plan for the fix
- If complex (3+ steps), enter plan mode

### 5. Implement the fix

- Make the necessary code changes
- Follow the codebase's existing patterns
- Add or update tests if needed
- Ensure no regressions

### 6. Verify the fix

- Run relevant tests
- Check for syntax errors
- Verify the fix addresses the issue requirements

### 7. Commit and reference

- Create a commit with a message that references the issue
- Format: `Fix #<number>: <short description>`
- Ask if user wants to push or create a PR

## Notes

- Be autonomous — don't ask for permission at each step
- If stuck, use an Explore agent to find relevant code
- For test failures, fix them before marking complete
- Always verify the fix works before finishing
