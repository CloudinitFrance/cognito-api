# ! /bin/bash
# Prepare aws python lambda layer package - requirements.txt file is mandatory

# Some colors
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

RUNNING_INSIDE_DOCKER=0

function running_inside_docker() {
	if grep -s docker /proc/1/cgroup; then
		echo -e "${BOLD}${GREEN}Running inside docker${RESET}"
		RUNNING_INSIDE_DOCKER=1
	fi
}

function create_deployment_package() {
	echo -e "${BOLD}${GREEN}Create lambda layer deployment package${RESET}"
	LAYER_SRC_PATH=`realpath $1`
	LAYER_SRC_PATH="$LAYER_SRC_PATH/"
	LAMBDA_DOCKER_IMAGE_TAG=$2
	DOCKER_FILE_PATH=`realpath $3`
	REQUIREMENTS_FILE_PATH="$LAYER_SRC_PATH/requirements.txt"
	PYTHON_RUNTIME=$4
	echo "${LAYER_SRC_PATH}"
	echo "${LAMBDA_DOCKER_IMAGE_TAG}"
	echo "${DOCKER_FILE_PATH}"
	echo "${REQUIREMENTS_FILE_PATH}"
	# We will build for X64 architectures
	# Just in case yoou are using a MacOs X on ARM architectures
	# Which can leads to some unhappy surprises like:
	# _rust.abi3.so: cannot open shared object file
	# When building cryptography libs
	export DOCKER_DEFAULT_PLATFORM=linux/amd64

	#if [[ -f "${LAYER_SRC_PATH}/${LAMBDA_DOCKER_IMAGE_TAG}.zip" ]] ; then
	#	echo -e "${GREEN}Package ${LAYER_SRC_PATH}/${LAMBDA_DOCKER_IMAGE_TAG}.zip already exists, skip packaging.${RESET}"
	#	return
	#fi

	if [ "$RUNNING_INSIDE_DOCKER" -eq "0" ]; then
		docker build -f $DOCKER_FILE_PATH -t $LAMBDA_DOCKER_IMAGE_TAG .
		echo "Run a new image"
		docker run --rm -v ${LAYER_SRC_PATH}:/root -v ${REQUIREMENTS_FILE_PATH}:/root/requirements.txt -i -t ${LAMBDA_DOCKER_IMAGE_TAG} \
			sh -c "	pip install -r /root/requirements.txt --root-user-action=ignore -t python/lib/python${PYTHON_RUNTIME}/site-packages/ && \
				zip -r ${LAMBDA_DOCKER_IMAGE_TAG}.zip python && rm -rf python"
		# Remove the docker image
		docker rmi $LAMBDA_DOCKER_IMAGE_TAG
		# Remove the build directory
		rm -rf python
	else
		pip install -r /root/requirements.txt --root-user-action=ignore -t python/lib/python${PYTHON_RUNTIME}/site-packages/ && \
		zip -r ${LAMBDA_DOCKER_IMAGE_TAG}.zip python
		# Remove the build directory
		rm -rf python
	fi
}

function check_dependencies() {
	if [ "$RUNNING_INSIDE_DOCKER" -eq "1" ]; then
		return
	fi

	# Check if docker is installed
	if [ $? -ne 0 ]; then
		echo -e "${BOLD}${RED}docker is not installed!${RESET}"
		echo -e "${BOLD}${RED}Please install docker and retry${RESET}"
		echo -e "${BOLD}${RED}For all systems, check this URL: https://docs.docker.com/install/${RESET}"
	else
		echo -e "${BOLD}${GREEN}docker is already installed${RESET}"
		return
	fi

	if [ $? -ne 0 ]
	then
		echo -e "${BOLD}${RED}Error check dependencies${RESET}"
		exit 1
	fi
}

function help() {
	echo -e "${BOLD}${RED}Illegal number of parameters "
	echo -e "Usage: $0 layer_src_path layer_name dockerfile_path python_runtime ${RESET}"
	exit 1
}

function validate_args() {
	LAYER_SRC_PATH=$1

	if [ ! -d "$LAYER_SRC_PATH" ]; then
		echo -e "${BOLD}${RED}Layer source path not found${RESET}"
		exit 1
	fi

	# TODO: Use Docker to build
	# Detect Windows OS :)
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		echo -e "${BOLD}${GREEN}OS OK, you can go further${RESET}"
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		echo -e "${BOLD}${GREEN}OS OK, you can go further${RESET}"
	else
		echo -e "${BOLD}${RED}Are you using windows? Long life to the pinguin :)${RESET}"
		exit 1
	fi
}

# Script entry point
# Check args
if (( $# != 4 )); then
	help
fi

validate_args $1
running_inside_docker
check_dependencies
create_deployment_package $1 $2 $3 $4
