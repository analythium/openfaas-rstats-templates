# Principal Component Analysis (PCA)

[PCA](https://en.wikipedia.org/wiki/Principal_component_analysis) is used for dimensionality reduction to obtain lower-dimensional representation of the data while preserving as much of the variation as possible.

We will create a function that takes a multi-dimensional JSON array as input and returns principal coordinate axes as JSON.

## Prerequisites

__Step 1.__ Install the [OpenFaaS CLI](https://docs.openfaas.com/cli/install/).

__Step 2.__ Set up your [k8s, k3s, or faasd with OpenFaaS](https://docs.openfaas.com/deployment/).

__Step 3.__ Use `docker login` to log into your registry of choice for pushing images.
Export your Docher Hub user or organization name:

```bash
export OPENFAAS_PREFIX="" # Populate with your Docker Hub username
```

__Step 4.__ Log into your OpenFaaS instance (see more info [here](https://github.com/openfaas/workshop/blob/master/lab1b.md)):

```bash
export OPENFAAS_URL="http://174.138.114.98:8080" # Populate with your OpenFaaS URL

# This command retrieves your password
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)

# This command logs in and saves a file to ~/.openfaas/config.yml
echo -n $PASSWORD | faas-cli login --username admin --password-stdin
```

Note: use `http://127.0.0.1:8080` as your OpenFaaS URL when using port forwarding via:

```bash
kubectl port-forward svc/gateway -n openfaas 8080:8080
```

## Create a new function using a template

Use the [`faas-cli`](https://github.com/openfaas/faas-cli) and pull R templates:

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

This example uses the `rstats-ubuntu-plumber` template.

Create a new function called `r-pca`. We use `psolymos` as docker user, replace it with your registry/user name as needed.

```bash
faas-cli new --lang rstats-ubuntu-plumber r-pca
```

Note: we dropped the ` --prefix=dockeruser` prefix because we exported `OPENFAAS_PREFIX` above.
## Customize the function

Change the `./r-pca/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

```R
library(vegan)
handle <- function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  vegan::rda(x)$CA$u
}
```

Edit the `./r-pca/DESCRIPTION` file.
Note: we need to build vegan from source otherwise it cannot link to shared libraries.
Therefore we add it to Remotes (we have to list it under Imports, but
Remotes indicates that it is to be installed from GitHub and not from the RSPM
CRAN repo).

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  vegan
Remotes:
  vegandevs/vegan
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

Test the Docker image locally after `docker run -p 4000:8080 psolymos/r-pca`:

```bash
curl http://localhost:4000/ -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]]'
```

Test we can test teh deployed instance in the [UI](https://docs.openfaas.com/architecture/gateway/) or with curl:

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
