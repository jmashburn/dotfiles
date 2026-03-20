---
description: Start a new task by scaffolding tasks/todo.md with standard planning sections, then enter plan mode
argument-hint: Brief description of the task to plan
allowed-tools: ["Read", "Write", "Bash", "Glob", "EnterPlanMode"]
---

# /plan — Task Planning

Your job is to scaffold a `tasks/todo.md` file for the current task and enter plan mode.

## Steps

### 1. Understand the task

- If `$ARGUMENTS` is provided, use it as the task description.
- If not, ask the user what they want to accomplish before proceeding.

### 2. Load context

- Check if `tasks/todo.md` already exists. If so, read it — the user may be resuming a task.
- Check if `tasks/lessons.md` exists and skim it for patterns relevant to this task.

### 3. Scaffold tasks/todo.md

Create (or replace) `tasks/todo.md` with this exact structure:

```markdown
# Task: {task description}

## Goal
{1-3 sentence description of what success looks like}

## Plan
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
...

## Questions / Dependencies
- {any blockers or unknowns — leave empty if none}

## Results
{leave empty — fill in when done}

## Lessons
{leave empty — fill in if anything unexpected happened}
```

Guidelines for the Plan section:
- Each item should be a discrete, verifiable action (not vague)
- Order from first to last dependency
- Include verification steps (e.g., "run tests", "check output")
- Aim for 4–10 steps; break it down further if more complex

### 4. Enter plan mode

After writing the file, enter plan mode so the user can review and refine the plan before implementation begins. Present a brief summary of the plan you just wrote.
