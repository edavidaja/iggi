options(
  clustermq.scheduler = "slurm",
  clustermq.template = here::here("inst", "clustermq.slurm.tmpl")
)

library(clustermq)

res <- Q(iggi::parse_pdf, report_id = targets$report, file = targets$files, n_jobs = 2)
