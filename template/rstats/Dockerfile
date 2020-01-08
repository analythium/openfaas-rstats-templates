FROM openfaas/classic-watchdog:0.18.1 as watchdog

FROM r-base:latest
RUN R --vanilla -e 'install.packages("remotes", repos="http://cran.rstudio.com")'

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /root/

COPY index.R           .
COPY requirements.txt  .
COPY install.R         .
RUN Rscript --vanilla install.R requirements.txt
RUN rm -f install.R

RUN mkdir -p function
WORKDIR /root/function/
COPY function/requirements.txt  .
COPY install.R                  .
RUN Rscript --vanilla install.R requirements.txt
RUN rm -f install.R

WORKDIR /root/

COPY function           function

ENV fprocess="Rscript index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
