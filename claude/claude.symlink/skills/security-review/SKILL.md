---
name: security-review
description: Perform security review focusing on common vulnerabilities and OWASP Top 10
---

# Security Review Skill

Performs security audits with focus on preventing common vulnerabilities.

## When to Use

Invoke this skill when:
- Reviewing code for security issues
- Before deploying to production
- After adding authentication/authorization
- When handling user input or sensitive data
- Regular security audits

## Quick Security Scan

### 1. Secrets & Credentials
```bash
# Search for common secret patterns
grep -r "api_key\|apikey\|secret\|password\|token" --include="*.js" --include="*.py" --include="*.go"

# Check for .env files in version control
git log --all --full-history -- "**/.env*"
```

### 2. SQL Injection
```python
# Bad
query = f"SELECT * FROM users WHERE id = {user_id}"

# Good
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))
```

### 3. Command Injection
```javascript
// Bad
exec(`convert ${userFilename}`)

// Good
exec('convert', [userFilename])
```

### 4. XSS Prevention
```javascript
// Bad
element.innerHTML = userInput

// Good
element.textContent = userInput
// or use framework escaping (React, Vue, etc.)
```

### 5. Authentication Issues
- Password complexity requirements
- Secure session management
- Rate limiting on auth endpoints
- Multi-factor authentication
- Password reset security

### 6. Authorization Issues
- Check user permissions before actions
- Prevent privilege escalation
- Validate object ownership
- No client-side authorization only

## OWASP Top 10 Checklist

### A01: Broken Access Control
- [ ] Authorization checked server-side
- [ ] User can't access other users' data
- [ ] Admin functions properly protected
- [ ] Direct object references validated

### A02: Cryptographic Failures
- [ ] Sensitive data encrypted in transit (HTTPS)
- [ ] Sensitive data encrypted at rest
- [ ] Strong encryption algorithms used
- [ ] No hardcoded keys

### A03: Injection
- [ ] SQL queries parameterized
- [ ] Shell commands sanitized
- [ ] LDAP/XML/NoSQL queries safe
- [ ] Input validation on all user data

### A04: Insecure Design
- [ ] Threat modeling performed
- [ ] Security requirements defined
- [ ] Secure development lifecycle followed

### A05: Security Misconfiguration
- [ ] No default credentials
- [ ] Error messages don't leak info
- [ ] Unnecessary features disabled
- [ ] Security headers configured
- [ ] Dependencies up-to-date

### A06: Vulnerable Components
```bash
# Check for vulnerabilities
npm audit
pip-audit
go list -json -m all | nancy sleuth
```

### A07: Authentication Failures
- [ ] Strong password policy
- [ ] Account lockout after failed attempts
- [ ] Session timeout configured
- [ ] Secure session management
- [ ] MFA available

### A08: Data Integrity Failures
- [ ] Input validation
- [ ] Code signing
- [ ] CI/CD pipeline secured
- [ ] Deserialization secured

### A09: Security Logging Failures
- [ ] Login attempts logged
- [ ] Access control failures logged
- [ ] Input validation failures logged
- [ ] No sensitive data in logs

### A10: Server-Side Request Forgery
- [ ] URL validation
- [ ] Deny by default network access
- [ ] Separate network segments

## Code Patterns to Flag

### High Risk
```javascript
// Eval usage
eval(userInput)

// Unsafe reflection
eval(`require('${userModule}')`)

// Direct file path from user
fs.readFile(userPath)

// Unsafe deserialization
pickle.loads(user_data)
```

### Medium Risk
```python
# Weak random
import random
token = random.randint(1, 1000000)  # Use secrets module

# Hash without salt
md5(password)  # Use bcrypt/argon2

# Timing attacks
if user_token == expected_token:  # Use constant-time compare
```

## Security Headers

Required headers for web apps:
```
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-XSS-Protection: 1; mode=block
```

## Dependency Security

### Regular Updates
```bash
# JavaScript
npm outdated
npm audit fix

# Python
pip list --outdated
pip-audit

# Go
go list -u -m all
```

### Lock Files
- Always commit lock files
- Review dependency changes in PRs
- Use automated security scanning

## API Security

### Authentication
- Use OAuth 2.0/JWT for APIs
- Validate tokens on every request
- Short token expiration
- Refresh token rotation

### Rate Limiting
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1623456789
```

### CORS Configuration
```javascript
// Be specific, not *
cors({
  origin: 'https://yourdomain.com',
  credentials: true
})
```

## Security Review Report Template

```markdown
## Security Review Report
**Date**: YYYY-MM-DD
**Scope**: [what was reviewed]

### Critical Issues
- [Issue] at [location]
  - **Risk**: [description]
  - **Fix**: [recommendation]

### High Priority
[Same format]

### Medium Priority
[Same format]

### Recommendations
- [General security improvements]

### Summary
- Critical: X
- High: X
- Medium: X
- Low: X
```

## Quick Wins

Easy security improvements:
1. Enable security headers
2. Update dependencies
3. Add rate limiting
4. Enable HTTPS everywhere
5. Add input validation
6. Use parameterized queries
7. Implement CSP
8. Add security logging
9. Use environment variables for secrets
10. Enable MFA

## Tools to Use

- `npm audit` / `pip-audit` - Dependency scanning
- `bandit` - Python security linter
- `brakeman` - Ruby security scanner
- `gosec` - Go security checker
- `semgrep` - Multi-language security patterns
- `git-secrets` - Prevent committing secrets
- SAST tools in CI/CD
