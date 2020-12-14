#FROM openfaas/of-watchdog:0.8.1 as watchdog
FROM rocker/r-base:latest

#COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
#RUN chmod +x /usr/bin/fwatchdog

# Install system requirements for index.R as needed
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    libssl-dev \
    libjemalloc-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Change options as needed in Rprofile.site
COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

# Install basic dependencies for index.R
RUN install2.r -r http://www.rforge.net/ Rserve
RUN install2.r -e remotes Rcpp R6 uuid checkmate mime jsonlite RestRserve

RUN cd /tmp && \
    wget http://www.haproxy.org/download/2.2/src/haproxy-2.2.6.tar.gz && \
    tar -xvzf haproxy-2.2.6.tar.gz && \
    cd haproxy-2.2.6/ && \
    make TARGET=linux-glibc && \
    chmod +x haproxy && \
    cp haproxy /bin/ && \
    rm -rf /tmp/*

ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so

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

# --- the usual of-watchdog setup would look like this ---
#ENV fprocess="Rscript index.R"
#ENV mode="http"
#ENV http_upstream_url="http://127.0.0.1:5000"

#HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

#CMD ["fwatchdog"]

# --- without of-watchdog ---
# from the docs: https://docs.openfaas.com/reference/workloads/#stateless-microservices
# > Use of the of-watchdog is optional, but recommended for stateless microservices
# > to provide a consistent experience for timeouts, logging and configuration.
# > On Kubernetes is possible to run any container image as an OpenFaaS function
# > as long as your application exposes port 8080 and has a HTTP health check endpoint.
HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1

CMD ["Rscript", "index.R"]
