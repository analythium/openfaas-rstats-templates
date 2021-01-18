# HTML Widget

We will create a function that returns a self contained HTML widget that can be embedded into websites or BI tools as an e.g. iframe.

> You will learn how to make custom Plotly graphs based on URL parameters.

You'll need the prerequisites listed [here](https://github.com/analythium/openfaas-rstats-templates/tree/master/examples).

## Create a new function using a template

Create a new function called `r-widget`.

```bash
faas-cli new --lang rstats-base-plumber r-widget
```

## Customize the function

Edit the `./r-widget/DESCRIPTION` file:

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  plotly
Remotes:
SystemRequirements:
  pandoc
VersionedPackages:
```

Change the `./r-widget/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

```R
library(htmlwidgets)
library(plotly)

gauge <- function(value, min=0, max=100, title="Percent") {
  plot_ly(
    type = "indicator",
    mode = "gauge+number",
    value = value,
    title = list(text = title),
    gauge = list(axis = list(range = list(min, max)))) %>%
    layout(margin = list(l=20, r=30)) %>%
    config(displayModeBar = FALSE)
}

#* Gauge
#* @serializer htmlwidget
#* @get /
function(value, min, max, title) {
  if (missing(title))
    title <- "Percent"
  if (missing(min))
    min <- 0
  if (missing(max))
    max <- 100
  gauge(value, min, max, title)
}
```

Edit the `r-widget.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-widget.yml
```

## Testing

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-widget` using default settings:

```bash
curl -X GET -G \
  localhost:5000 \
  -d value=20 \
  --output index.html
```

Test the deployed instance using different settings:

```bash
curl -X GET -G \
  $OPENFAAS_URL/function/r-widget \
  -d value=20 \
  --output index.html
```

Now you should see the file gauge after opening the `index.html` file in the browser.

Go to the `OPENFAAS_URL/function/r-widget?value=20` URL to see the widget in the browser.
