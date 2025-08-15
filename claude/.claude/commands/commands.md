# Command Mappings

## Build & Compile
- [COMPILE_CHECK]: Verify code compiles
  - Go: `go build ./...`
  - TypeScript: `tsc --noEmit`
  - Makefile override: `make build`

- [CONTRACTS_CURRENT]: Verify generated code is up-to-date
  - Default: `make proto-check || make proto`

## Testing
- [TEST_UNIT]: Run unit tests
  - Go: `go test ./... -short`
  - TypeScript: `npm test`
  - Makefile override: `make test-unit`

- [TEST_INTEGRATION]: Run integration tests  
  - Go: `go test ./... -tags=integration`
  - TypeScript: `npm run test:integration`
  - Makefile override: `make test-integration`

- [TEST_BASELINE]: Run all existing tests
  - Default: `make test`

- [TEST_COVERAGE]: Check test coverage
  - Go: `go test -cover ./... | grep coverage`
  - TypeScript: `npm test -- --coverage`
  - Makefile override: `make test-coverage`

## Code Quality
- [LINT_CHECK]: Run linters
  - Go: `gofmt -l . && go vet ./...`
  - TypeScript: `npm run lint`
  - Makefile override: `make lint-all`

- [TYPE_CHECK]: Verify type safety
  - Go: `go vet ./...`
  - TypeScript: `tsc --noEmit`

## Security
- [SECURITY_SCAN]: Run security checks
  - Go: `gosec ./...`
  - TypeScript: `npm audit`
  - All: `grep -r "SECRET\|PASSWORD\|KEY" --exclude-dir=.git`

## Database
- [MIGRATE_UP]: Apply migrations
  - Default: `make migrate-up`

- [MIGRATE_VERIFY]: Verify schema state
  - Default: `make migrate-status`

## Workspace
- [WORKSPACE_CLEAN]: Check for clean working directory
  - Default: `git status --porcelain | wc -l | grep "^0$"`

- [DEPENDENCIES_CURRENT]: Verify dependencies installed
  - Go: `go mod verify`
  - TypeScript: `npm ls --depth=0`
