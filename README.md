# Short Tutorial on Plumber

First make sure you have the `plumber` and `textcat` packages installed in your library (use `install.packages()`).

To have a play with this you can simly clone this repo but I will also walk through the steps in this readme so you can do it from scratch if needed.

## Introduction

In this tutorial we will go through the following steps to create your plumber API.

[1. Write your function(s)](#1-write-your-function(s))

[2. Add the plumber special comments](#2-add-the-plumber-special-comments)

[3. Try it out!](#3-try-it-out)

[4. Record the traffic](#4-record-the-traffic)

## Resources

[TO DO]

### 1. Write your function(s)

Start a new directory that will house the API, make a file called `plumber.R`, save it in a directory called `api` and write a function definition, one that you want to expose to the API. For example here I am using the textcat package to guess the language of user text input.

```r
library(plumber)
library(textcat)

guessLanguage = function(txt) {
  
  input = txt

  output = textcat(txt)
  
  return(output)
  
}
```

This function takes a character (string) value, executes the `textcat()` function and then returns the results of `textcat()`. Run this code and then try something like `guessLanguage("Hallo")` to make sure it works.

Easy.

### 2. Add the plumber special comments

Next we need to add some special comments (decorations) to the file that will act as instructions to plumber on how to interpret your file and how to serve the contents. At a mimimum we need to name the endpoint and give it an address. All plumber comments start with `#*` rather than `#`, this distinguishes them from actual comments in the script. So to our `plumber.R` file above we would add the following just above the function definition.

```r
#* @param txt A string value, the text to categorise.
#* @get /textcat
```

The `@param` tag will define a parameter input for the function and the `@get` tag will define the http method used. So our file would now look like this:

```r
library(plumber)
library(textcat)

#* @param txt A string value, the text to categorise.
#* @get /textcat
guessLanguage = function(txt) {
  
  input = txt

  output = textcat(txt)
  
  return(output)
  
}
```

This is we're now ready to try out our first API.

### 3. Try it out!

To serve the API locally on our machines, we should now open a new script file, I called mine `serve_local.R` and save it in the parent directory of this project. I use this script to store a few commands that will set up a local server and run the API. The script should use the `plumb()` function to run the server:

```r
library(plumber)

p = plumb(dir = "api")
p$run(port = 8000)
```

We are telling plumber that our plumber files are in the directory called `api`, change this if needed. We then tell plumber to run the api on port `8000`. You will see some output in the console something like this:

```
Starting server to listen on port 8000
Running the swagger UI at http://127.0.0.1:8000/__swagger__/
```

And you will not get your prompt back, R is still busy.

Next you should copy the URL `http://127.0.0.1:8000/__swagger__/` into your browser and there you have it, your API is running and you have a nice swagger UI to test it with. If you expand the `/textcat` box and click 'Try it out' you will get a box that you can type into. Type something in and click execute to see some example ouput.

### 4. Record the traffic

That was beautifully simple lets add some more functionality. We're going to add a filter. Filters are used to execute some logic on all incoming requests before they reach their endpoints. We will use a filter example from the plumber website to print some information about the request into the log file.

This is a good time to mention the request and the result objects. When your R code is running, there will be two objects available in the environment, `req` containing information about the request and `res` containing information about the result. These can be accessed by your functions. For example, we could have a filter that prints some information from the request out as follows:

```r
logger = function(req){
  
  cat("\n", as.character(Sys.time()), 
      "\n", req$REQUEST_METHOD, req$PATH_INFO, 
      "\n", req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR)
  
  plumber::forward()

}
```

This function will print out various parts of the `req` object to the console (and probably and nginx log buried on the server if you have deployed your API) but in reality you might want to store this in your own log file somwhere or even better in a database so you can analyse the traffic to your API. Note that (a) we passed the `req` object into the function as an argument and (b) we then used the `forward()` function to pass the request on (either to the next filter or to its endpoint).

Your final API plumber.R file should now look like this:

```r
# plumber.R
library(plumber)
library(textcat)

#* Print to log
#* @filter logger
logger = function(req){
  
  cat("\n", as.character(Sys.time()), 
      "\n", req$REQUEST_METHOD, req$PATH_INFO, 
      "\n", req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR)
  
  plumber::forward()
  
}

#* @param txt A string value, the text to categorise.
#* @get /textcat
#* @description Perform language categorisation
guessLanguage = function(txt) {
  
  input = txt
  
  output = textcat(txt)
  
  cat(
    "\n   Input: ", input,
    "\n   Most likely: ", output
  )
  
  return(output)
  
}
```

Notice the decorations above the filter, we used @filter to specify we were creating a filter.
