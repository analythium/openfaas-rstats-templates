ARG WATCHDOG_VERSION="0.1.5"
ARG R_IMAGE="rocker/r-ubuntu:20.04"

FROM ghcr.io/openfaas/classic-watchdog:${WATCHDOG_VERSION} as watchdog
FROM ${R_IMAGE}

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Install system requirements for index.R as needed
#ENV LIBS=''
#RUN apt-get update && apt-get install -y \
#    --no-install-recommends ${LIBS} \
#    && rm -rf /var/lib/apt/lists/*

# Change options as needed in Rprofile.site
COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

# Install basic dependencies for index.R
RUN R -q -e 'install.packages(c("remotes", "jsonlite"))'

COPY install.R /usr/local/bin/

COPY function/DESCRIPTION     .

# Istall SystemRequirements for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R");install$sysreqs()'
RUN echo requirements.txt
RUN apt-get update
RUN xargs -a requirements.txt apt-get install -y --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*
RUN rm requirements.txt

# Install packages (incl. remotes) for handler.R from DESCRIPTION
RUN R -q -e 'remotes::install_deps()'

# Install VersionedPackages for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R");install$versioned()'

RUN rm -f ./DESCRIPTION

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

COPY index.R           .
COPY function          .

# Switch to app user
RUN chown app:app -R /home/app
USER app

ENV fprocess="Rscript index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
