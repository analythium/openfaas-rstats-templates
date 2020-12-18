handle <- function(request) {
  jsonlite::toJSON(paste0('Hello ', request$body, '!'))
}
