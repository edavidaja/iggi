library(pdftools)
library(jsonlite)
library(purrr)
library(furrr)
library(stringr)
library(tibble)
library(dplyr)
library(magrittr)

source("R/footnotes.R")
source("R/sidebar-text.R")
source("R/agency-comments.R")
source("R/gao-citations.R")
source("R/legal-citations.R")
source("R/boilerplates.R")

parse_pdf <- function(report_id, file) {
  # extract table of contents and report text

  toc <- pdf_toc(file) %>%
    unlist(., use.names = FALSE)

  text <- pdf_text(file) %>%
    str_split(., pattern = "\n")

  footnotes <- map(text, extract_footnotes) %>%
    bind_rows() %>% 
    filter(
      str_length(index) < 3,
      index != "0",
      str_detect(text, "[A-z]")
      )

  sidebar <- map_chr(text, extract_sidebar_text)

  gao_citations <- get_gao_citations(text)

  # agency_comments <- get_comments(file, text)

  legal_citations <- get_legal_citations(footnotes)
  
  text <- text %>%
    map(remove_page_numbers) %>% 
    map(clip_footnotes) %>%  
    map(markdownify_footnotes) %>% 
    map(clip_sidebar_text)

  parsed_pdf <- list(
#    toc             = toc,
 #   text            = text,
    footnotes       = footnotes,
    sidebar         = sidebar,
    gao_citations   = gao_citations,
   # agency_comments = agency_comments,
    legal_citations = legal_citations
  )

  jsonlite::write_json(
    parsed_pdf, 
    path = glue::glue("parsed/{report_id}.json")
    )
}

targets <- readr::read_csv("metadata.csv") %>% 
  filter(lubridate::year(published) == 2017, !is.na(target)) %>%
  mutate(files = paste0("pdfs/", basename(target))) %>% 
  sample_n(10)

targets %$%
  map2(report, files, ~ parse_pdf(.x, .y))

