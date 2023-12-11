#' Measure central tendency
#' 
#' @param x a vector
Mode <- function(x, na.rm = FALSE) {
  # There's no built-in mode?!
  # https://stackoverflow.com/a/25635740
  if(na.rm) {
    x = x[!is.na(x)]
  }
  
  ux <- unique(x)
  return(ux[which.max(tabulate(match(x, ux)))])
}


#' extract sidebar text from page
#' 
#' @param page 
extract_sidebar_text <- function(page) {
  # only header text appears in the left third of the page
  # the right two thirds contains any body text. When extracted by by poppler,
  # the page shows as a wall of leading spaces for most lines, with the
  # title text replacing spaces where relevant
  space_block <- str_locate(page, "^ +")[, 2]
  
  # the space block may contain indented lines, so identify
  # the modal position at which the spaces terminate
  end_block <- Mode(space_block)
  substr(page, 1, end_block) %>% 
    str_flatten() %>% 
    str_squish()
}

clip_sidebar_text <- function(page) {
  space_block <- str_locate(page, "^ +")[,2]
  
  if (is.na(Mode(space_block))) {
    return(page)
  }
  
  # if page is only indented by one space block is a parsing artefact
  if (Mode(space_block) == 1) {
    return(page)
  }
  
  # if page contains bullets then indentation will be wacky and page
  # should be returned as is
  if (any(str_detect(page, "\u2022"))) {
    return(page)
  }
  
  end_block <- Mode(space_block)
  str_sub(page, start = end_block)
}
