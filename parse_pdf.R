library(pdftools)
library(jsonlite)
library(purrr)
library(furrr)
library(stringr)
library(tibble)
library(dplyr)

source("footnotes.R")
source("sidebar_text.R")
source("agency_comments.R")
source("get_gao_citations.R")
source("legal-citations.R")

parse_pdf <- function(file) {
  # extract table of contents and report text

  toc <- pdf_toc(file) %>%
    unlist(., use.names = FALSE)

  text <- pdf_text(file) %>%
    str_split(., pattern = "\r\n")

  footnotes <- map(text, extract_footnotes) %>%
    bind_rows()

  sidebar <- map_chr(text, extract_sidebar_text)

  gao_citations <- get_gao_citations(text)

  agency_comments <- get_comments(file, text)

  legal_citations <- get_legal_citations(footnotes)

  list(
    toc             = toc,
    text            = text,
    footnotes       = footnotes,
    sidebar         = sidebar,
    gao_citations   = gao_citations,
    agency_comments = agency_comments,
    legal_citations = legal_citations
  )

}

targets <- readr::read_csv("metadata.csv") %>% 
  filter(lubridate::year(published) > 2010, !is.na(target)) %>%
  mutate(files = paste0("pdfs/", basename(target))) %>% 
  sample_n(5)

infiles <- targets$files %>% future_map(parse_pdf)

