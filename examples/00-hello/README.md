# Hello

This is a Hello World example using OpenFaaS R templates.

> You will learn how to make a function that uses POST request passing info from the request body, then modify it to a GET request using URL parameters.

You'll need the prerequisites listed [here](https://github.com/analythium/openfaas-rstats-templates/tree/master/examples).

## Create a new function using a template

Create a new function called `r-hello`.

```bash
faas-cli new --lang rstats-base-plumber r-hello
```

We don't need to edit the function further because the template contains the Hello World example.

## Build, push, deploy the function

`faas-cli up` is a [shorthand](https://docs.openfaas.com/cli/templates/)
for automating `faas-cli build`, `faas-cli push`, and `faas-cli deploy`.

```bash
faas-cli up -f r-hello.yml
```

## Testing

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-hello`:

```bash
curl http://localhost:5000/ -d '"World"'
```

Test the deployed instance:

```bash
curl $OPENFAAS_URL/function/r-hello -d '"World"'
```

The output should be `"Hello World!"`.

## Customize the function

Edit the `./r-hello/handler.R` file:

```R
#* Hello
#* @serializer unboxedJSON
#* @get /
function(name) {
  paste0("Hello ", name, "!")
}
```

This will use a parameter from the URL instead of parsing the request body.

Note: we have changed the function argument (from `req` to `name`) and the HTTP request method from `@post` to `@get`.

Build, push, deploy the function:

```bash
faas-cli up -f r-hello.yml
```

Test the Docker image locally after `docker run -p 5000:8080 $OPENFAAS_PREFIX/r-hello`:

```bash
curl http://localhost:5000/?name=World
```

Test the deployed instance (we have to pass parameters as data using `-G`):

```bash
curl -X GET -G \
  $OPENFAAS_URL/function/r-hello \
  -d name=World
```

The output should still be `"Hello World!"`.
