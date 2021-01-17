#!/usr/bin/env Rscript

# load plumber
suppressMessages(library(plumber))

# create new Plumber router
pr <- Plumber$new()

# source handler.R script
source("handler.R")

# handle with simple error
pr$handle("POST", "/", function(req, res) {
  tryCatch(handle(req), error = function(e) {
    res$status <- 400
    return(list(error = e))
  })
})

# start a server using the plumber object
pr$run(
  host = "0.0.0.0",
  port = 5000)
