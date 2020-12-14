#!/usr/bin/env Rscript

suppressMessages(library(opencpu))

ocpu_start_server(
  port = 5000,
  root = "/",
  workers = 1,
  preload = NULL,
  on_startup = NULL,
  no_cache = FALSE
)
