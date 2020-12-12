FROM openfaas/classic-watchdog:0.20.1 as watchdog
FROM rocker/r-base:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Change repos as needed
RUN echo 'local(options(repos = c(CRAN = "https://cloud.r-project.org/")))' > /usr/lib/R/etc/Rprofile.site
#RUN echo 'local(options(repos = c(CRAN = "https://cloud.r-project.org/")))' > /usr/lib/R/etc/Rprofile.site
#RUN echo 'local(options(repos = c(CRAN = "https://packagemanager.rstudio.com/all/__linux__/bionic/latest")))' > /usr/lib/R/etc/Rprofile.site

# Install basic dependencies for index.R
ENV _R_SHLIB_STRIP_=true
RUN R -q -e 'install.packages(c("remotes", "jsonlite"))'

COPY install.R /usr/local/bin/
# Install system requirements for index.R as needed
#RUN apt-get update \
#  apt-get install -y \
#  --no-install-recommends\
#  ADDITIONAL_PACKAGES \
#  rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

COPY index.R           .
COPY function          .
RUN ls -la

# Istall SystemRequirements for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$sysreqs()'
RUN echo requirements.txt
RUN apt-get update
RUN xargs -a requirements.txt apt-get install -y --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*
RUN rm requirements.txt

# Install packages (incl. remotes) for handler.R from DESCRIPTION
RUN R -q -e 'remotes::install_deps()'

## Install VersionedPackages for handler.R from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$versioned()'

## Switch to app user
RUN chown app:app -R /home/app
USER app

ENV fprocess="Rscript index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
