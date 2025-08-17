**TRIGGERED BY**: /check [arguments]
**PURPOSE**: Verify system is ready for work on $ARGUMENTS

**SYSTEM HEALTH CHECKS**:

1. **Workspace Clean**
   - Run: [WORKSPACE_CLEAN]
   - No uncommitted changes blocking work

2. **Dependencies Ready**
   - Run: [DEPENDENCIES_CURRENT]
   - All required dependencies installed

3. **Tests Passing**
   - Run: [TEST_BASELINE]
   - Existing tests must pass

4. **Code Generation Current**
   - Run: [CONTRACTS_CURRENT]
   - Generated code up to date

**RESULT**: 
- ✅ **READY** → proceed to /explore
- ❌ **BLOCKED** → fix issues first

---
**WORKFLOW**: You are here → Next: [/explore]
