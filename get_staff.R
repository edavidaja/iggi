library(tibble)
library(tidyr)
library(tidytext)
library(dplyr)
library(glue)
library(spacyr)
library(stringi)


terms <- read_csv('./term.csv')
terms <- terms %>% pull(word)
terms <- c('testimony', 'Contacts', 'Staff', 'Natural', 'Resources', 'Environment', 'reached', '@gao.gov', 'Acknowledgements', terms)

get_staff_pages <- function(text){
  # get the appendcices
  appendices <- unlist(map(text, function(x) any(str_detect(x, 'Contact') & 
                                                   str_detect(x, 'Staff'))))
  unlist(text[appendices])
}


get_staff_page <- function(x){
  
  #x <- '694656.pdf'
  
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
  staff_page <- stri_replace_last_regex(staff_page, '\\.', '')
  staff_page <- staff_page %>% str_squish()
  
  ads <- str_extract(staff_page, '.*\\(Assistant.*Director(|.*)\\)')
  staff <- str_extract(staff_page, '\\(Assistant.*Director(|.*)\\).*') %>% str_replace('\\(Assistant.*Director(|.*)\\)', '')

  
  staff = list(ads = ads, staff = staff)
  staff = map(staff, function(x) as.character(str_replace(x, '\\(.*\\)', '') %>% str_squish()))
  staff = staff %>% str_split(',(?! Jr\\.|Sr\\.)|;|\\. Additional assistance was provided by| and')

  staff = map(staff, function(x) as.character(str_trim(x)))
  
  staff = map(staff, function(x) as.character(str_replace_all(x, collapse(terms, sep = '|'), '')))
  staff = map(staff, function(x) as.character(x %>% str_squish()))
  list(`Assistants Directors` = staff[[1]], Staff = staff[[2]])
  
  
}



get_staff_page('694656.pdf')

