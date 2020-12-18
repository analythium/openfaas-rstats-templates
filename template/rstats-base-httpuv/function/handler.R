suppressMessages(library(jsonlite))

handle <- function(req) {
  input <- req[["rook.input"]]
  postdata <- input$read_lines()
  jsonlite::toJSON(
    paste0(
      "Hello ", jsonlite::fromJSON(paste(postdata)), "!"
    )
  )
}
