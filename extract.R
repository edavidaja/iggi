library(pdftools)
library(jsonlite)
library(purrr)
library(stringr)

read_pdf <- function(file) {
  list(
    meta = pdf_toc(file),
    text = pdf_text(file)
  )
}

get_citations <- function(text){
  
  # its always to followed by 2-4
  citations <- str_extract_all(text, 'GAO-.{2}-.{2,4}', simplify = FALSE)
  # unlist
  citations <- unlist(citations)
  # remove the punctuation
  citations <- gsub('[[:punct:]]', '', citations)
  # add the dash that got removed back in
  citations <- gsub('GAO', 'GAO-', citations)
  # remove the whitespace
  citations <- stringr::str_trim(citations)
  # your first citation is a self cite
  self <- citations[1]
  # remove it 
  citations <- citations[! citations %in% self]
  citations
}

# 691520.pdf
infile <- read_pdf("pdfs/694425.pdf")

infile$citations <- get_citations(infile$text)


inflat <- str_split(infile$text, pattern = "\r\n")

# drop all children of acknowledgements in toc
# drop last page

infile
