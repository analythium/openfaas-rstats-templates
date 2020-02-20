# R-minimal template for OpenFaaS with classic watchdog

> Sends and receives JSON using
> [classic watchdog](https://github.com/openfaas/faas/tree/master/watchdog).

### R-minimal introduce

R-miniaml use `r-hub/r-minimal` docker image as base instead of `rocker/r-base`.

![](https://user-images.githubusercontent.com/6179259/74970476-c57bb080-5461-11ea-9135-f2b6af97139b.png)

### Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-minimal <function-name> --prefix="<docker-user>"
```

### Customizing your function

- edit `./<function-name>/function/handler.R`
- add dependencies to `./PACKAGES`
- possibly add system dependencies to the `Dockerfile`

### Build, push, and deploy

```bash
faas-cli up -f <function-name>.yml
```

## Testing

Use the UI or curl (should give `["Hello Friend!"]`)

```
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
```
