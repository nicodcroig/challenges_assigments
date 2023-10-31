To run the script from the command line:
  ruby main.rb seed_stock_data.tsv gene_information.tsv cross_data.tsv new_bank.tsv

#### Main.rb

*The option for search for stocks is currently commented in the main script. It needs an array to work propperly no matter how many stocks are you trying to identify. If a different class than array is introduced as argument, it raises a friendly error mensage*

#### GenBank.rb

The script GeneBank.rb contais the class GeneBank, that is equivalent to the proposed "DataBase". It requires the name the three -tsv files to create initialize the class. After being initialized it creates three arrays, one for each class (SeedStock, CrossData and GeneData) where the independent objects are storaged (one for each row in the .tsv file).

All the methods of the class follow a similar mechanism. They iterate the objects of the particular array, and call for the specific method of whatever class is being called.
For example
seed_stock.tsv:

| Seed_Stock | Mutant_Gene_ID |Last_Planted | Storage | Grams_Remaining |
|------------|----------------|-------------|---------|-----------------|
| seed_stock_1 info | x | x | x | x                                      |
| seed_stock_2_info  | x | x | x | x | 

GeneBank.new(seed_stock.tsv, cross_data.tsv, gene_info.tsv )
GeneBank.SeedStocks = [seed_stock_1, seed_stock_2]

Genebank.plant_seeds would do:
+ seed_stock1.plant_seeds
+ seed_stock2.plant_seeds
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

The rest of the scripts contain the classes for the rest of the objects. Each object created in each classs corresponds to a row of the original tsv file, and each attribute corresponds to a column from the file. 

Every class has its specifict methods, like def chi_square or def plant_seeds, that are called by the GeneBank object.

Although the output is not exactly as the stablished in Moodle, the functionallity of the program is the same as required.

