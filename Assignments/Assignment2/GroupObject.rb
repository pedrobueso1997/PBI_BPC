
###############################################################################################################

#BRIEF EXPLANATION

###############################################################################################################

#This file defines the class Group

#A group object has the following properties:
#group_id
#group_components

#The Group class has the following methods:
#.count: it returns the number of group objects
#.get_all: it returns all the group objects
#.show_all: it returns the inspection of all the group objects
#.load_groups(consider_only_list): it loads group objects from an array of interaction objects

#A group object has the following methods:
#.initialize: it assigns the properties and stores the group object
#.property: it returns the value for a property
#.property=(value): it assigns the value for a property

###############################################################################################################

#CLASS

###############################################################################################################

class Group
  
  attr_accessor :group_id
  attr_accessor :group_components
  @@objects = []

  ###############################################################################################################
  
  #OBJECT METHODS
  
  ###############################################################################################################

  #This is a method for initializing group objects
  #It assigns the properties group_id and group_components
  #It stores the group object in an array
  
  def initialize (parameters={})   
    @group_id = parameters.fetch(:group_id, "XXXXXX")
    @group_components = parameters.fetch(:group_components, "XXXXXX")
    @@objects << self
  end
 
  ###############################################################################################################
  
  #CLASS METHODS
  
  ###############################################################################################################

  #This is a method that returns the number of network objects
  
  def Group.count
    puts @@objects.length
    return @@objects.length
  end
  
  #This is a method that returns all the network objects
  
  def Group.get_all
    return @@objects
  end
  
  #This is a method that returns the inspection of all the network objects
  
  def Group.show_all
    puts @@objects.inspect
    return @@objects.inspect
  end
 
  #This is a method that loads group objects from an array of interaction objects

  def Group.load_groups(consider_only_list)
    
    @@objects = []  
    group_number = 0
    Group.new(:group_id => group_number, :group_components => ["NULL"])
    
    #It obtains non-redundant groups by considering all the pairs of interactions stored as interaction objects
    #If there is already a group with one of the genes from the pair, it adds the other to the group object
    #If there is no group with one of the genes from the pair, it adds the pair to a newly created group object
    
    for interaction in Interaction.get_all      
      pair_interaction = [interaction.gene_id_1, interaction.gene_id_2]
      included = false
      for object in @@objects
        if object.group_components.include?(pair_interaction[0]) or object.group_components.include?(pair_interaction[1])
          object.group_components |= [pair_interaction[0]]
          object.group_components |= [pair_interaction[1]]
          included = true
        end
      end
      if included == false
        group_number += 1
        Group.new(:group_id => group_number, :group_components => [pair_interaction[0], pair_interaction[1]])
      end  
    end
    
    #It merges groups with common values (the intersection between them is not the empty array)
    #If two group objects have common values, one gets all elements while the other takes "NULL" value
    #I feel like this functionality is important because we would be having different groups that are not really different. However, it modifies the meaning of iteration
    #For example, if we did one iteration, one could think that we are only looking for direct interactors of our original genes. However, merging different groups results in non-direct interactions appearing
    #This is why we should see the iterations, not as a measure of our networks depth, but as the number of times we do consecutive searches
    
    for object in @@objects
      for object_compared in @@objects
        if object != object_compared
          if object.group_components & object_compared.group_components != []
            (object.group_components << object_compared.group_components).flatten!.uniq!
            object_compared.group_components = ["NULL"]
          end
        end
      end
    end
    
    #It deletes those groups objects with "NULL" value
    #If consider_only_list = true, it keeps only the groups with at least two components from the list

    @@objects.reject! {|obj| obj.group_components == ["NULL"]}  
    @@objects.reject! {|obj| (obj.group_components & $genes).length < 2 } if consider_only_list == true
  end

end