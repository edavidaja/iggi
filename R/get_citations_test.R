library(readr)
library(tibble)
library(dplyr)
library(tidyverse)

d <- read_csv('metadata.csv')

d <- d %>% dplyr::filter(! is.na(report))


get_citations <- function(text){
  # its always to followed by 2-4
  citations <- str_extract_all(text, '([:upper:]+(-|\\.)[:digit:]{1,4}(-|\\.).{1,5})|(CC-.{1,})|(FFMSR-.{1,})|(GAGAS-.{1,4}-.{1,4})|(OSP\\(OPA\\).{1,4}-.{1,4})|(B-[:digit:]{5,}.*)', simplify = FALSE)
  # unlist
  citations <- unlist(citations)
  # remove everything after last period
  citations <- str_replace(citations, "\\.[^\\.] $", "")
  # also remove last period
  citations <- str_replace(citations, "\\.$", "")
  # remove the whitespace
  citations <- stringr::str_trim(citations) %>% stringr::str_squish()
  
  
  if (length(citations) == 0){
    return (NA_character_)
  }else{
    return(citations)
  }
}


get_citations('AA-98-29(1)')


d$first_chars <- map_chr(str_split(d$report, '-'), function(x) x[[1]])
d$citations <- map_chr(d$report, function(x) get_citations(x))

d %>% dplyr::group_by(first_chars) %>% dplyr::sample_n(2, replace = T) %>% dplyr::distinct(report, citations) %>% print(n=200)



d %>% filter(! is.na(citations)) %>% filter(grepl('A-|B-', report)) %>% print(n = 50)
d %>% filter(is.na(citations)) %>% filter(grepl('A-|B-', report)) %>% print(n = 50)

d %>% dplyr::filter(grepl('AIMD', report))
