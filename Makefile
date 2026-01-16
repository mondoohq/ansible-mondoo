# Ansible Role Makefile
# Copyright (c) Mondoo, Inc.

.PHONY: help
.DEFAULT_GOAL := help

# Colors for help output
CYAN := \033[36m
YELLOW := \033[33m
GREEN := \033[32m
RED := \033[31m
RESET := \033[0m

# Check if virtual environment is activated
define check_venv
	@if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)ERROR: Virtual environment not activated!$(RESET)"; \
		echo "$(YELLOW)Run: source molecule-env/bin/activate$(RESET)"; \
		echo "$(YELLOW)Or first run: make setup/install$(RESET)"; \
		exit 1; \
	fi
endef

help: ## Show this help message
	@echo "$(CYAN)Ansible Mondoo Role - Available Commands$(RESET)"
	@echo ""
	@echo "$(YELLOW)Development Setup:$(RESET)"
	@grep -E '^setup/.*:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)License Management:$(RESET)"
	@grep -E '^license/.*:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Molecule Testing - Individual Distributions:$(RESET)"
	@grep -E '^molecule/(ubuntu|debian|rhel|suse)/.*:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-28s$(RESET) %s\n", $$1, $$2}' | sort
	@echo ""
	@echo "$(YELLOW)Molecule Testing - Groups:$(RESET)"
	@grep -E '^molecule/test/.*:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Molecule Lifecycle:$(RESET)"
	@grep -E '^molecule/(create|converge|verify|destroy|login):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-28s$(RESET) %s\n", $$1, $$2}'

# Development Setup
setup/molecule: ## Setup molecule testing environment with uv
	@echo "$(YELLOW)Setting up molecule environment...$(RESET)"
	uv venv --python 3.11 --clear molecule-env
	@echo "$(GREEN)Environment created. Run 'source molecule-env/bin/activate' then run setup again$(RESET)"

setup/install: ## Install molecule dependencies (creates environment if needed)
	@if [ -n "$$VIRTUAL_ENV" ]; then \
		echo "$(RED)ERROR: Virtual environment already activated!$(RESET)"; \
		echo "$(YELLOW)Run 'deactivate' first, then run this command$(RESET)"; \
		exit 1; \
	fi
	@if [ ! -d "molecule-env" ]; then \
		echo "$(YELLOW)Environment not found, creating it first...$(RESET)"; \
		uv venv --python 3.11 --clear molecule-env; \
	else \
		echo "$(GREEN)Environment exists$(RESET)"; \
	fi
	@echo "$(YELLOW)Installing molecule dependencies...$(RESET)"
	uv pip install --python molecule-env/bin/python ansible-core==2.18.12 molecule==6.0.3 molecule-docker==2.1.0
	@echo "$(GREEN)Molecule environment ready!$(RESET)"
	@echo "$(YELLOW)IMPORTANT: Run 'source molecule-env/bin/activate' before testing$(RESET)"
	@echo "$(CYAN)Then you can use: make molecule/debian/12$(RESET)"


# License Management
license/headers/check: ## Check license headers
	copywrite headers --plan

license/headers/apply: ## Apply license headers
	copywrite headers

# Molecule Testing - Ubuntu
molecule/ubuntu/2204: ## Test with Ubuntu 22.04
	$(call check_venv)
	@export image=geerlingguy/docker-ubuntu2204-ansible tag=latest && molecule test -s default

molecule/ubuntu/2404: ## Test with Ubuntu 24.04
	$(call check_venv)
	@export image=geerlingguy/docker-ubuntu2404-ansible tag=latest && molecule test -s default

# Molecule Testing - Debian
molecule/debian/12: ## Test with Debian 12
	$(call check_venv)
	@export image=geerlingguy/docker-debian12-ansible tag=latest && molecule test -s default

molecule/debian/13: ## Test with Debian 13
	$(call check_venv)
	@export image=geerlingguy/docker-debian13-ansible tag=latest && molecule test -s default

# Molecule Testing - RHEL Family
molecule/rhel/rocky9: ## Test with Rocky Linux 9
	$(call check_venv)
	@export image=geerlingguy/docker-rockylinux9-ansible tag=latest && molecule test -s default

molecule/rhel/fedora40: ## Test with Fedora 40
	$(call check_venv)
	@export image=geerlingguy/docker-fedora40-ansible tag=latest && molecule test -s default

# Molecule Testing - SUSE Family
molecule/suse/opensuse: ## Test with OpenSUSE
	$(call check_venv)
	@export image=rsprta/opensuse-ansible tag=latest && molecule test -s default

# Molecule Lifecycle Management
molecule/create: ## Create test environment
	molecule create -s default

molecule/converge: ## Apply role to test environment
	molecule converge -s default

molecule/verify: ## Run verification tests
	molecule verify -s default

molecule/destroy: ## Destroy test environment
	molecule destroy -s default

molecule/login: ## Login to test environment
	molecule login -s default

# Comprehensive Testing
molecule/test/all: ## Run tests on all supported distributions
	@echo "$(YELLOW)Testing all distributions...$(RESET)"
	@make molecule/ubuntu/2204
	@make molecule/ubuntu/2404
	@make molecule/debian/12
	@make molecule/debian/13
	@make molecule/rhel/rocky9
	@make molecule/rhel/fedora40
	@make molecule/suse/opensuse
	@echo "$(GREEN)All tests completed!$(RESET)"

# Quick Testing
molecule/test/debian: ## Test all Debian-based distributions
	@echo "$(YELLOW)Testing Debian distributions...$(RESET)"
	@make molecule/ubuntu/2204
	@make molecule/ubuntu/2404
	@make molecule/debian/12
	@make molecule/debian/13

molecule/test/rhel: ## Test all RHEL-based distributions
	@echo "$(YELLOW)Testing RHEL distributions...$(RESET)"
	@make molecule/rhel/rocky9
	@make molecule/rhel/fedora40