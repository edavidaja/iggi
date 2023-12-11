# download pdfs from web -------
library(dplyr)
library(magrittr)

# downloaded <- list.files(path = "pdfs")
# 
# infile <- readr::read_csv(here::here("inst", "metadata.csv")) %>% 
#   mutate(file = basename(target)) %>% 
#   filter(
#     target != "", !(file %in% downloaded),
#     lubridate::year(published) == 2017
#   )
# 
# infile$target %>%
#   walk(safely(
#     ~{
#       Sys.sleep(.1)
#       download.file(
#         url = glue("https://www.gao.gov{.x}"),
#         destfile = glue("{here::here('pdfs')}/{basename(.x)}"),
#         mode = "wb"
#       )}
#   ))

# list pdfs for parsing ---------

targets <- readr::read_csv(here::here("inst", "metadata.csv")) %>% 
  filter(lubridate::year(published) == 2017, !is.na(target)) %>%
  mutate(files = here::here("pdfs/", basename(target))) %>% 
  sample_n(10)
