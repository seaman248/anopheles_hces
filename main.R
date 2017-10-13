library(plyr)
library(dplyr)
library(IRanges)
library(GenomicRanges)

source('./R/remap.R')

# Examples

scfs_on_els <- read.csv('./configs/chr_el_coordinates.csv')

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
