bed_to_granges <- function(path, metacolumns = NULL){
  bed <- read.table(path)
  colnames(bed)[1:4] <- c('chr', 'start', 'end', 'strand')
  meta_c <- 5:ncol(bed)
  meta_n <- 1:length(meta_c)
  if(is.null(metacolumns)){
    colnames(bed)[meta_c] <- c(paste0('meta', meta_n))
  } else if(!is.null(metacolumns) && length(metacolumns) < length(meta_n)){
    warning('Length of user defined metacolumn names less than existing')
  } else {
    colnames(bed)[meta_c] <- metacolumns
  }
  with(bed, GRanges(seqnames = chr, ranges = IRanges(start = start, end = end), strand = strand, id = id, uid = uid))
}