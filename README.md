# R (rstats) templates for OpenFaaS

<img src="https://hub.analythium.io/assets/web/faastr.png" align="right" style="padding-left:10px;background-color:white;" />

> [OpenFaaS](https://www.openfaas.com/) templates
> for the [R](https://www.r-project.org/) language.

- [R (rstats) templates for OpenFaaS](#r-rstats-templates-for-openfaas)
  - [Introduction](#introduction)
    - [Parent image](#parent-image)
    - [Watchdog type](#watchdog-type)
    - [Server framework (for of-watchdog only)](#server-framework-for-of-watchdog-only)
  - [Usage](#usage)
    - [Setup](#setup)
    - [Make a new function](#make-a-new-function)
    - [Customize your function](#customize-your-function)
  - [Contributing](#contributing)
  - [License](#license)

## Introduction

The `/template` folder contains the following OpenFaaS templates:

| Template | Base image | Watchdog | Server framework |
|----------|------------|----------|------------------|
| [rstats-base](template/rstats-base) | rocker/r-base | classic | None (STDIO) |
| [rstats-ubuntu](template/rstats-ubuntu) | rocker/r-ubuntu | classic | None (STDIO) |
| [rstats-minimal](template/rstats-minimal) | rhub/r-minimal | classic | None (STDIO) |
| [rstats-base-plumber](template/rstats-base-plumber) | rocker/r-base | of-watchdog | plumber |
| [rstats-ubuntu-plumber](template/rstats-ubuntu-plumber) | rocker/r-ubuntu | of-watchdog | plumber |
| [rstats-minimal-plumber](template/rstats-minimal-plumber) | rhub/r-minimal | of-watchdog | plumber |
| [rstats-base-httpuv](template/rstats-base-httpuv) | rocker/r-base | of-watchdog | httpuv |
| [rstats-ubuntu-httpuv](template/rstats-ubuntu-httpuv) | rocker/r-ubuntu | of-watchdog | httpuv |
| [rstats-minimal-httpuv](template/rstats-minimal-httpuv) | rhub/r-minimal | of-watchdog | httpuv |
| [rstats-base-beakr](template/rstats-base-beakr) | rocker/r-base | of-watchdog | beakr |
| [rstats-ubuntu-beakr](template/rstats-ubuntu-beakr) | rocker/r-ubuntu | of-watchdog | beakr |
| [rstats-minimal-beakr](template/rstats-minimal-beakr) | rhub/r-minimal | of-watchdog | beakr |
| [rstats-base-fiery](template/rstats-base-fiery) | rocker/r-base | of-watchdog | fiery |
| [rstats-ubuntu-fiery](template/rstats-ubuntu-fiery) | rocker/r-ubuntu | of-watchdog | fiery |
| [rstats-minimal-fiery](template/rstats-minimal-fiery) | rhub/r-minimal | of-watchdog | fiery |
| [rstats-base-ambiorix](template/rstats-base-ambiorix) | rocker/r-base | of-watchdog | ambiorix |
| [rstats-ubuntu-ambiorix](template/rstats-ubuntu-ambiorix) | rocker/r-ubuntu | of-watchdog | ambiorix |
| [rstats-minimal-ambiorix](template/rstats-minimal-ambiorix) | rhub/r-minimal | of-watchdog | ambiorix |

The templates differ with respect to:

- R parent image,
- watchdog type, and
- the server framework used.

### Parent image

- Debian-based `rocker/r-base` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-base) project for bleeding edge,
- Ubuntu-based `rocker/r-ubuntu` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-ubuntu) project for long term support (uses [RSPM](https://packagemanager.rstudio.com/client/) binaries),
- Alpine-based `rhub/r-minimal` Docker image from the [r-hub](https://github.com/r-hub/r-minimal) project for smallest image sizes.

See the [Rocker](https://journal.r-project.org/archive/2017/RJ-2017-065/RJ-2017-065.pdf) and the [Rockerverse](https://journal.r-project.org/archive/2020/RJ-2020-007/RJ-2020-007.pdf) papers in the R Journal about the current state of the art regarding the use of container technology in R.

### Watchdog type

- The [classic watchdog](https://github.com/openfaas/classic-watchdog) is a tiny Golang webserver that marshals an HTTP request accepted on the API Gateway and to invoke your chosen application. This is the init process for your container. The classic watchdog passes in the HTTP request via STDIN and reads a HTTP response via STDOUT.
- The _http mode_ of the [of-watchdog](https://github.com/openfaas/of-watchdog) provides more control over your HTTP responses ("hot functions", persistent connection pools, or caching).

The of-watchdog _http mode_ loads the handler as a small background web server.
The classic watchdog's forking mode would instead load this file for every invocation creating additional latency when loading packages, saved data, or trained models.

### Server framework (for of-watchdog only)

Frameworks are listed in the order of their dependence relationships:

- [httpuv](https://CRAN.R-project.org/package=httpuv)
  - [plumber](https://www.rplumber.io/)
  - [fiery](https://CRAN.R-project.org/package=fiery)
  - [beakr](https://CRAN.R-project.org/package=beakr)
  - [ambiorix](https://ambiorix.john-coene.com/)

More server frameworks are being explored, such as the 
[Rserve](https://www.rforge.net/Rserve/) based [RestRserve](https://restrserve.org/),
or the httpuv based [opencpu](https://www.opencpu.org/).
See [**ROADMAP**](https://github.com/analythium/openfaas-rstats-templates/issues/19) for details. **PRs are welcome!**

## Usage

### Setup

It is recommended to read the [OpenFaaS docs](https://docs.openfaas.com/) first
and set up a local or remote [Kubernetes cluster](https://docs.openfaas.com/deployment/kubernetes/) or [faasd](https://docs.openfaas.com/deployment/faasd/) with
OpenFaaS deployed. To get going quickly,
follow the official OpenFaaS [workshop](https://docs.openfaas.com/tutorials/workshop/),
read the book [Serverless For Everyone Else](https://gumroad.com/l/serverless-for-everyone-else) by Alex Ellis, or enroll into the free
[Introduction to Serverless on Kubernetes](https://www.edx.org/course/introduction-to-serverless-on-kubernetes) course.

See recommended [setup steps](https://github.com/analythium/openfaas-rstats-examples) for the R template examples.

### Make a new function

Use the [`faas-cli`](https://github.com/openfaas/faas-cli) and pull R templates:

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Now `faas-cli new --list` should give you a list with the available `rstats-*` templates.

Create a new function called `hello-rstats`:

```bash
export OPENFAAS_PREFIX="" # Populate with your Docker Hub username
faas-cli new --lang rstats-base hello-rstats --prefix=$OPENFAAS_PREFIX
```

the `OPENFAAS_PREFIX` means a user or organization on e.g. Docker Hub where
you have push privileges; don't forget to log in to your registry using `docker login`.

Your folder now should contain the following:

```bash
hello-rstats/handler.R
hello-rstats/DESCRIPTION
hello-rstats.yml
```

The `hello-rstats/handler.R` file does the heavy lifting by executing the desired
functionality. `hello-rstats/DESCRIPTION` lists the dependencies for the handler.
The `hello-rstats.yml` is the stack file used to configure functions
(read more [here](https://docs.openfaas.com/reference/yaml/)).

You can build, push, and deploy the `hello-rstats` function using:

```bash
faas-cli up -f hello-rstats.yml
```

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

Once the function is deployed, you can test it in the UI
(e.g. at `OPENFAAS_URL/ui/`) or using curl:

```bash
curl $OPENFAAS_URL/function/hello-rstats -d '["World"]'
```

Both should give the JSON output `"Hello World!"`.

### Customize your function

You can now edit `hello-rstats/handler.R` to your liking.
Don't forget to add dependencies to the `hello-rstats/DESCRIPTION` file.

See [worked examples](https://github.com/analythium/openfaas-rstats-examples) for different use cases.
Read more about the [structure of the templates](template/README.md) if advanced tuning is required, e.g. by editing the `Dockerfile`, etc.

The template installs dependencies specified in the `DESCRIPTION` file
in this order:

1. `SystemRequirements:` list OS specific system requirements here, comma separated, these are then installed by the OS's package manager,
2. CRAN packages listed in `Depends:`, `Imports:`, `LinkingTo:` fields are installed by `remotes::install_deps()`,
3. `Remotes:` fields are installed according to [remotes](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) specifications, make sure to list the package in `Imports:` as well, the location specified in `Remotes:` will be used to get the package from,
4. `VersionedPackages:` this field can be used to pin package versions using `remotes::install_version()`, do not list these packages in other fields (spaces after operators and after commas inside parentheses are important, e.g. `devtools (1.11.0), mypackage (>= 1.12.0, < 1.14)`).

You can also modify the `Dockerfile` in the template if specific
R version or further customization is needed. The R parent image is defined as a Docker `ARG` called `R_IMAGE`that you can override. I.e. use the versioned Rocker Debian image using [custom build arguments](https://docs.openfaas.com/cli/build/#30-pass-custom-build-arguments):

```bash
faas-cli new --lang rstats-base-plumber hello-rstats-2 --prefix=$OPENFAAS_PREFIX

faas-cli build -f hello-rstats-2.yml --build-arg R_IMAGE=rocker/r-base:4.0.0
```

You can also edit the [stack YAML file](https://docs.openfaas.com/reference/yaml/#function-build-args-build-args):

```yaml
...
functions:
  hello-rstats-2:
    lang: rstats-base-plumber
...
    build_args:
      R_IMAGE: rocker/r-base:4.0.0
```

System requirements for the same package might be different across
Linux distributions. This is a grey area of the R package ecosystem, see these links for help:

- [rstudio/r-system-requirements](https://github.com/rstudio/r-system-requirements)
- [r-hub/sysreqsdb](https://github.com/r-hub/sysreqsdb)
- [r-universe/](https://r-universe.dev/)
- [maketools](https://cran.r-project.org/web/packages/maketools/vignettes/sysdeps.html) to determine run-time and build-time dependencies

## Contributing

Please read the [code of conduct](CODE_OF_CONDUCT.md).
[DCO](https://en.wikipedia.org/wiki/Developer_Certificate_of_Origin) is required,
sign commits that are submitted as PR (`git commit -s -m "Commit message"`).

## License

Copyright (c) 2020, Peter Solymos, Analythium Solutions Inc. [MIT](LICENSE.md)
