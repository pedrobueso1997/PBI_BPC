require 'cgi'
require 'rdf'
require 'sparql/client'
require 'rdf/ntriples'
require 'rdf/repository'

cgi = CGI.new('html4')
ID = cgi.params["id"][0]
graph = RDF::Graph.load("./small_database.nt")
#graph = RDF::Graph.load("./database.nt")
repo = RDF::Repository.new
repo.insert(*graph)
sparql = SPARQL::Client.new(repo)

#This query searches for the organism and chromosome to which the gene belongs

query1 =
<<END
PREFIX local:<http://localhost/>
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo:<http://purl.obolibrary.org/obo/>
SELECT ?chr_name ?org_id ?org_name
WHERE
{
  ?gene local:hasID "#{ID}" .
  ?gene rdf:type obo:NCIT_C16612 .
  ?gene local:belongsTo ?chr .
  ?chr rdf:type obo:NCIT_C13202 .
  ?chr rdfs:label ?chr_name .
  ?chr local:belongsTo ?org .
  ?org local:hasID ?org_id .
  ?org rdfs:label ?org_name
}
END

results1 = sparql.query(query1)
results1.each do |result1|
  puts "ORGANISM"
  puts "Identifier: #{result1[:org_id]}"
  puts "Name: #{result1[:org_name]}"
  puts
  puts "CHROMOSOME"
  puts "Number: #{result1[:chr_name]}"
end

#This query searches for the gene related features

query2 =
<<END
PREFIX local:<http://localhost/>
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo:<http://purl.obolibrary.org/obo/>
SELECT ?gene_name ?gene_chr_pos ?gene_length ?gene_seq
WHERE
{
  ?gene local:hasID "#{ID}" .
  ?gene rdf:type obo:NCIT_C16612 .
  ?gene rdfs:label ?gene_name .
  ?gene local:hasChromosomePosition ?gene_chr_pos .
  ?gene local:hasLength ?gene_length .
  ?gene local:hasSequence ?gene_seq .
}
END

results2 = sparql.query(query2)
results2.each do |result2|
  puts
  puts "GENE"
  puts "Identifier: #{ID}"
  puts "Name: #{result2[:gene_name]}"
  puts "Position in the chromosome: #{result2[:gene_chr_pos]}"
  puts "Length (nucleotides): #{result2[:gene_length]}"
  puts "Sequence: #{result2[:gene_seq]}"
end

#These two queries search for the transcripts related features

query3 =
<<END
PREFIX local:<http://localhost/>
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX obo:<http://purl.obolibrary.org/obo/>
SELECT ?mrna_pos ?cds_pos ?protein_id ?protein_seq ?protein_length
WHERE
{
  ?gene local:hasID "#{ID}" .
  ?gene rdf:type obo:NCIT_C16612 .
  ?gene local:producesMRNAin ?mrna_pos .
  ?gene local:producesCDSin ?cds_pos .
  ?gene local:transcribes ?protein .
  ?protein rdf:type obo:NCIT_C17021 .
  ?protein local:hasID ?protein_id .
  ?protein local:hasSequence ?protein_seq .
  ?protein local:hasLength ?protein_length .
}
END

results3 = sparql.query(query3)
results3.each do |result3|
  puts "Regions converted to mRNA: #{result3[:mrna_pos]}"
  puts "Regions converted to CDS: #{result3[:cds_pos]}"
  puts
  puts "PROTEIN"
  puts "Identifier: #{result3[:protein_id]}"
  puts "Length (amino acids): #{result3[:protein_length]}"
  puts "Sequence: #{result3[:protein_seq]}"
end

query4 =
<<END
PREFIX local:<http://localhost/>
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX obo:<http://purl.obolibrary.org/obo/>
SELECT ?misc_rna_pos
WHERE
{
  ?gene local:hasID "#{ID}" .
  ?gene rdf:type obo:NCIT_C16612 .
  ?gene local:producesMISCRNAin ?misc_rna_pos .
}
END

results4 = sparql.query(query4)
results4.each do |result4|
  puts "Regions converted to miscRNA: #{result4[:misc_rna_pos]}"
end

#These query searches for the polyA sites that belongs to the gene

query5 =
<<END
PREFIX local:<http://localhost/>
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo:<http://purl.obolibrary.org/obo/>
SELECT DISTINCT ?polyA_chr_pos ?polyA_gene_pos ?polyA_strand ?polyA_type ?polyA_conditions
WHERE 
{
  ?gene rdf:type obo:NCIT_C16612 .
  ?polyA rdf:type obo:SO_0000553 .
  ?gene local:hasID "#{ID}" .
  ?gene local:contains ?polyA .
  ?polyA local:hasChromosomePosition ?polyA_chr_pos .
  ?polyA local:hasGenePosition ?polyA_gene_pos .
  ?polyA local:isInStrand ?polyA_strand .
  ?polyA local:isClassifiedAs ?polyA_type .
  ?polyA local:appearsInConditions ?polyA_conditions .
}
END

results5 = sparql.query(query5)
results5.each do |result5|
  puts
  puts "polyA SITE"
  puts "Position in the chromosome: #{result5[:polyA_chr_pos]}"
  puts "Position in the gene: #{result5[:polyA_gene_pos]}"
  puts "Strand in the DNA: #{result5[:polyA_strand]}"
  puts "Type regarding its location: #{result5[:polyA_type]}"
  puts "Conditions in which it appears: #{result5[:polyA_conditions].to_s.split(",").length} (see below)"
  puts "#{result5[:polyA_conditions].to_s.tr(",","\n")}"
end
