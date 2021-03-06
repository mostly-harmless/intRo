library(shiny)
library(shinyAce)
library(YaleToolkit)
library(ggplot2)
library(ggvis)
library(dplyr)
library(lubridate)
library(gridExtra)
library(R.utils)
library(RCurl)
library(rmarkdown)
library(formatR)
library(Hmisc)

#cat("```{r, echo=FALSE}\nopts_chunk$set(echo=FALSE)\n```\n\n```{r, child="test.Rmd", message=FALSE, warning=FALSE}\n```", file = "outfile.Rmd")

###
### Global Helper Functions
###
numericNames <- function(data) {
  vec <- as.character(subset(whatis(data), type == "numeric")$variable.name)
  if (length(vec) == 0) vec <- ""
  
  return(vec)
}

q1 <- function(x) { return(quantile(x, .25, na.rm = TRUE)) }
q3 <- function(x) { return(quantile(x, .75, na.rm = TRUE)) }

categoricNames <- function(data) {
  vec <- as.character(subset(whatis(data), type != "numeric")$variable.name)
  if (length(vec) == 0) vec <- ""
  
  return(vec)
}

isNullEvent <- function(value) {
    is.null(value) || (inherits(value, 'shinyActionButtonValue') && value == 0)
}

observeEvent <- function(eventExpr, handlerExpr,
                         event.env = parent.frame(), event.quoted = FALSE,
                         handler.env = parent.frame(), handler.quoted = FALSE,
                         label=NULL, suspended=FALSE, priority=0, domain=getDefaultReactiveDomain(),
                         autoDestroy = TRUE, ignoreNULL = TRUE) {
    
    eventFunc <- shiny::exprToFunction(eventExpr, event.env, event.quoted)
    if (is.null(label))
        label <- sprintf('observeEvent(%s)', paste(deparse(body(eventFunc)), collapse='\n'))
    
    handlerFunc <- shiny::exprToFunction(handlerExpr, handler.env, handler.quoted)
    
    invisible(shiny::observe({
        e <- eventFunc()
        
        if (ignoreNULL && isNullEvent(e)) {
            return()
        }
        
        shiny::isolate(handlerFunc())
    }, label = label, suspended = suspended, priority = priority, domain = domain,
    autoDestroy = TRUE))
}

sourceDir <- function(path, type, local = FALSE, ...) { 
  for (nm in list.files(path, pattern = paste0("\\.", type, "$"))) { 
    source(file.path(path, nm), local=local) 
  } 
}

my.summary <- function(data) {
    mean.val <-suppressWarnings(sapply(as.data.frame(data), mean, na.rm=TRUE))
    sd.val <- sapply(as.data.frame(data), function(col) {
        if (is.numeric(type.convert(as.character(col)))) as.numeric(sd(col, na.rm = TRUE)) else NA
    })
    min.val <- sapply(as.data.frame(data), function(col) {
        if (is.numeric(type.convert(as.character(col)))) as.numeric(min(col, na.rm = TRUE)) else NA
    })
    q1.val <- sapply(as.data.frame(data), function(col) {
        if (is.numeric(type.convert(as.character(col)))) as.numeric(q1(col)) else NA
    })
    median.val <- sapply(as.data.frame(data), function(col) {
        if (is.numeric(type.convert(as.character(col)))) as.numeric(median(col, na.rm = TRUE)) else NA
    })
    q3.val <- sapply(as.data.frame(data), function(col) {
        if (is.numeric(type.convert(as.character(col)))) as.numeric(q3(col)) else NA
    })
    max.val <- sapply(as.data.frame(data), function(col) {
        if (is.numeric(type.convert(as.character(col)))) as.numeric(max(col, na.rm = TRUE)) else NA
    })
    
    return(data.frame(mean = mean.val, sd = sd.val, min = min.val, q1 = q1.val, median = median.val, q3 = q3.val, max = max.val))
}

checkVariable <- function(data, var) {
    return(nchar(var) > 0 & var %in% names(data))
}

process_input <- function(inp) {
    if (is.character(inp)) {
        if (length(inp) == 1)  {
            if (length(grep("intro.", inp)) > 0) return(inp)
            else if (inp == "NULL") return(inp)
            else return(paste0("\"", inp, "\""))
        } else {
            return(paste0("c(", paste(paste0("\"", inp, "\""), collapse = ", "), ")"))
        }
    } else {
        return(inp)
    }
}

clean_readlines <- function(file) {
    return(tidy_source(file, output = FALSE)$text.tidy)
}

cat_and_eval <- function(mystr, mydir, env = parent.frame(), file = "code_All.R", append = FALSE, save_result = FALSE) {
    cat(paste0(gsub("; ", "\n", mystr), "\n"), file = file.path(mydir, file), append = append)
    
    if (save_result) cat(paste0(paste(readLines(file.path(mydir, file)), collapse = "\n"), "\n"), file = file.path(mydir, "code_All.R"), append = TRUE)
    
    eval(parse(text = mystr), envir = env)
}
