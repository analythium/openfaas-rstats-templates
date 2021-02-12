handle <- function(body) {
  paste0('Hello ', body, '!')
}

app$post("/", function(req, res){
  res$json(handle(parse_json(req)))
})
