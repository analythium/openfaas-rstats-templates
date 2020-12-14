FROM openfaas/of-watchdog:0.8.1 as watchdog
FROM rocker/r-ubuntu:18.04
#FROM rocker/r-base:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Install system requirements for index.R as needed
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    make \
    libicu-dev \
    pandoc \
    libprotobuf-dev \
    protobuf-compiler \
    git \
    libapparmor-dev \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Change options as needed in Rprofile.site
COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

# Install basic dependencies for index.R
# build Rcpp from source
RUN install2.r -r "https://cloud.r-project.org" httpuv
RUN install2.r -e remotes opencpu
RUN install2.r -e unix


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
RUN apt-get update
RUN xargs -a requirements.txt apt-get install -y --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*
RUN rm requirements.txt

# Install packages (incl. remotes) for handler.R from DESCRIPTION
RUN R -q -e 'remotes::install_deps()'

# Install VersionedPackages for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$versioned()'

# Switch to app user
RUN chown app:app -R /home/app
USER app

ENV fprocess="Rscript index.R"
ENV mode="http"
ENV http_upstream_url="http://127.0.0.1:5000"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
