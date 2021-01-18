# Image Generation

We will create a function that takes a JSON array of parameters and returns an math art image whose content depends on the input parameters. The math art is produced by the [mathart](https://github.com/marcusvolz/mathart) R package.

> You will learn how to render plot based on input parameters and send back a image file.

You'll need the prerequisites listed [here](https://github.com/analythium/openfaas-rstats-templates/tree/master/examples).

## Create a new function using a template

Create a new function called `r-image`.

```bash
faas-cli new --lang rstats-base-plumber r-image
```

## Customize the function

Edit the `./r-image/DESCRIPTION` file:

```yaml
Package: OpenFaaStR
Version: 0.0.1
Imports:
  ggplot2,
  dplyr
Remotes:
SystemRequirements:
VersionedPackages:
```

Change the `./r-image/handler.R` file.
Note: loading libraries is good practice, it makes trouble shooting installation related
issues much easier (i.e. when shared objects are not found doe to not building
the package against specific libraries). Startup messages can also be useful.

The `mathart::mollusc` function is used to generate a mollusc shall shape.
Input parameters are passed as JSON from the request body, available arguments are explained [here](https://github.com/marcusvolz/mathart/blob/master/R/mollusc.R).

```R
library(ggplot2)

# from https://github.com/marcusvolz/mathart
mollusc <- function(n_s = 100, n_t = 500,
                    alpha = 80, beta = 40, phi = 55, mu = 30, 
                    Omega = 10, s_min = -270, s_max = 62,
                    A = 25, a = 12, b = 16, P = 2, 
                    W_1 = 1, W_2 = 1, N = 0, L = 0, D = 1,
                    theta_start = 0, theta_end = 10*pi) {
  alpha <- alpha * pi / 180
  beta <- beta * pi / 180
  phi <- phi * pi / 180
  mu <- mu * pi / 180
  Omega <- Omega * pi / 180
  s_min <- s_min * pi / 180
  s_max <- s_max * pi / 180
  P <- P * pi / 180
  W_1 <- W_1 * pi / 180
  W_2 <- W_2 * pi / 180
  data.frame(expand.grid(seq(s_min, s_max, (s_max-s_min)/(n_s-1)),
                         seq(theta_start, theta_end, (theta_end-theta_start)/(n_t-1))) %>%
               dplyr::rename(s = Var1, theta = Var2)) %>%
    dplyr::mutate(
      f_theta = ifelse(N == 0, Inf, 360/N*(theta*N/360-round(theta*N/360, 0))),
      R_e = (a^(-2)*(cos(s))^2+b^(-2)*(sin(s))^2)^(-0.5),
      k = L*exp(-(2*(s-P)/W_1)^2)*exp(-(2*f_theta/W_2)^2),
      R = R_e + k,
      x = D*(A*sin(beta)*cos(theta)+R*cos(s+phi)*cos(theta+Omega)-R*sin(mu)*sin(s+phi)*sin(theta))*exp(theta/tan(alpha)),
      y =  (-A*sin(beta)*sin(theta)-R*cos(s+phi)*sin(theta+Omega)-R*sin(mu)*sin(s+phi)*cos(theta))*exp(theta/tan(alpha)),
      z =  (-A*cos(beta)+R*sin(s+phi)*cos(mu))*exp(theta/tan(alpha))
    ) %>%
    dplyr::select(x, y, z)
}
theme_blankcanvas <- function(bg_col = "transparent", margin_cm = 2.5) {
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        legend.position = "none",
        panel.background = element_rect(fill = bg_col, colour = bg_col),
        panel.border = element_blank(),
        panel.grid = element_blank(),
        plot.background = element_rect(fill = bg_col, colour = bg_col),
        plot.margin = unit(rep(margin_cm, 4), "cm"), # top, right, bottom, left
        strip.background = element_blank(),
        strip.text = element_blank())
}

#* Math art
#* @serializer contentType list(type='image/png')
#* @post /
function(req) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  x <- x[names(x) %in% names(formals(mollusc))]
  e <- paste0("mollusc(", paste0(names(x), "=", unlist(x), collapse=", "), ")")
  df <- eval(parse(text=e))

  p <- ggplot() +
    geom_path(aes(x, z), df, size=0.1, alpha=0.2) +
    coord_equal() +
    theme_blankcanvas(margin_cm=0)
  ggsave("shell.png", p, width=10, height=10, units="cm")
  readBin("shell.png", 'raw', n=file.info("shell.png")$size)
}
```

Edit the `r-pca.yml` file as required, see [configuration](https://docs.openfaas.com/reference/yaml/) options.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-image.yml
```

## Testing

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-image` using default settings:

```bash
curl http://localhost:5000/ -H \
  "Content-Type: application/json" -d \
  '{}' \
  --output shell.png
```

Test the deployed instance using different settings:

```bash
curl $OPENFAAS_URL/function/r-image -H \
  "Content-Type: application/json" -d \
  '{"A": 8, "a": 4, "b": 2}' \
  --output shell.png
```

Now you should see the file `shell.png`.
