#!/usr/bin/env Rscript

suppressMessages(library(plumber))

source("function/handler.R")

# curl http://localhost:5000 -H "Content-Type: application/json" -d '["Friend"]'

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
