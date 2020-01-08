FROM rocker/r-base
MAINTAINER Peter Solymos <peter@analythium.io>

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  && rm -rf /var/lib/apt/lists/*

RUN install2.r -e remotes plumber

CMD ["R"]
