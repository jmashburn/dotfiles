---
name: deploy
description: Handle deployment workflows with pre-flight checks and rollback awareness
---

# Deploy Skill

Manages deployment workflows with safety checks and best practices.

## When to Use

Invoke this skill when:
- User asks to deploy code
- Running `/deploy` command
- Need to push to staging/production
- Deploying via CI/CD
- Rolling back a deployment

## Workflow

### 1. Pre-Deployment Validation

**Git Status**
- Check for uncommitted changes
- Verify on correct branch (main/master for production)
- Ensure branch is up-to-date with remote

**Tests**
- Run test suite if available
- Check CI/CD status
- Verify build succeeds

**Dependencies**
- Check for outdated security vulnerabilities
- Verify lock files are committed

### 2. Deployment Execution

**Find deployment method:**
- Look for `script/deploy` or similar
- Check `Makefile` for deploy target
- Look in `package.json` for deploy script
- Check for CI/CD configs (GitHub Actions, GitLab CI, etc.)
- Check for platform-specific (Heroku, AWS, Vercel, etc.)

**Execute with confirmation:**
- Show what will be executed
- Ask for confirmation (especially for production)
- Run deployment command
- Monitor output for errors

### 3. Post-Deployment

**Verification**
- Check deployment logs
- Verify health endpoints if available
- Suggest smoke tests
- Monitor error tracking (Sentry, etc.)

**Rollback Plan**
- Document the current version/commit
- Explain how to rollback if needed
- Keep previous version info available

## Safety Checks

### Critical Checks (Block Deployment)
- Uncommitted changes on production branch
- Failing tests
- Security vulnerabilities in dependencies
- Wrong branch for environment

### Warning Checks (Warn but Allow)
- Missing tests
- Outdated dependencies (non-security)
- No CI/CD validation
- Direct push to production (suggest PR process)

## Environment-Specific

### Staging
- Less strict validation
- Allow faster iteration
- Auto-deploy from develop branch OK

### Production
- Strict validation required
- Require manual confirmation
- Prefer tag/release over direct branch deploy
- Ensure rollback plan exists

## Common Platforms

### Heroku
```bash
git push heroku main
heroku logs --tail
```

### AWS/Docker
```bash
docker build -t app:latest .
docker push registry/app:latest
kubectl rollout restart deployment/app
```

### Vercel/Netlify
```bash
vercel --prod
# or
netlify deploy --prod
```

### Traditional
```bash
ssh user@server 'cd /app && git pull && restart-service'
```

## Rollback Procedures

If deployment fails:
1. Note the failing commit
2. Revert to previous working version:
   ```bash
   git revert <commit>
   # or
   git reset --hard <previous-good-commit>
   git push --force  # only if absolutely necessary
   ```
3. Re-deploy previous version
4. Investigate failure in staging
5. Fix and re-deploy

## Best Practices

- **Always deploy from clean state** - commit or stash changes
- **Tag releases** - use semantic versioning
- **Keep deployments small** - easier to debug and rollback
- **Automate what you can** - reduce human error
- **Monitor after deploy** - catch issues early
- **Have rollback plan** - know how to undo quickly
- **Use feature flags** - deploy code, enable features separately
- **Blue-green deployments** - zero-downtime deploys

## Checklist Template

```markdown
## Deployment Checklist

- [ ] Tests passing
- [ ] No uncommitted changes
- [ ] Branch up-to-date
- [ ] Dependencies secure
- [ ] Deployment method identified
- [ ] Target environment confirmed
- [ ] Rollback plan documented
- [ ] Health checks defined
- [ ] Monitoring ready
```
