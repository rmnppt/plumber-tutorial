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

#* @description Perform language categorisation
#* @param txt A string value, the text to categorise.
#* @get /textcat
guessLanguage = function(txt) {
  
  input = txt
  
  output = textcat(txt)
  
  cat(
    "\n   Input: ", input,
    "\n   Most likely: ", output
  )
  
  return(output)
  
}
