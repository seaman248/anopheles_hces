library(biomaRt)


# Define which species will be download
species <- c('gambiae', 'albimanus', 'atroparvus')

# Define variables for  biomart
vb_host <- 'biomart.vectorbase.org'
vb_base <- listMarts(host=vb_host)$biomart[1] # like vb_gene_mart_1708
vb_datasets <- as.character(listDatasets(useMart(vb_base, host = vb_host))$dataset) # Download all names of datasets
vb_species <- unlist(lapply(species, function(sp){
  vb_datasets[grep(sp, vb_datasets)] # find the name of dataset according to name of species
}))

# Download genes for each species

genes <- lapply(vb_species, function(vb_spec){
  vb_mart <- useMart(vb_base, host = vb_host, dataset = vb_spec)
  attr = c('ensembl_gene_id', 'chromosome_name', 'start_position', 'end_position', 'strand')
  getBM(mart = vb_mart, attributes = attr)
})

names(genes) <- species

# Download orthologs for all species

sp_1_mart <- useMart(vb_base, host = vb_host, dataset = vb_species[1]) # Define mart for base species (gambiae for example)

sp_1_attrs <- listAttributes(sp_1_mart)[, 1] 
sp_1_attrs <- sp_1_attrs[grep('homolog_ensembl_gene', sp_1_attrs)] # Find attr which contain 'homolog_ensembl_gene' 

sps_attrs_names <- unlist(lapply(species, function(sp){
  sp_1_attrs[grep(sp, sp_1_attrs)] # Find 'homolog_ensembl_gene' attribute for each species except base sp.
}))

orthologs <- getBM(mart = sp_1_mart, attributes = c('ensembl_gene_id', sps_attrs_names)) # Download table
colnames(orthologs) <- species

# Save datasets: genes, orthologs

lapply(species, function(sp){
  genes_table <- genes[[sp]]
  path_to_save <- paste0('./data/base/', sp, '_genes.csv')
  write.csv(genes_table, path_to_save, quote = F)
})

write.csv(orthologs, './data/base/orthologs.csv', quote = F)
