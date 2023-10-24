.PHONY: all plan apply
SHELL := $(SHELL) -e
TERRAFOM_STATE_BUCKET=$(shell grep terraform-state-bucket $(TERRAFORM_TFVARS) | cut -d "=" -f 2)
TERRAFOM_STATE_FILE_KEY=$(shell grep auth-microservice-terraform-state-file-key $(TERRAFORM_TFVARS) | cut -d "=" -f 2)

all: test plan apply

version:
	terraform version

check-terraform-tfvars:
	@if [ -z $(TERRAFORM_TFVARS) ]; then\
		echo "Plaese provide terraform tfvars file"; \
		exit 1; \
	fi

validate:
	terraform validate

plan: check-terraform-tfvars
	../../../../helper_scripts/prepare_backend.sh $(TERRAFOM_STATE_BUCKET) $(TERRAFOM_STATE_FILE_KEY)
	terraform get -update
	../../../../helper_scripts/terraform_remote_state.sh
	./build_layers_packages.sh
	terraform plan -var-file="$(TERRAFORM_TFVARS)" -compact-warnings

apply: check-terraform-tfvars
	../../../../helper_scripts/prepare_backend.sh $(TERRAFOM_STATE_BUCKET) $(TERRAFOM_STATE_FILE_KEY)
	terraform get -update
	../../../../helper_scripts/terraform_remote_state.sh
	find . -name *.zip -print0 | xargs -0 rm -rf
	./build_layers_packages.sh
	terraform apply -input=false -auto-approve -var-file="$(TERRAFORM_TFVARS)" -compact-warnings

destroy: check-terraform-tfvars
	../../../../helper_scripts/prepare_backend.sh $(TERRAFOM_STATE_BUCKET) $(TERRAFOM_STATE_FILE_KEY)
	terraform get -update
	../../../../helper_scripts/terraform_remote_state.sh
	terraform destroy $(filter-out $@,$(MAKECMDGOALS)) -var-file="$(TERRAFORM_TFVARS)"

taint: check-terraform-tfvars
	terraform taint $(filter-out $@,$(MAKECMDGOALS)) -var-file="$(TERRAFORM_TFVARS)"

clean:
	rm -rf terraform.tfplan
	rm -rf terraform.tfstate
	rm -rf terraform.tfstate.backup
	rm -rf .terraform
	rm -rf *.log
	rm -rf *.png
	rm -rf *.bak
	find . -name *.zip -print0 | xargs -0 rm -rf
	find . -name python -print0 | xargs -0 rm -rf
	rm -rf .terraform.lock.hcl
	rm -rf venv
	find . -name *.cache -print0 | xargs -0 rm -rf

test:
	../../../../helper_scripts/prepare_backend.sh $(TERRAFOM_STATE_BUCKET) $(TERRAFOM_STATE_FILE_KEY)
	terraform get -update
	../../../../helper_scripts/terraform_remote_state.sh
	../../../../helper_scripts/test_validate.sh

show: check-terraform-tfvars
	terraform show -var-file="$(TERRAFORM_TFVARS)"

format:
	terraform fmt

graph:
	../../../../helper_scripts/gen_graph.sh

%:
	@:    # If you don't find any rule do nothing
