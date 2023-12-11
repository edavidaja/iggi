#' @import tesseract
#' @import pdftools

#' @export
get_comments_text <- function(file, appendix_page) {
  # need to comine all appendix pages into a single str  
  # convert the page of the pdf
  tmp <- tempfile(fileext = ".png")
  
  pngfile <- pdf_convert(
    pdf = file,
    dpi = 600,
    pages = appendix_page,
    format = "png",
    filenames = tmp
    )
  # teseract it
  text <- ocr(pngfile)
  text
}

#' @export
get_comments <- function(file, text) {
  # get the appendcices
  appendices <- text %>% 
    map(~any(str_detect(.x, 'Appendix') & str_detect(.x, 'Comments'))) %>% 
    unlist()
  
  appendix_pages <- which(appendices)
  # remove the first. its going to be the toc
  appendix_pages <- appendix_pages[-1]
  # now ocr the text 
  map_chr(appendix_pages, ~get_comments_text(file, .x)) %>% 
    str_split(., pattern = "\n")  
}

