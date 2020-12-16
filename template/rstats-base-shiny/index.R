#!/usr/bin/env Rscript

library(shiny)

source("global.R") # globals
source("ui.R")     # UI object
source("server.R") # server function

runApp(
#  host = "0.0.0.0",
  port = 5000,
  display.mode = "normal"
)
