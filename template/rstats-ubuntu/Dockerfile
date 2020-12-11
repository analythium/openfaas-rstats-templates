FROM openfaas/classic-watchdog:0.18.10 as watchdog
FROM rocker/r-ubuntu:latest

# Allows you to add additional system dependencies
ARG ADDITIONAL_PACKAGE

RUN apt-get update && apt-get install -y \
    --no-install-recommends ${ADDITIONAL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r -e remotes

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

COPY index.R           .
COPY PACKAGES          .
COPY install.R         .
RUN Rscript --vanilla install.R PACKAGES
RUN rm -f install.R

RUN mkdir -p function
WORKDIR /home/app/function
COPY function/PACKAGES .
COPY install.R         .
RUN Rscript --vanilla install.R PACKAGES
RUN rm -f install.R

WORKDIR /home/app

COPY function           function

RUN chown app:app -R /home/app

USER app

ENV fprocess="Rscript index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
