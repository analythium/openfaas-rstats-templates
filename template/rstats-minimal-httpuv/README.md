# R/httpuv template for OpenFaaS with of-watchdog

> Sends and receives JSON using [httpuv]( https://CRAN.R-project.org/package=httpuv)
> and [of-watchdog](https://github.com/openfaas/of-watchdog).

This template uses the rhub/r-minimal:latest image.

## Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-minimal-httpuv r-minimal-httpuv-hello --prefix=dockeruser
```

## Customizing your function

Now we have a `r-minimal-httpuv-hello.yml` file and function folder `./r-minimal-httpuv-hello`.
Files in the function folder will get copied to the `/home/app` directory of the image.
Read more about the [YAML configuration](https://docs.openfaas.com/reference/yaml/).
Customize the `./r-minimal-httpuv-hello/handler.R` file as needed:

- load required packages using `library()`,
- put your data in the folder and load it relative to the function folder (e.g. `data.RData`) or use the full path (e.g. `/home/app/data.csv`),
- define the output given the input of the `handle` function, the output must be JSON parsable,
- add packages/remotes/system requirements and optionally metadata to the `DESCRIPTION` file.

## Build, push, and deploy

The `up` command includes `build` (build an image into the local Docker library)
`push` (push that image to a remote container registry),
and `deploy` (deploy your function into a cluster):

```bash
faas-cli up -f r-minimal-httpuv-hello.yml
```

## Testing

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-minimal-httpuv-hello
```

Curl should return `["Hello Friend!"]`:

```bash
curl http://localhost:4000/ -d '["Friend"]'
# ["Hello Friend!"]
```

Use the OpenFaaS UI or curl (should give `["Hello Friend!"]`).
Replace `localhost` with IP address if testing on remote location:

```bash
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
# ["Hello Friend!"]
```

## Example: PCA

Create a new function:

```bash
faas-cli new --lang rstats-minimal-httpuv r-minimal-pca --prefix=dockeruser
```

Change `handler.R`:

```R
suppressMessages({
  library(jsonlite)
  library(vegan)
})
handle <- function(req) {
  input <- req[["rook.input"]]
  postdata <- input$read_lines()
  x <- jsonlite::fromJSON(paste(postdata))
  output <- scores(rda(x), 1:2)$sites
  jsonlite::toJSON(output)
}
```

Edit `DESCRIPTION` (vegan needs compilation, so we use GitHub remote):

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  jsonlite,
  vegan
Remotes:
  vegandevs/vegan
SystemRequirements:
VersionedPackages:
```

Build the image: `faas-cli build -f r-minimal-pca.yml` and
test with `docker run -p 4000:8080 dockeruser/r-minimal-pca` and

```bash
curl http://localhost:4000/ -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]]'
# [[2.9545,3.042],[2.7754,-2.5023],[-3.4647,2.7223],[-2.2652,-3.262]]
```
