## req is the input parsed from stdin
## return value must be coercible to JSON
handle <- function(req) {
    paste0("Hello ", req, "!")
}
