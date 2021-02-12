FROM openfaas/of-watchdog:0.8.1 as watchdog
FROM rhub/r-minimal:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Change options as needed in Rprofile.site
COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

# Install system requirements and dependencies for index.R as needed
# See tips for alpine 3.12 https://github.com/rstudio/httpuv/issues/280
RUN apk add --no-cache --update-cache \
    --repository http://nl.alpinelinux.org/alpine/v3.11/main \
    autoconf=2.69-r2 \
    automake=1.16.1-r0 \
    bash gcc
RUN installr -d \
    -t "R-dev file linux-headers libxml2-dev gnutls-dev openssl-dev" \
    -a "libxml2" \
    remotes httpuv jsonlite glue fs websocket cli
#RUN installr -e ambiorix
# Use gh version for now until JSON parsing is fixed on CRAN
RUN R -q -e 'remotes::install_github("JohnCoene/ambiorix")'

COPY install.R /usr/local/bin/

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

COPY index.R           .
COPY function          .

# Istall SystemRequirements for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$sysreqs()'
RUN echo requirements.txt
RUN apk update
RUN xargs -a requirements.txt apk add
RUN rm -rf /var/cache/apk/*
RUN rm requirements.txt

# Install packages (incl. remotes) for handler.R from DESCRIPTION
RUN R -q -e 'remotes::install_deps()'

# Install VersionedPackages for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$versioned()'

# Switch to app user
RUN chown app:app -R /home/app
USER app

ENV fprocess="R --slave -f index.R"
ENV mode="http"
ENV http_upstream_url="http://127.0.0.1:5000"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
