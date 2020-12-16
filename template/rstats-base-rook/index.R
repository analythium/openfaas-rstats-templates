#!/usr/bin/env Rscript

# http://127.0.0.1:5000/custom/RookTest
library(Rook)
s <- Rhttpd$new()
s$start(
  listen='127.0.0.1',
  port=5000
)
