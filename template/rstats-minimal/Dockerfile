FROM openfaas/classic-watchdog:0.18.10 as watchdog
FROM rhub/r-minimal:latest

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

COPY index.R           .
COPY PACKAGES          .
RUN installr -d ""$(tr '\n' '  ' < PACKAGES)""

RUN mkdir -p function
WORKDIR /home/app/function
COPY function/PACKAGES .
RUN installr -d ""$(tr '\n' '  ' < PACKAGES)""

WORKDIR /home/app

COPY function           function

RUN chown app:app -R /home/app

USER app

ENV fprocess="R --slave -f index.R"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
