# Report Generation

We will create a function that takes a JSON array of parameters and returns document whose content depends on the input parameters.

> You will learn how to render R markdown document based on input parameters and send back a Word (docx) document file.

You'll need the prerequisites listed [here](https://github.com/analythium/openfaas-rstats-templates/tree/master/examples).

## Create a new function using a template

Create a new function called `r-report`.

```bash
faas-cli new --lang rstats-base-plumber r-report
```

## Customize the function

Edit the `./r-report/DESCRIPTION` file (system requirements are taken care of by the `rocker/verse` base image).

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  rmarkdown,
  whisker
Remotes:
SystemRequirements:
  pandoc,
  pandoc-citeproc
VersionedPackages:
```

Change the `./r-report/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

See the [`template.Rmd` file](template.Rmd) for the R markdown template.
We use a custom serializer and content type suitable for a [docx file](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types) format.

```R
library(rmarkdown)
library(whisker)

tmp <- readLines("template.Rmd")

#* Report
#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.wordprocessingml.document")
#* @post /
function(req) {
  x <- as.data.frame(
    jsonlite::fromJSON(paste(req$postBody))
  )
  x$date <- as.character(Sys.Date())
  v <- whisker.render(tmp, x)
  writeLines(v, "report.Rmd")
  render("report.Rmd") # this renders into report.docx
  readBin("report.docx", "raw", n=file.info("report.docx")$size)
}
```

Edit the `r-report.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-report.yml
```

## Testing

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-report`:

```bash
curl http://localhost:5000/ -H \
  "Content-Type: application/json" -d \
  '{"name": "Brett", "mean": -2, "stddev": 1.5}' \
  --output report.docx
```

Test the deployed instance:

```bash
curl $OPENFAAS_URL/function/r-report -H \
  "Content-Type: application/json" -d \
  '{"name": "Brett", "mean": -2, "stddev": 1.5}' \
  --output report.docx
```

Now you should see the file `report.docx`.
