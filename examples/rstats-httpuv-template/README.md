# R/httpuv template for OpenFaaS with of-watchdog

Sends and receives JSON using [httpuv](https://CRAN.R-project.org/package=httpuv)
and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

Testing: use the UI or curl (should give `["Hello Friend!"]`)

```
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
```

Note: the use of the `rstats-http` template based on [{plumber}](https://www.rplumber.io/)
is preferred. It does not add significant overhead, but it provides a better documented interface.
