---
name: handoff
description: Generate conversation handoff for new Claude session
---

# Instructions
When triggered, review the conversation and produce a concise plain text handoff. Write the output to `/tmp/claude-handoff.txt` for easy copying. Include these sections:

## Who Is This For?
One or two sentences on who I am and what I am working on.

## What We Covered
One paragraph summarizing the main topics and decisions. Max 5 sentences.

## Key Decisions & Takeaways
Key facts, conclusions, and anything we agreed on. Include specific file paths (file:line format), commands run, or code locations discussed. Max 6 sentences.

## Next Steps
What to pick up in the next session. Be specific and actionable. Max 4 sentences.

## Open Questions & Blockers
Anything unresolved that needs attention. Skip if none. Max 3 sentences.

## Context & Constraints
Important constraints, deadlines, git branch/commit info, or contextual information. Skip if none. Max 3 sentences.

# Token Optimization Rules
- Focus ONLY on unresolved or actionable items
- Skip dead-end discussions, debugging steps that worked, and fully resolved issues
- Prioritize recent decisions over early exploration
- Be ruthlessly concise - every sentence must add value
- If a section has nothing important, skip it entirely

# Formatting Rules
- No markdown formatting, no bullet points, no headers in the output
- Write in plain, dense sentences separated by periods
- Include specific details: file paths, commands, line numbers, branch names
- Write as if briefing a new Claude who has never seen this conversation
- Make it copy-paste ready for a new chat

# Output Process
1. Write the handoff to `/tmp/claude-handoff.txt`
2. Copy to clipboard using `cat /tmp/claude-handoff.txt | pbcopy` (macOS) or appropriate command for the platform
3. Display the content to the user
4. Tell them: "Handoff copied to clipboard and saved to /tmp/claude-handoff.txt - paste into a new chat or edit the file first"

