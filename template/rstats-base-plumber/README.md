# R/plumber template for OpenFaaS with of-watchdog

> Sends and receives JSON using [{plumber}](https://www.rplumber.io/)
> and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

### Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-http <function-name> --prefix="<docker-user>"
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
