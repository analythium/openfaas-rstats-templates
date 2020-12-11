# R (rstats) templates for OpenFaaS

This directory contains the `rstats` and `rstats-http` templates with [classic](https://github.com/openfaas/faas/tree/master/watchdog) and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

## Structure

The templates follow similar structure:

- `./template.yml`: this file specifies the language for the template and the init process for your container
- `./Dockerfile`: the container is based on this file, edit as needed when adding system requirements for R packages
- `./index.R`: this is the R entry point receiving and outputting the request
- `./DESCRIPTION`: R package dependencies for the entry point and handler
- `./function/handler.R`: R handler

## Dependencies

The `Dockerfile` install script handles dependencies as specified in the
`DESCRIPTION` file:

- CRAN packages listed in `Depends:`, `Imports:`, `LinkingTo:` fields are installed by `remotes::install_deps()`
- `Remotes:` fields are installed according to [remotes](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) specs
- `SystemRequirements:` are saved and installed
- `VersionedPackages:` field can be used to pin package versions using `remotes::install_version()`

For example:

```bash
Package: OpenFaaS
Version: 0.0.1
Imports:
  jsonlite
Remotes: psolymos/pbapply
SystemRequirements:
  git-core,
  libssl-dev,
  libcurl4-gnutls-dev
VersionedPackages:
  devtools (>= 1.12.0, < 1.14)
```

You might also have to meddle with the `Dockerfile` if specific
R version or further customization is needed.
The templates are using the following base images:

- Debian-based `rocker/r-base` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-base) project for bleeding edge
- Ubuntu-based `rocker/r-ubuntu` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-ubuntu) project for long term support
- Alpine-based `rhub/r-minimal` Docker image the [rr-hub](https://github.com/r-hub/r-minimal) project for smallest image sizes

System requirements for the same packages might also be different across
Linux distros. This is a grey area of the R package ecosystem, see
[rstudio/r-system-requirements](https://github.com/rstudio/r-system-requirements)
and [r-hub/sysreqsdb](https://github.com/r-hub/sysreqsdb) for help.
