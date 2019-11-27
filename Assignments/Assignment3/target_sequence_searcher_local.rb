
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file looks for the presence of a specific sequence in a series of Arabidopsis thaliana genes
#To do so, it requires from an intensive use of Ensemble database

###############################################################################################################

#PRE-REQUISITES

###############################################################################################################

require 'rest-client'
require 'bio'
require_relative 'functions.rb'

###############################################################################################################

#TASK: look for a target sequence in a set of genes and create GFF3 with the new discovered features

###############################################################################################################

puts ""
puts "###############################################################################################################"
puts ""
puts "TASK: look for a target sequence in a set of genes and create GFF3 with the new discovered features"
puts ""
puts "###############################################################################################################"
puts ""

genes = IO.readlines(ARGV[0], chomp: true).map!(&:upcase)
genes_overlapped = Hash.new([])
genes_no_target = []
biosequences = []

#We retrieve the ensembl genome file for all the genes in the list and bring it to local
#We iterate over each entry in the file and converts it to biosequence
#We retrieve the exon positions (as the targets are only valid inside exons) and store those exons belonging to overlapping genes
#We search for the target using regular expressions on the sequence
#We add the new features found to the biosequence
#We add the updated biosequence to an array of biosequences

puts
puts "Searching for the list genes..."
puts

genes_file = create_gene_file(genes)
i=0
genes_file.each_entry do |entry|
  biosequence = entry.to_biosequence
  if biosequence.definition != ""
    puts "#{i}/#{genes.length-1}"
    gene_id = genes[i]
    plus_exon_positions, minus_exon_positions, genes_overlapped = get_exon_positions(biosequence, genes, genes_overlapped)
    plus_target_positions, minus_target_positions, genes_no_target = search_target(biosequence, gene_id, plus_exon_positions, minus_exon_positions, genes_no_target)
    updated_biosequence = add_features(biosequence, gene_id, plus_target_positions, minus_target_positions)
    biosequences << updated_biosequence
    i += 1
  end
end

#We repeat the same process for the overlapping genes, with the only difference that the search is restricted to the overlapping exons.

puts
puts "Searching for the overlapping genes..."
puts

genes_overlapped_file = create_gene_file(genes_overlapped.keys)
i=0
genes_overlapped_file.each_entry do |entry|
  biosequence = entry.to_biosequence
  if biosequence.definition != ""
    puts "#{i}/#{genes_overlapped.keys.length-1}"
    gene_id = genes_overlapped.keys[i]
    permited_exons = genes_overlapped[gene_id]
    plus_exon_positions, minus_exon_positions = get_exon_positions_overlapped(biosequence, permited_exons)
    plus_target_positions, minus_target_positions, genes_no_target = search_target(biosequence, gene_id, plus_exon_positions, minus_exon_positions, genes_no_target)
    updated_biosequence = add_features(biosequence, gene_id, plus_target_positions, minus_target_positions)
    biosequences << updated_biosequence
    i += 1
  end
end

#We create the GFF3 files, both for genes and chromosomes, and the gene file with no targets

puts
puts "Giving the results..."
puts

gene_lines, chr_lines = write_features(biosequences)
create_file_no_target(genes_no_target, genes)
create_file_contigs(gene_lines)
create_file_chromosome(chr_lines)
system("rm genes_file.embl")