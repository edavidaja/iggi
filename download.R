library(purrr)
library(dplyr)
library(glue)

infile <- readr::read_csv("metadata.csv") %>% 
  filter(target != "") %>% 
  mutate(file = basename(target))

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
