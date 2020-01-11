# R/plumber template for OpenFaaS with of-watchdog

Sends and receives JSON using [{plumber}](https://www.rplumber.io/)
and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

Testing: use the UI or curl (should give `["Hello Friend!"]`)

```
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
```
