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


split(scfs_on_els_gr, scfs_on_els$sp) %>% # Разделяем по видам
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
        # remap(genes_on_scf_gr, scf_on_els) # Ремапаем
      })
    
  })



ex_genes_on_scf <- GRanges(
  seqnames = c('scf1', 'scf1'),
  ranges = IRanges(
    start = c(1, 300),
    end = c(299, 600),
    names = c('gene1', 'gene2')
  ),
  strand = c('+', '-')
)


ex_scf_on_el <- GRanges(
  seqnames = c('el1'),
  ranges = IRanges(
    start = c(500),
    end = c(3000),
    names = c('scf1')
  ),
  strand = c('-')
)

remap(ex_genes_on_scf, ex_scf_on_el)
