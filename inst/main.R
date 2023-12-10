# download pdfs from web -------

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
      Sys.sleep(.1)
      download.file(
        url = glue("https://www.gao.gov{.x}"),
        destfile = glue("pdfs/{basename(.x)}"),
        mode = "wb"
      )}
  ))

# list pdfs for parsing ---------

targets <- readr::read_csv("metadata.csv") %>% 
  filter(lubridate::year(published) == 2017, !is.na(target)) %>%
  mutate(files = paste0("pdfs/", basename(target))) %>% 
  sample_n(10)
