# boilerplates.R

remove_page_numbers <- function(page) {
  page[!str_detect(page, "Page.+GAO")]
}

