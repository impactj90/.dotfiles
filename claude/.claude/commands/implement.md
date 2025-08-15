**MANDATORY FIRST STEP**: Read and quote 2–3 key coding standards from `architecture.md` before writing any code. Also confirm which workflow rules from `claude.md` apply.

We are going to **IMPLEMENT** $ARGUMENTS exactly as per the latest PLAN.

**STRICT PROCESS**:
1. Write ONE code block per step from the PLAN.
2. STOP – Run [LINT_CHECK] and show output
3. STOP – Run [COMPILE_CHECK] and show output  
5. STOP – Run [TEST_UNIT] and show output
6. STOP – Run [TEST_INTEGRATION] and show output
7. Proceed only when ALL checks pass.

**VERIFICATION CHECKLIST**:
- [ ] Code matches PLAN
- [ ] Standards from architecture.md applied
- [ ] Linting passed
- [ ] Compilation passed
- [ ] Tests written & passing
- [ ] `make test` passed
- [ ] `make test-integration` passed

**FAILURE PROTOCOL**: Fix before moving forward. No skipped steps.

**SAFETY**: All tests must pass before next code block.
