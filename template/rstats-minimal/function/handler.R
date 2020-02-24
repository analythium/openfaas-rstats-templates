handle <- function(req) {
  # req is named list from requests convert using jsonlite::fromJSON
  data.table::data.table(return = paste0("Hello ", req, "!"))
}
