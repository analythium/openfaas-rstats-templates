# R template for OpenFaaS with classic watchdog based on rocker/r-base

> Sends and receives JSON using
> [classic watchdog](https://github.com/openfaas/classic-watchdog).

### Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-base <function-name> --prefix="<docker-user>"
```

### Customizing your function

* edit `./<function-name>/function/handler.R`
* edit `./Dockerfile` if specific base image or R version is needed
* add dependencies to `./DESCRIPTION`
  - CRAN packages listed in `Depends:`, `Imports:`, `LinkingTo:` fields are installed by `remotes::install_deps()`
  - `Remotes:` fields are installed according to [remotes](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) specs
  - `SystemRequirements:` are saved and installed, check https://github.com/rstudio/r-system-requirements and https://github.com/r-hub/sysreqsdb
  - `VersionedPackages:` field can be used to pin package versions using `remotes::install_version()`
### Build, push, and deploy

```bash
faas-cli up -f <function-name>.yml
```

## Testing

Use the UI or curl (should give `["Hello Friend!"]`)

```
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
# ["Hello Friend!"]
```
