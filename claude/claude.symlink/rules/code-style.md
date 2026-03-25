---
name: code-style
description: Code style and formatting guidelines
applies-to: ["*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.go", "*.rb", "*.sh"]
---

# Code Style Guidelines

## General Principles

- **Readability First**: Code is read more than written
- **Consistency**: Follow existing codebase patterns
- **Simplicity**: Prefer simple solutions over clever ones
- **Self-Documenting**: Clear names over comments

## Naming Conventions

### Variables & Functions
- Use descriptive, meaningful names
- `snake_case` for Python
- `camelCase` for JavaScript/TypeScript
- `kebab-case` for CSS/HTML
- Booleans should read like questions: `isValid`, `hasPermission`, `canEdit`

### Constants
- `SCREAMING_SNAKE_CASE` for true constants
- Group related constants

### Files & Directories
- Match the language/framework conventions
- Use singular names for single-responsibility modules
- Use plural for collections/utilities

## Code Organization

### File Structure
- Imports/requires at top
- Constants after imports
- Helper functions before main logic
- Export/public interface at bottom (unless framework dictates otherwise)

### Function Size
- Keep functions small (< 50 lines ideal)
- One function, one responsibility
- Extract complex logic into named helper functions

### Indentation & Spacing
- Use 2 or 4 spaces (match project's `.editorconfig`)
- No tabs unless project uses them
- Blank line between logical sections
- No trailing whitespace

## Comments

### When to Comment
- **Why**, not **what** - code should explain what it does
- Complex algorithms or business logic
- Non-obvious workarounds
- TODOs with ticket references

### When NOT to Comment
- Don't comment obvious code
- Don't leave commented-out code (use git history)
- Don't write novels - if you need to, refactor instead

## Error Handling

- Handle errors explicitly, don't ignore them
- Provide context in error messages
- Don't catch exceptions you can't handle
- Use specific exception types
- Clean up resources (use try/finally or context managers)

## Imports

- Group imports logically (stdlib, third-party, local)
- Sort alphabetically within groups
- Remove unused imports
- Use specific imports, not wildcards (unless idiomatic)

## Anti-Patterns to Avoid

- Magic numbers - use named constants
- Deep nesting - extract to functions
- Massive functions/classes - break them down
- Copy-paste code - create shared utilities
- God objects - single responsibility principle
- Premature optimization - profile first

## Language-Specific

### Python
- Follow PEP 8
- Use list/dict comprehensions when clear
- Prefer f-strings for formatting
- Use type hints for public interfaces

### JavaScript/TypeScript
- Use `const` by default, `let` when needed, avoid `var`
- Prefer arrow functions for callbacks
- Use destructuring where it improves clarity
- Async/await over raw promises

### Go
- Run `gofmt` before committing
- Follow effective Go guidelines
- Keep interfaces small
- Handle errors explicitly

## When in Doubt

1. Check if the project has a style guide (README, CONTRIBUTING.md)
2. Look at existing code in the same module
3. Run the project's linter/formatter
4. Prefer established patterns over personal preference
