**TRIGGERED BY**: /validate [arguments]
**PURPOSE**: Verify implementation of $ARGUMENTS meets standards

**VALIDATION CHECKS**:

1. **Code Quality**
   - Run: [LINT_CHECK]
   - Run: [TYPE_CHECK]

2. **Tests**
   - Run: [TEST_UNIT]
   - Run: [TEST_INTEGRATION]
   - Run: [TEST_COVERAGE]

3. **Security**
   - Run: [SECURITY_SCAN]
   - Review any warnings

4. **Requirements**
   - [ ] Acceptance criteria from RFC met
   - [ ] All PLAN tasks completed
   - [ ] Edge cases handled

5. **Performance**
   - [ ] No obvious bottlenecks
   - [ ] Resource usage acceptable

**RESULT**:
- ✅ **PASSED** → proceed to /demo
- ❌ **FAILED** → return to /implement

---
**WORKFLOW**: [/implement] ← You are here → [/demo]
