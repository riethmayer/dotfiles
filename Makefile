STOW_DIR = $(shell pwd)/stow
PACKAGES = $(shell ls -d stow/* | xargs basename -a)

default: bootstrap

info: ## Info about the current environment
	@echo "STOW_DIR: $(STOW_DIR)"
	@echo "PACKAGES: $(PACKAGES)"

install: ## install all stows
	@if [ "$$(uname)" = "Darwin" ]; then \
		stow --dir $(STOW_DIR) --target ~ $(PACKAGES); \
	fi

delete: ## delete all stows
	@if [ "$$(uname)" = "Darwin" ]; then \
		stow --dir $(STOW_DIR) --delete --target ~ $(PACKAGES); \
	fi

bootstrap: bootstrap_stage1 install ## bootstrap the environment
	# Stage 2: Install all requirements
	@$$HOME/bin/system-bootstrap.sh

bootstrap_stage1:
	# Stage 1: Install Homebrew and Stow
	@stow/bootstrap/bin/system-bootstrap.sh


update: ## update the sources
	./update_sources.sh

define print_help
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m%s\n", $$1, $$2}'
endef

help:
	@printf "\033[36mHelp: \033[0m\n"
	@$(foreach file, $(MAKEFILE_LIST), $(call print_help, $(file));)
