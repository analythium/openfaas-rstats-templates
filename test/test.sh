# Setup

export OPENFAAS_PREFIX="psolymos"
export OPENFAAS_URL="https://faas.analythium.io"
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username admin --password-stdin

# Pull rstats templates - not needed here
#faas-cli template pull https://github.com/analythium/openfaas-rstats-templates

# Which template to use
#export TEMPLATE_NAME="rstats-ubuntu-plumber"
#export TEMPLATE_NAME="rstats-ubuntu-httpuv"
#export TEMPLATE_NAME="rstats-ubuntu-fiery"
#export TEMPLATE_NAME="rstats-ubuntu-beakr"
#export TEMPLATE_NAME="rstats-ubuntu-ambiorix"
#export TEMPLATE_NAME="rstats-ubuntu"

#export TEMPLATE_NAME="rstats-base-plumber"
#export TEMPLATE_NAME="rstats-base-httpuv"
#export TEMPLATE_NAME="rstats-base-fiery"
#export TEMPLATE_NAME="rstats-base-beakr"
#export TEMPLATE_NAME="rstats-base-ambiorix"
#export TEMPLATE_NAME="rstats-base"

#export TEMPLATE_NAME="rstats-minimal-plumber"
#export TEMPLATE_NAME="rstats-minimal-httpuv"
#export TEMPLATE_NAME="rstats-minimal-fiery"
#export TEMPLATE_NAME="rstats-minimal-beakr"
#export TEMPLATE_NAME="rstats-minimal-ambiorix"
#export TEMPLATE_NAME="rstats-minimal"

# Create Hello World example
export FUNCTION_NAME=r-$TEMPLATE_NAME
faas-cli new --lang $TEMPLATE_NAME $FUNCTION_NAME --prefix=$OPENFAAS_PREFIX
faas-cli up -f $FUNCTION_NAME.yml

# Inspect logs
faas-cli logs $FUNCTION_NAME

# Test the function
curl $OPENFAAS_URL/function/$FUNCTION_NAME \
  -d '"World"' \
  -H 'Content-Type: application/json'

# Remove the function and files
faas-cli remove -f $FUNCTION_NAME.yml
rm $FUNCTION_NAME.yml
rm -r $FUNCTION_NAME

## --

docker images --filter=reference='*/r-rstats-*' --format "{{.Repository}}\t{{.Size}}"

#psolymos/r-rstats-base-plumber      927MB
#psolymos/r-rstats-base-fiery        934MB
#psolymos/r-rstats-base-httpuv       873MB
#psolymos/r-rstats-base-beakr        923MB
#psolymos/r-rstats-base-ambiorix     921MB
#psolymos/r-rstats-base              833MB
#psolymos/r-rstats-ubuntu-ambiorix   884MB
#psolymos/r-rstats-ubuntu-beakr      849MB
#psolymos/r-rstats-ubuntu            768MB
#psolymos/r-rstats-ubuntu-fiery      860MB
#psolymos/r-rstats-ubuntu-httpuv     804MB
#psolymos/r-rstats-ubuntu-plumber    853MB
