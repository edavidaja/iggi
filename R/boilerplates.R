#' @export
remove_page_numbers <- function(page) {
  page[!str_detect(page, "Page.+GAO")]
}

#' a page with instructions for contacting gao appears at the end of 
#' most reports. This function detects and removes that page by searching
#' for the GAO phone number, which should not appear in the body of
#' any report
#' @param text the text of a report as extracted by `pdf_text()`
#' @export
remove_contact_page <- function(text) {
  discard(
    .x = text,
    .p = ~any(str_detect(.x, fixed("(202) 512-6000"))))
}
