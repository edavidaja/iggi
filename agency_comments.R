rm(list=ls())


setwd('~/iggi')

library(purrr)
library(dplyr)
library(pdftools)
library(stringr)
library(tidytext)
library(glue)
library(tesseract)

fils <- list.files('./pdfs')
fil <- './pdfs/691520.pdf'

text <- pdf_text(fil) %>% 
  str_split(., pattern = "\n")

# get the appendcices
appendices <- unlist(map(text, function(x) any(str_detect(x, 'Appendix') & str_detect(x, 'Comments from'))))
# now only 16 pages to look through
appendix_pages <- which(appendices)
# remove teh first. its going to be the toc
appendix_pages <- appendix_pages[-1]
# need to comine all appendix pages into a single str

get_comments_text <- function(x){
  # conver the page of the pdf
  pngfile <- pdftools::pdf_convert(fil, dpi = 600, page = x)
  # teseract it
  text <- tesseract::ocr(pngfile)
  # get the path to the png
  png_fil <- dir(path = getwd(),  pattern = '.png')
  # remove the png
  file.remove(png_fil)
  # return the text
  text
  
}

# now ocr the text 
agency_comments <- map_chr(appendix_pages, function(x) get_comments_text(x))
