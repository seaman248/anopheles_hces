# 1. Remap coordinates of genes on scaffolds/chromosomes to coordinates on elements
# Results in ./data/processed/genes_on_elements

# source('./scripts/remap_scf_or_chr_to_elements.R')


# 2. Rename genes to uid base on orthologs table
# Results in ./data/processed/uid_genes_on_elements

# source('./scripts/rename_genes_as_orthologs.R')


# 3. Make Table for Grimm
# Result in ./data/procesed/grimm_input

# source('./scripts/make_grimm_table.R')

# 4. Run GRIMM
# source('./scripts/run_grimm.R')

# 5. Parse GRIMM_Synteny