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
- add system dependencies to `./function/SYSTEMDEPS`
- add dependencies to `./function/PACKAGES`

installr -t option need to seperate SYSTEMDEPS file using as a openfaas template.

Template is also example with `data.table` and system dependoncy is that `zlib-dev`.

Plaaes add items with enter or space in PACKAGES and SYSTEMDEPS.

Please read [this](https://github.com/r-hub/r-minimal) for dependoncies.

There are lots of examples like dplyr, data.table.

### Build, push, and deploy

```bash
faas-cli up -f <function-name>.yml
```

## Testing

Use the UI or curl (should give `["Friend"]`)

```r
library(httr)
library(jsonlite)
library(magrittr)
"http://localhost:8080/function/<function-name>" %>% 
  POST(body = toJSON("test"), encode = "json") %>% 
  content()
  
"http://localhost:8080/function/<function-name>" %>% 
  POST(body = list(name = "test"), encode = "json") %>% 
  content()
```

```
curl http://localhost:8080/function/<function-name> -d '[{"return":"Hello Friend!"}]'
```