FROM openfaas/classic-watchdog:0.20.1 as watchdog
FROM rhub/r-minimal:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

COPY index.R           .
COPY PACKAGES          .
COPY SYSREQS           .
RUN TEMS=$(cat SYSREQS | tr '(\r|)\n' ' ') \
    && apk add $TEMS \
    && installr -d ""$(tr '(\r|)\n' ' ' < PACKAGES)"" \
    && apk del $TEMS \
    && rm -rf /var/cache/apk/*

RUN mkdir -p function
WORKDIR /home/app/function
COPY function/PACKAGES          .
COPY function/SYSREQS           .
RUN TEMS=$(cat SYSREQS | tr '(\r|)\n' ' ') \
    && apk add $TEMS \
    && installr -d ""$(tr '(\r|)\n' ' ' < PACKAGES)"" \
    && apk del $TEMS \
    && rm -rf /var/cache/apk/*

WORKDIR /home/app

COPY function           function

RUN chown app:app -R /home/app

USER app

ENV fprocess="R --slave -f index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
