
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Seedstock

#A seed stock object has the following properties:
#seed_stock_id
#gene
#last_planted
#storage
#grams_remaining

#The Seedstock class has the following methods:
#.count: it returns the number of seed stock objects
#.get_all: it returns all the seed stock objects
#.show_all: it returns the inspection of all the seed stock objects
#.get_seed_stock(seed_stock_id): it returns the seed stock object with a specific seed_stock_id
#.load_all(path_to_file) -requires previously loading the gene objects-: it loads all the seed stock objects from a tsv file containing them
#.write_all(path_to_file): it writes all the seed stock objects to a tsv file
#.append(object, path_to_file): it appends one seed stock object to a tsv file
#.plant(quantity): simulates planting the same quantity -in grams- for all the seed stock objects

#A gene object has the following methods:
#.initialize -called automatically from Seedstock.new-: it assigns the properties (checking that gene is a gene object, that last_planted is a date and that grams_remaining is an integer or float), increases the number of seed stock objects and stores the seed stock object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property

###############################################################################################################

#CLASS

###############################################################################################################

require_relative 'GeneObject.rb'

class Seedstock
  
  attr_accessor :seed_stock_id
  attr_accessor :gene
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  @@count = 0
  @@objects = []
  
  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing seed stock objects
  #It assigns the properties seed_stock_id, gene, last_planted, storage and grams_remaining
  #It increases the number of seed stock objects by one
  #It stores the seed stock object in an array
  
  def initialize (parameters={})
    @seed_stock_id = parameters.fetch(:seed_stock_id, "XXXXXX")
    @gene = self.check_gene=(parameters.fetch(:gene, "XXXXXX"))
    @last_planted = self.check_last_planted=(parameters.fetch(:last_planted, "XXXXXX"))
    @storage = parameters.fetch(:storage, "XXXXXX")
    @grams_remaining = self.check_grams_remaining=(parameters.fetch(:grams_remaining, "XXXXXX"))
    @@count += 1
    @@objects << self
  end
  
  #This is a method that checks if the gene is a gene object
  
  def check_gene=(code)
    if code.is_a?(Gene)
      return code
    else
      raise "You must create a gene object and then assign it to the gene. You can do that with Gene.new method"
    end
  end
  
  #This is a method that checks if last_planted has a date format
  
  def check_last_planted=(code)
    begin
      require "date"
      Date.strptime(code, '%d/%m/%Y')
      return code
    rescue
      raise "The date for the last plantation is incorrect. It should follow the format day/month/year"
    end
  end
  
  #This is a method that checks if grams_remaining is an integer or float
  
  def check_grams_remaining=(code)
    if code.is_a?(Integer) or code.is_a?(Float)
      return code
    else
      raise "The quantity for the grams remaining is incorrect. It should be integer or float"
    end
  end
  
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that returns the number of seed stock objects
  
  def Seedstock.count
    puts @@count
    return @@count
  end
  
  #This is a method that returns all the seed stock objects
  
  def Seedstock.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all seed stock objects
  
  def Seedstock.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end
  
  #This is a method that returns the seed stock object with a specific seed_stock_id
  
  def Seedstock.get_seed_stock(seed_stock_id)
    for object in @@objects
      if object.seed_stock_id == seed_stock_id
        return object
      end
    end
    raise "There is no seed stock stored with that seed stock id"
  end

  #This is a method that loads all the seed stock objects from a tsv file containing them
  #It requires previously loading gene objects (the gene property requires a gene objects)

  def Seedstock.load_all(path_to_file)  
    require 'csv'
    require 'matrix'
    matrix = Matrix[*(CSV.table(path_to_file, col_sep: "\t" ))]
    number_objects = matrix.row_count()-1 
    for i in 1..number_objects
      Seedstock.new(:seed_stock_id => matrix[i,0], :gene => Gene.get_gene(matrix[i,1]), :last_planted => matrix[i,2], :storage => matrix[i,3], :grams_remaining => matrix[i,4])
    end
    return @@objects
  end
   
  #This is a method that writes all the seed stock objects to a tsv file

  def Seedstock.write_all(path_to_file)
    header = "Seed_Stock\tMutant_Gene_ID\tLast_Planted\tStorage\tGrams_Remaining"
    File.open(path_to_file,"w"){|file| file.puts header}
    for object in @@objects
      tsv_line = object.seed_stock_id.to_s + "\t" + object.gene.gene_id.to_s + "\t" + object.last_planted.to_s + "\t" + object.storage.to_s + "\t" + object.grams_remaining.to_s
      File.open(path_to_file,"a"){|file| file.puts tsv_line}
    end
  end
  
  #This is a method that appends one seed stock objects to a tsv file
  
  def Seedstock.append(object, path_to_file)
    tsv_line = object.seed_stock_id.to_s + "\t" + object.gene.gene_id.to_s + "\t" + object.last_planted.to_s + "\t" + object.storage.to_s + "\t" + object.grams_remaining.to_s
    File.open(path_to_file,"a"){|file| file.puts tsv_line}
  end
  
  #This is a method that simulates planting the same quantity -in grams- for all the seed stock objects
  #It consists on substracting quantity to the property grams_remaining (those initial quantities that are equal or lower than quantity should end up with 0)

  def Seedstock.plant(quantity)
    if !(quantity.is_a?(Integer) or quantity.is_a?(Float))
      raise "The quantity of grams indicated for the Seedstock.plant(quantity) method is incorrect. It should be integer or float"
    end
    for object in @@objects
      if object.grams_remaining > quantity
        object.grams_remaining -= quantity
        puts "Recording: There are still #{object.grams_remaining} grams remaining for seed stock #{object.seed_stock_id}"
      elsif object.grams_remaining == quantity
        puts "Warning: We have run out of seed stock #{object.seed_stock_id}"
        object.grams_remaining = 0
      else
        puts "Warning: We have run out of seed stock #{object.seed_stock_id} and we only planted #{object.grams_remaining} grams"
        object.grams_remaining = 0
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

#seed_stock1 = Seedstock.new #seed stock with default values
#seed_stock2 = Seedstock.new(:seed_stock_id => "NOT OK", :gene => "NOT OK", :last_planted => "NOT OK", :storage => "NOT OK", :grams_remaining => "NOT OK") #seed stock with wrong values
#seed_stock3 = Seedstock.new(:seed_stock_id => "OK", :gene => gene, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10) #seed stock with proper values
#seed_stockX = Seedstock.new(:seed_stock_id => "A330", :gene => geneX, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10)
#seed_stockY = Seedstock.new(:seed_stock_id => "A331", :gene => geneY, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10)
#seed_stockZ = Seedstock.new(:seed_stock_id => "A332", :gene => geneZ, :last_planted => "10/10/2010", :storage => "OK", :grams_remaining => 10)

#Selecting a seed stock object according to its seed_stock_id
#puts Seedstock.get_seed_stock("A330") #This will work
#puts Seedstock.get_seed_stock("A335") #This wont work (there is not such gene_stock_id within the seed stock objects)

#Appending all seed stock objects to a file
#Seedstock.write_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/new_seed_stock_file.tsv')

#Appending one seed stock object to a file
#Seedstock.append(seed_stockX, '/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/new_seed_stock_file.tsv')

#Loading a file and creating as many seed stock objects as it contains
#Gene.load_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/gene_information.tsv')
#Seedstock.load_all('/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/gene_information.tsv','/home/osboxes/PBI_Bioinformatic_Programming_Challenges/Assignment1/seed_stock_data.tsv')
#Seedstock.show_all



