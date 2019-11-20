
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Interaction

#An interaction object has the following properties:
#gene_id_1
#gene_id_2
#score

#The Interaction class has the following methods:
#.count: it returns the number of interaction objects
#.get_all: it returns all the interaction objects
#.show_all: it returns the inspection of all the interaction objects
#.load_interactions(iterations, max_interactions, threshold, annotate_only_list): it loads interaction objects from an array of genes

#An interaction object has the following methods:
#.initialize: it assigns the properties and stores the interaction object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property

###############################################################################################################

#CLASS

###############################################################################################################

class Interaction
  
  attr_accessor :gene_id_1
  attr_accessor :gene_id_2
  attr_accessor :score
  @@objects = []

  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing interaction objects
  #It assigns the properties gene_id_1, gene_id_2 and score
  #It stores the interaction object in an array
  
  def initialize (parameters={})   
    @gene_id_1 = parameters.fetch(:gene_id_1, "XXXXXX")
    @gene_id_2 = parameters.fetch(:gene_id_2, "XXXXXX")
    @score = parameters.fetch(:score, "XXXXXX")
    @@objects << self
  end
  
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################
  
  #This is a method that returns the number of interaction objects
  
  def Interaction.count
    puts @@objects.length
    return @@objects.length
  end
  
  #This is a method that returns all the interaction objects
  
  def Interaction.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all the interaction objects
  
  def Interaction.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end
  
  #This is a method that loads interaction objects from an array of genes
 
  def Interaction.load_interactions(iterations, max_interactions, threshold, annotate_only_list)
 
    #It iterates over the number of iterations
    #For iterations = 1, we would only search for our genes (set A) and their interactors (setB)
    #For iterations = 2, we would search for our genes (set A), their interactors (setB) and the interactors' interactors (setC)
    #For iteration = 3, ... you probably already got it
    #It iterates over the genes we want to search
    
    @@objects = []
    genes_to_search = $genes
    for iteration in 1..iterations
      puts "Iteration " + iteration.to_s + " started"
      genes_found = []
      for gene in genes_to_search
                
        #It access to the EBI’s PSICQUIC (IntAct) REST interface  to retrieve:
        #The interactor, inside the structure uniprotkb:(A[Tt]\d[Gg]\d\d\d\d\d)\(locus name\) 
        #The score, inside the structure intact-miscore:(\d\.\d\d)
  
        num_interactions = 0
        res = fetch('http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/' + gene + '?format=tab25')
        if res
          if res.body != ''
            interactions = res.body.split("\n")
            for interaction in interactions
              if num_interactions < max_interactions 
                interaction_fields = interaction.split("\t")
                interactor1 = interaction_fields[4].match(Regexp.new(/uniprotkb:(A[Tt]\d[Gg]\d\d\d\d\d)\(locus name\)/))
                interactor2 = interaction_fields[5].match(Regexp.new(/uniprotkb:(A[Tt]\d[Gg]\d\d\d\d\d)\(locus name\)/))
                score = interaction_fields[14].match(Regexp.new(/intact-miscore:(\d\.\d\d)/)).captures[0]
                
                #It creates gene objects that are not already created, match Arabidopsis thaliana id and with interaction score greater than the threshold
                #When annotate_only_list is true, it only annotates gene objects that are in the list; when annotate_only_list is false, it annotates all gene objects
                #It creates interaction objects with the already defined genes
                #It includes new genes as genes found

                if !(interactor1.singleton_class == NilClass or interactor2.singleton_class == NilClass) and score.to_f > threshold
                  if interactor1.captures[0].upcase != gene #The first gene is not the one we were using as sample
                    if !(Gene.get_gene(gene))
                      Gene.new(:gene_id => gene)
                      Gene.get_gene(gene).annotate if $genes.include?(gene) or annotate_only_list == false
                    end
                    if !(Gene.get_gene(interactor1.captures[0].upcase))
                      Gene.new(:gene_id => interactor1.captures[0].upcase)
                      Gene.get_gene(interactor1.captures[0].upcase).annotate if $genes.include?(interactor1.captures[0].upcase) or annotate_only_list == false
                    end
                    Interaction.new(:gene_id_1 => gene, :gene_id_2 => interactor1.captures[0].upcase, :score => score)
                    genes_found |= [interactor1.captures[0].upcase]
                  else #The second gene is not the one we were using as sample
                    if !(Gene.get_gene(gene))
                      Gene.new(:gene_id => gene)
                      Gene.get_gene(gene).annotate if $genes.include?(gene) or annotate_only_list == false
                    end
                    if !(Gene.get_gene(interactor2.captures[0].upcase))
                      Gene.new(:gene_id => interactor2.captures[0].upcase)
                      Gene.get_gene(interactor2.captures[0].upcase).annotate if $genes.include?(interactor2.captures[0].upcase) or annotate_only_list == false
                    end
                    Interaction.new(:gene_id_1 => gene, :gene_id_2 => interactor2.captures[0].upcase, :score => score)
                    genes_found |= [interactor2.captures[0].upcase]
                  end
                  num_interactions += 1         
                end  
              end
            end
          end
        end
      end

      #It removes duplicated interaction objects (we consider A interacts with B to be equal to B interacts with A)
      #The genes found become the new genes to be searched
      
      @@objects.uniq! { |obj| [obj.gene_id_1, obj.gene_id_2].sort }
      genes_to_search = genes_found
      puts "Iteration " + iteration.to_s + " finished"
      
    end 
  end

end
