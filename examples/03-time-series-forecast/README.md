# Time Series Forecast

[Exponential smoothing](https://en.wikipedia.org/wiki/Exponential_smoothing) is a forecasting method.

We will create a function that pulls JSON data from public [COVID-19 data API](https://github.com/analythium/covid-19#readme), fits exponential smoothing model and returns the forecast results as JSON.

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

Create a new function called `r-covid`.

```bash
faas-cli new --lang rstats-base-plumber r-covid
```

Note: we dropped the `--prefix=dockeruser` prefix because we exported `OPENFAAS_PREFIX` above.

## Customize the function

Edit the `./r-covid/DESCRIPTION` file.
Note: `r-base` based images install from source, thus avoiding most of build issues
related to using pre-build packages.

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  forecast
Remotes:
SystemRequirements:
VersionedPackages:
```

Change the `./r-covid/handler.R` file:

```R
library(forecast)

covid_forecast <- function(region, cases="confirmed", window=14) {
    ## check arguments
    cases <- match.arg(cases, c("confirmed", "deaths"))
    window <- round(window)
    if (window < 1)
        stop("window must be > 0")
    ## API endpoint for region in global data set
    ## available values: https://hub.analythium.io/covid-19/api/v1/regions/
    u <- paste0("https://hub.analythium.io/covid-19/api/v1/regions/", region)
    x <- jsonlite::fromJSON(u) # will throw error if region is not found
    ## time series: daily new cases
    y <- pmax(0, diff(x$rawdata[[cases]]))
    ## last date
    l <- as.Date(x$rawdata$date[length(x$rawdata$date)])
    ## fit ETS
    m <- ets(y)
    ## forecaset based on model and window
    f <- forecast(m, h=window)
    ## process forecast
    p <- cbind(Date=seq(l+1, l+window, 1), as.data.frame(f))
    p[p < 0] <- 0
    as.list(p)
}

handle <- function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  covid_forecast(x$region, x$cases, x$window)
}
```

Edit the `r-covid.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-covid.yml
```

## Testing

Test the Docker image locally after `docker run -p 4000:8080 $OPENFAAS_PREFIX/r-covid`:

```bash
curl http://localhost:4000/ -H \
  "Content-Type: application/json" -d \
  '{"region": "canada-combined", "cases": "confirmed", "window": 4}'
```

The key-value pairs are as follows:

- region: a region slug value for the API endpoint in global data set (see [available values](https://hub.analythium.io/covid-19/api/v1/regions/)),
- cases: one of `"confirmed"` or `"deaths"`,
- windows: a positive integer giving the forecast horizon in days.

Test we can test teh deployed instance in the [UI](https://docs.openfaas.com/architecture/gateway/) or with curl:

```bash
curl $OPENFAAS_URL/function/r-covid -H \
  "Content-Type: application/json" -d \
  '{"region": "canada-combined", "cases": "confirmed", "window": 4}'
```

The output should include the 4-day forecast including 80% and 95% forecast intervals:

```bash
{
  "Date": ["2021-01-16", "2021-01-17", "2021-01-18", "2021-01-19"],
  "Point Forecast": [7954.9403, 7995.8122, 8036.6842, 8077.5561],
  "Lo 80": [6782.2353, 6815.0554, 6847.1382, 6878.4625],
  "Hi 80": [9127.6454, 9176.569, 9226.2301, 9276.6497],
  "Lo 95": [6161.4427, 6190.0005, 6217.4306, 6243.7007],
  "Hi 95": [9748.4379, 9801.6239, 9855.9377, 9911.4114]
}
```
