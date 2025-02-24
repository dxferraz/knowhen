install: ## Default rule, does everything needed to run the project
install: deps gen

check: ## Run linter and tests (automatic before every push)
check: lint test

clean: ## Clean everything
	@echo "|-> Cleaning the project..."
	@flutter clean

lint: ## Lint the code (included in check)
	@dart analyze . --fatal-infos --fatal-warnings

test: ## Run tests (included in check)
	@flutter test || (echo "Error while running tests"; exit 1)

deps: ## Install dependencies (included in install)
	@echo "|-> Installing dependencies..."
	@flutter pub get

gen: ## Run build_runner (included in install)
	@echo "|-> Generating auto-generated files"
	@dart run build_runner build --delete-conflicting-outputs

build: ## Run build_runner (included in install)
	@echo "|-> Building auto-generated files"
	@dart run build_runner build --delete-conflicting-outputs

run: ## Run the app from the command line
	@echo "|-> Running the app"
	@flutter run --flavor dev

coverage: ## Generate test coverage files
	@echo "|-> Generating coverage"
	@flutter test --coverage
	@genhtml coverage/lcov.info -o coverage/html
	@open coverage/html/index.html

# From https://gist.github.com/prwhite/8168133#gistcomment-1313022
help:
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done

.PHONY: build test