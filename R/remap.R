remap <- function(genes_on_scf, scf_on_el){
  # genes_on_scf:   GRange  seqname   range     name      strand
  #                         scf1      [1-300]   gene1     +
  #                         scf1      [299-600] gene2     -
  # scf_on_el:      GRange  seqname   range       name      strand
  #                         el1       [15M-20M]   scf1      -
  
  ## Shift ranges
  ranges(genes_on_scf) <- ranges(genes_on_scf) %>%
    shift(shift = start(scf_on_el))
  
  ## If scf has "-" strand:
  ## Add end pseudogene (gap from end of last gene to end of scf)
  ## Scf:    ====================
  ## genes: (+++     ++++________) / + - true genes / _ - pseudogene gap
  
  if(runValue(strand(scf_on_el))[1] == '-'){

    end_gap <- GRanges(
      seqnames = names(scf_on_el),
      ranges = IRanges(
        start = max(end(genes_on_scf)+1),
        end = max(end(scf_on_el)),
        names = c('end_gap')
      ),
      strand = c('*')
    )

    genes_on_scf <- append(genes_on_scf, end_gap)

    ranges(genes_on_scf) <- ranges(genes_on_scf) %>%
      reverse()

    strand(genes_on_scf) <- invertStrand(strand(genes_on_scf))
  }
  
  ## remove gap
  genes_on_scf <- genes_on_scf[names(genes_on_scf) != 'end_gap']
  
  genes_on_el <- GRanges(
    seqnames = seqnames(scf_on_el),
    ranges <- ranges(genes_on_scf),
    strand = strand(genes_on_scf)
  )
  
  return(genes_on_el)
  # genes_on_el:    GRange  seqname   range       name      strand
  #                         el1       [1799-2000] gene1     +
}