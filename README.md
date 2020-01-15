# R/rstats templates for OpenFaaS

This project provides [OpenFaaS](https://www.openfaas.com/)
templates for the [R](https://www.r-project.org/) language.

## Contents

- `/docker-images`: [Docker](https://www.docker.com) images used by the templates (from [rocker]() images with [{remotes}](https://CRAN.R-project.org/package=remotes) and other packages preinstalled)
- `/examples`: various examples using, e.g. the [{httpuv}](https://CRAN.R-project.org/package=httpuv) based template or a [{plumber}](https://CRAN.R-project.org/package=plumber) microservice exposing multiple endpoints
- `/template`: `rstats` and `rstats-http` templates with [classic](https://github.com/openfaas/faas/tree/master/watchdog) and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog)

## Details

The `install.R` installs dependencies as specified in
`PACKAGES`, one dependency per line, separator is new line.
[CRAN](https://cran.r-project.org/) packages can be specified by their `name`s, or as `name@version`.
Remotes can be defined according to specs in the
[{remotes}](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) package.
Base Docker images for R are from the [rocker](https://github.com/rocker-org) project.

## Resources

The templates were inspired by and built on these resources:

- https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R
- https://medium.com/@beanies/serverless-r-functions-with-openfaas-1cd34905834d
- https://github.com/openfaas/templates/tree/master/template/python3
- https://github.com/openfaas-incubator/of-watchdog#1-http-modehttp
