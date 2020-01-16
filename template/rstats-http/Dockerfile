FROM openfaas/of-watchdog:0.7.2 as watchdog

FROM rocker/r-base:latest

# Add here more system dependencies as needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    git-core libssl-dev libcurl4-gnutls-dev \
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

COPY function           function

RUN chown app:app -R /home/app

USER app

ENV fprocess="Rscript index.R"
ENV mode="http"
ENV http_upstream_url="http://127.0.0.1:5000"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
