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

#psolymos/r-rstats-base              833MB
#psolymos/r-rstats-base-ambiorix     921MB
#psolymos/r-rstats-base-beakr        923MB
#psolymos/r-rstats-base-fiery        934MB
#psolymos/r-rstats-base-httpuv       873MB
#psolymos/r-rstats-base-plumber      927MB

#psolymos/r-rstats-ubuntu            768MB
#psolymos/r-rstats-ubuntu-ambiorix   884MB
#psolymos/r-rstats-ubuntu-beakr      849MB
#psolymos/r-rstats-ubuntu-fiery      860MB
#psolymos/r-rstats-ubuntu-httpuv     804MB
#psolymos/r-rstats-ubuntu-plumber    853MB

#psolymos/r-rstats-minimal           286MB
#psolymos/r-rstats-minimal-ambiorix  488MB
#psolymos/r-rstats-minimal-beakr     388MB
#psolymos/r-rstats-minimal-fiery     400MB
#psolymos/r-rstats-minimal-httpuv    349MB
#psolymos/r-rstats-minimal-plumber   392MB

## test build args

export FNNAME="hello-r"
faas-cli new --lang rstats-base-plumber $FNNAME --prefix=$OPENFAAS_PREFIX

faas-cli build -f $FNNAME.yml --build-arg R_IMAGE=rocker/r-base:4.0.0

faas-cli remove -f $FNNAME.yml
rm $FNNAME.yml
rm -r $FNNAME


faas-cli new --lang rstats-base-plumber hello-rstats-2 --prefix=$OPENFAAS_PREFIX

faas-cli build -f hello-rstats-2.yml --build-arg R_IMAGE=rocker/r-base:4.0.0

# Debian - working
# https://hub.docker.com/r/rocker/r-base/tags
faas-cli new --lang rstats-base-plumber hello1 --prefix=$OPENFAAS_PREFIX
faas-cli build -f hello1.yml --build-arg R_IMAGE=rocker/r-base:4.0.0

# Debian - working
# https://hub.docker.com/r/rocker/r-ver/tags
faas-cli new --lang rstats-base-plumber hello2 --prefix=$OPENFAAS_PREFIX
faas-cli build -f hello2.yml --build-arg R_IMAGE=rocker/r-ver:4.0.0

# Ubuntu - working
# https://hub.docker.com/r/rstudio/r-base/tags
faas-cli new --lang rstats-ubuntu-plumber hello3 --prefix=$OPENFAAS_PREFIX
faas-cli build -f hello3.yml --build-arg R_IMAGE=rstudio/r-base:4.0.0-focal

# Ubuntu - working
# https://hub.docker.com/r/rocker/r-ubuntu/tags
faas-cli new --lang rstats-ubuntu-plumber hello4 --prefix=$OPENFAAS_PREFIX
faas-cli build -f hello4.yml --build-arg R_IMAGE=rocker/r-ubuntu:18.04

# Alpine - working
# https://hub.docker.com/r/rhub/r-minimal/tags
faas-cli new --lang rstats-minimal-plumber hello5 --prefix=$OPENFAAS_PREFIX
faas-cli build -f hello5.yml --build-arg R_IMAGE=rhub/r-minimal:4.0

docker images --filter=reference='*/hello*' --format "{{.Repository}}\t{{.Size}}"

#psolymos/hello1  926MB
#psolymos/hello2 1210GB
#psolymos/hello3 1040GB
#psolymos/hello4  746MB
#psolymos/hello5  392MB
