project_dir <- getwd()

grimm_input <- paste0(project_dir, '/data/processed/grimm_input/grimm_input.tsv')
grimm_output <- paste0(project_dir, '/data/processed/grimm_output')
n_anchors <- 2
gap <- 115000

command <- paste0(
  '~/Documents/GRIMM_SYNTENY-2.02/grimm_synt -f ', grimm_input,
  ' -d ', grimm_output,
  ' -n ', n_anchors,
  ' -g ' , gap
)

system(command)