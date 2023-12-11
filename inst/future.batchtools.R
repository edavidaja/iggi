library(future.batchtools)
library(furrr)

plan(
  list(
    batchtools_slurm,
    multisession
    )
  )

targets %$%
  future_map2(report, files, ~ iggi::parse_pdf(.x, .y))
