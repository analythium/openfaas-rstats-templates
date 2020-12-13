# R (rstats) templates for OpenFaaS

> This project provides [OpenFaaS](https://www.openfaas.com/)
> templates for the [R](https://www.r-project.org/) language.

- [R (rstats) templates for OpenFaaS](#r-rstats-templates-for-openfaas)
  - [Introduction](#introduction)
    - [Base images](#base-images)
    - [Watchdog type](#watchdog-type)
    - [Server framework (for of-watchdog)](#server-framework-for-of-watchdog)
  - [Usage](#usage)
    - [Setup](#setup)
    - [Make a new function](#make-a-new-function)
    - [Customize your function](#customize-your-function)

## Introduction

The `/template` folder contains the following OpenFaaS templates:

| Template | Base image | Watchdog | Server framework |
|----------|------------|----------|------------------|
| rstats-base | rocker/r-base | classic | None (stdio) |
| rstats-base-plumber | rocker/r-base | of-watchdog | plumber |
| rstats-ubuntu | rocker/r-ubuntu | classic | None (stdio) |
| rstats-ubuntu-plumber | rocker/r-ubuntu | of-watchdog | plumber |
| rstats-minimal | rhub/r-minimal | classic | None (stdio) |

The templates differ with respect to:

- R base image,
- watchdog type, and
- the server framework used.

### Base images

* Debian based rocker/r-base: consistency for most adopted base images, call this base;
* Ubuntu based rocker/r-ubuntu: long term support can be important in corporate context and it jives with RSPM, call this ubuntu;
* Alpine based r-hub/r-minimal: small size is always a good thing, call this minimal.

### Watchdog type

* The [watchdog](https://github.com/openfaas/faas/tree/master/watchdog) is a tiny Golang webserver that marshals an HTTP request accepted on the API Gateway and to invoke your chosen application. This is the init process for your container. The classic watchdog passes in the HTTP request via `stdin` and reads a HTTP response via `stdout`.
* The _http mode_ of the [of-watchdog](https://github.com/openfaas-incubator/of-watchdog) provides more control over your HTTP responses ("hot functions", persistent connection pools, or caching). This is what the `rstats-http` template is using.

### Server framework (for of-watchdog)

* plumber.

More server frameworks are being explored, such as the Rserve based RestRserve, or the httpuv based opencpu, fiery, and beakr. **PRs are welcome!**

## Usage

### Setup

It is recommended to read the [OpenFaaS docs](https://docs.openfaas.com/) first
and set up a local or remote Kubernetes or Docker Swarm installation with
OpenFaaS deployed to the cluster (see docs [here](https://docs.openfaas.com/deployment/)).
To get going quickly,
follow the official OpenFaaS [workshop](https://docs.openfaas.com/tutorials/workshop/),
or enroll into the free
[Introduction to Serverless on Kubernetes](https://www.edx.org/course/introduction-to-serverless-on-kubernetes) course.

### Make a new function

Use the [`faas-cli`](https://github.com/openfaas/faas-cli) and pull R templates:

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Now `faas-cli new --list` should give you a list with the available `rstats` templates.

Create a new function called `hello-rstats`:

```bash
faas-cli new --lang rstats-http hello-rstats --prefix=dockeruser
```

the `dockeruser` means a user or organization on e.g. Docker Hub where
you have push privileges; don't forget to log in to the registry using `docker login`.

Your folder now should contain the following:

```bash
hello-rstats/handler.R
hello-rstats/DESCRIPTION
hello-rstats.yml
```

The `handler.R` file does the heavy lifting by executing the desired
functionality. `DESCRIPTION` lists the dependencies.
The `hello-rstats.yml` is the stack file used to configure functions
(read more [here](https://docs.openfaas.com/reference/yaml/)).

You can build, push, and deploy the `hello-rstats` function using:

```bash
faas-cli up -f hello-rstats.yml
```

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

Once the function is deployed, you can test it in the UI
(e.g. at `http://localhost:8080/ui/`) or using curl:

```bash
curl http://localhost:8080/function/hello-rstats -d '["Friend"]'
```

Both should give the JSON output `["Hello Friend!"]`.

### Customize your function

You can now edit `./hello-rstats/handler.R` to your liking.
Don't forget to add dependencies to `./hello-rstats/DESCRIPTION` file.

For example, calculate principal components
based on an input data array using the
[vegan](https://CRAN.R-project.org/package=vegan) R package.

The `./hello-rstats/handler.R` file should look like this:

```bash
handle <- function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  vegan::rda(x)$CA$u
}
```

Add the vegan package to the `./hello-rstats/DESCRIPTION` file, which now
looks like this:

```yaml
Package: OpenFaaS
Version: 0.0.1
Imports:
  vegan
Remotes:
SystemRequirements:
VersionedPackages:
```

The template installs dependencies specified in the `DESCRIPTION` file
in this order:

1. `SystemRequirements:` list OS specific sysreqs here, comma separated, these are then installed by the OS's package manager,
2. CRAN packages listed in `Depends:`, `Imports:`, `LinkingTo:` fields are installed by `remotes::install_deps()`,
3. `Remotes:` fields are installed according to [remotes](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) specs, make sure to list the package in `Imports:` as well, the location specified in `Remotes:` will be used to get the package from,
4. `VersionedPackages:` this field can be used to pin package versions using `remotes::install_version()`, do not list these packages in other fields (spaces after operators and commas inside parenthesis are important).

You can also modify the `Dockerfile` in the template if specific
R version or further customization is needed.
The templates are using the following base images:

- Debian-based `rocker/r-base` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-base) project for bleeding edge,
- Ubuntu-based `rocker/r-ubuntu` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-ubuntu) project for long term support (uses RSPM binaries),
- Alpine-based `rhub/r-minimal` Docker image the [rr-hub](https://github.com/r-hub/r-minimal) project for smallest image sizes.

System requirements for the same package might be different across
Linux distros. This is a grey area of the R package ecosystem, see
[rstudio/r-system-requirements](https://github.com/rstudio/r-system-requirements)
and [r-hub/sysreqsdb](https://github.com/r-hub/sysreqsdb) for help.

After pushing and deploying the function,
we can test either in the UI or with curl:

```bash
curl http://localhost:8080/function/hello-rstats -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]] '
```

Now you should see the JSON output
`[[0.5099,0.5251,-0.4629],[0.479,-0.4319,0.5779],[-0.598,0.4699,0.4143],[-0.391,-0.563,-0.5293]]`.

Note that the of-watchdog _http mode_ loads the handler as a
small background web server. The classic watchdog's forking mode
would instead load this file for every invocation creating additional latency
when loading packages, saved data, or trained models.
