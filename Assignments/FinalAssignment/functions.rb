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

#This function creates a non redundant GFF array
#It receives 4 files with its 4 conditions
#It considers only non-redundant lines
#It adds information regarding to the conditions in which such line appears
#It returns an array with each of the new lines as an element

def create_non_redundant_array(polyAs0,condition0,polyAs1,condition1,polyAs2,condition2,polyAs3,condition3)
  old_polyAs = (polyAs0 + polyAs1 + polyAs2 + polyAs3).uniq!
  polyAs = []
  for old_polyA in old_polyAs
    polyA = old_polyA + "conditions="
    polyA = polyA + condition0 + "," if polyAs0.include?(old_polyA)
    polyA = polyA + condition1 + "," if polyAs1.include?(old_polyA)
    polyA = polyA + condition2 + "," if polyAs2.include?(old_polyA)
    polyA = polyA + condition3 + "," if polyAs3.include?(old_polyA)
    polyA.chomp!(",")
    polyAs << polyA
  end
  return polyAs
end

##################################################################################################################################

#This function retrieves the id (in this case, gene id) from given GFF line

def obtain_id(polyA)
    polyA = polyA.split("\t")
    id = polyA[8].match(/gene=(.+);/)[1]
    return (id)
end

##################################################################################################################################

#This function creates a biosequence object from a given id
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