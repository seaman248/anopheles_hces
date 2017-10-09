library(biomaRt)

species <- c('gambiae', 'albimanus')

vb_host <- 'biomart.vectorbase.org'
vb_base <- listMarts(host=vb_host)$biomart[1]
vb_datasets <- as.character(listDatasets(useMart(vb_base, host = vb_host))$dataset)
vb_species <- unlist(lapply(species, function(sp){
  vb_datasets[grep(sp, vb_datasets)]
}))

# get genes for each species

genes <- lapply(vb_species, function(vb_spec){
  vb_mart <- useMart(vb_base, host = vb_host, dataset = vb_spec)
  attr = c('ensembl_gene_id', 'chromosome_name', 'start_position', 'end_position', 'strand')
  getBM(mart = vb_mart, attributes = attr)
})

names(genes) <- species

# get orthologs for all species

sp_1_mart <- useMart(vb_base, host = vb_host, dataset = vb_species[1])

sp_1_attrs <- listAttributes(sp_1_mart)[, 1]
sp_1_attrs <- sp_1_attrs[grep('homolog_ensembl_gene', sp_1_attrs)]

sps_attrs_names <- unlist(lapply(species, function(sp){
  sp_1_attrs[grep(sp, sp_1_attrs)]
}))

orthologs <- getBM(mart = sp_1_mart, attributes = c('ensembl_gene_id', sps_attrs_names))
colnames(orthologs) <- species

# Save datasets: genes, orthologs
