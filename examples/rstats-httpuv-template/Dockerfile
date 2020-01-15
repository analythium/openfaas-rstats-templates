FROM openfaas/of-watchdog:0.7.2 as watchdog

FROM analythium/r-base-plumber

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /root/

COPY index.R           .
COPY PACKAGES          .
COPY install.R         .
RUN Rscript --vanilla install.R PACKAGES
RUN rm -f install.R

RUN mkdir -p function
COPY function           function

ENV fprocess="Rscript index.R"
ENV mode="http"
ENV http_upstream_url="http://127.0.0.1:5000"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
