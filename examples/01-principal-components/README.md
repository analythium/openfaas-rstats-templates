# Principal Component Analysis (PCA)

[PCA](https://en.wikipedia.org/wiki/Principal_component_analysis) is used for dimensionality reduction to obtain lower-dimensional representation of the data while preserving as much of the variation as possible.

We will create a function that takes a multi-dimensional JSON array as input and returns principal coordinate axes as JSON.

> You will learn how to pre-load libraries and process the request data using a statistical method on the fly.

You'll need the prerequisites listed [here](https://github.com/analythium/openfaas-rstats-templates/tree/master/examples).

## Create a new function using a template

Create a new function called `r-pca`.

```bash
faas-cli new --lang rstats-base-plumber r-pca
```

## Customize the function

Change the `./r-pca/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

```R
library(vegan)
#* PCA
#* @post /
function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  vegan::rda(x)$CA$u
}
```

Edit the `./r-pca/DESCRIPTION` file.

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  vegan
Remotes:
SystemRequirements:
  libgfortran5
VersionedPackages:
```

Edit the `r-pca.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-pca.yml
```

## Testing

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-pca`:

```bash
curl http://localhost:5000/ -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]]'
```

Test the deployed instance:

```bash
curl $OPENFAAS_URL/function/r-pca -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]]'
```

The output should be:

```bash
[[0.5099,0.5251,-0.4629],[0.479,-0.4319,0.5779], 
[-0.598,0.4699,0.4143],[-0.391,-0.563,-0.5293]]
```
