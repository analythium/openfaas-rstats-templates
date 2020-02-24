#!/usr/bin/env Rscript

suppressMessages(library(fiery))

source("function/handler.R")

# Create a New App
app <- Fire$new(host = '0.0.0.0', port = 5000L)

# Handle requests
app$on('request', function(server, request, ...) {
  response <- request$respond()
  response$status <- 200L
  print(request$body)
  response$body <- handle(request$body)
  response$type <- 'text/html'
})

# Be polite
app$on('end', function(server) {
  message('Goodbye')
  flush.console()
})

app$ignite()
