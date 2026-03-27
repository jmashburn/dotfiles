---
description: Run a post-implementation review: diff summary, test verification, elegance check, and staff engineer bar
argument-hint: Optional specific area or concern to focus the review on
allowed-tools: ["Read", "Bash", "Grep", "Glob"]
---

## Changes to Review

!`git diff --name-only main...HEAD`

## Detailed Diff

!`git diff main...HEAD`

# /review — Post-Implementation Review

Your job is to run a structured review of recent changes and produce a clear pass/fail verdict before marking any task complete.

## Steps

### 1. Gather the diff

Run `git diff HEAD` (and `git diff --staged` if relevant) to see all changes. If `$ARGUMENTS` specifies a path or concern, focus there.

Summarize what changed in plain language:
- Files modified and why
- Key logic changes
- Anything removed

### 2. Check tests

- Look for a test runner (package.json scripts, Makefile, pytest, etc.)
- Run the relevant test suite if one exists
- If no tests exist, note it as a gap

### 3. Elegance check

For each changed file, ask yourself:
- Is this the simplest possible solution?
- Are there unnecessary abstractions or over-engineering?
- Does it touch only what's necessary (minimal impact)?
- Would a reader understand this without comments?
- Are there any hacks, workarounds, or TODOs left in?

Flag anything that feels off.

### 4. Security check

Scan changed code for obvious issues:
- User input used in shell commands (injection risk)
- Hardcoded secrets or tokens
- Unsafe file operations
- XSS, SQL injection patterns

### 5. Staff engineer bar

Ask: "Would a staff engineer approve this PR without requesting changes?"

Criteria:
- Solves the actual problem (not a workaround)
- No leftover debug code
- No regressions introduced
- Consistent with existing codebase style
- Handles edge cases that are reasonably likely

### 6. Verdict

Output a structured summary:

```
## Review Summary

**Changes**: {1-2 sentence summary}

**Tests**: ✓ passing / ✗ failing / ⚠ none

**Elegance**: ✓ clean / ⚠ minor issues / ✗ needs rework
{list any issues}

**Security**: ✓ clean / ⚠ review / ✗ issues found
{list any issues}

**Staff engineer bar**: ✓ approve / ✗ request changes
{reason if failing}

**Verdict**: DONE ✓ / NEEDS WORK ✗
```

If verdict is NEEDS WORK, list the specific items to fix before marking complete.
