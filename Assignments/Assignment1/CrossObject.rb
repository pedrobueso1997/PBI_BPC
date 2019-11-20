
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Cross

#A cross object has the following properties:
#parent1
#parent2
#f2_wild
#f2_parent1
#f2_parent2
#f2_parent1_parent2

#The Cross class has the following methods:
#.count: it returns the number of cross objects
#.get_all: it returns all the cross objects
#.show_all: it returns the inspection of all the cross objects
#.get_cross(parent1, parent2): it returns the cross stock object with the specific parent1 and parent2
#.load_all(path_to_file) -requires previously loading the gene objects and the seed stock objects-: it loads all the cross objects from a tsv file containing them
#.write_all(path_to_file): it writes all the cross objects to a tsv file
#.append(object, path_to_file): it appends one cross object to a tsv file
#.obtain_linked_genes() does the chi-square test to the cross objects and determine whether the genes are linked

#A gene object has the following methods:
#.initialize -called automatically from Cross.new-: it assigns the properties (checking that the parents are seed stock objecta and that f2 data are integers), increases the number of cross objects and stores the cross object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property

###############################################################################################################

#CLASS

###############################################################################################################

require_relative 'GeneObject.rb'
require_relative 'SeedstockObject.rb'

class Cross
  
  attr_accessor :parent1
  attr_accessor :parent2
  attr_accessor :f2_wild
  attr_accessor :f2_parent1
  attr_accessor :f2_parent2
  attr_accessor :f2_parent1_parent2 
  @@count = 0
  @@objects = []
  
  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing cross object
  #It assigns the properties parent1, parent2, f2_wild, f2_parent1, f2_parent2, f2_parent1_parent2
  #It increases the number of seed stock objects by one
  #It stores the seed stock object in an array
  
  def initialize (parameters={})
    @parent1 = self.check_parent=(parameters.fetch(:parent1, "XXXXXX"))
    @parent2 = self.check_parent=(parameters.fetch(:parent2, "XXXXXX"))
    @f2_wild = self.check_f2=(parameters.fetch(:f2_wild, "XXXXXX"))
    @f2_parent1 = self.check_f2=(parameters.fetch(:f2_parent1, "XXXXXX"))
    @f2_parent2 = self.check_f2=(parameters.fetch(:f2_parent2, "XXXXXX"))
    @f2_parent1_parent2 = self.check_f2=(parameters.fetch(:f2_parent1_parent2, "XXXXXX"))
    @@count += 1
    @@objects << self
  end
  
  #This is a method that checks if parent1 and parent2 are a seed stock object
  
  def check_parent=(code)
    if code.is_a?(Seedstock)
      return code
    else
      raise "You must create a seed stock object and then assign it to the cross. You can do that with Seedstock.new method"
    end
  end
  
  #This is a method that checks if f2_wild, f2_parent1, f2_parent2 and f2_parent1_parent2 are integers
  
  def check_f2=(code)
    if code.is_a?(Integer)
      return code
    else
      raise "The quantity for the f2 is incorrect. It should be integer"
    end
  end

  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that gives the number of cross objects
  
  def Cross.count
    puts @@count
    return @@count
  end
  
  #This is a method that returns all the cross objects
  
  def Cross.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all cross objects
  
  def Cross.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end
  
  #This is a method that returns the cross object from a specific parent1 and parent2
  
  def Cross.get_cross(parent1, parent2)
    for object in @@objects
      if object.parent1 == parent1 and object.parent2 == parent2
        return object
      end
    end
    raise "There is no cross recorded with that parents, or at least they are not indicated in that order"
  end

  #This is a method that loads cross objects from a tsv file containing them
  #It requires previously loading gene objects (the gene property requires a gene objects)
  #It requires previously loading the seed stock objects (the parent1 and parent2 property requires a seed stock object)
  
  def Cross.load_all(path_to_file)
    require 'csv'
    require 'matrix'
    matrix = Matrix[*(CSV.table(path_to_file, col_sep: "\t" ))]
    number_objects = matrix.row_count()-1
    for i in 1..number_objects
      Cross.new(:parent1 => Seedstock.get_seed_stock(matrix[i,0]), :parent2 => Seedstock.get_seed_stock(matrix[i,1]), :f2_wild => matrix[i,2], :f2_parent1 => matrix[i,3], :f2_parent2 => matrix[i,4], :f2_parent1_parent2 => matrix[i,5])
    end
    return @@objects
  end
  
  #This is a method that writes all the cross objects to a file in a tsv format

  def Cross.write_all(path_to_file)
    header = "Parent1\tParent2\tF2_Wild\tF2_P1\tF2_P2\tF2_P1P2"
    File.open(path_to_file,"w"){|file| file.puts header}
    for object in @@objects
      tsv_line = object.parent1.seed_stock_id.to_s + "\t" + object.parent2.seed_stock_id.to_s + "\t" + object.f2_wild.to_s + "\t" + object.f2_parent1.to_s + "\t" + object.f2_parent2.to_s + "\t" + object.f2_parent1_parent2.to_s
      File.open(path_to_file,"a"){|file| file.puts tsv_line}
    end
  end
  
  #This is a method that appends one cross objects to a file in a tsv format
  
  def Cross.append(object, path_to_file)
    tsv_line = object.parent1.seed_stock_id.to_s + "\t" + object.parent2.seed_stock_id.to_s + "\t" + object.f2_wild.to_s + "\t" + object.f2_parent1.to_s + "\t" + object.f2_parent2.to_s + "\t" + object.f2_parent1_parent2.to_s
    File.open(path_to_file,"a"){|file| file.puts tsv_line}
  end

  #This is a method that does the chi-square test to the cross objects and determine whether the genes are linked

  def Cross.obtain_linked_genes()
    
  #Null hypothesis: there is no significant difference between observed and expected frequencies (genes are not linked)
  #Alternative hypothesis: there is a significant difference between observed and expected frequencies (genes are linked)

    for object in @@objects
  
      #For every F2, we calculate (observed-expected)²/expected and then we sum all the quantities
      #The observed frecuencies are the ones shown in the cross file
      #The expected frequencies are the expected ratios (9/16, 3/16, 3/16, 1/16) multiplied by the total
  
      total = object.f2_wild + object.f2_parent1 + object.f2_parent2 + object.f2_parent1_parent2
      f2_wild = ((object.f2_wild - 9.0/16.0*total)**2)/(9.0/16.0*total)
      f2_parent1 = ((object.f2_parent1 - 3.0/16.0*total)**2)/(3.0/16.0*total)
      f2_parent2 = ((object.f2_parent2 - 3.0/16.0*total)**2)/(3.0/16.0*total)
      f2_parent1_parent2 = ((object.f2_parent1_parent2 - 1.0/16.0*total)**2)/(1.0/16.0*total)
      chi_square_value = f2_wild + f2_parent1 + f2_parent2 + f2_parent1_parent2
  
      #The p-value is the smallest level of significance at which we can still reject the null hypothesis
      #For p-values < 0.05, we reject the null hypothesis (genes are linked)
      #For p-values > 0.05, we accept the null hypothesis (genes are not linked)
      #In dihybrid crosses, the degrees of freedom are the number of phenotypes minus 1 (we have 4 phenotypes, so df = 3)
      #When df = 3, for chi-square > 7.815, we reject the null hypothesis (genes are linked)
      #When df = 3, for chi-square < 7.815, we accept the null hypothesis (genes are not linked)
      #If genes are linked, we change the value for the property linked_to and include the linked gene

      if chi_square_value > 7.815
        puts "Recording: the genes #{object.parent1.gene.gene_name} and #{object.parent2.gene.gene_name} are genetically linked, with a chi-square value of #{chi_square_value.round(3)}"
        Gene.get_gene(object.parent1.gene.gene_id).linked_to=(Gene.get_gene(object.parent2.gene.gene_id))
        Gene.get_gene(object.parent2.gene.gene_id).linked_to=(Gene.get_gene(object.parent1.gene.gene_id)) 
      else
        puts "Recording: the genes #{object.parent1.gene.gene_name} and #{object.parent2.gene.gene_name} are genetically not linked, with a chi-square value of #{chi_square_value.round(3)}"
      end
    end
  end
