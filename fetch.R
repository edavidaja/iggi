library(httr)
library(rvest)
library(tidyverse)
library(lubridate)

init <- read_html("https://www.gao.gov/browse/date/custom?&rows=50&o=&now_sort=issue_date_dt+desc%2Ctitle_sort+asc&adv_begin_date=01/01/1974&adv_end_date=08/18/2018")

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
      
      r <- RETRY(
        verb = "GET",
        url = url,
        query = list(
          o = .x,
          now_sort="issue_date_dt+desc,title_sort+asc",
          adv_begin_date="01/01/1974",
          adv_end_date="08/18/2018",
          rows=50
        )
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


library(magrittr)
z <- meta %>% transpose %$% result %>% bind_rows()
write_csv(z, "metadata.csv")
