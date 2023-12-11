library(purrr)
library(furrr)

plan(multisession)

targets %$%
  map2(report, files, ~ parse_pdf(.x, .y))

targets %$%
  future_map2(report, files, ~ iggi::parse_pdf(.x, .y))
