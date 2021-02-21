# Setup

export OPENFAAS_PREFIX="psolymos"
export OPENFAAS_URL="https://faas.analythium.io"
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username admin --password-stdin

# Pull rstats templates - not needed here
#faas-cli template pull https://github.com/analythium/openfaas-rstats-templates

# Which template to use
export TEMPLATE_NAME="rstats-base-plumber"

# Create Hello World example
export FUNCTION_NAME=r-$TEMPLATE_NAME
faas-cli new --lang $TEMPLATE_NAME $FUNCTION_NAME --prefix=$OPENFAAS_PREFIX
faas-cli up -f $FUNCTION_NAME.yml

# Test the function
curl $OPENFAAS_URL/function/$FUNCTION_NAME -d '"World"'

# Remove the function and files
faas-cli remove -f $FUNCTION_NAME.yml
rm $FUNCTION_NAME.yml
rm -r $FUNCTION_NAME
