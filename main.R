library(plyr)
library(dplyr)
library(IRanges)
library(GenomicRanges)

# Examples
sp_genes <- read.csv('./data/base/atroparvus_genes.csv')
chr_to_el <- read.csv('./configs/chr_el_coordinates.csv', na.strings = 0) %>% filter(sp == 'atroparvus')

sp_gr <- GRanges(
  seqnames = sp_genes$chr,
  ranges = IRanges(start = sp_genes$start, end = sp_genes$end, names = sp_genes$name),
  strand = sp_genes$strand
)

ce_gr <- GRanges(
  seqnames = chr_to_el$el,
  ranges = IRanges(
    start = chr_to_el$el_start,
    width = chr_to_el$chr_length,
    names = chr_to_el$chr
  ),
  strand = chr_to_el$strand
)

genes_on_elements <- lapply(names(ce_gr), function(scf){
  scf_on_el <- ce_gr[names(ce_gr) == scf]
  genes_on_scf <- sp_gr[seqnames(sp_gr) == scf]
  scf_strand <- as.character(unique(strand(scf_on_el)))
  genes_on_el_ranges <- switch(scf_strand,
    '+' = {
      ranges(genes_on_scf) <- shift(ranges(genes_on_scf), start(scf_on_el)-1)
    },
    '-' = {
      ranges(genes_on_scf) <- shift(reverse(ranges(genes_on_scf)), end(scf_on_el -1))
      strand(genes_on_scf) <- invertStrand(strand(genes_on_scf))
    },
    '*' = NULL
  )
  data.frame(genes_on_scf) %>%
    mutate(scf = seqnames, seqnames = unique(seqnames(scf_on_el)), names = names(genes_on_scf))
}) %>%
  bind_rows() %>%
  makeGRangesFromDataFrame(keep.extra.columns = T)
  
viz_genes <- genes_on_elements[seqnames(genes_on_elements) == 1]
viz_scaffolds <- ce_gr[seqnames(ce_gr) == 1]

ggplot() +
  geom_rect(data = data.frame(viz_scaffolds), aes(xmin = start, xmax = end, ymin = 0, ymax = 1, fill = strand), col = 'grey') +
  geom_rect(data = data.frame(viz_genes), aes(xmin = start, xmax = end, ymin = 1, ymax = 2, col = scf)) +
  theme_bw()
