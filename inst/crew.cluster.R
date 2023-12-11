library(crew.cluster)

controller <- crew_controller_slurm(
  name = "parse_pdf",
  workers = 5L,
  seconds_idle = 300,
  slurm_memory_gigabytes_per_cpu = 1,
  script_lines = paste0("export PATH=",Sys.getenv("R_HOME"),"/bin:$PATH"),
  verbose = TRUE
)

controller$start()

results <- controller$map(
  command = iggi::parse_pdf(.x, .y),
  iterate = list(
    .x = targets$report,
    .y = targets$files
  ),
  verbose = TRUE
)

finaldata <- results$result

controller$terminate()
