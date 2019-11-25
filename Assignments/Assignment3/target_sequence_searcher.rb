
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file looks for the presence of a specific sequence in a series of Arabidopsis thaliana genes
#To do so, it requires from an intensive use of Ensemble database

###############################################################################################################

#PRE-REQUISITES

###############################################################################################################

#We use these gems (you might need to install them)

require 'rest-client'
require 'bio'

#We load the files in which the functions are defined
#We use require_relative because it works whenever this file and the others are in the same folder

require_relative 'additional_functions.rb'

###############################################################################################################

#TASK: look for a target sequence in a set of genes and create gff3 with the new discovered features

###############################################################################################################

puts ""
puts "###############################################################################################################"
puts ""
puts "TASK: look for a target sequence in a set of genes and create gff3 with the new discovered features"
puts ""
puts "###############################################################################################################"
puts ""

#We create two different arrays; one refers to the genes that are going to be studied and the other one to the already studied genes

initial_genes = IO.readlines(ARGV[0], chomp: true).map!(&:upcase)
genes_to_study = initial_genes.map(&:clone)
genes_studied = initial_genes.map(&:clone)

#We search for the target sequence in the genes to be studied
#Some iterations are required because the genes might be linked to other genes that have not been studied

genes_no_target = []
contig_lines = []
chr_lines = []
iteration=1

while genes_to_study != []
  puts "Iteration" + iteration.to_s; iteration += 1
  puts "The following genes are going to be studied"
  p genes_to_study
  genes_to_study_file = create_gene_file(genes_to_study)
  genes_linked, genes_no_target, contig_lines, chr_lines = analyse_gene_file(genes_to_study_file, genes_to_study, genes_studied, genes_no_target, contig_lines, chr_lines)
  (genes_studied << genes_linked).flatten!
  genes_to_study = genes_linked
  puts
end

#We create the output files

create_file_no_target(genes_no_target, initial_genes)
create_file_contigs(contig_lines)
create_file_chromosome(chr_lines)

#We remove the files that should not be output

system("rm genes_to_study_file.embl")
