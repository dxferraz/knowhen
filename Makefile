FLUTTER_VERSION := $(shell sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' .fvmrc)
FLUTTER_SERIES := $(basename $(FLUTTER_VERSION))

install: ## Default rule, does everything needed to run the project
install: flutter-version clean deps gen

check: ## Run linter and tests (automatic before every push)
check: flutter-version lint test

flutter-version: ## Check that the Flutter on PATH matches .fvmrc (same major.minor)
	@flutter --version --machine | grep -q '"frameworkVersion": "$(FLUTTER_SERIES)\.' || \
		(echo "Flutter $(FLUTTER_SERIES).x is required (.fvmrc: $(FLUTTER_VERSION)). Found:"; flutter --version | head -n 1; exit 1)

clean: ## Clean everything
	@echo "|-> Cleaning the project..."
	@flutter clean

lint: ## Lint the code (included in check)
	@dart analyze . --fatal-infos --fatal-warnings

test: ## Run tests with coverage (included in check; writes coverage/lcov.info)
	@flutter test --coverage || (echo "Error while running tests"; exit 1)

deps: ## Install dependencies (included in install)
	@echo "|-> Installing dependencies..."
	@flutter pub get

gen: ## Run build_runner (included in install)
	@echo "|-> Generating auto-generated files"
	@dart run build_runner build

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

.PHONY: clean install lint coverage test flutter-version
