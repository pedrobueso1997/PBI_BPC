# ASSIGNMENT 2

In order to run this program, write the following command in the Linux shell (both files must be available in the same folder):

*$ ruby find_networks.rb ArabidopsisSubNetwork_GeneList.txt*

## ArabidopsisSubNetwork_GeneList.txt

This file contains a list of genes from Arabidopsis thaliana, each of them in one row.

## find_networks.rb

This file looks for interactions between genes and comes up with the networks that connect this genes.

### Steps

1.  It defines pair interactions between genes, which requires from an intensive use of EBI’s PSICQUIC (IntAct) REST API. To do so, it considers the *iterations* (how many times do we take our results as new samples for interaction searching), *maximum_interactions* (how many interactions we take into account for each gene) and *threshold* (what score is enough for taking the interaction into account).
2.  It defines and annotates those genes participating in interactions. When *annotate_only_list* is true, it limits the annotation to those genes from the list.
3.  It defines groups of genes that belong to the same network. When *consider_only_list* is true, it limits the output to those groups with at least two genes from the list.
4.  It defines networks of genes, which are the groups of genes and their interactions.
5.  It creates a report and represents the network graphs.

### Results

The results obtained when running this program include:

- A report with information of the networks (components and annotation). Whether all genes are shown or only the ones in the list do depends on *annotate_only_list* value.
- A graphical representation of all the components of the networks.

The results obtained for this program vary a lot depending on the parameters we consider, even for the same gene file. The effect that these parameters have are the following:

- The *iterations* make our network grow in size but decrease in number (as we consider further interactors, the genes tend to group in a unique network).
- The *maximum_interactions* make our network increase in size but decrease in number (as we consider more interactors, the genes tend to group in a unique network).
- The *threshold* makes our networks decrease in size (as we consider higher values, more interactions are filtered out).
- The *consider_only_list* set to true makes our networks decrease in number (only those networks with at least two elements from our list are considered).

### Take into consideration

These are a few things you need to consider when running these programm and playing with its parameters:

- The *maximum_interactions* should stay like it is because the algorithm is not designed for priorising between interactions (so filtering would be done under no criteria).
- If you try to reduce the *threshold* or increase the *iterations*, it would be recommended to comment the graph drawing command (in additional_functions.rb) as it could give problems with networks of that size.
- If you set *annotate_only_list* to false, be aware that this will result in annotating all the genes found, which increases enourmously time of computation.

### Gems required

It uses these gems (you might need to install them):

**rest-client**

**rgl/adjacency**

**rgl/dot**

### Files required

It uses the following class files (they need to be in the same folder):

**GeneObject.rb**

This file defines the class Gene.

A gene object has the following properties:

    gene_id
    go_annotations
    kegg_annotations

The Gene class has the following methods:

    .count: it returns the number of gene objects
    .get_all: it returns all the gene objects
    .show_all: it returns the inspection of all the gene objects
    .get_gene(gene_id): it returns the gene object with a specific gene_id
  
A gene object has the following methods:

    #initialize: it assigns the properties (checking that gene_id has the proper format) and stores the gene object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property
    #annotate: it includes information on the pathways and biological processes in which the gene participates

**InteractionObject.rb**

This file defines the class Interaction.

An interaction object has the following properties:

    gene_id_1
    gene_id_2
    score

The Interaction class has the following methods:

    .count: it returns the number of interaction objects
    .get_all: it returns all the interaction objects
    .show_all: it returns the inspection of all the interaction objects
    .load_interactions(iterations, max_interactions, threshold, annotate_only_list): it loads interaction objects from an array of genes

An interaction object has the following methods:

    #initialize: it assigns the properties and stores the interaction object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property

**GroupObject.rb**

This file defines the class Group.

A group object has the following properties:

    group_id
    group_components

The Group class has the following methods:

    .count: it returns the number of group objects
    .get_all: it returns all the group objects
    .show_all: it returns the inspection of all the group objects
    .load_groups(consider_only_list): it loads group objects from an array of interaction objects

A group object has the following methods:

    #initialize: it assigns the properties and stores the group object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property

**NetworkObject.rb**

This file defines the class Network.

A network object has the following properties:

    network_id
    networ_graph
    network_components
    network_relations
    network_kegg_features
    network_go_features

The Network class has the following methods:

    .count: it returns the number of network objects
    .get_all: it returns all the network objects
    .show_all: it returns the inspection of all the network objects
    .get_network(network_id): it returns the network object with a given network_id
    .load_networks: it loads network objects from an array of interaction objects and group objects

A network object has the following methods:

    #initialize: it assigns the properties and stores the network object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property
    #annotate: it includes information on the pathways and biological processes in which the network participates

**additional_functions.rb**

This file contains a function for connecting to web addresses safely and a function for creating a report.
