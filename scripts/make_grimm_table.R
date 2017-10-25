source('./R/bed_to_ranges.R')

input_path <- './data/processed/uid_genes_on_elements'

genes <- unlist(lapply(dir(input_path, full.names = T), function(path){
  sp <- sub(pattern = '.bed', replacement = '', basename(path))
  genes <- bed_to_granges(path, metacolumns = c('id', 'uid'))
  genome(genes) <- sp
  genes
}))

names(genes) <- lapply(genes, function(gr){genome(gr) %>% unique()}) %>% unlist()

grimm_table <- lapply(1:length(genes), function(n){
  gr <- genes[[n]]
  res <- data.frame(gr$uid, seqnames(gr), start(gr), width(gr), strand(gr))
  if(n > 1) {
    res <- res[, 2:5]
  }
  res
}) %>%
  bind_cols()

filepath <- './data/processed/grimm_input/grimm_input.tsv'
con <- file(filepath, open = 'wt')
writeLines(paste0('# Genome_', 1:length(names(genes)), ': ', names(genes)), con)
write.table(grimm_table, con, quote = F, sep = '\t', col.names = F, row.names = F)
close(con)