end
  
###############################################################################################################
  
#EXAMPLES
  
###############################################################################################################

#geneX = Gene.new(:gene_id => "AT1G69120", :gene_name => "X", :mutant_phenotype => "X")
#geneY = Gene.new(:gene_id => "AT1G69121", :gene_name => "Y", :mutant_phenotype => "Y")
#geneZ = Gene.new(:gene_id => "AT1G69122", :gene_name => "Z", :mutant_phenotype => "Z")

#seedstockX = Seedstock.new(:seed_stock_id => "A330", :gene => geneX, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10)
#seedstockY = Seedstock.new(:seed_stock_id => "A331", :gene => geneY, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10)
#seedstockZ = Seedstock.new(:seed_stock_id => "A332", :gene => geneZ, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10)

#cross1 = Cross.new #cross with default values
#cross2 = Cross.new(:parent1 => "NOT OK", :parent2 => "NOT OK", :f2_wild => "NOT OK", :f2_parent1 => "NOT OK", :f2_parent2 => "NOT OK", :f2_parent1_parent2 => "NOT OK") #cross with wrong values
#cross3 = Cross.new(:parent1 => seed_stock, :parent2 => seed_stock, :f2_wild => 10, :f2_parent1 => 10, :f2_parent2 => 10, :f2_parent1_parent2 => 10) #cross with proper values
#crossXY = Cross.new(:parent1 => seedstockX, :parent2 => seedstockY, :f2_wild => 10, :f2_parent1 => 10, :f2_parent2 => 10, :f2_parent1_parent2 => 10)
#crossXZ = Cross.new(:parent1 => seedstockX, :parent2 => seedstockZ, :f2_wild => 10, :f2_parent1 => 10, :f2_parent2 => 10, :f2_parent1_parent2 => 10)
#crossYZ = Cross.new(:parent1 => seedstockY, :parent2 => seedstockZ, :f2_wild => 10, :f2_parent1 => 10, :f2_parent2 => 10, :f2_parent1_parent2 => 10)

#Selecting a cross object according to its parent1 and parent2
#puts Cross.get_cross(seedstockX,seedstockY) #This will work
#puts Cross.get_cross(seedstockY,seedstockX) #This will not work (there are not such parents within the cross objects, or at least not in that order)

#Appending all cross objects to a file
#Cross.write_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/new_cross_file.tsv')

#Appending one cross object to a file
#Cross.append(crossXY, '/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/new_cross_file.tsv')

#Loading a file and creating as many cross objects as it contains
#Gene.load_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/gene_information.tsv')
#Seedstock.load_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/gene_information.tsv','/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/seed_stock_data.tsv')
#Cross.load_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/gene_information.tsv','/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/seed_stock_data.tsv','/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/cross_data.tsv')
#Cross.show_all


