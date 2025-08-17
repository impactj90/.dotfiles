**TRIGGERED BY**: /implement [arguments]
**PURPOSE**: Execute the PLAN for $ARGUMENTS

**PROCESS**:

For each task in PLAN:

1. **Write Code**
   - Implement one task at a time
   - Follow project conventions
   - Include error handling

2. **Verify Code Quality**
   - Run: [LINT_CHECK]
   - Run: [COMPILE_CHECK]

3. **Write Tests**
   - Create tests for new code
   - Follow test patterns

4. **Run Tests**
   - Run: [TEST_UNIT]
   - Run: [TEST_INTEGRATION] if applicable

5. **Continue only if passing**

**CHECKLIST**:
- [ ] Each task from PLAN completed
- [ ] Code quality checks pass
- [ ] Tests written and passing
- [ ] Conventions followed

**FAILURE PROTOCOL**: 
- Fix issues before proceeding
- Re-run all checks after fixes

---
**WORKFLOW**: [/plan] ← You are here → [/validate]
