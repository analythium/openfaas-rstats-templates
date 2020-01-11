# R/plumber API template for OpenFaaS with of-watchdog

Sends and receives JSON using [{plumber}](https://www.rplumber.io/)
and [of-watchdog](https://github.com/openfaas-incubator/of-watchdog).

https://www.openfaas.com/blog/golang-serverless/#new-service-using-a-dockerfile

Testing: won't work in UI, use curl to test the endpoints

```
# simple hello
curl http://localhost:8080/function/<function-name>/

# random numbers
curl http://localhost:8080/function/<function-name>/rnorm -H \
    "Content-Type: application/json" -d \
    '{"n":[10],"mean":[2],"sd":[2]}'

# principal components
curl http://localhost:8080/function/<function-name>/prcomp -H \
  "Content-Type: application/json" -d \
  '[[1,4,7,10],[2,5,8,11],[3,6,9,12]]'

# use the test.csv file in this directory
curl -X POST -H 'Content-Type: text/csv' \
  --data-binary @test.csv \
  http://localhost:8080/function/<function-name>/upload
```
