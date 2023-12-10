options(
  clustermq.scheduler = "slurm",
  clustermq.template = "clustermq.slurm.tmpl"
)

library(clustermq)

res <- Q(parse_pdf, targets$report, targets$files, n_jobs = 1)
