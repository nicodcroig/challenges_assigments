require './SeedStock'
require './CrossData'
require './GeneData'
require 'csv'

# Class Genebank contains the rest of the classes.
class GeneBank
  attr_accessor :stock_array, :stock_header, :seed_stocks   # Attrs from the seed_stock file
  attr_accessor :cross_array, :cross_header, :cross_data_array, :linked_genes_array, :chis # Attrs from the cross_data file
  attr_accessor :gene_array, :gene_header, :gene_data_array # Attrs from the gene_info file

  # Within the initialize funtion, the rest of the objects are created.
  def initialize(stock_array, cross_array, gene_array)
    stock_array_  = CSV.read(stock_array, :quote_char => "|")
    @stock_array = stock_array_[1..]
    @stock_header = stock_array_[0]
    self.create_seed_stocks

    cross_array_ = CSV.read(cross_array, :quote_char => "|")
    @cross_array = cross_array_[1..]
    @cross_header = cross_array_[0]
    self.create_cross_data

    gene_array_ = CSV.read(gene_array, :quote_char => "|")
    @gene_array = gene_array_[1..]
    @gene_header = gene_array_[0]
    self.create_gene_data
  end

  # Creating the different objects
  def create_seed_stocks
    @seed_stocks = []
    @stock_array.each do |stock|
      new_stock = SeedStock.new(stock)
      @seed_stocks << new_stock
    end
  end

  def create_cross_data
    @cross_data_array = []
    @cross_array.each do |cross|
      new_cross = CrossData.new(cross)
      @cross_data_array << new_cross
    end
  end

  def create_gene_data
    @gene_data_array = []
    @gene_array.each do |gene|
      new_gene = GeneData.new(gene)
      @gene_data_array << new_gene
    end
  end

  # Functions
  # Planting seeds
  def plant_seeds(grams)
    @seed_stocks.each do |stock|
      stock.plant_seeds(grams)
    end
  end

  # Performing linkeage test
  def perform_chi_square
    @linked_genes_array = []
    @chis = []
    @cross_data_array.each do |cross|
      result = cross.chi_square
      if result
        @linked_genes_array << result[0]
        @chis << result[1]
      end
    end
    self.gene_names
  end

  # Checking the results of chi square
  def gene_names
    gene_hash = Hash.new
    index = (0..(self.seed_stocks.length - 1)).to_a
    index.each do |i|
      seed_stock = self.seed_stocks[i].seed_stock
      gene_name = self.gene_data_array[i].gene_name
      gene_hash[seed_stock] = gene_name
    end
    @linked_genes_array.each_with_index do |linked_genes, i|
      names = []
      linked_genes.each do |genes|
        names << gene_hash[genes]
      end
      puts "Recording: #{names[0]} is linked to #{names[1]}. Chi square = #{@chis[i]}"
    end
  end

  # Updating the seed_stock after planting
  def update_seed_stock(file_name)
    array = [[@stock_header]]
    @seed_stocks.each do |stock|
      array << stock.update_stock
    end
    puts "\n\nUpdated SeedStock:\t", array
    File.open(file_name, 'w') do |file|
      file.puts array
    end
  end

  # Accessing the stocks with the ID
  def get_seed_stock(seed_stock)
    if seed_stock.is_a?(Array)
      answer = []
      answer_array = [@stock_header]
      @seed_stocks.each do |stock|
        answer = []
        answer_stock = stock.identify(seed_stock)
        if answer_stock
          answer[0] = answer_stock.seed_stock
          answer[1] = answer_stock.mutant_id
          answer[2] = answer_stock.last_planted
          answer[3] = answer_stock.stock_location
          answer[4] = answer_stock.grams_remain
          answer_array << [answer.join("\t")]
        end
      end
      return answer_array
    else 
      raise ArgumentError, "Please, provide an array to identify the stock."
    end
  end
end
