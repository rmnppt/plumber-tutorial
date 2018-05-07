# Short Tutorial on Plumber

First make sure you have the `plumber` and `textcat` packages installed in your library (use `install.packages()`).

To have a play with this you can simly clone this repo but I will also walk through the steps in this readme so you can do it from scratch if needed.

### 1. Write your function(s)

Start a new directory that will house the API, make a file called `plumber.R`, save it in a directory called `api` and write a function definition, one that you want to expose to the API. For example here I am using the textcat package to guess the language of user text input.

```{r}
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

```{r}
#* @param txt A string value, the text to categorise.
#* @get /textcat
```

The `@param` tag will define a parameter input for the function and the `@get` tag will define the http method used. So our file would now look like this:

```{r}
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

```{r}
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
