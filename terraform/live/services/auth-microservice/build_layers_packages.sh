# ! /bin/bash
# Build all lambda layers packages

for layer in `ls layers-src/`
do
	../../../../helper_scripts/build_lambda_layer.sh layers-src/${layer} ${layer} ../../../../helper_scripts/Dockerfile 3.9
done
