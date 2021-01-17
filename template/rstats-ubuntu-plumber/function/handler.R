#* Hello
#* @serializer unboxedJSON
#* @post /
function(req) {
  paste0("Hello ", jsonlite::fromJSON(paste(req$postBody)), "!")
}
