handle <- function(req) {
  paste0("Hello ", jsonlite::fromJSON(paste(req$postBody)), "!")
}
