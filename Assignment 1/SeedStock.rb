# SeedStock class has the information from seed_stock_data.tsv
class SeedStock
  attr_accessor :seeds_row, :seed_stock, :mutant_id, :last_planted, :stock_location, :grams_remain

  def initialize(stock_array)
    attrs = stock_array[0].split("\t")
    @seed_stock = attrs[0]
    @mutant_id = attrs[1]
    @last_planted = attrs[2]
    @stock_location = attrs[3]
    @grams_remain = attrs[4].to_i
  end

  # General funtion to plant seeds
  def plant_seeds(grams)
    if @grams_remain >= grams.to_i
      self.many_seeds(grams)
    else
      self.few_seeds
    end
  end

  # Planting seeds for those with more than the specifyied amount
  def many_seeds(grams)
    puts "\nPlanting #{grams} grams from #{seed_stock}...\n"
    @grams_remain -= grams

    if @grams_remain.zero?
      puts "Friendly reminde, stock #{@seed_stock} out of seeds."
    end
    puts "Updating plant date...\n"
    @last_planted = Time.now.strftime('%d/%m/%Y')
  end

  # Planting seeds for those with less than the specifyied amount
  def few_seeds
    puts "\nOnly #{@grams_remain} grams of #{@seed_stock} seeds left! Would you like to plant them? (y/n)\n"
    input = $stdin.gets.chomp
    # It asks the users if they want to plant the sees left
    if %w[y Y].include?(input)
      puts "Planting #{@grams_remain} grams...\nUpdating plant date..."
      @grams_remain = 0
      @last_planted = Time.now.strftime('%d/%m/%Y')
    end
  end

  # Accessory function to update the stock
  def update_stock
    [[@seed_stock, @mutant_id, @last_planted, @stock_location, @grams_remain].join("\t")]
  end

  # Accessory function to identify the stock by ID
  def identify(seed_stock)
    if seed_stock.include?(@seed_stock)
      return self
    end
  end
end
