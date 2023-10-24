.SHELL := /bin/bash
.PHONY: help configure-env plan apply clean format graph show
TERRAFORM_TFVARS="environments/$(ENVIRONMENT)/terraform.tfvars.$(ENVIRONMENT)"
BOLD=$(shell tput -Txterm bold)
RED=$(shell tput -Txterm setaf 1)
GREEN=$(shell tput -Txterm setaf 2)
RESET=$(shell tput -Txterm sgr0)

help: ## Print this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

list-envs: ## Get the list of possible environments
	@echo $(BOLD)$(GREEN)
	@find environments -type f | rev | cut -d. -f1 | rev

configure-env: ## Prepare the target environment if needed
	@if [ -z $(ENVIRONMENT) ]; then\
		echo "$(BOLD)$(RED)Plaese set ENVIRONMENT$(RESET)"; \
		echo "$(BOLD)$(GREEN)Use it like this: ENVIRONMENT=dev make plan$(RESET)"; \
		exit 1; \
	fi
	@if [ ! -d "environments/$(ENVIRONMENT)" ]; then\
		echo "$(BOLD)$(RED)Environment does not exist!$(RESET)"; \
		echo "$(BOLD)$(GREEN)Use a valid one by listing all availables envs with: make list-envs$(RESET)"; \
		exit 1; \
	fi

prepare-tf:
	@mkdir -p ~/.terraform.d/plugins
	@if [ `uname` = "Darwin" ]; then\
		echo "$(BOLD)$(GREEN)Macos detected$(RESET)"; \
		if [ `uname -m` = "arm64" ]; then\
			echo "$(BOLD)$(GREEN)Arm arch detected$(RESET)"; \
			curl -s https://releases.hashicorp.com/terraform-provider-aws/5.8.0/terraform-provider-aws_5.8.0_darwin_arm64.zip -o /tmp/terraform-aws.zip; \
			unzip -qqo /tmp/terraform-aws.zip -d ~/.terraform.d/plugins; \
			rm /tmp/terraform-aws.zip; \
		elif [ `uname -m` = "x86_64" ]; then\
			echo "$(BOLD)$(GREEN)X86 arch detected$(RESET)"; \
			curl -s https://releases.hashicorp.com/terraform-provider-aws/5.8.0/terraform-provider-aws_5.8.0_darwin_amd64.zip -o /tmp/terraform-aws.zip; \
			unzip -qqo /tmp/terraform-aws.zip -d ~/.terraform.d/plugins; \
			rm /tmp/terraform-aws.zip; \
		fi; \
	elif [ `uname` = "Linux" ]; then\
		echo "$(BOLD)$(GREEN)Linux detected$(RESET)"; \
		if [ `uname -m` = "arm64" ]; then\
			echo "$(BOLD)$(GREEN)Arm arch detected$(RESET)"; \
			curl -s https://releases.hashicorp.com/terraform-provider-aws/5.8.0/terraform-provider-aws_5.8.0_linux_arm64.zip -o /tmp/terraform-aws.zip; \
			unzip -qqo /tmp/terraform-aws.zip -d ~/.terraform.d/plugins; \
			rm /tmp/terraform-aws.zip; \
		elif [ `uname -m` = "x86_64" ]; then\
			echo "$(BOLD)$(GREEN)X86 arch detected$(RESET)"; \
			curl -s https://releases.hashicorp.com/terraform-provider-aws/5.8.0/terraform-provider-aws_5.8.0_linux_amd64.zip -o /tmp/terraform-aws.zip; \
			unzip -qqo /tmp/terraform-aws.zip -d ~/.terraform.d/plugins; \
			rm /tmp/terraform-aws.zip; \
		fi; \
	fi

plan: configure-env #prepare-tf  ## Perform a terraform plan after configuring the target environment
	@$(MAKE) -C live/services/auth-microservice plan TERRAFORM_TFVARS="$(CURDIR)/environments/$(ENVIRONMENT)/terraform.tfvars.$(ENVIRONMENT)"

apply: configure-env prepare-tf ## Perform a terraform apply after configuring the target environment 'Be carefull!'
	@$(MAKE) -C live/services/auth-microservice apply TERRAFORM_TFVARS="$(CURDIR)/environments/$(ENVIRONMENT)/terraform.tfvars.$(ENVIRONMENT)"

destroy: configure-env prepare-tf ## Perform a terraform destroy after configuring the target environment 'VERY DANGEROUS!'
	@$(MAKE) -C live/services/auth-microservice destroy TERRAFORM_TFVARS="$(CURDIR)/environments/$(ENVIRONMENT)/terraform.tfvars.$(ENVIRONMENT)"

test: configure-env ## Unit Tests
	@$(MAKE) -C live/services/auth-microservice test TERRAFORM_TFVARS="$(CURDIR)/environments/$(ENVIRONMENT)/terraform.tfvars.$(ENVIRONMENT)"

clean: ## Clean the stack from '*.log', '*.bak' and '.terraform' files/directories
	@$(MAKE) -C live/services/auth-microservice clean

format: ## Format all terraform files: 'terraform fmt'
	@$(MAKE) -C live/services/auth-microservice format

graph: ## Genarte a png graphs from terraform infra 'Needs graphviz to be installed'
	@$(MAKE) -C live/services/auth-microservice graph

show: ## Perform a 'terraform show '
	@$(MAKE) -C live/services/auth-microservice show
