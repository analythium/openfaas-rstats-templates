# R template for OpenFaaS with classic watchdog based on rocker/r-ubuntu

> Sends and receives JSON using
> [classic watchdog](https://github.com/openfaas/classic-watchdog).

This template uses the rocker/r-ubuntu:18.04 image and
the repos option to Ubuntu bionic via [RSPM](https://packagemanager.rstudio.com).

## Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Use the `rstats-ubuntu` function template and
create a new function called `r-ubuntu-hello`; prefix the `dockeruser` to the
docker image tag (i.e. `dockeruser/r-ubuntu-hello` will be the image name):

```bash
faas-cli new --lang rstats-ubuntu r-ubuntu-hello --prefix=dockeruser
```

## Customizing your function

Now we have a `r-ubuntu-hello.yml` file and function folder `./r-ubuntu-hello`.
Files in the function folder will get copied to the `/home/app` directory of the image.
Read more about the [YAML configuration](https://docs.openfaas.com/reference/yaml/).
Customize the `./r-ubuntu-hello/handler.R` file as needed:

- load required packages using `library()`,
- put your data in the folder and load it relative to the function folder (e.g. `data.RData`) or use the full path (e.g. `/home/app/data.csv`),
- define the output given the input of the `handle` function, the output must be JSON parsable,
- add packages/remotes/system requirements and optionally metadata to the `DESCRIPTION` file.

## Build, push, and deploy

The `up` command includes `build` (build an image into the local Docker library)
`push` (push that image to a remote container registry),
and `deploy` (deploy your function into a cluster):

```bash
faas-cli up -f r-ubuntu-hello.yml
```

Now you should see something like this:

```bash
[0] > Building r-ubuntu-hello.
...
[0] < Building r-ubuntu-hello done in 10.97s.
[0] Worker done.

Total build time: 0.97s

[0] > Pushing r-ubuntu-hello [dockeruser/r-ubuntu-hello:latest].
...
[0] < Pushing r-ubuntu-hello [dockeruser/r-ubuntu-hello:latest] done.
[0] Worker done.

Deploying: r-ubuntu-hello.
WARNING! Communication is not secure, please consider using HTTPS. Letsencrypt.org offers free SSL/TLS certificates.

Deployed. 202 Accepted.
URL: http://IP_ADDRESS:8080/function/r-ubuntu-hello.openfaas-fn

```

## Testing

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-ubuntu-hello
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
