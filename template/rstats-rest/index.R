#!/usr/bin/env Rscript

suppressMessages(library(RestRserve))

source("function/handler.R")

handle <- function(body) {
  paste0("Hello ", body$name, "!")
}

app_logger = Logger$new()
app_logger$set_log_level("debug")
app_logger$set_name("MW Logger")

mw = Middleware$new(
  process_request = function(rq, rs) {
    app_logger$info("start")
    app_logger$info(sprintf("req: %s", (rq$body)))
    app_logger$info("end")
  },
  id = "awesome-app-logger"
)

app <- Application$new(middleware = list(mw), content_type = "application/json")
app$logger$set_log_level("all")

app$add_post(
  path = "/",
  FUN = function(request, response){
    body <- jsonlite::fromJSON(rawToChar(request$body))
    result <- handle(body)
    if (is.list(result)) {
      result <- jsonlite::toJSON(result)
    }
    response$set_body(result)
  }
)

backend = BackendRserve$new()
backend$start(app, http_port = 5000, encoding = "utf8")

