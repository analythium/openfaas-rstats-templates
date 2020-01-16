# R (rstats) templates for OpenFaaS

This directory contains the `rstats` and `rstats-http` templates with [classic](https://github.com/openfaas/faas/tree/master/watchdog) and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

## Structure

The templates follow similar structure:

- `./template.yml`: this file specifies the language for the template and the init process for your container
- `./Dockerfile`: the container is based on this file, edit as needed when adding system requirements for R packages
- `./index.R`: this is the R entry point receiving and outputting the request
- `./PACKAGES`: R package dependencies for the entry point
- `./install.R`: this script installs the packages listed in the `PACKAGES` file
- `./function/handler.R`: R handler
- `./function/PACKAGES`: R package dependencies for the handler

## Dependencies

The `install.R` script installs dependencies as specified in the
`PACKAGES` file: one dependency per line, separator is new line.
[CRAN](https://cran.r-project.org/) packages can be specified by
their `name`s, or as `name@version`.
Remotes can be defined according to specs in the
[{remotes}](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) package.
This includes GitHub, GitLab, Bitbucket etc.

You might also have to add system dependencies to the `Dockerfile`.
This is a grey area of the R package ecosystem, see some helpful pointers
[here](https://github.com/rstudio/r-system-requirements).
The templates are using the Debian-based `rocker/r-base` Docker image from the
[rocker](https://github.com/rocker-org) project.
