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
# 691520.pdf
infile <- read_pdf("pdfs/691526.pdf")
inflat <- str_split(infile$text, pattern = "\r\n")

# drop all children of acknowledgements in toc
# drop last page

infile