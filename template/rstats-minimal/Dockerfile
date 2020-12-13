FROM openfaas/classic-watchdog:0.20.1 as watchdog
FROM rhub/r-minimal:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Install system requirements for index.R as needed
#ENV LIBS=''
#RUN apk update
#RUN apk add ${LIBS}
#RUN rm -rf /var/cache/apk/*

# Change options as needed in Rprofile.site
COPY Rprofile.site /usr/local/lib/R/etc/Rprofile.site
ENV _R_SHLIB_STRIP_=true

# Install basic dependencies for index.R
RUN installr -d remotes jsonlite

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

# Cleanup
RUN R -q -e 'remove.packages("remotes")'
RUN rm /usr/local/bin/install.R

# Switch to app user
RUN chown app:app -R /home/app
USER app

ENV fprocess="R --slave -f index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
