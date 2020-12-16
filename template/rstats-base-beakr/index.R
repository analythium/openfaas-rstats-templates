#!/usr/bin/env Rscript

suppressMessages(library(beakr))

source("handler.R")

newBeakr() %>%
  httpPOST(
    path = "/",
    decorate(
      FUN = handle,
      content_type = "application/json"
    )
  ) %>%
  handleErrors() %>%
  listen(host = "0.0.0.0", port = 5000)
