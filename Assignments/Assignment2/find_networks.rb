
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file looks for interactions between genes and considers the networks that connect genes from a given file
#To do so, it requires from an intensive use of EBI’s PSICQUIC (IntAct) REST API and TOGO REST API

###############################################################################################################

#PRE-REQUISITES

###############################################################################################################

#We use these gems (you might need to install them)

require 'rest-client'
require 'rgl/adjacency'
require 'rgl/dot'

#We load the files in which the classes are defined
#We use require_relative because it works whenever this file and the others are in the same folder

require_relative 'GeneObject.rb'
require_relative 'InteractionObject.rb'
require_relative 'GroupObject.rb'
require_relative 'NetworkObject.rb'
require_relative 'additional_functions.rb'

###############################################################################################################

#TASK: look for interactions between genes and consider the networks that connect genes from a given file

###############################################################################################################

puts ""
puts "###############################################################################################################"
puts ""
puts "TASK: look for interactions between genes and consider the networks that connect genes from a given file"
puts ""
puts "###############################################################################################################"
puts ""

#We convert the gene_file into an array of genes

gene_file = ARGV[0]
$genes = IO.readlines(gene_file, chomp: true).map!(&:upcase)

#We set some initial parameters
#Number of iterations (times we do consecutive searches on interactions)
#Maximum number of interactions (direct interactions we consider per gene)
#Threshold (score above which we consider an interaction to be consistant)
#I included two configurations that do well.
#The first one is quite flexible with the score (which means that many interactions pass the filter). We do only one iteration so we are looking for closer interactors
#The second one is more rigid with the the score (which means that little interactions pass the filter). We do three iterations so we are looking for further interactors

iterations = 1; max_interactions = Float::INFINITY; threshold = 0.3
#iterations = 3; max_interactions = Float::INFINITY; threshold = 0.5

#We load the interactions with Interaction.load_interactions
#When genes appear in an interaction, we initialise them with Gene.new
#We annotate (add information on pathwats and biological processes) the genes with gene.annotate.
#The only_list = true parameter is used to annotate only the proteins from our list (this is much more efficient because in the report we are only supposed to show such annotations)

puts "The interactions are going to be loaded (this will take a while, we are intensively accesing to REST APIs)"
annotate_only_list = true
Interaction.load_interactions(iterations, max_interactions, threshold, annotate_only_list)
puts "The interactions were loaded"

#We load the groups (group together the genes that are in a interaction network) with Group.load_groups
#The consider_only_list = true parameter is used to filter only those networks that contain at least two genes from our list 

puts "The groups are going to be loaded"
consider_only_list = true
Group.load_groups(consider_only_list)
puts "The groups we loaded"

#We load the networks (state the relations between  genes in the same group) with Network.load_networks

puts "The networks are going to be loaded"
Network.load_networks
puts "The networks were loaded"

#We create a report and visual representations of the networks

write_report("Final Report.txt", annotate_only_list)
puts "The report was written and saved as 'Final Report'"
puts "The network graphs were created and saved as 'Network{number}'"
puts ""
