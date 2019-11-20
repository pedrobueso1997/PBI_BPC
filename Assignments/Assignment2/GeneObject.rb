
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Gene

#A gene object has the following properties:
#gene_id
#go_annotations
#kegg_annotations

#The Gene class has the following methods:
#.count: it returns the number of gene objects
#.get_all: it returns all the gene objects
#.show_all: it returns the inspection of all the gene objects
#.get_gene(gene_id): it returns the gene object with a specific gene_id
  
#A gene object has the following methods:
#.initialize -called automatically from Gene.new-: it assigns the properties (checking that gene_id has the proper format) and stores the gene object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property
#.annotate: it includes information on the pathways and biological processes in which the gene participates

###############################################################################################################

#CLASS

###############################################################################################################

class Gene
  
  attr_accessor :gene_id
  attr_accessor :kegg_annotations
  attr_accessor :go_annotations
  @@objects = []
  
  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing gene objects
  #It assigns the properties gene_id, kegg_annotations and go_annotations
  #It stores the gene object in an array
  
  def initialize (parameters={})   
    @gene_id = self.check_gene_id=(parameters.fetch(:gene_id, "XXXXXX"))
    @kegg_annotations = parameters.fetch(:kegg_annotations, "XXXXXX")
    @go_annotations = parameters.fetch(:go_annotations, "XXXXXX")
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
  
  #This is a method that includes information on the pathways and biological processes in which the gene participates
  #It access to the TOGO REST API  to retrieve:
  #The kegg id and associated name (from kegg-genes files)
  #The go id and associated name of biological processes (from uniport files)
  
  def annotate
    kegg_features = []
    go_features = []
    kegg = fetch('http://togows.org/entry/kegg-genes/ath:'+ self.gene_id)
    if kegg
      pathways = kegg.body.match(Regexp.new(/PATHWAY(.*)BRITE/m))
      if pathways.singleton_class != NilClass
        pathways = pathways.captures[0].split("\n")
        for pathway in pathways
          pathway = pathway.split(" ")
          pathway_id = pathway[0]
          pathway_name = pathway[1]
          kegg_features << [pathway_id, pathway_name]
        end
      end
    end
    go = fetch('http://togows.org/entry/ebi-uniprot/'+ self.gene_id)
    if go
      go_ids = go.body.scan(Regexp.new(/DR\s*GO;\s(GO:\d{7});\sP:.*;/))
      go_names = go.body.scan(Regexp.new(/DR\s*GO;\sGO:\d{7};\sP:(.*);/))
      for i in 0..go_ids.length-1
        go_id = go_ids[i][0]
        go_name = go_names[i][0]
        go_features << [go_id, go_name]
      end     
    end
    self.kegg_annotations = kegg_features
    self.go_annotations = go_features
  end
  
       
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that returns the number of gene objects
  
  def Gene.count
    puts @@objects.length
    return @@objects.length
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
  #If no object has the gene_id, it returns false
  
  def Gene.get_gene(gene_id)
    for object in @@objects
      if object.gene_id == gene_id
        return object
      end
    end
    return false
  end
  
end