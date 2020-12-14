# R/opencpu template for OpenFaaS with of-watchdog

> Sends and receives JSON using [opencpu](https://www.opencpu.org/)
> and [of-watchdog](https://github.com/openfaas/of-watchdog).

This template uses the rocker/r-ubuntu:18.04 image.

This microservice based on OpenCPU runs fine with of-watchdog.
The GET requests are great for installed packages and data sets,
the POST requests are quite useless given the stateless nature of OpenFaaS
architecture.
This will only be useful if `opencpu/user.conf` can be set to write
session objects to the common `/tmp` folder shared across the instances.

```
faas-cli new --lang rstats-ubuntu-opencpu r-opencpu --prefix=dockeruser
```

Up:

```bash
faas-cli up -f r-opencpu.yml
```

## Test

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-opencpu
```

The OpenCPU endpoints are not defined in the `handler.R` file,
but are defined through existing packages using the [OpenCPU API](https://www.opencpu.org/api.html).
Note: because OpenFaaS functions are stateless, we cannot really take advantage of the session API.

```bash
# session info
curl http://localhost:4000/info
# list function in the MASS package
curl http://localhost:4000/library/MASS/R
curl http://localhost:4000/library/MASS/R/rlm/print
# package data objects
curl http://localhost:4000/library/MASS/data/housing/json
curl 'http://localhost:4000/library/datasets/R/mtcars/tab?sep="|"'
# manual pages
curl http://localhost:4000/library/MASS/man/rlm/text

# run R script
curl http://localhost:4000/library/MASS/scripts/ch01.R -X POST
# ... can't access the session outputs

# call a function: always getting argument x missing with no default...
curl http://localhost:4000/library/base/R/mean -H \
  "Content-Type: application/json" -d \
  '{"x":[1,0,0,1,1,1,0,1,1,0]}'
# ... can't access the session outputs
```

JSON I/O RPC (a.k.a. Data Processing Units)

For the common special case where a client is only interested in the output data from a function call in JSON format, the HTTP POST request url can be post-fixed with /json. In this case, a successfull call will return status 200 (instead of 201), and the response body directly contains the returned object in JSON; no need for an additional GET request.

```
curl http://localhost:4000/library/stats/R/rnorm/json -d n=2

curl http://localhost:4000/library/stats/R/rnorm/json \
-H 'Content-Type: application/json' -d '{"n":3, "mean": 10, "sd":10}'
```

This is not working as is.
