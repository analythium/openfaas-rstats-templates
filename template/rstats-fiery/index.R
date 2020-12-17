#!/usr/bin/env Rscript

suppressMessages(library(fiery))
suppressMessages(library(reqres))
## needs parallelly and globals as well

source("function/handler.R")

app <- Fire$new(host = '0.0.0.0', port = 5000L)

app$on('request', function(server, id, request, ...) {
  request$parse(json = parse_json())
  response <- request$respond()
  response$status <- 200L
  response$body <- handle(request)
  response$type <- 'Application/json; charset=utf-8'
})

app$ignite()
