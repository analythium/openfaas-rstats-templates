#!/usr/bin/env Rscript

# load RestRserve
suppressMessages(library(RestRserve))

# source handler.R script
source("handler.R")
#source("function/handler.R")

#mw = EncodeDecodeMiddleware$new()
#mw$ContentHandlers$set_decode('application/json', jsonlite::fromJSON)
#mw$ContentHandlers$set_encode('application/json', jsonlite::toJSON)
#mw$ContentHandlers$get_decode("application/json")
#mw$ContentHandlers$get_encode("application/json")

# create application
app = Application$new(
#  middleware = list(mw),
#  content_type = "text/plain"
  content_type = "application/json"
)
#app$logger$set_log_level("trace")

# register endpoint and corresponding handlers
app$add_post(
  path = "/",
  FUN = handle
)
#request = Request$new(path = "/", method = "POST", body = '"world"', content_type = "application/json")
#response = app$process_request(request)
#response$body

# start a server using the plumber object
backend = BackendRserve$new()

# with of-watchdog, something isn't quite right
#backend$start(app, http_port = 5000)

# without of-watchdog
writeLines("", "/tmp/.lock")
backend$start(app, http_port = 8080)
