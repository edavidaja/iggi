#' @importFrom httr GET

# accessor functions for grabbing the citation
citation1 <- function(x) x$results$citations
citation2 <- function(x) x$citation

# predicate function to reject "reporter" type citations
irrelevant <- function(x) x$type == "reporter"

get_legal_citations <- function(footnotes) {
  footnotes$text %>%
    map(
      ~ GET(
        # todo: pararmeterize citaiton URL?ß 
        url = "https://citation.fly.dev/citation/find",
        query = list(text = .x)
      )
    ) %>% 
    map(~content(.x, "parsed")) %>% 
    map(~pluck(.x, citation1)) %>%
    compact() %>% 
    flatten() %>% 
    discard(.p = irrelevant) %>% 
    map(~pluck(.x, citation2)) %>%
    compact() %>%
    flatten_chr() %>% 
    unique()
}
