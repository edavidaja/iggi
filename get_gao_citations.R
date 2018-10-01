library(stringr)
library(purrr)

get_gao_citations <- function(text) {
  # its always to followed by 2-4
  citations <- text %>% map(
    str_extract_all, '([:upper:]+(-|\\.)[:digit:]{1,4}(-|\\.).{1,4})|(CC-.{1,})|(FFMSR-.{1,})|(GAGAS-.{1,4}-.{1,4})|(OSP\\(OPA\\).{1,4}-.{1,4})|(B-[:digit:]{5,}.*)',
    simplify = FALSE
    ) 
  # unlist
  # remove the punctuation at the end
  # remove the whitespace
  citations <- unlist(citations) %>% 
    gsub("[[:punct:]]$", "", x = .) %>% 
    str_trim(., side = "both")
  
  if (length(citations) == 0) {
    return (NA_character_)
  } else {
    return(unique(citations))
  }
}



