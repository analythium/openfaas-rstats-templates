#!/usr/bin/env Rscript

# load plumber
suppressMessages(library(plumber))

# source handler.R script
source("handler.R")

# create new Plumber router
pr <- Plumber$new()

# note: only pass req or res when used to avoid
# `simpleError in handle(req, res): unused argument (res)`
pr$handle("POST", "/", function(req) {
  tryCatch(handle(req), error = function(e) {
    res$status <- 400
    return(list(error = e, traceback = ...))
  })
})

# start a server using the plumber object
pr$run(
  host = "0.0.0.0",
  port = 5000)
