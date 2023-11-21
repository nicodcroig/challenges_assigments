

require 'rest-client'

class InteractomeBuilder
  attr_accessor :gene_list, :interactome
  

  PSICQUIC_BASE_URL = 'http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/query/'

  def initialize(filename)
    @gene_list = retrieve_genes_from_file(filename)
  end

  ### METHODS TO RETRIEVE THE SWISSPROT NAMES ###
  def retrieve_genes_from_file(filename)
    protein_ids = []
    array_of_lines = IO.readlines(filename)
    array_of_lines[0..].each do |data|

      geneid = data.split("\t").first.chomp  # Remove newline character
      res = RestClient.get("https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{geneid}&style=raw")
      unless res
        abort "failed to retrieve #{geneid}"
      end

      record = res.body

      if record.match(/db_xref="Uniprot\/SWISSPROT\:([^"]+)"/)
        protein_id = record.match(/db_xref="Uniprot\/SWISSPROT\:([^"]+)"/)[1]
        puts "the protein ID of #{geneid} is #{protein_id}"
        protein_ids << protein_id
      else
        puts "couldn't find the protein ID of #{geneid}"
      end
    end
    protein_ids
  end

  ### BUILDING MANY SIMPLE INTERACTOMES WITH 3 LEVELS OF DEPTH ###
  def build_interactome
    interactome = {}

    @gene_list.each do |query_gene|
      interactome[query_gene] = fetch_interactions(query_gene)
    end

    @interactome = expand_interactome(interactome)
  end

  

  def fetch_interactions(query_gene, quality_threshold = 0.55)
    url = "#{PSICQUIC_BASE_URL}#{query_gene}?format=tab25"
    puts "AAAAAAAAA #{url}"
    response = RestClient.get(url)

    parse_interactions(response.body, query_gene, quality_threshold)
  rescue RestClient::Exception => e
    puts "Error fetching interactions for #{query_gene}: #{e.message}"
    []
  end

   def parse_interactions(response_body, query_gene, quality_threshold)
    interactions = []

    # Quality checks
    response_body.lines.each do |line|
      fields = line.strip.split("\t")
      next if fields.empty?

      # Check if the gen belongs to arabidopsis
      next if fields[9].match(/taxid:(\d+)\(([^)]+)\)/)[1] != "3702"
          
      # Check if the intact score is better than the threshold
      intact_score_str = fields.last.match(/intact-miscore:(\d+\.\d+)/)&.captures&.first
      intact_score = intact_score_str.to_f if intact_score_str

      next if intact_score.nil? || intact_score < quality_threshold

      # Check if the query gene is in the first column
      next unless fields[0] == "uniprotkb:#{query_gene}"

      interacting_gene = fields[1].split(":").last

      # Skip self-interactions
      next if interacting_gene == query_gene

      # Add interacting gene only if not already present
      interactions << interacting_gene unless interactions.include?(interacting_gene)
    end

    interactions
  end

  def expand_interactome(interactome)
    expanded_interactome = {}

    interactome.each do |query_gene, interactions|
      expanded_interactome[query_gene] = {}

      interactions.each do |gene|
        expanded_interactome[query_gene][gene] = fetch_interactions(gene).uniq
      end
    end

    expanded_interactome
  end
end
