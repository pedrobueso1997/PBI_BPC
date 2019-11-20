
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Gene

#A gene object has the following properties:
#gene_id
#gene_name
#mutant_phenotype
#linked_to

#The Gene class has the following methods:
#.count: it returns the number of gene objects
#.get_all: it returns all the gene objects
#.show_all: it returns the inspection of all the gene objects
#.get_gene(gene_id): it returns the gene object with a specific gene_id
#.load_all(path_to_file): it loads all the gene objects from a tsv file containing them
#.write_all(path_to_file): it writes all the gene objects to a tsv file
#.append(object, path_to_file): it appends one gene object to a tsv file
#.show_linked_genes(): it shows which genes are linked
  
#A gene object has the following methods:
#.initialize -called automatically from Gene.new-: it assigns the properties (checking that gene_id has the proper format), increases the number of gene objects and stores the gene object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property

###############################################################################################################

#CLASS

###############################################################################################################

class Gene
  
  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  attr_accessor :linked_to
  @@count = 0
  @@objects = []
  
  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing gene objects
  #It assigns the properties gene_id, gene_name and mutant_phenotype
  #It increases the number of gene objects by one
  #It stores the gene object in an array
  
  def initialize (parameters={})   
    @gene_id = self.check_gene_id=(parameters.fetch(:gene_id, "XXXXXX"))
    @gene_name = parameters.fetch(:gene_name, "XXXXXX")
    @mutant_phenotype = parameters.fetch(:mutant_phenotype, "XXXXXX")
    @linked_to = parameters.fetch(:linked_to, "NULL")
    @@count += 1
    @@objects << self
  end
  
  #This is a method that checks if the gene_id has the correct format
  
  def check_gene_id=(code)
    if code.match(Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/))
      return code
    else
      raise "The gene id is incorrect. It should follow the format /A[Tt]\d[Gg]\d\d\d\d\d/"
    end
  end 
  
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that returns the number of gene objects
  
  def Gene.count
    puts @@count
    return @@count
  end
  
  #This is a method that returns all the gene objects
  
  def Gene.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all gene objects
  
  def Gene.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end
 
  #This is a method that returns the gene object with a specific gene_id
  
  def Gene.get_gene(gene_id)
    for object in @@objects
      if object.gene_id == gene_id
        return object
      end
    end
    raise "There is no gene stored with that gene id"
  end

  #This is a method that loads all the gene objects from a tsv file containing them
  
  def Gene.load_all(path_to_file)  
    require 'csv'
    require 'matrix'
    matrix = Matrix[*(CSV.table(path_to_file, col_sep: "\t" ))]
    number_objects = matrix.row_count()-1
    for i in 1..number_objects
      Gene.new(:gene_id => matrix[i,0], :gene_name => matrix[i,1], :mutant_phenotype => matrix[i,2])
    end
    return @@objects
  end
   
  #This is a method that writes all the gene objects to a tsv file

  def Gene.write_all(path_to_file)
    header = "Gene_ID\tGene_Name\tMutant_Phenotype\tLinked_To"
    File.open(path_to_file,"w"){|file| file.puts header}
    for object in @@objects
      tsv_line = object.gene_id.to_s + "\t" + object.gene_name.to_s + "\t" + object.mutant_phenotype.to_s + "\t" + object.linked_to.to_s  
      File.open(path_to_file,"a"){|file| file.puts tsv_line}
    end
  end
  
  #This is a method that appends one gene objects to a tsv file
  
  def Gene.append(object, path_to_file)
    tsv_line = object.gene_id.to_s + "\t" + object.gene_name.to_s + "\t" + '"' + object.mutant_phenotype.to_s + '"' + "\t" + object.linked_to.to_s  
    File.open(path_to_file,"a"){|file| file.puts tsv_line}
  end
  
  #This is a method that shows which genes are linked
  #To do so, it checks which gene objects have the property linked_to with a value different from default "NULL"
  
  def Gene.show_linked_genes()
    for object in @@objects
      if object.linked_to != "NULL"
        puts "The gene #{object.gene_name} is linked to the gene #{object.linked_to.gene_name}"
      end
    end
  end
  
end

###############################################################################################################
  
#EXAMPLES
  
###############################################################################################################

#gene1 = Gene.new #Gene with default values
#gene2 = Gene.new(:gene_id => "NOT OK", :gene_name => "NOT OK", :mutant_phenotype => "NOT OK") #Gene with wrong values
#gene3 = Gene.new(:gene_id => "AT1G69120", :gene_name => "OK", :mutant_phenotype => "OK") #Gene with proper values
#geneX = Gene.new(:gene_id => "AT1G69120", :gene_name => "X", :mutant_phenotype => "X") #Gene with proper values
#geneY = Gene.new(:gene_id => "AT1G69121", :gene_name => "Y", :mutant_phenotype => "Y") #Gene with proper values
#geneZ = Gene.new(:gene_id => "AT1G69122", :gene_name => "Z", :mutant_phenotype => "Z") #Gene with proper values

#Selecting a gene object according to its gene_id
#puts Gene.get_gene("AT1G69120") #This will work
#puts Gene.get_gene("AT1G69125") #This will not work (there is not such gene_id within the gene objects)

#Appending all gene objects to a file
#Gene.write_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/new_gene_file.tsv')

#Appending one gene object to a file
#Gene.append(geneX, '/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/new_gene_file.tsv')

#Loading a file and creating as many gene objects as it contains
#Gene.load_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/gene_information.tsv')
#Gene.show_all


