# R (rstats) templates for OpenFaaS

> This project provides [OpenFaaS](https://www.openfaas.com/)
> templates for the [R](https://www.r-project.org/) language.

## Contents

- `/docker-images`: [Docker](https://www.docker.com) images used by the templates (from [rocker]() images with [{remotes}](https://CRAN.R-project.org/package=remotes) and other packages preinstalled)
- `/examples`: various examples using, e.g. the [{httpuv}](https://CRAN.R-project.org/package=httpuv) based template or a [{plumber}](https://CRAN.R-project.org/package=plumber) microservice exposing multiple endpoints
- `/template`: `rstats` and `rstats-http` templates with [classic](https://github.com/openfaas/faas/tree/master/watchdog) and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog)

## Usage

### Setup

It is recommended to read the [OpenFaaS docs](https://docs.openfaas.com/) first and set up
Kubernetes or Docker Swarm and deploy OpenFaaS
(see docs [here](https://docs.openfaas.com/deployment/)).
Follow the official OpenFaaS workshop [here](https://docs.openfaas.com/tutorials/workshop/)
to get going quickly.

### Make a new function

Use the [`faas-cli`](https://github.com/openfaas/faas-cli) and pull R templates:

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Now `faas-cli new --list` should give you a list with `rstats` and `rstats-http` among
the templates.

Let's create a new function called `hello-rstats`:

```bash
faas-cli new --lang rstats-http hello-rstats --prefix="<docker-user>"
```

the `<docker-user>` means a user or organization on e.g. Docker Hub where
you have push privileges; don't forget to log in to the registry using `docker login`.

You can build, push, and deploy the `hello-rstats` function using:

```bash
faas-cli up -f hello-rstats.yml
```

Once the function is deployed, you can test it in the UI (at http://localhost:8080/ui/)
or using curl:

```
curl http://localhost:8080/function/hello-rstats -d '["Friend"]'
```

Both should should give the JSON output `["Hello Friend!"]`.

### Customize your function

You can now edit `./hello-rstats/function/handler.R` to your liking.
Don't forget to add dependencies to `./hello-rstats/function/PACKAGES` file.

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

### Classic or of-watchdog

The `rstats` template uses the classic watchdog.
The [watchdog](https://github.com/openfaas/faas/tree/master/watchdog)
is a tiny Golang webserver that marshals an HTTP request accepted on the API Gateway
and to invoke your chosen application.
This is the init process for your container.
The classic watchdog passes in the HTTP request
via `stdin` and reads a HTTP response via `stdout`.

The _http mode_ of the new [of-watchdog](https://github.com/openfaas-incubator/of-watchdog)
provides more control over your HTTP responses ("hot functions", persistent connection pools,
or caching). This is what the `rstats-http` template is using.

## Resources

The templates were inspired by and built on these resources:

- https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R
- https://medium.com/@beanies/serverless-r-functions-with-openfaas-1cd34905834d
- https://github.com/openfaas/templates/tree/master/template/python3
- https://github.com/openfaas-incubator/of-watchdog#1-http-modehttp
