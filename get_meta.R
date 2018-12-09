library(magrittr)
library(stringr)
library(spacyr)
library(pdftools)
library(purrr)
library(glue)
#require(rJava)
#library(spacyr)

#spacy_install()
#spacy_initialize()

#gsutil cp *.pdf gs://iggi-data

#pdfs:
#  690028.pdf
#  691520.pdf
#  694174.pdf
#  694188.pdf
#  694320.pdf
#  694425.pdf
#  694432.pdf
#  694759.pdf

file.exists(fil)


fil <- './pdfs/694320.pdf'

text <- pdf_text(fil) %>% 
  str_split(., pattern = "\r\n")
text


get_staff_pages <- function(text){
  # get the appendcices
  appendices <- unlist(map(text, function(x) any(str_detect(x, 'Contact') & 
                                                   str_detect(x, 'Staff'))))
  unlist(text[appendices])
}


staff_page <- text %>% get_staff_pages()
# get the last one for the staff
staff_page <- staff_page[length(staff_page)]
staff_page <- str_replace_all(str_trim(staff_page), "\\s+", " ") 
staff_page <- str_replace_all(str_trim(staff_page), "Page .*", " ") 


staff_page
staff = staff_page %>% str_split(',(?! Jr\\.|Sr\\.)|;|\\. Additional assistance was provided by| and')
staff = staff[[1]]

staff = staff %>% stringr::str_trim()

library(stringr)
terms
staff = str_replace_all(staff, terms, '')
staff
# (                # begin capture
#   [A-Z]            # one uppercase letter  \ First Word
#     (?=\s[A-Z])      # must have a space and uppercase letter following it
#   (?:                # non-capturing group
#       \s               # space
#     [A-Z]            # uppercase letter   \ Additional Word(s)
#     [a-z]+           # lowercase letter   /
#   )+              # group can be repeated (more words)
# ) 

regex = '([A-Z].+(?=\\s[A-Z])(?:\\s[A-Z].+)+)'



staff = str_extract_all(staff, regex)
staff = unlist(staff)
staff = str_replace(staff, '\\(|\\)', '')  
staff = str_replace(staff, '\\. [:digit:].*', '')
staff = str_replace(staff, '.* at ', '')
staff = str_replace(staff, '.* include ', '')
staff = str_replace(staff, 'GAO Contact In addition to the contact named above', '')
staff = str_replace(staff, 'Analyst-in-Charge', '')
staff = str_replace(staff, 'Acknowledgments', '')
staff = str_replace(staff, 'Staff', '')
staff = str_replace(staff, ':', '')
staff = str_replace(staff, 'Appendix [:alpha:]{1,3}', '')
staff = str_replace(staff, 'Appendix [:alpha:]{1,3}:', '')
staff = str_replace(staff, 'Assistant Directors', '')
staff = str_replace(staff, 'Assistant Director', '')
staff = str_replace(staff, '[:alpha:]@gao.gov', '')
staff = str_replace(staff, 'GAO Contact', '')
staff = str_trim(staff)
staff = str_replace(staff, '[:punct:]$', '')
staff = str_trim(staff)
staff = staff[staff != '']

staff

