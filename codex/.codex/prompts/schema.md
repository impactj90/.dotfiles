**MANDATORY FIRST STEP**: Read `architecture.md` DB section + `claude.md` database conventions.

We are going to **SCHEMA** changes for $ARGUMENTS.

**REQUIRED OUTPUT**:
1. Migration filename + SQL content
2. Model/entity updates (Go/TS)
3. Proto contract changes if needed
4. Command to apply migration: `make migrate`
5. Tests for migrations if applicable

**CHECKLIST**:
- [ ] DB conventions referenced
- [ ] Naming follows standards
- [ ] Migration reversible
- [ ] Tests for schema changes
