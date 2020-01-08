# R template for OpenFaaS with classic watchdog

Sends and receives JSON using
[classic watchdog](https://github.com/openfaas/faas/tree/master/watchdog).

Testing: use the UI or curl (should give `["Hello Friend!"]`)

```
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
```
