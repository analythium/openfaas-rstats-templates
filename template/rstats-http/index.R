#!/usr/bin/env Rscript

suppressMessages(library(plumber))

source("function/handler.R")

pr <- plumber$new()

## note: only pass req or res when used to avoid
## `simpleError in handle(req, res): unused argument (res)`
pr$handle("POST", "/", function(req) {
  tryCatch(handle(req), error = function(e) {
    res$status <- 400
    return(list(error = e, traceback = ...))
  })
})

pr$run(
  host = "0.0.0.0",
  port = 5000)
