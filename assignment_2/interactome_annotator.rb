require 'rest-client'
require 'json'

class InteractomeAnnotator
  def initialize(networks)
    @networks = networks
    @go_annotations = Hash.new { |hash, key| hash[key] = { count: 0, genes: [] } }
    @kegg_annotations = Hash.new { |hash, key| hash[key] = { count: 0, genes: [] } }
  end

  def annotate_with_go_and_kegg
    annotate_networks
    print_network_report
  end

  def borrar_go
    puts @go_annotations.sort_by { |_, info| -info[:count] }
    # puts "GO terms:"

    # @networks.each do |network|
    #   sorted_go_annotations = @go_annotations.sort_by { |_, info| -info[:count] }

    #   sorted_go_annotations.each do |go_id, info|
    #     puts "INFO #{info}"
    #     next unless info[:genes].any? { |gene_info| network.include?(gene_info[:gene]) }

    #     puts "#{go_id} (#{info[:count]} occurrences): #{info[:genes].first[:go_name]}"
    #     info[:genes].each do |gene_info|
    #       next unless network.include?(gene_info[:gene])

    #       puts "  Gene: #{gene_info[:gene]}"
    #     end
    #   end
    # end
  end

  def borrar_kegg
    puts @kegg_annotations
    # @networks.each_with_index do |network, index|
    #   puts "#{network}, #{index}"
    # end
    # @networks.each do |network|
    #   sorted_kegg_annotations = @kegg_annotations.sort_by { |_, info| -info[:count] }

    #   sorted_kegg_annotations.each do |kegg_id, info|
    #     puts "INFO #{info}"
    #     next unless info[:genes].any? { |gene_info| network.include?(gene_info[:gene]) }
    
    #     puts "#{kegg_id} (#{info[:count]} occurrences): #{info[:genes][0][:kegg_data].keys[0]}, (#{info[:genes][0][:kegg_data].values[0]})"
    #     info[:genes].each do |gene_info|
    #       next unless network.include?(gene_info[:gene])
    #       puts "  Gene: #{gene_info[:gene]}"
    #     end
    #   end
    # end
  end

  private

  def retrieve_go_annotations(protein_id)
    address = "http://togows.dbcls.jp/entry/uniprot/#{protein_id}/dr.json"
    response = RestClient::Request.execute(method: :get, url: address)
    data = JSON.parse(response.body)

    go_terms = data[0]["GO"] if data[0]["GO"]
    go_terms.each_with_object({}) do |go, hash|
      next unless (go[2] =~ /IDA:/) || (go[2] =~ /IMP:/)

      go_id = go[0]
      go_name = go[1]
      #puts "GO ID #{go_id}"
      hash[go_id] = go_name
    end if go_terms.is_a?(Array)
  rescue RestClient::Exception => e
    puts "Error retrieving GO annotations for #{protein_id}: #{e.message}"
    {}
  end

  def retrieve_kegg_annotations(gene_id)
    address = "http://togows.dbcls.jp/entry/uniprot/#{gene_id}/dr.json"
    response = RestClient::Request.execute(method: :get, url: address)
    data = JSON.parse(response.body)
    
    kegg_terms = data[0]["KEGG"] if data[0]["KEGG"]
    
    kegg_terms.each_with_object([]) do |kegg_info, result|
      kegg_id = kegg_info[0]
      #puts "LALALA #{kegg_id}"
      address = "http://togows.org/entry/kegg-genes/#{kegg_id}/pathways.json"
      #puts "ADD #{address}"
      
      begin
        response = RestClient::Request.execute(method: :get, url: address)
        data = JSON.parse(response.body)

        result << { 'id' => data[0].keys[0], 'description' => data[0] } if data[0]&.any?
        #puts "ESTE SERIA EL RESULT  #{data[0].keys}"
      rescue RestClient::Exception => e
        puts "Error retrieving KEGG annotations for #{gene_id}: #{e.message}"
      end
    end
  end

  def annotate_gene(gene, network_index)
    go_terms = retrieve_go_annotations(gene)


    if go_terms.nil?
      puts "No GO annotations found for #{gene}."
      return
    end

    go_terms.each do |go_id, go_name|
      @go_annotations[go_id][:count] += 1
      @go_annotations[go_id][:genes] << { gene: gene, network: network_index + 1, go_name: go_name }
    end

    kegg_terms = retrieve_kegg_annotations(gene)
    # puts "DEBERIAN SER IGUALES, #{kegg_terms}"

    if kegg_terms[0].nil?
      puts "No KEGG annotations found for #{gene}."
      return
    end

    # puts "KEGG TERMS: #{kegg_terms}"
    kegg_terms.each do |kegg_info|
      kegg_id = kegg_info['id']
      kegg_data = kegg_info['description']


      @kegg_annotations[kegg_id][:count] += 1
      @kegg_annotations[kegg_id][:genes] << { gene: gene, network: network_index + 1, kegg_data: kegg_data }
      # puts "KEG ID #{kegg_id}"
      # puts "KEGG DATA #{kegg_data}"
      # puts "KEGG COUNT #{@kegg_annotations[kegg_id][:count]}"
      # puts "KEGG GENES #{@kegg_annotations[kegg_id][:genes]}"
      #puts "NO SE QUE ES ESTO #{@kegg_annotations}"
    end
  end

  def annotate_network(network, network_index)
    network.each do |gene|
      annotate_gene(gene, network_index)
    end
  end

  def annotate_networks
    @networks.each_with_index do |network, index|
      annotate_network(network, index)
    end
  end

  private 
  
  def print_network_report
    puts "\nNETWORK REPORT:"
    puts " "
    @networks.each_with_index do |network, index|
      puts "Network #{index + 1}:"
      print_components(network)
      print_go_terms(network)
      print_kegg_terms(network)
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

  def print_go_terms(network)
    puts "\nGO terms:"
    sorted_go_annotations = @go_annotations.sort_by { |_, info| -info[:count] }

    sorted_go_annotations.each do |go_id, info|
      next unless info[:genes].any? { |gene_info| network.include?(gene_info[:gene]) }

      puts "#{go_id} (#{info[:count]} occurrences): #{info[:genes].first[:go_name]}"
      info[:genes].each do |gene_info|
        next unless network.include?(gene_info[:gene])

        puts "  Gene: #{gene_info[:gene]}"
      end
    end
  end

def print_kegg_terms(network)
  puts "\nKEGG terms:"
  sorted_kegg_annotations = @kegg_annotations.sort_by { |_, info| -info[:count] }

  sorted_kegg_annotations.each do |kegg_id, info|
    next unless info[:genes].any? { |gene_info| network.include?(gene_info[:gene]) }

    puts "#{kegg_id} (#{info[:count]} occurrences): #{info[:genes][0][:kegg_data].values[0]}"
    info[:genes].each do |gene_info|
      next unless network.include?(gene_info[:gene])
      puts "  Gene: #{gene_info[:gene]}"
    end
  end
end

end