
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Gene

#A gene object has the following properties:
#id
#gene_info
#polyA_info

#The Gene class has the following methods:
#.count: it returns the number of gene objects
#.get_all: it returns all the gene objects
#.show_all: it returns the inspection of all the gene objects
#.get(id): it returns the gene object with a specific id
  
#A gene object has the following methods:
#.initialize -called automatically from Gene.new-: it assigns the properties, increases the number of objects and stores the object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property
#.write_gene_chars(biosequence): it includes the basic characteristics of a gene
#.write_polyA_chars(polyA,biosequence): it includes the basic characteristics of a polyA
#.write_to_RDF(path_to_file): it writes the information contained in the gene object to a RDF file

###############################################################################################################

#CLASS

###############################################################################################################

class Gene
  
  attr_accessor :id
  attr_accessor :gene_info
  attr_accessor :polyA_info
  @@count = 0
  @@objects = []
  
  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This method initialises gene objects
  #It assigns the properties
  #It increases the number of objects by one
  #It stores the object in an array
  
  def initialize (parameters={})   
    @id = parameters.fetch(:id, "XXXXXX")
    @gene_info = parameters.fetch(:gene_info, {})
    @polyA_info = parameters.fetch(:polyA_info, [])
    @@count += 1
    @@objects << self
  end

  #This method includes the basic characteristics of a gene
  #It receives the biosequence associated with the gene id
  #It iterates over its fields to get information on the organism, chromosome, gene and protein
  #It save these characteristics in the gene object

  def write_gene_chars(biosequence)
    
    gene_name = "Unknown"   
    begin chr_num = biosequence.entry_id(); rescue; end
    begin gene_chr_pos = biosequence.definition.match(/(\d+\.\.\d+)/)[1]; rescue; end
    begin gene_seq = biosequence.seq(); gene_length = gene_seq.length; rescue; end
    
    for feature in biosequence.features
      if feature.feature == "source"
        org_name = feature.assoc["organism"]
        begin org_id = feature.assoc["db_xref"].match(/taxon:(.+)/)[1]; rescue; end
      end
      if feature.feature == "gene" and feature.assoc["gene"] == self.id
          gene_id = feature.assoc["gene"]
          begin gene_name = feature.assoc["note"].match(/(.+) \[/)[1]; rescue; end
      end
      if feature.feature == "mRNA" and feature.assoc["gene"] == self.id
        mrna_pos = feature.position
      end
      if feature.feature == "CDS" and feature.assoc["gene"] == self.id
        cds_pos = feature.position
        for qualifier in feature.qualifiers
          if qualifier.qualifier == "db_xref"
            begin protein_id = qualifier.value.match(/Uniprot\/SPTREMBL:(.+)/)[1]; rescue; end
          end
        end
        protein_seq = feature.assoc["translation"]
        protein_length = protein_seq.length
      end
      if feature.feature == "misc_RNA" and feature.assoc["gene"] == self.id
        misc_rna_pos = feature.position
      end
    end
        
    dict = {"org_id"=>org_id,"org_name"=>org_name,"chr_num"=>chr_num,"gene_id"=>gene_id,"gene_chr_pos"=>gene_chr_pos,
            "gene_seq"=>gene_seq,"gene_name"=>gene_name,"gene_length"=>gene_length,"mrna_pos"=>mrna_pos,"cds_pos"=>cds_pos,
            "protein_id"=>protein_id,"protein_seq"=>protein_seq,"protein_length"=>protein_length, "misc_rna_pos"=>misc_rna_pos}
    p dict
    self.gene_info=(dict)

  end
  
  #This method includes the basic characteristics of a polyA
  #It receives the GFF line and the biosequence associated with the gene id
  #It retrieves the characteristics that are accesible from the GFF line
  #It retrieves the characteristics that are not accesible from the GFF line
  #For classifying it as intronic,exonic,5'UTR or 3'UTR it considers the following
  #If the polyA is out of the gene coordinate, it is incorrectly annotated
  #If the polyA is within the mRNA regions that are not CDS regions, it is UTR (5' UTR or 3'UTR depend on its position and strand)
  #If the polyA is within the CDS regions, it is exonic
  #If non of these are met, it is intronic
  #It save these characteristics in the gene object
    
  def write_polyA_chars(polyA,biosequence)
       
    polyA = polyA.split("\t")
    polyA_chr_pos = polyA[3].to_i
    polyA_strand = polyA[6]
    polyA_conditions = polyA[8].match(/conditions=(.+)/)[1]
    begin; chr_start = biosequence.definition.match(/(\d+)\.\.\d+/)[1].to_i; polyA_gene_pos = polyA_chr_pos - chr_start + 1; rescue; end
    
    for feature in biosequence.features
      if feature.feature == "gene" and feature.assoc["gene"] == self.id
        begin gene = feature.position.scan(/(\d+\.\.\d+)/).map!{|x| x[0].split("..")}[0].map(&:to_i); rescue; end
      end
      if feature.feature == "mRNA" and feature.assoc["gene"] == self.id
        begin mrna = feature.position.scan(/(\d+..\d+)/).map!{|x| x[0].split("..").map(&:to_i)}; min_mrna,max_mrna = mrna.flatten.minmax; rescue; end
      end
      if feature.feature == "CDS" and feature.assoc["gene"] == self.id
        begin cds = feature.position.scan(/(\d+..\d+)/).map!{|x| x[0].split("..").map(&:to_i)}; min_cds,max_cds = cds.flatten.minmax; rescue; end;
      end
      if feature.feature == "misc_RNA" and feature.assoc["gene"] == self.id
        begin misc_rna = feature.position.scan(/(\d+..\d+)/).map!{|x| x[0].split("..").map(&:to_i)}; rescue; end
      end
    end
  
    begin
      polyA_type = "Intronic"
      if polyA_gene_pos.between?(gene[0],gene[1]) == false
        polyA_type = "Incorrectly annotated (the polyA site belongs to other gene than indicated in the GFF file)"
      elsif polyA_gene_pos.between?(min_mrna,min_cds-1)
        polyA_type = "5'UTR" if polyA_strand == "+"
        polyA_type = "3'UTR" if polyA_strand == "-"
      elsif polyA_gene_pos.between?(max_cds+1,max_mrna)
        polyA_type = "3'UTR" if polyA_strand == "+"
        polyA_type = "5'UTR" if polyA_strand == "-"
      elsif
        for cd in cds
          if polyA_gene_pos.between?(cd[0],cd[1])
            polyA_type = "Exonic"
          end
        end
      elsif polyA_gene_pos.between?(misc_rna[0],misc_rna[1])
        for misc in misc_rna
          if polyA_gene_pos.between?(mis[0],misc[1])
            polyA_type = "Exonic"
          end
        end
      end
    rescue;polyA_type = "Undefined";end

    dict = {"polyA_chr_pos"=>polyA_chr_pos,"polyA_gene_pos"=>polyA_gene_pos,"polyA_strand"=>polyA_strand,
            "polyA_type"=>polyA_type,"polyA_conditions"=>polyA_conditions}
    self.polyA_info.append(dict)
      
  end
  
  #This method writes the information contained in the gene object to a RDF (N-triples format) repository
  
  def write_to_RDF(repo)

    local = RDF::Vocabulary.new("http://localhost/")
    rdf = RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    rdfs = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
    obo = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
    uniprotkb = RDF::Vocabulary.new("http://purl.uniprot.org/uniprot/")
    taxon = RDF::Vocabulary.new("http://purl.uniprot.org/taxonomy/")

    gene_info = self.gene_info
    org_id = gene_info["org_id"]; org_name = gene_info["org_name"]; chr_num = gene_info["chr_num"]
    gene_id = gene_info["gene_id"]; gene_name = gene_info["gene_name"]; gene_chr_pos = gene_info["gene_chr_pos"]
    gene_seq = gene_info["gene_seq"]; gene_length = gene_info["gene_length"]; mrna_pos = gene_info["mrna_pos"]
    cds_pos = gene_info["cds_pos"]; protein_id = gene_info["protein_id"]; protein_seq = gene_info["protein_seq"]
    protein_length = gene_info["protein_length"]; misc_rna_pos = gene_info["misc_rna_pos"]

    triple = RDF::Statement(RDF::URI.new("#{taxon}#{org_id}"), rdf.type, RDF::URI.new("#{obo}NCIT_C14250")); repo.insert(triple) if org_id != nil
    triple = RDF::Statement(RDF::URI.new("#{taxon}#{org_id}"), local.hasID, RDF::Literal.new(org_id)); repo.insert(triple) if org_id != nil
    triple = RDF::Statement(RDF::URI.new("#{taxon}#{org_id}"), rdfs.label, RDF::Literal.new(org_name)); repo.insert(triple) if (org_id and org_name) != nil
    triple = RDF::Statement(RDF::URI.new("#{taxon}#{org_id}"), local.contains, RDF::URI.new("#{local}chr/#{org_id}#{chr_num}")); repo.insert(triple) if (org_id and chr_num) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}chr/#{org_id}#{chr_num}"), rdf.type, RDF::URI.new("#{obo}NCIT_C13202")); repo.insert(triple) if (org_id and chr_num) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}chr/#{org_id}#{chr_num}"), rdfs.label, RDF::Literal.new(chr_num)); repo.insert(triple) if (org_id and chr_num) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}chr/#{org_id}#{chr_num}"), local.belongsTo, RDF::URI.new("#{taxon}#{org_id}")); repo.insert(triple) if (org_id and chr_num) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}chr/#{org_id}#{chr_num}"), local.contains, RDF::URI.new("#{local}gene/#{gene_id}")); repo.insert(triple) if (org_id and chr_num and gene_id) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), rdf.type, RDF::URI.new("#{obo}NCIT_C16612")); repo.insert(triple) if gene_id != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.hasID, RDF::Literal.new(gene_id)); repo.insert(triple) if gene_id != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), rdfs.label, RDF::Literal.new(gene_name)); repo.insert(triple) if (gene_id and gene_name) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.hasChromosomePosition, RDF::Literal.new(gene_chr_pos)); repo.insert(triple) if (gene_id and gene_chr_pos) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.hasSequence, RDF::Literal.new(gene_seq)); repo.insert(triple) if (gene_id and gene_seq) != nil 
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.hasLength, RDF::Literal.new(gene_length)); repo.insert(triple) if (gene_id and gene_length) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.producesMRNAin, RDF::Literal.new(mrna_pos)); repo.insert(triple) if (gene_id and mrna_pos) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.producesCDSin, RDF::Literal.new(cds_pos)); repo.insert(triple) if (gene_id and cds_pos) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.producesMISCRNAin, RDF::Literal.new(misc_rna_pos)); repo.insert(triple) if (gene_id and misc_rna_pos) != nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.belongsTo, RDF::URI.new("#{local}chr/#{org_id}#{chr_num}")); repo.insert(triple) if (org_id and gene_id and chr_num)!= nil
    triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.transcribes, RDF::URI.new("#{uniprotkb}#{protein_id}")); repo.insert(triple) if (gene_id and protein_id) != nil
    triple = RDF::Statement(RDF::URI.new("#{uniprotkb}#{protein_id}"), rdf.type, RDF::URI.new("#{obo}NCIT_C17021")); repo.insert(triple) if protein_id != nil
    triple = RDF::Statement(RDF::URI.new("#{uniprotkb}#{protein_id}"), local.hasID, RDF::Literal.new(protein_id)); repo.insert(triple) if protein_id != nil
    triple = RDF::Statement(RDF::URI.new("#{uniprotkb}#{protein_id}"), local.hasSequence, RDF::Literal.new(protein_seq)); repo.insert(triple) if (protein_id and protein_seq) != nil
    triple = RDF::Statement(RDF::URI.new("#{uniprotkb}#{protein_id}"), local.hasLength, RDF::Literal.new(protein_length)); repo.insert(triple) if (protein_id and protein_length) != nil
    triple = RDF::Statement(RDF::URI.new("#{uniprotkb}#{protein_id}"), local.isTranscribedBy, RDF::URI.new("#{local}gene/#{gene_id}")); repo.insert(triple) if (protein_id and gene_id) != nil

    
    polyAs_info = self.polyA_info
    for polyA_info in polyAs_info
      
      polyA_chr_pos = polyA_info["polyA_chr_pos"]; polyA_gene_pos = polyA_info["polyA_gene_pos"]
      polyA_strand = polyA_info["polyA_strand"]; polyA_type = polyA_info["polyA_type"]; polyA_conditions = polyA_info["polyA_conditions"]

      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), rdf.type, RDF::URI.new("#{obo}SO_0000553")); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos) != nil
      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), local.hasChromosomePosition, RDF::Literal.new(polyA_chr_pos)); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos) != nil
      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), local.hasGenePosition, RDF::Literal.new(polyA_gene_pos)); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos and polyA_gene_pos) != nil
      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), local.isInStrand, RDF::Literal.new(polyA_strand)); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos and polyA_strand) != nil
      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), local.isClassifiedAs, RDF::Literal.new(polyA_type)); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos and polyA_type) != nil
      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), local.appearsInConditions, RDF::Literal.new(polyA_conditions)); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos and polyA_conditions) != nil 
      triple = RDF::Statement(RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}"), local.belongsTo, RDF::URI.new("#{local}gene/#{gene_id}")); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos and gene_id) != nil
      triple = RDF::Statement(RDF::URI.new("#{local}gene/#{gene_id}"), local.contains, RDF::URI.new("#{local}polyA/#{org_id}#{chr_num}#{polyA_chr_pos}")); repo.insert(triple) if (org_id and chr_num and polyA_chr_pos and gene_id) != nil

    end
    
    return(repo)
  
  end
    
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that returns the number of gene objects
  
  def Gene.count
    puts @@count
    return @@count
  end
  
  #This is a method that returns all the gene objects
  
  def Gene.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all the gene objects
  
  def Gene.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end
 
  #This is a method that returns the gene object with a specific id
  
  def Gene.get(id)
    for object in @@objects
      return object if object.id == id
    end
    return false
  end
  
end