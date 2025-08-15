**VALIDATE** changes for $ARGUMENTS

**VALIDATION SUITE**:
1. Run [LINT_CHECK] for all changed files
2. Run [TYPE_CHECK] for type safety
3. Run [TEST_UNIT] for changed modules
4. Run [TEST_INTEGRATION] for affected flows
5. Run [SECURITY_SCAN] for vulnerabilities
6. Run [COVERAGE_CHECK] - Must maintain/improve coverage

**FAILURE PROTOCOL**: Fix all issues before marking complete
