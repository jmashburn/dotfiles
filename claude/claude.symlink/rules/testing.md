---
name: testing
description: Testing standards and best practices
applies-to: ["**/*test*", "**/*spec*"]
---

# Testing Standards

## Testing Philosophy

- **Tests are documentation** - they show how code should be used
- **Tests enable refactoring** - good tests let you change implementation confidently
- **Fast tests get run** - slow tests get skipped
- **Flaky tests are technical debt** - fix or delete them

## Test Coverage Goals

- **Critical paths**: 100% coverage required
- **Business logic**: Aim for 90%+ coverage
- **Utilities/helpers**: 80%+ coverage
- **Glue code**: Test behavior, not implementation

Don't chase 100% coverage everywhere - focus on high-value tests.

## Test Structure

### Use AAA Pattern
```
// Arrange - Set up test data and conditions
const user = createTestUser()

// Act - Execute the code being tested
const result = authenticateUser(user)

// Assert - Verify the outcome
expect(result.isAuthenticated).toBe(true)
```

### Test Naming
- Describe WHAT is being tested and EXPECTED outcome
- Good: `test_user_login_with_valid_credentials_returns_token`
- Bad: `test_login_1`

### One Logical Assertion Per Test
- Test one behavior per test case
- Multiple assertions are OK if testing the same behavior
- Avoid: test cases that verify completely different things

## Test Types

### Unit Tests
- Test single function/method in isolation
- Mock external dependencies
- Fast (milliseconds)
- No I/O, no network, no database

### Integration Tests
- Test multiple components together
- May use test database or API mocks
- Medium speed (seconds)
- Verify components integrate correctly

### End-to-End Tests
- Test full user workflows
- Use real or test-like environment
- Slow (seconds to minutes)
- Keep minimal - only critical paths

## Mocking Guidelines

### When to Mock
- External APIs and services
- Databases (for unit tests)
- File system operations
- Time/dates for determinism
- Randomness

### When NOT to Mock
- Internal utilities (test the real thing)
- Simple data structures
- Pure functions
- Everything (over-mocking leads to testing mocks, not code)

### Good Mock Practices
- Keep mocks simple and realistic
- Don't mock what you don't own (wrap it)
- Verify mock interactions when behavior is important
- Share mock setup in fixtures/helpers

## Test Data

- Use factories/builders for test objects
- Make test data obvious and minimal
- Use realistic but anonymized data
- Don't rely on external data sources
- Seed databases with known state

## Anti-Patterns

### Don't
- **Test implementation details** - test behavior, not internals
- **Write brittle tests** - tests shouldn't break on refactor
- **Share state between tests** - each test should be independent
- **Test the framework** - trust that libraries work
- **Ignore flaky tests** - fix or delete them
- **Skip cleanup** - leave test environment as you found it

### Do
- **Test edge cases** - null, empty, max values, etc.
- **Test error conditions** - not just happy path
- **Keep tests simple** - complex tests are hard to debug
- **Run tests before committing** - don't break the build
- **Update tests with code** - don't let them drift

## Test Organization

```
project/
  src/
    module.js
  tests/
    unit/
      module.test.js
    integration/
      module.integration.test.js
    e2e/
      user-workflow.e2e.test.js
    fixtures/
      test-data.js
```

Or co-locate with source (framework dependent):
```
project/
  src/
    module.js
    module.test.js
```

## Running Tests

### Locally
- Run full suite before pushing
- Run affected tests during development
- Use watch mode for rapid feedback

### CI/CD
- Run on every PR
- Block merge on test failure
- Run expensive tests (e2e) on main/develop

## Performance

- Unit tests: < 100ms each
- Integration tests: < 5s each
- E2E tests: < 30s each
- Full suite: < 10 minutes (or parallelize)

If tests are slow:
1. Profile to find bottlenecks
2. Mock expensive operations
3. Parallelize test runs
4. Split into fast/slow suites

## Test Maintenance

- Delete tests for deleted code
- Update tests when behavior changes
- Refactor duplicated test setup
- Keep test code clean (it's code too!)
- Review tests in code review

## Framework-Specific

### Jest (JavaScript)
```javascript
describe('UserService', () => {
  beforeEach(() => {
    // Setup
  })

  it('should authenticate valid user', () => {
    // Test
  })
})
```

### pytest (Python)
```python
def test_user_authentication_with_valid_credentials():
    # Given
    user = create_test_user()
    # When
    result = authenticate(user)
    # Then
    assert result.is_authenticated
```

### Go
```go
func TestUserAuthentication(t *testing.T) {
    // Given
    user := createTestUser()
    // When
    result := Authenticate(user)
    // Then
    if !result.IsAuthenticated {
        t.Error("Expected user to be authenticated")
    }
}
```

## When Writing New Tests

1. Start with critical paths
2. Add edge cases
3. Add error handling tests
4. Verify with mutation testing if available
5. Ensure tests fail when they should
