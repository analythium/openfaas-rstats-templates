# R/rstats templates for OpenFaaS

This project provides [OpenFaaS](https://www.openfaas.com/)
templates for the [R](https://www.r-project.org/) language.

## Contents

- `/docker-images`: Docker images used by the templates (from `rocker/r-base` with remotes and plumber preinstalled)
- `rstats-plumber-api`: plumber API with of-watchdog
- `/template`: `rstats` and `rstats-http` templates with classic and of-watchdog

## Details

The `install.R` installs dependencies as specified in
`requirements.txt`, one dependency per line, separator is new line.
[CRAN](https://cran.r-project.org/) packages can be specified by their `name`s, or as `name@version`.
Remotes can be defined according to specs in the
[remotes](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) package.
Base Docker images for R are from the [rocker](https://github.com/rocker-org/rocker) project.

## Resources

The templates were inspired by and built on these resources:

- https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R
- https://medium.com/@beanies/serverless-r-functions-with-openfaas-1cd34905834d
- https://github.com/openfaas/templates/tree/master/template/python3
- https://github.com/openfaas-incubator/of-watchdog#1-http-modehttp

## TODO

- [x] maintain images with remotes+plumber and few utils added
- [ ] add `ARG ADDITIONAL_PACKAGE` functionality for system deps: https://docs.openfaas.com/reference/yaml/
- [ ] add versioning to images
- [ ] possibly write an R package to replace install.R
- [ ] move workdir to `/home/app` and use non-root user
- [x] add curl based test (see https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R)
- [ ] explore static version for rmarkdown/bookdown/knitr generated html
