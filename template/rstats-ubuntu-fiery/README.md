# R/fiery template for OpenFaaS with of-watchdog

> Sends and receives JSON using [fiery](https://CRAN.R-project.org/package=fiery)
> and [of-watchdog](https://github.com/openfaas/of-watchdog).

This template uses the rocker/r-ubuntu:latest image.

## Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-ubuntu-fiery r-ubuntu-fiery-hello --prefix=dockeruser
```

## Customizing your function

Now we have a `r-ubuntu-fiery-hello.yml` file and function folder `./r-ubuntu-fiery-hello`.
Files in the function folder will get copied to the `/home/app` directory of the image.
Read more about the [YAML configuration](https://docs.openfaas.com/reference/yaml/).
Customize the `./r-ubuntu-fiery-hello/handler.R` file as needed:

- load required packages using `library()`,
- put your data in the folder and load it relative to the function folder (e.g. `data.RData`) or use the full path (e.g. `/home/app/data.csv`),
- define the output given the input of the `handle` function, the output must be JSON parsable,
- add packages/remotes/system requirements and optionally metadata to the `DESCRIPTION` file.

## Build, push, and deploy

The `up` command includes `build` (build an image into the local Docker library)
`push` (push that image to a remote container registry),
and `deploy` (deploy your function into a cluster):

```bash
faas-cli up -f r-ubuntu-fiery-hello.yml
```

## Testing

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-ubuntu-fiery-hello
```

Curl should return `["Hello Friend!"]`:

```bash
curl http://localhost:4000/ -d '["Friend"]' -H 'Content-Type: application/json'
# ["Hello Friend!"]
```

The log looks like this:

```bash
2020/12/13 06:03:04 Started logging stderr from function.
2020/12/13 06:03:04 Started logging stdout from function.
2020/12/13 06:03:04 OperationalMode: http
2020/12/13 06:03:04 Timeouts: read: 10s, write: 10s hard: 10s.
2020/12/13 06:03:04 Listening on port: 8080
2020/12/13 06:03:04 Writing lock-file to: /tmp/.lock
2020/12/13 06:03:04 Metrics listening on port: 8081
Forking - Rscript [index.R]
2020/12/13 06:03:05 stderr: Running fiery API at http://0.0.0.0:5000
2020/12/13 06:03:05 stderr: Running swagger Docs at http://127.0.0.1:5000/__docs__/
2020/12/13 06:03:19 POST / - 200 OK - ContentLength: 17
```

Use the OpenFaaS UI or curl (should give `["Hello Friend!"]`).
Replace `localhost` with IP address if testing on remote location:

```bash
curl http://localhost:8080/function/<function-name> -H 'Content-Type: application/json' -d '["Friend"]'
# ["Hello Friend!"]
```

## Example: PCA

Create a new function:

```bash
faas-cli new --lang rstats-ubuntu-fiery r-ubuntu-pca --prefix=dockeruser
```

Change `handler.R`:

```R
suppressMessages(library(vegan))
handle <- function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  scores(rda(x), 1:2)$sites
}
```

Edit `DESCRIPTION`:

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  vegan
Remotes:
SystemRequirements:
VersionedPackages:
```

Build the image: `faas-cli build -f r-ubuntu-pca.yml` and
test with `docker run -p 4000:8080 dockeruser/r-ubuntu-pca` and

```bash
curl http://localhost:4000/ -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]]'
# [[2.9545,3.042],[2.7754,-2.5023],[-3.4647,2.7223],[-2.2652,-3.262]]
```
