require 'rest-client'
require 'bio'
require 'rdf'
require 'sparql/client'
require 'rdf/ntriples'
require 'rdf/repository'

require_relative 'functions.rb'
require_relative 'classes.rb'

#We save the input values as variables
#We generate a non-redundant array with all the polyA and information on the conditions in which they appear

polyAs0 = IO.readlines("WT-CM-X_polyA.gff",chomp:true)
condition0 = "Wild Type on Complete Medium"
polyAs1 = IO.readlines("WT--C-X_polyA.gff",chomp:true)
condition1 = "Wild Type in Carbon Starvation"
polyAs2 = IO.readlines("WT--N-X_polyA.gff",chomp:true)
condition2 = "Wild Type in Nitrogen Starvation"
polyAs3 = IO.readlines("WT-MM-X_polyA.gff",chomp:true)
condition3 = "Wild Type on Minimal Medium"
polyAs = create_non_redundant_array(polyAs0,condition0,polyAs1,condition1,polyAs2,condition2,polyAs3,condition3)
File.open("nr_polyA","w"){|file| file.puts polyAs}

#We iterate over each element of the array
#We retrieve the gene id
#We create a gene object unless one with the same id exists  
#We create a biosequence object 
#We include in the gene object the basic characteristics for the gene unless they have already been filled
#We include in the gene object the basic characteristics for the polyA

total = polyAs.length
i = 0
for polyA in polyAs
  i+=1
  puts "#{i}/#{total}"
  id = obtain_id(polyA)
  Gene.new(:id => id) if Gene.get(id) == false
  biosequence = create_biosequence(id)
  Gene.get(id).write_gene_chars(biosequence) if Gene.get(id).gene_info == {}
  Gene.get(id).write_polyA_chars(polyA,biosequence)
  #break if i == 100
end

#We create a file and include the RDF prefixed
#We iterate over each gene object and write it in RDF

repo = RDF::Repository.new
for gene_object in Gene.get_all()
  repo = gene_object.write_to_RDF(repo)
end
RDF::Writer.open("database.nt"){|writer| writer << repo}
