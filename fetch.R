library(httr)
library(readr)
library(rvest)
library(dplyr)
library(purrr)
library(tibble)
library(tidyr)
library(lubridate)
library(stringr)
library(magrittr)
library(glue)

mmddyyyy <- function(x) {
  glue("{str_pad(month(x), width = 2, side = 'left', pad='0')}/{str_pad(day(x), width = 2, side = 'left', pad='0')}/{year(x)}")
  }

max_report_date <- function() {
  if(file.exists("metadata.csv")) {
    meta <- read_csv("metadata.csv")
    dt <- max(meta$published, na.rm = TRUE)
  } else {
    dt <- Sys.Date()
  }
  mmddyyyy(dt)
}

min_report_date <- function() {
  if(file.exists("metadata.csv")) {
    meta <- read_csv("metadata.csv")
    dt <- as.character(min(meta$published, na.rm = TRUE))
    mmddyyyy(dt)
  } else {
    "01/01/1974"
  }
}


#' @param offset an integer
#' @param start_date a date, in MM/DD/YYYY form
#' @param end_date a date, in MM/DD/YYYY form
get_page_list <- function(offset, start_date, end_date) {
  RETRY(
    verb = "GET",
    url = "https://www.gao.gov/browse/date/custom",
    query = list(
      rows = 50,
      o = offset,
      now_sort = "issue_date_dt+desc,title_sort",
      adv_begin_date = start_date, # "01/01/1974",
      adv_end_date = end_date      # "08/18/2018"
    ))
  }

init <- get_page_list("0", start_date = max_report_date(), mmddyyyy(Sys.Date())) %>%
  content("text") %>% 
  read_html()

search_result_title <- init %>% 
  html_node(".scannableTitle") %>% 
  html_text()

results <- str_match(search_result_title, "(of )([0-9,]+)( items)")[,3] %>%
  str_replace(., ",", "") %>% 
  as.numeric()
url <- "https://www.gao.gov/browse/date/custom"

offsets <- seq(0, results, by = 50)

meta <- offsets %>% 
  map(safely(~{
      
      if (.x %% 1000 == 0) print(.x)
      Sys.sleep(.1)
      
      r <- get_page_list(
          .x,
          ifelse(file.exists("metadata.csv"), max_report_date(), min_report_date()),
          mmddyyyy(Sys.Date())
        )
      x <- read_html(r) %>% 
        html_nodes(".grayBorderTop") %>% 
        map(., .f = html_nodes, "a")
      
      spans <- x %>%  
        map(., .f = html_nodes, "span") %>% 
        map(., .f = html_text) %>% 
        map(possibly(~set_names(x = .x, c("title", "report_number", "pub_date")), otherwise = c(title = "", report_number="", pub_date=""))) %>% 
        map(., .f = as_data_frame) %>% 
        map_dfr(., .f = ~rownames_to_column(df = .x) %>% spread(., rowname, value)) %>% 
        separate(col = report_number, into = c("report"), sep = ":", extra = "drop" ) %>%
        separate(col = pub_date, into = c("published", "public"), sep = "\\.", extra = "drop") %>% 
        mutate_all(str_squish)
      
      link_targets <- x %>%
        map(., .f = html_text) %>% 
        map_dbl(., .f = ~detect_index(., ~str_detect(., "View Report")))
      
      reportLinks <- x %>%
        map(., .f = html_attr, "href") %>% 
        map2(.x = ., .y = link_targets, .f = ~pluck(.x, .y)) %>%
        replace_na(replace = "") %>%
        flatten_chr()
      
      df <- spans %>% 
        mutate(
          target = reportLinks,
          published = str_match(published, pattern = "(.)(:)(.+)")[,4],
          public = str_match(public, pattern = "(.)(:)(.+)")[,4]
        ) %>% 
        mutate_at(
          vars(published, public),
          mdy
        )
      df
    }
  ))

z <- meta %>% transpose %$% result %>% bind_rows()
write_csv(z, "metadata.csv", append = TRUE)
