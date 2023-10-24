#! /bin/bash
# Create a dynamodb table if needed in order to prevent concurent access 
# Init terraform

# Some colors
export TERM=xterm
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

function create_dynamodb_lock_table() {
	# Ensure lock table exists, otherwise create it
	aws dynamodb list-tables --output text | grep terraform-lock-states
	if [ $? -eq 0 ]; then
		echo -e "${BOLD}${BLUE}Terraform states lock table exists${RESET}"
	else
		echo -e "${BOLD}${GREEN}Creating terraform states lock table${RESET}"
		aws dynamodb create-table \
			--table-name terraform-lock-states \
			--attribute-definitions AttributeName=LockID,AttributeType=S \
			--key-schema AttributeName=LockID,KeyType=HASH \
			--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
	fi
	# Sleep for dynamodb table to be ready
	sleep 5
}

function init_terraform() {
	# Now perform terraform init
	#yes yes | terraform init -upgrade
	yes yes | terraform init
}

# Script entry point

create_dynamodb_lock_table
init_terraform
