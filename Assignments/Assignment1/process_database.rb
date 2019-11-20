
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file does two things
#1. It simulates planting 7 grams of seed from each of the records in seed_stock_data.tsv
#2. It determines, with a Chi-square test, which genes from the ones in cross_data.tsv are genetically linked

###############################################################################################################

#PRE-REQUISITES

###############################################################################################################

#We load the files in which the classes are defined
#We use require_relative because it works whenever this file and the others are in the same folder

require_relative 'GeneObject.rb'
require_relative 'SeedstockObject.rb'
require_relative 'CrossObject.rb'

#We assign variables in the command line to the files we need to read and create

gene_file = ARGV[0]
seed_stock_file = ARGV[1]
cross_file = ARGV[2]
new_seed_stock_file = ARGV[3]

###############################################################################################################

#TASK 1: Simulate planting 7 grams of seed from each of the records in seed_stock_data.tsv

###############################################################################################################

puts ""
puts "###############################################################################################################"
puts ""
puts "TASK 1: Simulate planting 7 grams of seed from each of the records in seed_stock_data.tsv"
puts ""
puts "###############################################################################################################"
puts ""

#We load the gene objects with the method Gene.load_all(path_to_file)
#We load the seed stock objects with the method Seedstock.load_all(path_to_file)
#This must be done in such order because one of the properties of seed stock objects has as values gene objects
#We simulate planting 7 grams of each seed stock object with the method Seedstock.plant(quantity)
#We upload the new seed stock objects into the new seed stock file with the method Seedstock.append_all(path_to_file)

Gene.load_all(gene_file)
Seedstock.load_all(seed_stock_file)
Seedstock.plant(7)
Seedstock.write_all(new_seed_stock_file)

###############################################################################################################

#TASK 2: Determine, with a Chi-square test, which genes from the ones in cross_data.tsv are genetically linked

###############################################################################################################

puts ""
puts "###############################################################################################################"
puts ""
puts "TASK 2: Determine, with a Chi-square test, which genes from the ones in cross_data.tsv are genetically linked"
puts ""
puts "###############################################################################################################"
puts ""

#We load the cross objects with the method Cross.load_all(path_to_file)
#Notice that we have already load the seed stock objects
#This must be done in such order because two of the properties of cross objects have as values seed stock objects
#We apply the chi-square test to the cross objects and determine whether the genes are linked with the method Cross.obtain_linked_genes()
#We indicate which genes are linked with the method Gene.show_linked_genes()

Cross.load_all(cross_file)
Cross.obtain_linked_genes()
puts ""
puts "Final Report:"
puts ""
Gene.show_linked_genes()
puts ""
