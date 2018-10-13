library(stringr)
library(dplyr)
library(purrr)

# footnotes appear at the bottom of a page as single number
# that starts and ends the line
extract_footnotes <- function(page) {
 
  if (any(str_detect(page, "^[ 0-9]+$"))) {
    footnote_start <- c(
        str_which(page, "^[ 0-9]+$"),
        length(page) - 1
      )
    
    footnote_length <- c(diff(footnote_start) - 1, NA)
    
    footnote_position <- 
      data_frame(footnote_start, footnote_length) %>% 
        mutate(footnote_end = footnote_start + footnote_length) %>%
        filter(!is.na(footnote_length))
    
    footnote_text <- footnote_position %>%   
      map2_chr(
        .x = .$footnote_start, .y = .$footnote_end,
        .f = ~str_c(page[(.x+1):.y], collapse = " ")
      )
    
    footnote_index <- footnote_position$footnote_start %>% 
      map_chr(~page[[.x]])
    
    list(
      index = footnote_index,
      text  = footnote_text
      ) %>% map(str_squish)
    }
  }
