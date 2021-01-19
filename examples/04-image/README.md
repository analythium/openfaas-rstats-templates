# Image Generation

We will create a function that takes a URL parameters and returns a corresponding. We will use different endpoints for base and ggplot2 based graphics.

> You will learn how to render plot based on input parameters and how to add different endpoints to the function.

You'll need the prerequisites listed [here](https://github.com/analythium/openfaas-rstats-templates/tree/master/examples).

## Create a new function using a template

Create a new function called `r-image`.

```bash
faas-cli new --lang rstats-base-plumber r-image
```

## Customize the function

Edit the `./r-image/DESCRIPTION` file:

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  ggplot2
Remotes:
SystemRequirements:
VersionedPackages:
```

Change the `./r-image/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

```R
library(ggplot2)

#* Plot a histogram with base graphics
#* @serializer png
#* @get /base
function(n, mean, stddev) {
  if (missing(n))
    n <- 100
  if (missing(mean))
    mean <- 0
  if (missing(stddev))
    stddev <- 1
  n <- as.numeric(n)
  mean <- as.numeric(mean)
  stddev <- as.numeric(stddev)
  x <- rnorm(n, mean, stddev)
  hist(x)
}

#* Plot a histogram with ggplot
#* @serializer png
#* @get /ggplot
function(n, mean, stddev) {
  if (missing(n))
    n <- 100
  if (missing(mean))
    mean <- 0
  if (missing(stddev))
    stddev <- 1
  n <- as.numeric(n)
  mean <- as.numeric(mean)
  stddev <- as.numeric(stddev)
  x <- rnorm(n, mean, stddev)
  p <- ggplot() + 
    geom_histogram(aes(x=x))
  print(p)
}
```

Edit the `r-image.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-image.yml
```

## Testing

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-image`.
Try `http://localhost:5000/base?n=1000&mean=1` and `http://localhost:5000/ggplot?n=1000&mean=1` in the browser to see the image.

```bash
curl -X GET -G http://localhost:5000/base \
  -d n=1000 -d stddev=10 \
  --output base.png

curl -X GET -G http://localhost:5000/ggplot \
  -d n=1000 -d stddev=10 \
  --output ggplot.png
```

Test the deployed instance using different settings:

```bash
curl -X GET -G $OPENFAAS_URL/function/r-image/base \
  -d n=1000 -d stddev=10 \
  --output base.png

curl -X GET -G $OPENFAAS_URL/function/r-image/ggplot \
  -d n=1000 -d stddev=10 \
  --output ggplot.png
```
Try `$OPENFAAS_URL/function/r-image/base?n=1000&mean=1` and `$OPENFAAS_URL/function/r-image/ggplot?n=1000&mean=1` in the browser to see the image.

Now you should see the file files `base.png` and `ggplot.png`.
