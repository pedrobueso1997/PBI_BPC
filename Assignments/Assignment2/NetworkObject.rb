
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Network

#A network object has the following properties:
#network_id
#network_graph
#network_components
#network_relations
#network_kegg_features
#network_go_features

#The Network class has the following methods:
#.count: it returns the number of network objects
#.get_all: it returns all the network objects
#.show_all: it returns the inspection of all the network objects
#.get_network(network_id): it returns the network object with a given network_id
#.load_networks: it loads network objects from an array of interaction objects and group objects

#A network object has the following methods:
#.initialize: it assigns the properties and stores the network object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property
#.annotate: it includes information on the pathways and biological processes in which the network participates

###############################################################################################################

#CLASS

###############################################################################################################

class Network
  
  attr_accessor :network_id
  attr_accessor :network_graph
  attr_accessor :network_components
  attr_accessor :network_relations
  attr_accessor :network_kegg_features
  attr_accessor :network_go_features
  @@objects = []

  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing network objects
  #It assigns the properties network_id, network_graph, network_components, network_relations, network_kegg_features and network_go_features
  #It stores the network object in an array
  
  def initialize (parameters={})
    @network_id = parameters.fetch(:network_id, "XXXXXX")
    @network_graph = parameters.fetch(:network_graph, "XXXXXX")
    @network_components = parameters.fetch(:network_components, "XXXXXX")
    @network_relations = parameters.fetch(:network_relations, "XXXXXX")
    @network_kegg_features = parameters.fetch(:network_kegg_features, "XXXXXX")
    @network_go_features = parameters.fetch(:network_go_features, "XXXXXX")
    @@objects << self
  end

  #This is a method that includes information on the pathways and biological processes in which the network participates
  #It basically searches for this information in its components and joins it together
  
  def annotate
    kegg_features = []
    go_features = []
    for component in self.network_components
      kegg_features << Gene.get_gene(component).kegg_annotations if Gene.get_gene(component).kegg_annotations != "XXXXXX"
      go_features << Gene.get_gene(component).go_annotations if Gene.get_gene(component).go_annotations != "XXXXXX"
    end
    self.network_kegg_features = kegg_features
    self.network_go_features = go_features
  end
    
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that returns the number of network objects
  
  def Network.count
    puts @@objects.length
    return @@objects.length
  end
  
  #This is a method that returns all the network objects
  
  def Network.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all the network objects
  
  def Network.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end

  #This is a method that returns the network object with a given network_id
  #If no network has the network_id, it returns false

  def Network.get_network(network_id)
    for object in @@objects
      if object.network_id == network_id
        return object
      end
    end
    return false
  end
  
  #This is a method that loads network objects from an array of interaction objects and group objects
  #It iterates over the groups and selects only the interactions that involve the components of each group
  #It initialises a network object and annotates a network object
  
  def Network.load_networks
    @@objects = []
    network_number = 0
    for group in Group.get_all
      network_number += 1
      network_nodes = []
      network_relations = []
      for interaction in Interaction.get_all
        pair_interaction = [interaction.gene_id_1, interaction.gene_id_2]
        if group.group_components.include?(pair_interaction[0]) or group.group_components.include?(pair_interaction[1])
          network_nodes << pair_interaction[0]
          network_nodes << pair_interaction[1]
          network_relations << pair_interaction
        end
      end
      network_graph = RGL::AdjacencyGraph.new
      i = 0; network_graph.add_edge network_nodes[i],network_nodes[i+1] and i += 2 while i < network_nodes.length
      Network.new(:network_id => network_number, :network_graph => network_graph, :network_components => group.group_components, :network_relations => network_relations)
      Network.get_network(network_number).annotate if Network.get_network(network_number)
    end
  end
  
end
