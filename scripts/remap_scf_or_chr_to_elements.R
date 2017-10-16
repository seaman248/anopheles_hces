library(plyr)
library(dplyr)
library(IRanges)
library(GenomicRanges)

source('./R/remap.R')

scfs_on_els <- read.csv('./configs/chr_el_coordinates.csv') # Координаты скэффолда/хромосомы на элементе

scfs_on_els_gr <- GRanges(
  seqnames = scfs_on_els$el,
  ranges = IRanges(
    start = scfs_on_els$el_start,
    width = scfs_on_els$chr_length,
    name = scfs_on_els$chr
  ),
  strand = scfs_on_els$strand,
  spec = scfs_on_els$sp
)


genes_on_elements <- split(scfs_on_els_gr, scfs_on_els$sp) %>% # Разделяем по видам
  lapply(function(scf_on_els_gr){
    
    spec <- unique(scf_on_els_gr$spec) # Сохраняем вид
    
    genes_on_scf <- paste0('./data/base/', spec, '_genes.csv') %>% # Читаем гены на скэффолдах / хромосомах вида
      read.csv()
    
    # Преобразуем их в GRanges
    genes_on_scf_gr <- GRanges( 
      seqnames = genes_on_scf$chr,
      ranges = IRanges(
        start = genes_on_scf$start,
        end = genes_on_scf$end,
        name = genes_on_scf$name
      ),
      strand = genes_on_scf$strand
    )
    
    split(scf_on_els_gr, names(scf_on_els_gr)) %>% # Пошли теперь по скэффолдам / хромосомам
      lapply(function(scf_on_els){
        scf_on_els
        remap(genes_on_scf_gr[seqnames(genes_on_scf_gr) == names(scf_on_els)], scf_on_els) # Ремапаем
      }) %>%
      GRangesList()
    
  }) %>% lapply(function(sp_genes_on_elements){
    unlist(sp_genes_on_elements, recursive = T, use.names = F)
  })

# Проверяем genes_on_elements
# test_sp <- 'atroparvus'
# test_el <- 5
# 
# test_plots <- lapply(c('albimanus', 'atroparvus', 'gambiae'), function(test_sp){
#   lapply(1:5, function(test_el){
#     test_genes_on_el <- as.data.frame(genes_on_elements[[test_sp]]) %>% filter(seqnames == test_el)
#     test_scf_on_el <- scfs_on_els %>% filter(sp == test_sp, el == test_el)
#     
#     ggplot() +
#       geom_rect(data = test_genes_on_el, aes(xmin = start, xmax = end, ymin = 0, ymax = 1, fill = strand)) +
#       geom_rect(data = test_scf_on_el, aes(xmin = el_start, xmax = (el_start + chr_length), ymin = 1, ymax = 2), fill = 'white', col = 'red') +
#       geom_text(data = test_scf_on_el, aes(x = (el_start * 2 + chr_length)/2, y = 1.5, label = chr), angle = 90) +
#       ggtitle(paste0(test_sp, '/', test_el))
#   })
# })
# 
# do.call(grid.arrange, c(test_plots[[3]], nrow = 5))

# Save results
lapply(names(genes_on_elements), function(sp){
  sp_genes_on_elements <- genes_on_elements[[sp]]
  sp_genes_on_elements$names <- names(sp_genes_on_elements)
  filename <- paste0(sp, '.bed')
  filepath <- paste0('./data/processed/genes_on_elements/', filename)
  write.table(sp_genes_on_elements, filepath, quote = F, sep = '\t', row.names = F, col.names = F)
})
