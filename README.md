# R (rstats) templates for OpenFaaS

> This project provides [OpenFaaS](https://www.openfaas.com/)
> templates for the [R](https://www.r-project.org/) language.

The `/template` folder contains the following OpenFaaS templates:

- `rstats` with [classic watchdog](https://github.com/openfaas/faas/tree/master/watchdog)
- `rstats-http` [of-watchdog](https://github.com/openfaas-incubator/of-watchdog)

The [watchdog](https://github.com/openfaas/faas/tree/master/watchdog)
is a tiny Golang webserver that marshals an HTTP request accepted on the API Gateway
and to invoke your chosen application.
This is the init process for your container.
The classic watchdog passes in the HTTP request
via `stdin` and reads a HTTP response via `stdout`.

The _http mode_ of the new [of-watchdog](https://github.com/openfaas-incubator/of-watchdog)
provides more control over your HTTP responses ("hot functions", persistent connection pools,
or caching). This is what the `rstats-http` template is using.

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

Your folder now should contain the following:

```bash
hello-rstats/handler.R
hello-rstats/PACKAGES
hello-rstats.yml
```

The `handler.R` file does the heavy lifting by executing the desired
functionality. `PACKAGES` describes the dependencies.
The `hello-rstats.yml` is the stack file used to configure functions
(read more [here](https://docs.openfaas.com/reference/yaml/)).

You can build, push, and deploy the `hello-rstats` function using:

```bash
faas-cli up -f hello-rstats.yml
```

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

Once the function is deployed, you can test it in the UI (at http://localhost:8080/ui/)
or using curl:

```bash
curl http://localhost:8080/function/hello-rstats -d '["Friend"]'
```

Both should should give the JSON output `["Hello Friend!"]`.

### Customize your function

You can now edit `./hello-rstats/handler.R` to your liking.
Don't forget to add dependencies to `./hello-rstats/PACKAGES` file.

For example, calculate principal components
based on an input data array using the
[{vegan}](https://CRAN.R-project.org/package=vegan) R package.

The `./hello-rstats/handler.R` file should look like this:

```bash
handle <- function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  vegan::rda(x)$CA$u
}
```

Add the {vegan} package to the `./hello-rstats/PACKAGES` file, which now
looks like this:

```bash
jsonlite
vegan
```

The template installs dependencies specified in the `PACKAGES` file:
one dependency per line, separator is new line.
[CRAN](https://cran.r-project.org/) packages can be specified by
their `name`s, or as `name@version`.
Remotes can be defined according to specs in the
[{remotes}](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html)
package. This includes GitHub, GitLab, Bitbucket etc.

You might also have to add system dependencies for your required packages.
This is a grey area of the R package ecosystem, see some helpful pointers
[here](https://github.com/rstudio/r-system-requirements)
(the templates are using the Debian-based `rocker/r-base` Docker image from the
[rocker](https://github.com/rocker-org) project).

System dependencies can be added as [build arguments](https://docs.openfaas.com/cli/build/#30-pass-custom-build-arguments) (see how to work with build options
[here](https://github.com/analythium/openfaas-rstats-templates/issues/10)):

```bash
faas-cli build -f hello-rstats.yml --build-arg ADDITIONAL_PACKAGE="git-core libssl-dev libcurl4-gnutls-dev"
```

After pushing and deploying the function,
we can test the either in the UI or with curl:

```bash
curl http://localhost:8080/function/hello-rstats -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]] '
```

Now you should see the JSON output
`[[0.5099,0.5251,-0.4629],[0.479,-0.4319,0.5779],[-0.598,0.4699,0.4143],[-0.391,-0.563,-0.5293]]`.

Note that the of-watchdog HTTP mode loads the handler as a
very small background web server. The classic watchdog's forking mode in
would instead load this file for every invocation creating additional latency
when loading packages or saved data or rained models.

## Resources

The templates were inspired by and built on these resources:

- https://github.com/openfaas/faas/tree/master/sample-functions/BaseFunctions/R
- https://medium.com/@beanies/serverless-r-functions-with-openfaas-1cd34905834d
- https://github.com/openfaas/templates/tree/master/template/python3
- https://github.com/openfaas-incubator/of-watchdog#1-http-modehttp
