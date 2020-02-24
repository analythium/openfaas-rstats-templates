#!/usr/bin/env Rscript

suppressMessages(library(jsonlite))

source("function/handler.R")

f <- file("stdin")
open(f)
input <- readLines(f, warn = FALSE, n = -1)

input <- jsonlite::fromJSON(input)

output <- handle(input)

output <- jsonlite::toJSON(output, auto_unbox = T)

write(output, stdout())
