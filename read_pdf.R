library(pdftools)
library(jsonlite)
library(purrr)
library(stringr)
library(tibble)
library(dplyr)

source("footnotes.R")
source("sidebar_text.R")

read_pdf <- function(file) {
  # extract table of contents and report text 
  
  toc <- pdf_toc(file) %>%
    unlist(., use.names = FALSE)
  
  text <- pdf_text(file) %>% 
    str_split(., pattern = "\r\n")
  
  footnotes <- map(text, extract_footnotes) %>% 
    bind_rows()
  
  sidebar <- map_chr(text, extract_sidebar_text)
  
  list(
    toc = toc,
    text = text,
    footnotes = footnotes,
    sidebar = sidebar
  )
}

infile <- read_pdf("pdfs/693817.pdf")

