require './GeneBank'

arg1 = ARGV[0]
arg2 = ARGV[1]
arg3 = ARGV[2]
arg4 = ARGV[3]

# Creating the GeneBank database object
gene_bank = GeneBank.new(arg1, arg2, arg3)

# Performing the linkeage test
gene_bank.perform_chi_square

# Planting the seeds from each stock
gene_bank.plant_seeds(7)

# Updating seed_stock.tsv
gene_bank.update_seed_stock(arg4)

# Identifying stocks by id
#puts gene_bank.get_seed_stock(['B3334', 'A334'])
