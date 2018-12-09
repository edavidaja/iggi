library(tibble)
library(tidyr)
library(tidytext)
library(dplyr)
library(glue)
library(spacyr)
library(stringi)


terms <- read_csv('./term.csv')
terms <- terms %>% filter(word != 'Assistant Staff Director')
terms <- terms %>% pull(word)
terms <- c('testimony', 'Contacts', 'Staff', 'Natural', 'Resources', 'Environment', 'reached', '@gao.gov', terms)

get_staff_pages <- function(text){
  # get the appendcices
  appendices <- unlist(map(text, function(x) any(str_detect(x, 'Contact') & 
                                                   str_detect(x, 'Staff'))))
  unlist(text[appendices])
}


get_it <- function(x){
  
  x <- '585588.pdf'
  text <- pdf_text(glue(getwd(), '/pdfs/', x)) %>% 
    str_split(., pattern = "\r\n")

  staff_page <- text %>% get_staff_pages()
  # get the last one for the staff
  staff_page <- staff_page[length(staff_page)]
  staff_page <- str_replace_all(str_trim(staff_page), "\\s+", " ") 
  staff_page <- str_replace_all(str_trim(staff_page), "Page .*", " ")
  staff_page <- str_extract(staff_page, 'include .*|above.*')
  staff_page <- str_replace(staff_page, 'include |above\\,', '')
  staff_page <- str_replace(staff_page, '\\([:digit:]+\\)', '')
  staff_page <- str_replace(staff_page, '\\.', '')
  staff_page <- stri_replace_last_regex(staff_page, '\\.', '')
  staff_page <- staff_page %>% str_squish()

  staff = staff_page %>% str_split(',(?! Jr\\.|Sr\\.)|;|\\. Additional assistance was provided by| and')
  staff = staff[[1]]
  
  staff = staff %>% stringr::str_trim()
  
  staff = as.character(str_replace_all(staff, collapse(terms, sep = '|'), ''))
  staff = staff %>% str_trim()
  staff
  
  
}



get_it('585588.pdf')

