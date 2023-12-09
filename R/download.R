library(purrr)
library(dplyr)
library(glue)

downloaded <- list.files(path = "pdfs")

infile <- readr::read_csv("metadata.csv") %>% 
  mutate(file = basename(target)) %>% 
  filter(
    target != "", !(file %in% downloaded),
    lubridate::year(published) == 2017
    )

infile$target %>%
  walk(safely(
    ~{
      Sys.sleep(.5)
      download.file(
        url = glue("https://www.gao.gov{.x}"),
        destfile = glue("pdfs/{basename(.x)}"),
        mode = "wb"
      )}
  ))
