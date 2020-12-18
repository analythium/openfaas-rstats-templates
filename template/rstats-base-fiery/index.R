#!/usr/bin/env Rscript

suppressMessages(library(fiery))
suppressMessages(library(reqres))

source("handler.R")

app <- Fire$new(host = '0.0.0.0', port = 5000L)

app$on('request', function(server, id, request, ...) {
  OK <- request$parse(json = parse_json())
  response <- request$respond()
  if (OK) {
    result <- try(handle(request))
    if (inherits(result, "try-error")) {
      response$body <- jsonlite::toJSON(result)
      response$status <- 400L
    } else {
      response$body <- result
      response$status <- 200L
    }
  } else {
    response$body <- jsonlite::toJSON("Error: wrong input")
    response$status <- 400L
  }
  response$type <- 'application/json; charset=utf-8'
})

app$ignite()
