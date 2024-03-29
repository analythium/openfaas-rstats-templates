# R (rstats) templates for OpenFaaS

This directory contains the _stable_ OpenFaaS R templates.

## Template structure

The templates follow a similar structure:

```tree
.
├── Dockerfile
├── README.md
├── Rprofile.site
├── function
│   ├── DESCRIPTION
│   └── handler.R
├── index.R
├── install.R
└── template.yml
```

- `./Dockerfile`: the container is based on this file,
- `./README.md`: description and examples for the template,
- `./Rprofile.site`: R startup options, e.g. repositories, etc.,
- `./function/DESCRIPTION`: R package dependencies for the handler to be edited by the user,
- `./function/handler.R`: R handler to be edited by the user,
- `./index.R`: this is the R entry point receiving the request and outputting the response,
- `./install.R`: utility function used to handle dependencies in the `Dockerfile`,
- `./template.yml`: stack file specifying the language for the template and the init process for your container, see the [YAML reference](https://docs.openfaas.com/reference/yaml/) for additional details.

The files the users are supposed to edit are inside the function folder,
users might put other files here that will be copied into the `/home/app`
folder of the Docker image. The handler file _usually_ contains a function called
`handler` that the `index.R` entry point calls. See the template readme file
for specific instructions.

## Dependencies

The `Dockerfile` install script handles dependencies as specified in the
`DESCRIPTION` file in this order:

1. `SystemRequirements:` list OS specific sysreqs here, comma separated, these are then installed by the OS's package manager,
2. CRAN packages listed in `Depends:`, `Imports:`, `LinkingTo:` fields are installed by `remotes::install_deps()`,
3. `Remotes:` fields are installed according to [remotes](https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html) specs, make sure to list the package in `Imports:` as well, the location specified in `Remotes:` will be used to get the package from,
4. `VersionedPackages:` this field can be used to pin package versions using `remotes::install_version()`, do not list these packages in other fields (spaces after operators and commas inside parenthesis are important).

An example `DESCRIPTION` file might look like this:

```yaml
Package: OpenFaaS
Version: 0.0.1
Imports:
  jsonlite,
  vegan
Remotes:
  vegandevs/vegan
SystemRequirements:
  git-core,
  libssl-dev,
  libcurl4-gnutls-dev
VersionedPackages:
  devtools (>= 1.12.0, < 1.14),
  mypackage (0.1.0)
```

You can also modify the `Dockerfile` in the template if specific
R version or further customization is needed. The R parent image is defined as a Docker `ARG` called `R_IMAGE`that you can override. I.e. use the versioned Rocker Debian image using [custom build arguments](https://docs.openfaas.com/cli/build/#30-pass-custom-build-arguments): `--build-arg R_IMAGE=rocker/r-base:4.0.0`, etc. You can also edit the [stack YAML file](https://docs.openfaas.com/reference/yaml/#function-build-args-build-args).

The templates are using the following parent images:

- Debian-based `rocker/r-base` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-base) project for bleeding edge,
- Ubuntu-based `rocker/r-ubuntu` Docker image from the [rocker](https://github.com/rocker-org/rocker/tree/master/r-ubuntu) project for long term support (uses [RSPM](https://packagemanager.rstudio.com/client/) binaries),
- Alpine-based `rhub/r-minimal` Docker image the [r-hub](https://github.com/r-hub/r-minimal) project for smallest image sizes.

System requirements for the same packages might be different across
Linux distros. This is a grey area of the R package ecosystem, see
[rstudio/r-system-requirements](https://github.com/rstudio/r-system-requirements),
[r-hub/sysreqsdb](https://github.com/r-hub/sysreqsdb),
and [https://r-universe.dev/](https://r-universe.dev/) for help. The [maketools](https://cran.r-project.org/web/packages/maketools/vignettes/sysdeps.html) R package makes it easy to determine run-time and build-time dependencies for the packages.
