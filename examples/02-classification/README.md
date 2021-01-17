# Classification

This examples using [Support-vector Machines (SVM)](https://en.wikipedia.org/wiki/Support-vector_machine) to do [multinomial classification](https://en.wikipedia.org/wiki/Statistical_classification).
Classification is predicting which class a new observation belongs to based on a model trained on a set of observations whose class membership is known. Multinomial problems have more then 2 possible classes. We use the [Iris flower data set](https://en.wikipedia.org/wiki/Iris_flower_data_set) that contains measurements for 3 Iris species.

We will create a function that takes a JSON array of measurements as input and returns JSON with the predicted class and class membership probabilities corresponding to the measurements.

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

This example uses the `rstats-base-plumber` template.

Create a new function called `r-iris`.

```bash
faas-cli new --lang rstats-base-plumber r-iris
```

Note: we dropped the `--prefix=dockeruser` prefix because we exported `OPENFAAS_PREFIX` above.

## Customize the function

Edit the `./r-iris/DESCRIPTION` file.
Note: `r-base` based images install from source, thus avoiding most of build issues
related to using pre-build packages.

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  e1071
Remotes:
SystemRequirements:
VersionedPackages:
```

Open R and perform model training, then save the trained model into `./r-iris/model.rda`:

```R
library(e1071) # library with SVM function
data(iris)     # Iris data set

str(iris) # see the measured variables
'data.frame': 150 obs. of  5 variables:
# $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
# $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
# $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
# $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
# $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 ...
levels(iris$Species) # the 3 Iris species
# [1] "setosa"     "versicolor" "virginica" 

## train model with probability=TRUE
model <- svm(Species ~ ., iris, probability=TRUE)
model # print our model info
#
# Call:
# svm(formula = Species ~ ., data = iris)
#
#
# Parameters:
#    SVM-Type:  C-classification 
#  SVM-Kernel:  radial 
#        cost:  1 
#
# Number of Support Vectors:  51

## save the trained model
saveRDS(model, "./r-iris/model.rda")
```

Change the `./r-iris/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

When reading in the rda file, we don't need the directory because the file will be moved into the function's root directory:

```R
library(e1071)

model <- readRDS("model.rda")

handle <- function(req) {
  x <- as.data.frame(
    jsonlite::fromJSON(paste(req$postBody))
  )
  p <- predict(model, x, probability=TRUE)
  list(
      species=as.character(p),
      probabilities=as.list(drop(attr(p,"probabilities")))
  )
}
```

Edit the `r-iris.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-iris.yml
```

## Testing

Test the Docker image locally after `docker run -p 4000:8080 $OPENFAAS_PREFIX/r-iris`:

```bash
curl http://localhost:4000/ -H \
  "Content-Type: application/json" -d \
  '{"Sepal.Length":5.2,"Sepal.Width":3.4,"Petal.Length":1.5,"Petal.Width":0.2}'
```

Test we can test teh deployed instance in the [UI](https://docs.openfaas.com/architecture/gateway/) or with curl:

```bash
curl $OPENFAAS_URL/function/r-iris -H \
  "Content-Type: application/json" -d \
  '{"Sepal.Length":5.2,"Sepal.Width":3.4,"Petal.Length":1.5,"Petal.Width":0.2}'
```

The output should include the predicted species name and the probabilities:

```bash
{
    "species":["setosa"],
    "probabilities":{
        "setosa":[0.9779],
        "versicolor":[0.0128],
        "virginica":[0.0093]
    }
}
```
