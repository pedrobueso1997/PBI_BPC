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

def create_gene_file(genes_to_study)
  
  genes_to_study_string = genes_to_study.join(",")
  address = URI('http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id='+genes_to_study_string)
  response = fetch(address)
  record = response.body
  File.open('genes_to_study_file.embl', 'w') do |myfile| myfile.puts record end
  genes_to_study_file = Bio::FlatFile.auto('genes_to_study_file.embl')
  puts "The local file was created"
  return genes_to_study_file
  
end

##################################################################################################################################

#This function receives a local file, creates biosequence objects from its entries, adds "targeting vector" features features and puts them in a gff3 format

def analyse_gene_file(genes_to_study_file, genes_to_study, genes_studied, genes_no_target, contig_lines, chr_lines)
  
  gene_number= 0
  genes_linked = []
  
  genes_to_study_file.each_entry do |entry|
     
    bio_sequence = entry.to_biosequence
    
    if bio_sequence.definition != ''
      
      #We retrieve the gene id
      
      gene_id = genes_to_study[gene_number]
      gene_number += 1
      
      #We retrieve the chromosome number and the chromosome initial position
      
      chr_num = entry.definition.match(/chromosome\s(\d)/)[1]
      chr_init_pos = entry.definition.match(/(\d+)\.\.\d+/)[1].to_i
    
      #We retrieve the exon positions
      #The plus_exon_positions refer to those cases in which the exon is in the plus strand
      #The minus_exon_positions refer to those cases in which the exon is in the minus strand
      
      plus_exon_positions = []
      minus_exon_positions = []
      
      bio_sequence.features.each do |feature|
        if feature.assoc.to_s.match(/exon/) != nil
          if feature.position.match(/:\d+..\d+/)
            gene_linked = feature.assoc.to_s.match(/exon_id=(A[Tt]\d[Gg]\d\d\d\d\d)\./)[1]
            genes_linked |= [gene_linked] if genes_studied.include?(gene_linked) == false
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
    
      #We search for the targets CTTCTT and complement
      #The plus_target_positions refer to those targets found in the plus strand (they are only considered if being inside and exon)
      #The minus_target_positions refer to those targets found in the minus strand (they are only considered if being inside and exon)
      
      plus_target = Regexp.new(Bio::Sequence.auto("CTTCTT"))
      minus_target = Regexp.new(Bio::Sequence.auto("CTTCTT").reverse_complement) 
      plus_target_positions = []
      minus_target_positions = []
      
      if plus_exon_positions != []
        bio_sequence.seq.scan(plus_target) do |target|
          target_start = Regexp.last_match.offset(0).first + 1
          target_end = Regexp.last_match.offset(0).last
          in_exon = false
          for exon in plus_exon_positions
            if target_start > exon[0].to_i and target_end < exon[1].to_i
              in_exon = true
              break
            end
          end
          plus_target_positions << [target_start, target_end] if in_exon == true 
        end
      end
      
      if minus_exon_positions != []
        bio_sequence.seq.scan(minus_target) do |target|
          target_start = Regexp.last_match.offset(0).first + 1
          target_end = Regexp.last_match.offset(0).last
          in_exon = false
          for exon in minus_exon_positions
            if target_start > exon[0].to_i and target_end < exon[1].to_i
              in_exon = true
              break
            end
          end
          minus_target_positions << [target_start, target_end] if in_exon == true 
        end
      end  
      
      genes_no_target |= [gene_id] if plus_target_positions == [] and minus_target_positions == []
      
      #We add the new features to the biosequence
         
      for target in plus_target_positions
        feature = Bio::Feature.new("targeting_vector","#{target[0]}..#{target[1]}")
        feature.append(Bio::Feature::Qualifier.new("seqid", gene_id))
        feature.append(Bio::Feature::Qualifier.new("strand", "+"))
        feature.append(Bio::Feature::Qualifier.new("chromosome", chr_num))
        feature.append(Bio::Feature::Qualifier.new("chromosome_position", chr_init_pos))
        bio_sequence.features << feature
      end
      
      for target in minus_target_positions
        feature = Bio::Feature.new("targeting_vector","complement(#{target[0]}..#{target[1]})")
        feature.append(Bio::Feature::Qualifier.new("seqid", gene_id))
        feature.append(Bio::Feature::Qualifier.new("strand", "-"))
        feature.append(Bio::Feature::Qualifier.new("chromosome", chr_num))
        feature.append(Bio::Feature::Qualifier.new("chromosome_position", chr_init_pos))
        bio_sequence.features << feature
      end
      
      #We loop over this new features and append GFF3 format lines to the contig_lines and chr_lines
      
      for feature in bio_sequence.features
        if feature.feature == "targeting_vector"
          start_contig = feature.position.match(/(\d+)\.\./)[1].to_i
          finish_contig = feature.position.match(/\.\.(\d+)/)[1].to_i
          start_chr = chr_init_pos + start_contig - 1
          finish_chr = chr_init_pos + finish_contig - 1
          contig_line = "Chr#{chr_num}\t.\t#{feature.feature}\t#{start_contig}\t#{finish_contig}\t.\t#{feature.assoc["strand"]}\t.\tID=#{feature.assoc["seqid"]}"
          chr_line = "Chr#{chr_num}\t.\t#{feature.feature}\t#{start_chr}\t#{finish_chr}\t.\t#{feature.assoc["strand"]}\t.\tID=#{feature.assoc["seqid"]}"
          contig_lines << contig_line
          chr_lines << chr_line
        end
      end
    end
  end
  
  #We return the following items
  
  puts "The file has been analysed"
  return genes_linked, genes_no_target, contig_lines, chr_lines
  
end

##################################################################################################################################

#This function creates a file with the initial genes that don't have the target sequence

def create_file_no_target(genes_no_target, initial_genes)
  File.open('no_target.txt', 'w') do |myfile|
    myfile.puts "This is a list of the initial genes that don't have the target sequence in a coding region"
    myfile.puts
    for gene in genes_no_target
      if initial_genes.include?(gene)
        myfile.puts gene
      end        
    end
  end
  puts "The file no_target.txt has been created"
end

##################################################################################################################################

#This function creates a gff3 file with the contig information

def create_file_contigs(contig_lines)
  File.open('contigs.gff3', 'w') do |myfile|
    for contig_line in contig_lines
      myfile.puts contig_line
    end
  end
  puts "The file contigs.gff3 has been created"
end

##################################################################################################################################

#This function creates a gff3 file with the chromosome information

def create_file_chromosome(chr_lines)
  File.open('chromosomes.gff3', 'w') do |myfile|
    for chr_line in chr_lines
      myfile.puts chr_line
    end
  end
  puts "The file chromosomes.gff3 has been created"
end

##################################################################################################################################