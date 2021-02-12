# R/ambiorix template for OpenFaaS with of-watchdog

> Sends and receives JSON using [ambiorix](https://CRAN.R-project.org/package=ambiorix)
> and [of-watchdog](https://github.com/openfaas/of-watchdog).

This template uses the rhub/r-minimal:latest image.

## Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-minimal-ambiorix r-minimal-ambiorix-hello --prefix=dockeruser
```

## Customizing your function

Now we have a `r-minimal-ambiorix-hello.yml` file and function folder `./r-minimal-ambiorix-hello`.
Files in the function folder will get copied to the `/home/app` directory of the image.
Read more about the [YAML configuration](https://docs.openfaas.com/reference/yaml/).
Customize the `./r-minimal-ambiorix-hello/handler.R` file as needed:

- load required packages using `library()`,
- put your data in the folder and load it relative to the function folder (e.g. `data.RData`) or use the full path (e.g. `/home/app/data.csv`),
- define the output given the input of the `handle` function, the output must be JSON parsable,
- add packages/remotes/system requirements and optionally metadata to the `DESCRIPTION` file.

## Build, push, and deploy

The `up` command includes `build` (build an image into the local Docker library)
`push` (push that image to a remote container registry),
and `deploy` (deploy your function into a cluster):

```bash
faas-cli up -f r-minimal-ambiorix-hello.yml
```

## Testing

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-minimal-ambiorix-hello
```

Curl should return `["Hello Friend!"]`:

```bash
curl http://localhost:4000 -H 'Content-Type: application/json' -d '["Friend"]'
# ["Hello Friend!"]
```

Use the OpenFaaS UI or curl (should give `["Hello Friend!"]`).
Replace `localhost` with IP address if testing on remote location:

```bash
curl http://localhost:8080/function/<function-name> -d '["Friend"]'
# ["Hello Friend!"]
```

