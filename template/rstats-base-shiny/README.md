# R/shiny template for OpenFaaS with of-watchdog

> Sends and receives JSON using [shiny](https://shiny.rstudio.com/)
> and [of-watchdog](https://github.com/openfaas/of-watchdog).

This template uses the rocker/r-base:latest image.

## Making a new function

Use the `faas-cli` and pull R templates

```bash
faas-cli template pull https://github.com/analythium/openfaas-rstats-templates
```

Create a new function

```bash
faas-cli new --lang rstats-base-shiny r-base-shiny-hello --prefix=dockeruser
```

## Customizing your function

Now we have a `r-base-shiny-hello.yml` file and function folder `./r-base-shiny-hello`.
Files in the function folder will get copied to the `/home/app` directory of the image.
Read more about the [YAML configuration](https://docs.openfaas.com/reference/yaml/).
Customize the files in the `./r-base-shiny-hello` folder as needed
(will be copied into `/home/app`):

- load required packages data sets, global function definitions into `globel.R`,
- add your UI to `ui.R`,
- add the server function to `server.R`, any other folder/file,
- add packages/remotes/system requirements and optionally metadata to the `DESCRIPTION` file.

## Build, push, and deploy

The `up` command includes `build` (build an image into the local Docker library)
`push` (push that image to a remote container registry),
and `deploy` (deploy your function into a cluster):

```bash
faas-cli up -f r-base-shiny-hello.yml
```

## Testing

Test the local Docker image forwarding to port 4000

```bash
docker run -p 4000:8080 dockeruser/r-base-shiny-hello
```

No check `http://localhost:4000/`
