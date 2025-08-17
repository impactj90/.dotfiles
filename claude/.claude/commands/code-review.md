**TRIGGERED BY**: /code-review [arguments]
**PURPOSE**: Review code changes for $ARGUMENTS

**FILE DISCOVERY**:
1. Find relevant files for $ARGUMENTS
2. Identify recent changes
3. Locate related tests

**REVIEW CHECKLIST**:

## 1. Requirements
- [ ] Matches specified requirements
- [ ] Acceptance criteria met
- [ ] Edge cases handled

## 2. Code Quality
- [ ] Readable and maintainable
- [ ] Proper error handling
- [ ] No unnecessary complexity
- [ ] Appropriate comments

## 3. Security
- [ ] Input validation present
- [ ] No security vulnerabilities
- [ ] Sensitive data protected
- [ ] Authentication/authorization correct

## 4. Testing
- [ ] Tests exist for new code
- [ ] Tests cover edge cases
- [ ] Tests actually test the functionality

## 5. Performance
- [ ] No obvious bottlenecks
- [ ] Efficient algorithms used
- [ ] Resource usage reasonable

**AUTOMATED CHECKS**:
- Run: [LINT_CHECK]
- Run: [TYPE_CHECK]
- Run: [SECURITY_SCAN]
- Run: [TEST_COVERAGE]

**FINDINGS**:

**Good Practices:**
- [What was done well]

**Issues Found:**
- **Location:** [file:line]
- **Issue:** [description]
- **Risk:** [HIGH/MEDIUM/LOW]
- **Suggestion:** [how to fix]

**ASSESSMENT**:
- ✅ **APPROVED** - Ready to merge
- ⚠️ **CONDITIONAL** - Fix issues first
- ❌ **REJECTED** - Major problems

**DISCUSSION POINTS**:
[Questions or topics to discuss]
