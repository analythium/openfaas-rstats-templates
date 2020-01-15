# R/plumber API template for OpenFaaS with of-watchdog

> Sends and receives JSON using [{plumber}](https://www.rplumber.io/)
> and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

Setup is documented [here](https://www.openfaas.com/blog/golang-serverless/#new-service-using-a-dockerfile).

```bash
faas-cli new --lang dockerfile rstats-http-api --prefix="<docker-user>"
```

Copy contents of this directory into the newly created `./rstats-http-api` folder
overwriting the `Dockerfile`.

```bash
faas-cli up -f rstats-http-api.yml
```

## Testing

Won't work in UI, use curl to test the endpoints

```
# simple hello
curl http://localhost:8080/function/rstats-http-api/

# random numbers
curl http://localhost:8080/function/rstats-http-api/rnorm -H \
    "Content-Type: application/json" -d \
    '{"n":[10],"mean":[2],"sd":[2]}'

# principal components
curl http://localhost:8080/function/rstats-http-api/prcomp -H \
  "Content-Type: application/json" -d \
  '[[1,4,7,10],[2,5,8,11],[3,6,9,12]]'

# use the test.csv file in this directory
curl -X POST -H 'Content-Type: text/csv' \
  --data-binary @rstats-http-api/test.csv \
  http://localhost:8080/function/rstats-http-api/upload
```
