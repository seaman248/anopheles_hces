# --parse blocks
library(GenomicRanges)
library(dplyr)
grimm_blocks <- read.table('data/processed/grimm_output/blocks.txt')[, -1]

gr_blocks <- lapply(seq(1, ncol(grimm_blocks), 4), function(s_col){
  cols <- s_col:(s_col + 3)
  sp_blocks <- grimm_blocks[, cols]
  colnames(sp_blocks) <- c('chr', 'start', 'width', 'strand')
  with(sp_blocks, GRanges(seqnames = chr, ranges = IRanges(start = start, width = width), strand = strand, block_id = rownames(sp_blocks)))
}) %>%
  GRangesList()

# --parse report
library(stringr)
grimm_report <- readLines('./data/processed/grimm_output/report.txt')

sp_names <- grimm_report[grep('genome\\d', grimm_report)] %>%
  gsub(pattern = '  genome\\d:             ', replacement = '')

blocks_info <- lapply(grep('block \\d+: \\d+ anchors', grimm_report), function(row_name){
  ba <- grimm_report[row_name] %>%
    str_extract_all(pattern='\\d+')
  
  min_support <- grimm_report[row_name+3] %>%
    str_extract_all(pattern='\\d+.\\d+') %>%
    unlist() %>%
    as.numeric() %>%
    min()
  
  data.frame(
    block_id = ba[[1]][1],
    anchors = ba[[1]][2],
    min_support = min_support
  )
}) %>%
  bind_rows()
# 

# --combine reports
names(gr_blocks) <- sp_names

gr_blocks_with_meta <- lapply(gr_blocks, function(blocks_set){
  blocks_set$anchors <- blocks_info$anchors
  blocks_set$min_support <- blocks_info$min_support
  blocks_set
}) %>%
  GRangesList()

names(gr_blocks_with_meta) <- names(gr_blocks)

dir.create('./data/processed/blocks_bed', showWarnings = F)

lapply(names(gr_blocks_with_meta), function(sp_name){
  path <- paste0('./data/processed/blocks_bed/', sp_name, '.bed')
  # gr_blocks_with_meta[[sp_name]]
  write.table(gr_blocks_with_meta[[sp_name]], path, quote = F, row.names = F, col.names = F, sep = '\t')
})