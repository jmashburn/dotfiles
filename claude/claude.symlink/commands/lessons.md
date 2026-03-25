---
description: Load tasks/lessons.md and surface lessons relevant to the current task or topic
argument-hint: Optional topic or task type to filter lessons by
allowed-tools: ["Read", "Glob"]
---

# /lessons — Surface Relevant Lessons

Your job is to read `tasks/lessons.md` and surface the lessons most relevant to the current situation.

## Steps

### 1. Load lessons

Read `tasks/lessons.md`. If it doesn't exist, inform the user that no lessons have been recorded yet and suggest running `/plan` after a task to capture them.

### 2. Determine relevance context

- If `$ARGUMENTS` is provided, use it as the topic/task type to filter by.
- Otherwise, check if `tasks/todo.md` exists and read the current task goal to infer context.
- If neither exists, surface the 5 most recent or most frequently applicable lessons.

### 3. Present relevant lessons

Group lessons by relevance and present them clearly:

```
## Relevant Lessons for: {context}

### High relevance
- **{lesson title}**: {lesson content}
  _Why relevant: {brief explanation}_

### Possibly relevant
- **{lesson title}**: {lesson content}
```

Keep it concise — this is a quick reference, not a full report. Focus on actionable patterns the user should keep in mind before starting work.

### 4. Remind the user

End with: "Update `tasks/lessons.md` after this task if anything new comes up."
