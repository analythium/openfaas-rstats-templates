#!/usr/bin/env Rscript

suppressMessages(library(fiery))
suppressMessages(library(reqres))

source("function/handler.R")

# Create a New App
app <- Fire$new(host = '0.0.0.0', port = 5000L)

# Handle requests
app$on('request', function(server, request, ...) {
  response <- request$respond()
  response$status <- 200L

  request$set_body(NULL)
  request$parse(
    txt = parse_plain(),
    html = parse_html(),
    json = parse_json()
  )

  response$body <- handle(request$body)
  response$format(json = format_json())
  response$type <- 'Application/json; charset=utf-8'
})

# Be polite
app$on('end', function(server) {
  message('Goodbye')
  flush.console()
})

app$ignite()
