handle = function(.req, .res) {
  str(.req$body)
  .res$set_body(
    paste0("Hello ", .req$body, "!")
  )
}
