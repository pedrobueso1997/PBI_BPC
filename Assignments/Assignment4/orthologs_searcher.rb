###############################################################################################################
#BRIEF EXPLANATION
###############################################################################################################

#This file searches for orthologs between two given proteomes, using Best Reciprocal Hits (BRHs) approach

###############################################################################################################
#PRE-REQUISITES
###############################################################################################################

require 'stringio'
require 'bio'

###############################################################################################################
#TASK: search for orthologs between two given proteomes, using Best Reciprocal Hits (BRHs) approach
###############################################################################################################

puts ""
puts "###############################################################################################################"
puts "TASK: search for orthologs between two given proteomes, using Best Reciprocal Hits (BRHs) approach"
puts "###############################################################################################################"
puts ""

#We retrieve the number of sequences per proteome and create two files (short_proteome.fa, long_proteome.fa)
#From now on, we will be working with this files

sequences_1 = IO.read(ARGV[0]).scan(/(>[^>]*)/m)
sequences_2 = IO.read(ARGV[1]).scan(/(>[^>]*)/m)
if sequences_1.length < sequences_2.length
  system("cp #{ARGV[0]} short.fa"); short_proteome = ARGV[0]
  system("cp #{ARGV[1]} long.fa"); long_proteome = ARGV[1]
else
  system("cp #{ARGV[1]} short.fa"); short_proteome = ARGV[1]
  system("cp #{ARGV[0]} long.fa"); long_proteome = ARGV[0]
end

#We determine the type of molecule (DNA or protein) for each file
#We determine the type of blast (blast, blastp, blastx, tblastn) that will be done for each file
#This makes our code workable with independence from the input files

determine_type = {Bio::Sequence::AA => "prot", Bio::Sequence::NA => "nucl"} 
determine_blast = {"nucl,nucl" => "blast", "prot,prot" => "blastp", "nucl,prot" => "blastx", "prot,nucl" => "tblastn"}

sequences_short = IO.read("short.fa").scan(/(>[^>]*)/m)
sequences_long = IO.read("long.fa").scan(/(>[^>]*)/m)
type_short = determine_type[Bio::Sequence.auto(Bio::FastaFormat.new(sequences_short[0][0]).seq).seq.class]
type_long = determine_type[Bio::Sequence.auto(Bio::FastaFormat.new(sequences_long[0][0]).seq).seq.class]
blast_short = determine_blast["#{type_short},#{type_long}"]
blast_long = determine_blast["#{type_long},#{type_short}"]

#We create the index files necessary to do blast

puts "Creating the index files..."
system("makeblastdb -in short.fa -dbtype '#{type_short}' -out short > trash1")
system("makeblastdb -in long.fa -dbtype '#{type_long}' -out long > trash2")

#We blast the short proteome on the long proteome
#We only consider those alignments with an e-value lower than 1e-6 (this is a threshold that has been used in past experiments)
#We only keep the best alignments for each sequence; this is, the one with the lowest e-value
#Note that doing the blast first on the short proteome might save a lot of computational power

puts "Doing the first blast analysis..."
system("#{blast_short} -query short.fa -db long -max_target_seqs 1 -max_hsps 1 -evalue 1e-6 -outfmt 6 -out short_blast_report.txt")
system("cat short_blast_report.txt | cut -f1,2 > short_best_hits.txt")

#We store the pairs query - best hit in a dictionary
#The query is a sequence id of the short proteome
#The best hit is a sequence id of the long proteome

puts "Processing the first blast analysis..."
short_best_hits = IO.readlines("short_best_hits.txt")
short_pairs = {}
short_hits = []
for pair in short_best_hits
  pair.strip!
  query, hit = pair.split("\t")
  short_pairs[query] = hit
  short_hits |= [hit]
end

#We filter, from the file long.fa, those sequences that were hits in the blast analysis
#Note that filtering the file for the long proteome might save a lot of computational power

File.open('long.fa', 'w') do |myfile|
  for sequence in sequences_long
    fasta_object = Bio::FastaFormat.new(sequence[0])
    if short_hits.include?(fasta_object.entry_id)
      myfile.puts sequence
    end
  end
end

#We blast the long proteome on the short proteome
#We only consider those alignments with an e-value lower than 1e-6 (this is a threshold that has been used in past experiments)
#We only keep the best alignments for each sequence; this is, the one with the lowest e-value

puts "Doing the second blast analysis..."
system("#{blast_long} -query long.fa -db short -max_target_seqs 1 -max_hsps 1 -evalue 1e-6 -outfmt 6 -out long_blast_report.txt")
system("cat long_blast_report.txt | cut -f1,2 > long_best_hits.txt")

#We store the pairs query - best hit in a dictionary
#The query is a sequence id of the long proteome
#The best hit is a sequence id of the short proteome

puts "Processing the second blast analysis..."
long_best_hits = IO.readlines("long_best_hits.txt")
long_pairs = {}
for pair in long_best_hits
  pair.strip!
  query, hit = pair.split("\t")
  long_pairs[query] = hit
end

#We find the orthologs
#These are sequences that are the best hit of their best hit

puts "Finding the orthologs..."
File.open('orthologs.txt', 'w') do |myfile|
  myfile.puts "#{short_proteome}\t\t\t#{long_proteome}"
  for query in short_pairs.keys
    reciprocal_hit = long_pairs[short_pairs[query]]
    myfile.puts "#{query.split("|")[0]}\t\t\t#{short_pairs[query]}" if query == reciprocal_hit
  end
end
puts "The file orthologs.txt was created"
puts

#We remove intermediate files but keep the ones for the blast report (they migth be useful for the researcher)

system("cp short_blast_report.txt #{short_proteome}.blast_report.txt")
system("cp long_blast_report.txt #{long_proteome}.blast_report.txt")
system("rm trash1 trash2")
system("rm short* long*")