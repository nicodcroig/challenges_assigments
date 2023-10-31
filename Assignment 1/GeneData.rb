# GeneData class has the information from gene_information.tsv
class GeneData
  attr_accessor :gene_id, :gene_name, :mutant_phenotype

  def initialize(gene)
    attr = gene[0].split("\t")
    @gene_id = attr[0]
    self.check_id
    @gene_name = attr[1]
    @mutant_phenotype = attr[2]
  end

  # Checking if the gene_id is written propperly
  def check_id
    answer = @gene_id.match(/A[Tt]\d[Gg]\d\d\d\d\d/)
    unless answer
      raise ArgumentError, "Invalid argument provided.\nPlease provide a correct format for gene_id in Gene_information.tsv"
    end
  end
end
