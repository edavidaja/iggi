library(readr)
library(tibble)
library(dplyr)
library(tidyverse)


get_citations <- function(text){
  
  # its always to followed by 2-4
  citations <- str_extract_all(text, '([:upper:]+(-|\\.)[:digit:]{1,4}(-|\\.).{1,4})|(CC-.{1,})|(FFMSR-.{1,})|(GAGAS-.{1,4}-.{1,4})|(OSP\\(OPA\\).{1,4}-.{1,4})|(B-[:digit:]{5,}.*)', simplify = FALSE)
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


