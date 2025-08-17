# Command Mappings

When a command file references [COMMAND_NAME], use this mapping to find the actual command to run based on the context (file type, available tools, project setup).

## Build & Compile

### [COMPILE_CHECK]
Verify code compiles/builds successfully
- **Go:** `go build ./...`
- **TypeScript:** `tsc --noEmit`
- **JavaScript:** `npm run build`
- **Python:** `python -m py_compile **/*.py`
- **PHP:** `php -l **/*.php`
- **Ruby:** `ruby -c **/*.rb`
- **Rust:** `cargo build`
- **C/C++:** `make build`
- **Java:** `mvn compile`
- **Makefile override:** `make build`

### [CONTRACTS_CURRENT]
Verify generated code is up-to-date
- **Default:** `make proto-check || make proto`
- **OpenAPI:** `npm run openapi:check`
- **GraphQL:** `npm run codegen:check`

## Testing

### [TEST_UNIT]
Run unit tests
- **Go:** `go test ./... -short`
- **TypeScript/JavaScript:** `npm test`
- **Python:** `pytest tests/unit -v`
- **PHP:** `./vendor/bin/phpunit --testsuite unit`
- **Ruby:** `rspec spec/unit`
- **Rust:** `cargo test --lib`
- **Java:** `mvn test`
- **Makefile override:** `make test-unit`

### [TEST_INTEGRATION]
Run integration tests
- **Go:** `go test ./... -tags=integration`
- **TypeScript/JavaScript:** `npm run test:integration`
- **Python:** `pytest tests/integration -v`
- **PHP:** `./vendor/bin/phpunit --testsuite integration`
- **Ruby:** `rspec spec/integration`
- **Rust:** `cargo test --test '*'`
- **Java:** `mvn verify`
- **Makefile override:** `make test-integration`

### [TEST_BASELINE]
Run all existing tests to ensure clean baseline
- **Default:** `make test`
- **NPM project:** `npm test`
- **Python:** `pytest`
- **PHP:** `./vendor/bin/phpunit`
- **Ruby:** `rspec`
- **Rust:** `cargo test`

### [TEST_COVERAGE]
Check test coverage metrics
- **Go:** `go test -cover ./... -coverprofile=coverage.out && go tool cover -func=coverage.out | grep total`
- **TypeScript/JavaScript:** `npm test -- --coverage`
- **Python:** `pytest --cov=. --cov-report=term`
- **PHP:** `./vendor/bin/phpunit --coverage-text`
- **Ruby:** `rspec --format documentation --coverage`
- **Rust:** `cargo tarpaulin`
- **Makefile override:** `make test-coverage`

## Code Quality

### [LINT_CHECK]
Run code linters and formatters
- **Go:** `gofmt -l . && go vet ./... && golangci-lint run`
- **TypeScript/JavaScript:** `npm run lint`
- **Python:** `black --check . && flake8 && pylint src/`
- **PHP:** `./vendor/bin/phpcs && ./vendor/bin/phpstan analyse`
- **Ruby:** `rubocop`
- **Rust:** `cargo fmt --check && cargo clippy`
- **Java:** `mvn checkstyle:check`
- **Makefile override:** `make lint-all`

### [TYPE_CHECK]
Verify type safety
- **Go:** `go vet ./...`
- **TypeScript:** `tsc --noEmit`
- **Python:** `mypy src/`
- **PHP:** `./vendor/bin/phpstan analyse --level max`
- **Ruby:** `srb tc` (Sorbet)
- **Rust:** `cargo check`
- **Java:** `mvn compile`
- **Flow:** `flow check`

### [FORMAT_CHECK]
Check code formatting
- **Go:** `gofmt -l .`
- **TypeScript/JavaScript:** `prettier --check .`
- **Python:** `black --check . && isort --check-only .`
- **PHP:** `./vendor/bin/php-cs-fixer fix --dry-run`
- **Ruby:** `rubocop --auto-correct --dry-run`
- **Rust:** `cargo fmt --check`
- **Java:** `mvn formatter:validate`

## Security

### [SECURITY_SCAN]
Run security vulnerability scans
- **Go:** `gosec ./... && go list -json -deps | nancy sleuth`
- **TypeScript/JavaScript:** `npm audit && npx snyk test`
- **Python:** `bandit -r src/ && safety check && pip-audit`
- **PHP:** `./vendor/bin/security-checker security:check && psalm --taint-analysis`
- **Ruby:** `bundle audit && brakeman`
- **Rust:** `cargo audit`
- **Java:** `mvn dependency-check:check`
- **General:** `grep -r "SECRET\|PASSWORD\|KEY\|TOKEN" --exclude-dir=.git --exclude-dir=node_modules`

## Database

### [MIGRATE_UP]
Apply database migrations
- **Default:** `make migrate-up`
- **Node:** `npm run migrate:up`
- **Python (Alembic):** `alembic upgrade head`
- **Python (Django):** `python manage.py migrate`
- **PHP (Laravel):** `php artisan migrate`
- **PHP (Doctrine):** `./vendor/bin/doctrine-migrations migrate`
- **Ruby (Rails):** `rails db:migrate`
- **Ruby (Sequel):** `sequel -m migrations/ postgres://...`

### [MIGRATE_DOWN]
Rollback database migrations
- **Default:** `make migrate-down`
- **Node:** `npm run migrate:down`
- **Python (Alembic):** `alembic downgrade -1`
- **Python (Django):** `python manage.py migrate [previous_migration]`
- **PHP (Laravel):** `php artisan migrate:rollback`
- **PHP (Doctrine):** `./vendor/bin/doctrine-migrations migrate prev`
- **Ruby (Rails):** `rails db:rollback`
- **Ruby (Sequel):** `sequel -m migrations/ -M 0 postgres://...`

### [MIGRATE_VERIFY]
Check migration status
- **Default:** `make migrate-status`
- **Node:** `npm run migrate:status`
- **Python (Alembic):** `alembic current`
- **Python (Django):** `python manage.py showmigrations`
- **PHP (Laravel):** `php artisan migrate:status`
- **PHP (Doctrine):** `./vendor/bin/doctrine-migrations status`
- **Ruby (Rails):** `rails db:migrate:status`
- **Ruby (Sequel):** `sequel -m migrations/ -p postgres://...`

## Workspace

### [WORKSPACE_CLEAN]
Check for clean working directory
- **Default:** `git status --porcelain | wc -l | grep "^0$"`
- **Alternative:** `git diff-index --quiet HEAD --`

### [DEPENDENCIES_CURRENT]
Verify dependencies installed
- **Go:** `go mod verify && go mod tidy -diff`
- **Node/NPM:** `npm ls --depth=0`
- **Python (pip):** `pip check`
- **Python (Poetry):** `poetry check && poetry install --dry-run`
- **PHP (Composer):** `composer validate && composer check-platform-reqs`
- **Ruby (Bundler):** `bundle check`
- **Rust:** `cargo check --locked`
- **Java:** `mvn dependency:analyze`

### [DEPENDENCIES_UPDATE]
Update dependencies to latest versions
- **Go:** `go get -u ./... && go mod tidy`
- **Node/NPM:** `npm update`
- **Python (pip):** `pip list --outdated`
- **Python (Poetry):** `poetry update`
- **PHP (Composer):** `composer update`
- **Ruby (Bundler):** `bundle update`
- **Rust:** `cargo update`
- **Java:** `mvn versions:use-latest-versions`
