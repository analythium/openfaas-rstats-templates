#!/usr/bin/env Rscript

# load jsonlite
suppressMessages(library(jsonlite))

# source handler.R script
source("function/handler.R")

# read stdin as input
f <- file("stdin")
open(f)
input <- fromJSON(
    readLines(f, warn = FALSE, n = 1) # 1st line only
)
close(f)

# write output to stdout
output <- toJSON(
    handle(input)
)
write(output, stdout())
