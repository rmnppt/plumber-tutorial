library(plumber)

p = plumb(dir = "api")
p$run(port = 8000)

