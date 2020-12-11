FROM openfaas/classic-watchdog:0.20.1 as watchdog
FROM rocker/r-base:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

COPY install.R /usr/local/bin/

WORKDIR /home/app

COPY index.R           .
COPY DESCRIPTION       .
COPY function          .

# Note: remotes is already installed in rocker
ENV _R_SHLIB_STRIP_=true
ENV R_REMOTES_UPGRADE=false
#RUN echo 'local(options(repos = c(CRAN = "https://cloud.r-project.org")))' > /usr/lib/R/etc/Rprofile.site
#RUN echo 'local(options(repos = c(CRAN = "https://packagemanager.rstudio.com/all/__linux__/bionic/latest")))' > /usr/lib/R/etc/Rprofile.site

## Istall SystemRequirements from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$sysreqs(file="tmpfile")'
RUN LIBS=$(cat tmpfile)
RUN rm tmpfile

RUN apt-get update && apt-get install -y \
    --no-install-recommends ${LIBS} \
    && rm -rf /var/lib/apt/lists/*

## Install package dependencies (incl. remotes) from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$dependencies()'

## Install VersionedPackages from DESCRIPTION
RUN R -q -e 'source("/usr/local/bin/install.R"); install$versioned()'

## Switch to app user
RUN chown app:app -R /home/app

USER app

ENV fprocess="Rscript index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
