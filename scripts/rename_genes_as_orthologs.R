orthologs <- read.csv('./data/base/orthologs.csv', na.strings = '') %>% na.omit()

# Find replicates
dup_orths <- unlist(apply(orthologs, 2, function(col){
  which(duplicated(col) & duplicated(col, fromLast = T))
}))

dup_orths <- dup_orths[!duplicated(dup_orths)]

clean_orths <- orthologs[-dup_orths, ]

clean_orths$uid <- paste0('ano', 1:nrow(clean_orths))

write.csv(clean_orths, './data/processed/clean_orths.csv')

# assign uid to .bed files
bed_files <- dir('./data/processed/genes_on_elements', full.names = T)

result_table <- lapply(colnames(orthologs), function(sp){
  bed_file <- bed_files[grep(sp, bed_files)] %>%
    read.table()
  colnames(bed_file) <- c('el', 'start', 'end', 'width', 'strand', 'id')
  ids <- match(clean_orths[, sp], bed_file$id)
  # clean_orths[ids, sp]
  data.frame(uid = clean_orths$uid, bed_file[ids, ]) %>%
    select(el, start, end, strand, id, uid)
}) %>%
  bind_cols() %>%
  na.omit()

# devide result table by species
devided_tables <- lapply(seq(1, ncol(result_table), 6), function(start_col){
  cols_to_select <- c(start_col:(start_col+5))
  sp_result_table <- result_table[, cols_to_select]
})
names(devided_tables) <- colnames(orthologs)

# save results
lapply(names(devided_tables), function(sp){
  sp_devided_table <- devided_tables[[sp]]
  fp <- paste0('./data/processed/uid_genes_on_elements/', sp, '.bed')
  write.table(sp_devided_table, fp, row.names = F, col.names = F, quote = F, sep = '\t')
})