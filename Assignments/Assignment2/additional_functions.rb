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

#This function creates a report and saves it in a file

def write_report(file_name, annotate_only_list)
  system("rm *.jpg")
  File.open(file_name,"w"){|file| file.puts "\nFINAL REPORT\n\n"}
  for network in Network.get_all
    File.open(file_name,"a") {|file|
    file.puts "NETWORK" + network.network_id.to_s
    if annotate_only_list == true
      file.puts "\nThese are the network components that belong to your list\n\n"
      file.puts (network.network_components & $genes).inspect
      file.puts "\nThis is the information on the pathways for the genes that belong to your list\n\n"
      file.puts network.network_kegg_features.inspect
      file.puts "\nThis is the information on the biological processes for the genes that belong to your list\n\n"
      file.puts network.network_go_features.inspect
    else
      file.puts "\nThese are the network components\n\n"
      file.puts network.network_components.inspect
      file.puts "\nThis is the information on the pathways\n\n"
      file.puts network.network_kegg_features.inspect
      file.puts "\nThis is the information on the biological processes\n\n"
      file.puts network.network_go_features.inspect
    end
    file.puts "\n"}
    #Comment the following two lines if the drawing is giving you problems (it might happen when the number of genes in a network is too big)
    network.network_graph.write_to_graphic_file("jpg", "Network" + network.network_id.to_s)
    system("rm Network#{network.network_id}.dot")
  end
end