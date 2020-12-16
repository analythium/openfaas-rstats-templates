handle <- function(req, res, err) {
  paste0("Hello ", jsonlite::fromJSON(paste(req$body)), "!")
}
