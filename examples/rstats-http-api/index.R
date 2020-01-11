#!/usr/bin/env Rscript
suppressMessages(library(jsonlite))
suppressMessages(library(plumber))
suppressMessages(library(MASS))

pr <- plumber$new()

pr$filter("cors", function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers",
      req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
})

# curl http://localhost:5000
pr$handle("GET", "/", function(req, res){
  "Hello, this is R plumber API with OpenFaaS!"
})

## note -d @... is not sending line breaks, so use --data-binary
# curl -X POST -H 'Content-Type: text/csv' --data-binary @test.csv http://localhost:5000/upload
pr$handle("POST", "/upload", function(req, res) {
  f <- tempfile()
  writeLines(req$postBody, f)
  x <- read.csv(f)
  unlink(f)
  x
})

# curl http://localhost:5000/prcomp -H "Content-Type: application/json" -d '[[1,4,7,10],[2,5,8,11],[3,6,9,12]]'
pr$handle("POST", "/prcomp", function(req, res) {
  x <- jsonlite::fromJSON(paste(req$postBody))
  prcomp(x)$x
})

# curl http://localhost:5000/rnorm -H "Content-Type: application/json" -d '{"n":[10],"mean":[2],"sd":[2]}'
pr$handle("POST", "/rnorm", function(req, res) {
  args <- jsonlite::fromJSON(paste(req$postBody))
  rnorm(n = args$n, mean = args$mean, sd = args$sd)
})

pr$run(
  host = "0.0.0.0",
  port = 5000)
