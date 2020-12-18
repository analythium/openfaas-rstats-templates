#!/usr/bin/env Rscript

# load plumber
suppressMessages(library(httpuv))

# source handler.R script
source("handler.R")

# create app and start httpuv server
httpuv::runServer(
  host = "0.0.0.0",
  port = 5000,
  app = list(
    call = function(req) {
      list(
        status = 200L,
        headers = list(
          'Content-Type' = 'application/json'
        ),
        body = handle(req)
      )
    }
  )
)
