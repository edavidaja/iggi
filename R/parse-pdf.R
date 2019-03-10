library(pdftools)
library(jsonlite)
library(purrr)
library(furrr)
library(stringr)
library(tibble)
library(dplyr)

source("footnotes.R")
source("sidebar-text.R")
source("agency-comments.R")
source("get-gao-citations.R")
source("legal-citations.R")
source("boilerplates.R")

parse_pdf <- function(file) {
  # extract table of contents and report text

  toc <- pdf_toc(file) %>%
    unlist(., use.names = FALSE)

  text <- pdf_text(file) %>%
    str_split(., pattern = "\r\n")

  footnotes <- map(text, extract_footnotes) %>%
    bind_rows() %>% 
    filter(
      str_length(index) < 3,
      index != "0",
      str_detect(text, "[A-z]")
      )

  sidebar <- map_chr(text, extract_sidebar_text)

  gao_citations <- get_gao_citations(text)

  agency_comments <- get_comments(file, text)

  legal_citations <- get_legal_citations(footnotes)
  
  text <- text %>%
    map(remove_page_numbers) %>% 
    map(clip_footnotes) %>%  
    map(markdownify_footnotes) %>% 
    map(clip_sidebar_text)

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
  filter(lubridate::year(published) > 2000, !is.na(target)) %>%
  mutate(files = paste0("pdfs/", basename(target))) %>% 
  sample_n(15)

infiles <- targets$files %>%
  future_map(parse_pdf)

