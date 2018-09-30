library(stringr)
# There's no built-in mode?!
# https://stackoverflow.com/a/25635740/
Mode <- function(x, na.rm = FALSE) {
  if(na.rm) {
    x = x[!is.na(x)]
  }
  
  ux <- unique(x)
  return(ux[which.max(tabulate(match(x, ux)))])
}


# only header text appears in the left third of the page
# the right two thirds contains any body text. When extracted by by poppler,
# the page shows as a wall of leading spaces for most lines, with the
# title text replacing spaces where relevant
extract_sidebar_text <- function(page) {
  space_block <- str_locate(page, "^ +")
  
  # the space block may contain indented lines, so identify
  # the modal position at which the spaces terminate
  end_block <- Mode(space_block[,2])
  substr(page, 1, end_block) %>% 
    str_flatten() %>% 
    str_squish()
}

