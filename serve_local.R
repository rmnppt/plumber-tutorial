library(plumber)
p = plumb(dir = "api-demo")
p$run(port = 8000)

