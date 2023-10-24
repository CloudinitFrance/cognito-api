#! /bin/bash
# Validate all the terraform files

# Some colors
export TERM=xterm
BLUE="\033[0;34m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# $1 = exit code (will exit testing if non-zero)
# $2 = description of the test
# $3 = output of the test

function validate_terraform() {
	# Pre-testing log_result
	rm -fR .terraform/modules/

	desc="Can we find the terraform binary?"
	OUTPUT=$(which terraform)
	log_result "$?" "$desc" "Couldn't find terraform. Is it in your PATH?"

	terraform init
	desc="Does the validate ok?"
	OUTPUT=$(terraform validate)
	log_result "$?" "$desc" "$OUTPUT"

	# If we got here, all the tests passed
	echo -e "$BLUE All tests passed $RESET"
	exit 0
}

function log_result() {
	if [ $1 -ne 0 ]; then
		echo -e "$RED test '$2' failed: $RESET\n $3"
		exit $1
	fi
}


# Script entrypoint
validate_terraform
