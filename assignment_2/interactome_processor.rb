require 'rest-client'
require 'json'

class InteractomeProcessor
  attr_reader :networks

  def initialize(interactome)
    @interactome = interactome
    @lists = create_lists
    #puts "AAAA #{@lists}"
    @networks = []
  end

  def merge_interactomes
    self.process
    self.print_network_report
    self.networks
  end

   def create_lists
    lists = []


    @interactome.each do |outer_key, inner_hash|
      current_list = [outer_key]

      inner_hash.each do |inner_key, inner_values|
        current_list << inner_key
        current_list.concat(inner_values)
      end

      # Ensure unique protein IDs within each list
      current_list.uniq!

      lists << current_list
    end

    lists.reject! { |list| list.size <= 1 } # Remove lists with only one gene
    lists
  end

  def join
    joined_lists = []

    @lists.each do |list1|
      joined = false

      joined_lists.each do |list2|
        if (list1 & list2).any?
          list2.concat(list1).uniq!
          joined = true
          break
        end
      end

      joined_lists << list1 unless joined
    end

    joined_lists
  end

  def process
    @networks = join
    @networks.reject! { |network| network.size <= 1 } # Remove networks with only one gene
  end

  def print_network_report
    puts "#{@networks.size} networks have been identified:"

    @networks.each_with_index do |network, index|
      puts "\n\nNetwork #{index + 1}:"
      print_components(network)
    
      # The KEGG annotations will be handled by InteractomeAnnotator
      puts "\n"
    end
  end

  private

  def print_components(network)
    puts "Components:"
    network.each do |gene|
      puts "#{gene}"
    end
  end


end

