STOW_DIR = $(shell pwd)/stow
PACKAGES = $(shell ls -d stow/* | xargs basename -a)

define print_help
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m%s\n", $$1, $$2}'
endef

help: ## show this help
	@echo "STOW_DIR: $(STOW_DIR)"
	@echo "PACKAGES: $(PACKAGES)"
	@echo "\033[36mHelp: \033[0m"
	@for file in $(MAKEFILE_LIST); do \
		$(call print_help, $$file); \
	done

install: ## install all stows
	stow --dir $(STOW_DIR) --target ~ $(PACKAGES)

install-adopt: ## install all stows and adopt existing files
	stow --dir $(STOW_DIR) --target ~ $(PACKAGES) --adopt

delete: ## delete all stows
	stow --dir $(STOW_DIR) --delete --target ~ $(PACKAGES)

bootstrap: bootstrap_stage1 install ## bootstrap the environment
	# Stage 2: Install all requirements
	@$$HOME/bin/system-bootstrap.sh

bootstrap_stage1:
	# Stage 1: Install Homebrew and Stow
	@stow/bootstrap/bin/system-bootstrap.sh

update: ## update the sources
	./update_sources.sh

.PHONY: help install install-adopt delete bootstrap bootstrap_stage1 update default

