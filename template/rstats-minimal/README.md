# R template for OpenFaaS with classic watchdog based on rhub/r-minimal

> Sends and receives JSON using
> [classic watchdog](https://github.com/openfaas/classic-watchdog).

This template uses the rhub/r-minimal:latest image.

## Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Use the `rstats-minimal` function template and
create a new function called `r-minimal-hello`; prefix the `dockeruser` to the
docker image tag (i.e. `dockeruser/r-minimal-hello` will be the image name):

```bash
faas-cli new --lang rstats-minimal r-minimal-hello --prefix=dockeruser
```

## Customizing your function

Now we have a `r-minimal-hello.yml` file and function folder `./r-minimal-hello`.
Files in the function folder will get copied to the `/home/app` directory of the image.
Read more about the [YAML configuration](https://docs.openfaas.com/reference/yaml/).
Customize the `./r-minimal-hello/handler.R` file as needed:

- load required packages using `library()`,
- put your data in the folder and load it relative to the function folder (e.g. `data.RData`) or use the full path (e.g. `/home/app/data.csv`),
- define the output given the input of the `handle` function, the output must be JSON parsable,
- add packages/remotes/system requirements and optionally metadata to the `DESCRIPTION` file.

## Build, push, and deploy

The `up` command includes `build` (build an image into the local Docker library)
`push` (push that image to a remote container registry),
and `deploy` (deploy your function into a cluster):

```bash
faas-cli up -f r-minimal-hello.yml
```

Now you should see something like this:

```bash
[0] > Building r-minimal-hello.
...
[0] < Building r-minimal-hello done in 10.97s.
[0] Worker done.

Total build time: 0.97s

[0] > Pushing r-minimal-hello [dockeruser/r-minimal-hello:latest].
...
[0] < Pushing r-minimal-hello [dockeruser/r-minimal-hello:latest] done.
[0] Worker done.

Deploying: r-minimal-hello.
WARNING! Communication is not secure, please consider using HTTPS. Letsencrypt.org offers free SSL/TLS certificates.

Deployed. 202 Accepted.
URL: http://IP_ADDRESS:8080/function/r-minimal-hello.openfaas-fn

```

## Testing

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-minimal-hello
```

Curl should return `["Hello Friend!"]`:

```bash
curl http://localhost:4000/ -d '["Friend"]'
# ["Hello Friend!"]
```

The log looks like this:

```vim
2020/12/12 04:25:18 Version: 0.20.1     SHA: 7b6cc60bd9865852cd11c98d4420752815052918
2020/12/12 04:25:18 Timeouts: read: 5s, write: 5s hard: 0s.
2020/12/12 04:25:18 Listening on port: 8080
2020/12/12 04:25:18 Metrics listening on port: 8081
2020/12/12 04:25:18 Writing lock-file to: /tmp/.lock
2020/12/12 04:27:56 Forking fprocess.
2020/12/12 04:27:56 Wrote 18 Bytes - Duration: 0.335202s
...
```

Use the OpenFaaS UI or curl (should give `["Hello Friend!"]`).
Replace `localhost` with IP address if testing on remote location:

```bash
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
# ["Hello Friend!"]
```

## Example: PCA

Create a new function:
```bash
faas-cli new --lang rstats-minimal r-minimal-pca --prefix=dockeruser
```

Change `handler.R`:

```R
suppressMessages(library(vegan))
handle <- function(req) {
    scores(rda(req), 1:2)$sites
}
```

Edit `DESCRIPTION`:

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  vegan
Remotes:
SystemRequirements:
  gcc,
  musl-dev,
  gfortran
VersionedPackages:
```

Build the image: `faas-cli build -f r-minimal-pca.yml` and
test with `docker run -p 4000:8080 dockeruser/r-minimal-pca` and

```bash
curl http://localhost:4000/ -H \
  "Content-Type: application/json" -d \
  '[[-1,3,16],[10,-10,9],[-5,10,-14],[14,3,-12]]'
# [[2.9545,3.042],[2.7754,-2.5023],[-3.4647,2.7223],[-2.2652,-3.262]]
```
