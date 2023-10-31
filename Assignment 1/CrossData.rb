# SeedStock class has the information from cross_data.tsv
class CrossData
  attr_accessor :parent1, :parent2, :f2_wild, :f2_p1, :f2_p2, :f2_p1p2

  def initialize(cross_array)
    attr = cross_array[0].split("\t")
    @parent1 = attr[0]
    @parent2 = attr[1]
    @f2_wild = attr[2].to_f
    @f2_p1 = attr[3].to_f
    @f2_p2 = attr[4].to_f
    @f2_p1p2 = attr[5].to_f
  end

  # This is the function that performs the test itself for each cross
  def chi_square
    total = @f2_wild + @f2_p1 + @f2_p2 + @f2_p1p2
    expected_wild = total * 9/16
    expected_p1 = total * 3/16
    expected_p2 = total * 3/16
    expected_p1p2 = total * 1/16
    chi_2 = ((@f2_wild - expected_wild)**2/expected_wild) + ((@f2_p1 - expected_p1)**2/expected_p1) + ((@f2_p2 - expected_p2)**2/expected_p2) + ((@f2_p1p2 - expected_p1p2)**2/expected_p1p2) 
    # Signification = 0.05, degrees of freedom = 3. 
    if chi_2 > 7.185
      return [@parent1, @parent2], chi_2
    end
  end
end
