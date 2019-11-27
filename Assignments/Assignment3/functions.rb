##################################################################################################################################

#This functions connects to web addresses safely
#Credits for Mark Wilkinson

def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
  response = RestClient::Request.execute({
    method: :get,
    url: url.to_s,
    user: user,
    password: pass,
    headers: headers})
  return response
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.response
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue RestClient::Exception => e
    $stderr.puts e.response
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue Exception => e
    $stderr.puts e
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end

##################################################################################################################################

#This function receives a list of genes and creates a local file with information from ensembl of these genes

def create_gene_file(genes)
  
  genes_string = genes.join(",")
  address = URI('http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id='+genes_string)
  response = fetch(address)
  record = response.body
  File.open('genes_file.embl', 'w') do |myfile| myfile.puts record end
  genes_file = Bio::FlatFile.auto('genes_file.embl')
  puts "The local file was created"
  return genes_file
  
end

##################################################################################################################################

#This function creates a biosequence object from a given gene_id
#It first retrieves the gene information from ensembl genomes, converts it into a bioembl object and eventually into a biosequence object

def create_biosequence(gene)
  address = URI('http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id='+gene)
  response = fetch(address)
  record = response.body
  embl = Bio::EMBL.new(record)
  biosequence = embl.to_biosequence
  return biosequence
end

##################################################################################################################################

#This function retrieves the exon positions
#The plus_exon_positions refer to those cases in which the exon is in the plus strand
#The minus_exon_positions refer to those cases in which the exon is in the minus strand
#It also stores the overlapping genes in a hash {gene_id: [exon1, exon2...]}

def get_exon_positions(biosequence, genes, genes_overlapped)
  plus_exon_positions = []
  minus_exon_positions = []
  biosequence.features.each do |feature|
    if feature.assoc.to_s.match(/exon/) != nil
      if feature.position.match(/:\d+..\d+/)
        gene_overlapped = feature.assoc.to_s.match(/exon_id=(A[Tt]\d[Gg]\d\d\d\d\d)\./)[1]
        exon_overlapped = feature.assoc.to_s.match(/exon_id=(A[Tt]\d[Gg]\d\d\d\d\d\.\d+\.exon\d+)/)[1]
        if genes.include?(genes_overlapped) == false
          genes_overlapped[gene_overlapped] |= [exon_overlapped]
        end
      else
        if feature.position.match(/complement/) != nil
          minus_exon_position = feature.position.match(/complement\((\d+)\.\.(\d+)\)/).captures
          minus_exon_positions << minus_exon_position
        else
          plus_exon_position = feature.position.match(/(\d+)\.\.(\d+)/).captures
          plus_exon_positions << plus_exon_position
        end
      end
    end
  end
  return plus_exon_positions, minus_exon_positions, genes_overlapped
end

##################################################################################################################################

#This function retrieves the exon positions when there are only some permited exons
#The plus_exon_positions refer to those cases in which the exon is in the plus strand
#The minus_exon_positions refer to those cases in which the exon is in the minus strand

def get_exon_positions_overlapped(biosequence, permited_exons)
  plus_exon_positions = []
  minus_exon_positions = []
  biosequence.features.each do |feature|
    if feature.assoc.to_s.match(/exon/) != nil
      if permited_exons.include?(feature.assoc.to_s.match(/exon_id=(A[Tt]\d[Gg]\d\d\d\d\d\.\d+\.exon\d+)/)[1])
        if feature.position.match(/complement/) != nil
          minus_exon_position = feature.position.match(/complement\((\d+)\.\.(\d+)\)/).captures
          minus_exon_positions << minus_exon_position
        else
          plus_exon_position = feature.position.match(/(\d+)\.\.(\d+)/).captures
          plus_exon_positions << plus_exon_position
        end
      end
    end
  end
  return plus_exon_positions, minus_exon_positions
end

##################################################################################################################################

#This function searches for the target sequence, using a regular expression that allows identifying overlapping targets
#The plus_target_positions refer to those targets found in the plus strand (they are only considered if being inside and exon)
#The minus_target_positions refer to those targets found in the minus strand (they are only considered if being inside and exon)
#It also stores the genes with no target in an array 

