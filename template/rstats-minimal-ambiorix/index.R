#!/usr/bin/env Rscript

suppressMessages(library(ambiorix))
options(ambiorix.host="0.0.0.0", ambiorix.port=5000)
app <- Ambiorix$new()
source("handler.R")
app$start()
