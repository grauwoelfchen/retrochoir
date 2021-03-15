PACKAGE = retrochoir

CLANG_PATH ?= /usr/lib/llvm/10
CARGO := PATH=$(CLANG_PATH)/bin:$${PATH} LIBCLANG_PATH=$(CLANG_PATH)/lib64 cargo

# verify
verify\:check:  ## Verify code syntax [alias: check]
	@$(CARGO) check --all --verbose
.PHONY: verify\:check

check: | verify\:check
.PHONY: check

verify\:format:  ## Verify format without changes [alias: verify:fmt, format, fmt]
	@cargo fmt --all -- --check
.PHONY: verify\:format

format: | verify\:format
.PHONY: format

fmt: | verify\:format
.PHONY: fmt

verify\:lint:  ## Verify coding style using clippy [alias: lint]
	@$(CARGO) clippy --all-targets
.PHONY: verify\:lint

lint: | verify\:lint
.PHONY: lint

verify\:all: | verify\:check verify\:format verify\:lint  ## Check code using all verify:xxx targets [alias: verify]
.PHONY: verify\:all

verify: | verify\:all
.PHONY: verify

# test
test\:all:  ## Run all unit tests [alias: test]
	@$(CARGO) test --tests
.PHONY: test\:all

test: | test\:all
.PHONY: test

# coverage
coverage:  ## Generate coverage report of tests [alias: cov]
	@$(CARGO) test --bin $(PACKAGE) --no-run
	@./.tool/setup-kcov
	./.tool/get-covered $(PACKAGE)
.PHONY: coverage

cov: | coverage
.PHONY: cov

# build
build\:debug:  ## Build in debug mode [alias: build]
	@$(CARGO) build
.PHONY: build\:debug

build: | build\:debug
.PHONY: build

build\:release:  ## Create release build
	@$(CARGO) build --release
.PHONY: build\:release

# utility
clean:  ## Clean up
	@cargo clean
.PHONY: clean

package:  ## Create package
	@$(CARGO) package
.PHONY: package

publish:  ## Publish package
	@$(CARGO) publish
.PHONY: publish

help:  ## Display this message
	@grep -E '^[0-9a-z\:\\]+: ' $(MAKEFILE_LIST) | \
	  grep -E '  ## ' | \
	  sed -e 's/\(\s|\(\s[0-9a-z\:\\]*\)*\)  /  /' | \
	  tr -d \\\\ | \
	  awk 'BEGIN {FS = ":  ## "};  \
	       {printf "\033[38;05;222m%-14s\033[0m %s\n", $$1, $$2}' | \
	  sort
.PHONY: help

.DEFAULT_GOAL = test:all
default: verify\:check verify\:format verify\:lint test\:all
