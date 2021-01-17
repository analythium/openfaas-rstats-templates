#!/usr/bin/env Rscript

library(plumber) # load plumber
pr <- plumb("handler.R") # process plumber API
pr # print router info
pr$run(host = "0.0.0.0", port = 5000) # start server