def search_target(biosequence, gene_id, plus_exon_positions, minus_exon_positions, genes_no_target)
  plus_target = Bio::Sequence.auto("CTTCTT").seq
  minus_target = Bio::Sequence.auto("CTTCTT").reverse_complement.seq
  length_target = plus_target.length
  plus_target_positions = []
  minus_target_positions = []
  if plus_exon_positions != []
    biosequence.seq.scan(/(?=(#{plus_target}))/) do |target|
      target_start = Regexp.last_match.offset(0).first + 1
      target_end = Regexp.last_match.offset(0).first + length_target
      in_exon = false
      for exon in plus_exon_positions
        if target_start >= exon[0].to_i and target_end <= exon[1].to_i
          in_exon = true
          break
        end
      end
      plus_target_positions << [target_start, target_end] if in_exon == true 
    end
  end
  if minus_exon_positions != []
    biosequence.seq.scan(/(?=(#{minus_target}))/) do |target|
      target_start = Regexp.last_match.offset(0).first + 1
      target_end = Regexp.last_match.offset(0).first + length_target
      in_exon = false
      for exon in minus_exon_positions
        if target_start >= exon[0].to_i and target_end <= exon[1].to_i
          in_exon = true
          break
        end
      end
      minus_target_positions << [target_start, target_end] if in_exon == true 
    end
  end  
  genes_no_target |= [gene_id] if plus_target_positions == [] and minus_target_positions == []
  return plus_target_positions, minus_target_positions, genes_no_target
end

##################################################################################################################################

#This function adds new features to a biosequence

def add_features(biosequence, gene_id, plus_target_positions, minus_target_positions)
  chr_num = biosequence.definition.match(/chromosome\s(\d)/)[1]
  chr_init_pos = biosequence.definition.match(/(\d+)\.\.\d+/)[1].to_i 
  for target in plus_target_positions
    feature = Bio::Feature.new("targeting_vector","#{target[0]}..#{target[1]}")
    feature.append(Bio::Feature::Qualifier.new("seqid", gene_id))
    feature.append(Bio::Feature::Qualifier.new("strand", "+"))
    feature.append(Bio::Feature::Qualifier.new("chromosome", chr_num))
    feature.append(Bio::Feature::Qualifier.new("chromosome_position", chr_init_pos))
    biosequence.features << feature
  end
  for target in minus_target_positions
    feature = Bio::Feature.new("targeting_vector","complement(#{target[0]}..#{target[1]})")
    feature.append(Bio::Feature::Qualifier.new("seqid", gene_id))
    feature.append(Bio::Feature::Qualifier.new("strand", "-"))
    feature.append(Bio::Feature::Qualifier.new("chromosome", chr_num))
    feature.append(Bio::Feature::Qualifier.new("chromosome_position", chr_init_pos))
    biosequence.features << feature
  end  
  return biosequence
end

##################################################################################################################################

#This function puts the new features in GFF3 format lines, both for genes and chromosomes
#It then adds this new features to an array containing all GFF3 format lines, both for genes and chromosomes

def write_features(biosequences)
  gene_lines = []
  chr_lines = []
  for biosequence in biosequences
    for feature in biosequence.features
      if feature.feature == "targeting_vector"
        start_gene = feature.position.match(/(\d+)\.\./)[1].to_i
        finish_gene = feature.position.match(/\.\.(\d+)/)[1].to_i
        start_chr = feature.assoc["chromosome_position"] + start_gene - 1
        finish_chr = feature.assoc["chromosome_position"] + finish_gene - 1
        gene_line = "Chr#{feature.assoc["chromosome"]}\t.\t#{feature.feature}\t#{start_gene}\t#{finish_gene}\t.\t#{feature.assoc["strand"]}\t.\tID=#{feature.assoc["seqid"]}"
        chr_line = "Chr#{feature.assoc["chromosome"]}\t.\t#{feature.feature}\t#{start_chr}\t#{finish_chr}\t.\t#{feature.assoc["strand"]}\t.\tID=#{feature.assoc["seqid"]}"
        gene_lines << gene_line
        chr_lines << chr_line
      end
    end
  end
  return gene_lines, chr_lines
end

##################################################################################################################################

#This function creates a file with those initial genes that do not have the target sequence

def create_file_no_target(genes_no_target, genes)
  File.open('no_target.txt', 'w') do |myfile|
    for gene in genes_no_target
      if genes.include?(gene)
        myfile.puts gene
      end        
    end
  end
  puts "The file no_target.txt has been created"
end

##################################################################################################################################

#This function creates a GFF3 file with the gene information

def create_file_contigs(gene_lines)
  File.open('genes.gff3', 'w') do |myfile|
    for gene_line in gene_lines
      myfile.puts gene_line
    end
  end
  puts "The file gene.gff3 has been created"
end

##################################################################################################################################

#This function creates a GFF3 file with the chromosome information

def create_file_chromosome(chr_lines)
  File.open('chromosomes.gff3', 'w') do |myfile|
    for chr_line in chr_lines
      myfile.puts chr_line
    end
  end
  puts "The file chromosomes.gff3 has been created"
end

##################################################################################################################################