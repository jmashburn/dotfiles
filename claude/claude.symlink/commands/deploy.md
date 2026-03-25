---
description: Deploy code to production or staging environment
argument-hint: Optional environment (staging/production)
allowed-tools: ["Bash", "Read", "Grep", "Glob"]
---

# /deploy — Deployment Command

Deploy the current code to the specified environment.

## Steps

### 1. Determine target environment

- If `$ARGUMENTS` is provided, use it as the environment (staging, production, etc.)
- Otherwise, default to staging

### 2. Pre-deployment checks

- Run `git status` to check for uncommitted changes
- Warn if there are uncommitted changes
- Check if current branch is appropriate for deployment
- Verify tests pass (if test command exists)

### 3. Look for deployment scripts

Check for common deployment patterns:
- `script/deploy`
- `Makefile` with deploy target
- `package.json` with deploy script
- `deploy.sh`
- CI/CD configuration (`.github/workflows`, `.gitlab-ci.yml`, etc.)

### 4. Execute deployment

If a deployment script is found:
- Show the user what will be executed
- Ask for confirmation before running
- Execute the deployment command
- Monitor output for errors

If no deployment script found:
- List the common deployment options found in the codebase
- Ask the user how they typically deploy
- Suggest creating a deployment script

### 5. Post-deployment

- Show deployment summary
- Suggest verification steps (checking logs, health endpoints, etc.)
- Remind about rollback procedures if something goes wrong
