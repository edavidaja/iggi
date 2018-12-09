library(tibble)
library(tidyr)
library(tidytext)
library(dplyr)
library(glue)
library(readr)

fils = list.files('./pdfs')

get_staff_pages <- function(text){
  # get the appendcices
  appendices <- unlist(map(text, function(x) any(str_detect(x, 'Contact') & 
                                                   str_detect(x, 'Staff'))))
  unlist(text[appendices])
}




get_it <- function(x){

  text <- pdf_text(glue(getwd(), '/pdfs/', x)) %>% 
    str_split(., pattern = "\r\n")
  text
  
  staff_page <- text %>% get_staff_pages()
  # get the last one for the staff
  staff_page <- staff_page[length(staff_page)]
  staff_page <- str_replace_all(str_trim(staff_page), "\\s+", " ") 
  
  data_frame(text = staff_page, file = x)
  
}


df = map_dfr(fils, function(x) get_it(x))


df = df %>%  unnest_tokens(word, text, token = 'ngrams', n = 3, to_lower = F) %>% count(word, sort = T)


cut_off = quantile(df$n, probs = seq(0, 1, .01))['99%']
cut_off

df <- df %>% filter(n >= 11)
df %>% print(n=500)

write_csv(df, 'term.csv')





