#! /bin/bash
# Prepare terraform states file backend by doing some subtitutions

# Some colors
export TERM=xterm
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

function create_terraform_state_bucket() {
	TERRAFOM_STATE_BUCKET=$1

	if aws s3api head-bucket --bucket "$TERRAFOM_STATE_BUCKET" 2>/dev/null; then
		echo -e "${BOLD}${BLUE}Terraform state bucket already exists :-${RESET}"
	else
		echo -e "${BOLD}${GREEN}Create a new bucket for terraform state${RESET}"
		# Create a bucket
		aws s3api create-bucket --bucket $TERRAFOM_STATE_BUCKET \
			--region eu-west-1 \
			--create-bucket-configuration LocationConstraint=eu-west-1
		if [ $? -ne 0 ]
		then
			echo -e "${BOLD}${RED}Error when creating bucket${RESET}"
			exit 1
		fi
		# Encrypt the bucket using AES256
		aws s3api put-bucket-encryption --bucket $TERRAFOM_STATE_BUCKET \
			--server-side-encryption-configuration \
				'{ "Rules": [ { "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } } ] }'
		if [ $? -ne 0 ]
		then
			echo -e "${BOLD}${RED}Error when enabling bucket encryption${RESET}"
			exit 1
		fi
		# Enable versioning
		aws s3api put-bucket-versioning --bucket $TERRAFOM_STATE_BUCKET \
			--versioning-configuration Status=Enabled
		if [ $? -ne 0 ]
		then
			echo -e "${BOLD}${RED}Error when setting bucket versioning${RESET}"
			exit 1
		fi
		# Set bucket policy
		cp ../../../../helper_scripts/terraform_state_bucket_policy.json.template ../../../../helper_scripts/terraform_state_bucket_policy.json
		if [[ "$OSTYPE" == "linux-gnu" ]]; then
			sed -i -e 's:{%BUCKET_NAME%}:'"$TERRAFOM_STATE_BUCKET"':g' ../../../../helper_scripts/terraform_state_bucket_policy.json
		elif [[ "$OSTYPE" == "darwin"* ]]; then
			sed -i '.bak' -e 's:{%BUCKET_NAME%}:'"$TERRAFOM_STATE_BUCKET"':g' ../../../../helper_scripts/terraform_state_bucket_policy.json
		else
			echo -e "${BOLD}${RED}Are you using windows?${RESET}"
			exit 1
		fi
		if [ $? -ne 0 ]
		then
			echo -e "${BOLD}${RED}Error when setting bucket policy${RESET}"
			exit 1
		fi
	fi
}

function prepare_backend() {
	TERRAFOM_STATE_BUCKET=$1
	TERRAFOM_STATE_FILE_KEY=$2
	echo -e "$BLUE Fix 'backend.tf' file"
	cp backend.tf.template backend.tf
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		sed -i -e 's:{%TERRAFOM_STATE_BUCKET%}:'"$TERRAFOM_STATE_BUCKET"':g' backend.tf
		sed -i -e 's:{%TERRAFOM_STATE_FILE_KEY%}:'"$TERRAFOM_STATE_FILE_KEY"':g' backend.tf
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		sed -i '.bak' -e 's:{%TERRAFOM_STATE_BUCKET%}:'"$TERRAFOM_STATE_BUCKET"':g' backend.tf
		sed -i '.bak' -e 's:{%TERRAFOM_STATE_FILE_KEY%}:'"$TERRAFOM_STATE_FILE_KEY"':g' backend.tf
	else
		echo -e "${BOLD}${RED}Are you using windows?${RESET}"
		exit 1
	fi
}

# Script entry point
# Check args
if (( $# != 2 )); then
	echo -e "${BOLD}${RED}Illegal number of parameters "
	echo -e "Please a bucket name and " \
		"a terraform state file key${RESET}"
	exit 1
fi

create_terraform_state_bucket $1
prepare_backend $1 $2
