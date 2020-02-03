# ASSIGNMENT 1

In order to run this program, write the following command in the Linux shell (all the files except the last one must be available in the same folder)

*$ ruby process_database.rb  gene_information.tsv  seed_stock_data.tsv  cross_data.tsv  new_stock_file.tsv*

## process_database.rb

This file does two things:

1. It simulates planting 7 grams of seed from each of the records in seed_stock_data.tsv
2. It determines, with a Chi-square test, which genes from the ones in cross_data.tsv are genetically linked

It uses the following class files (they need to be in the same folder):

**GeneObject.rb**

This file defines the class Gene

A gene object has the following properties:

    gene_id
    gene_name
    mutant_phenotype
    linked_to

The Gene class has the following methods:

    #count: it returns the number of gene objects
    #get_all: it returns all the gene objects
    #show_all: it returns the inspection of all the gene objects
    #get_gene(gene_id): it returns the gene object with a specific gene_id
    #load_all(path_to_file): it loads all the gene objects from a tsv file containing them
    #write_all(path_to_file): it writes all the gene objects to a tsv file
    #append(object, path_to_file): it appends one gene object to a tsv file
    #show_linked_genes(): it shows which genes are linked
    
A gene object has the following methods:

    #initialize -called automatically from Gene.new-: it assigns the properties (checking that gene_id has the proper format), increases the number of gene objects and stores the gene object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property

**SeedstockObject.rb**

This file defines the class Seedstock

A seed stock object has the following properties:

    seed_stock_id
    gene
    last_planted
    storage
    grams_remaining

The Seedstock class has the following methods:

    #count: it returns the number of seed stock objects
    #get_all: it returns all the seed stock objects
    #show_all: it returns the inspection of all the seed stock objects
    #get_seed_stock(seed_stock_id): it returns the seed stock object with a specific seed_stock_id
    #load_all(path_to_file) -requires previously loading the gene objects-: it loads all the seed stock objects from a tsv file containing them
    #write_all(path_to_file): it writes all the seed stock objects to a tsv file
    #append(object, path_to_file): it appends one seed stock object to a tsv file
    #plant(quantity): simulates planting the same quantity -in grams- for all the seed stock objects

A seed stock object has the following methods:

    #initialize -called automatically from Seedstock.new-: it assigns the properties (checking that gene is a gene object, that last_planted is a date and that grams_remaining is an integer or float), increases the number of seed stock objects and stores the seed stock object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property

**CrossObject.rb**

This file defines the class Cross

A cross object has the following properties:

    parent1
    parent2
    f2_wild
    f2_parent1
    f2_parent2
    f2_parent1_parent2

The Cross class has the following methods:

    #count: it returns the number of cross objects
    #get_all: it returns all the cross objects
    #show_all: it returns the inspection of all the cross objects
    #get_cross(parent1, parent2): it returns the cross stock object with the specific parent1 and parent2
    #load_all(path_to_file) -requires previously loading the gene objects and the seed stock objects-: it loads all the cross objects from a tsv file containing them
    #write_all(path_to_file): it writes all the cross objects to a tsv file
    #append(object, path_to_file): it appends one cross object to a tsv file
    #obtain_linked_genes() does the chi-square test to the cross objects and determine whether the genes are linked

A cross object has the following methods:

    #initialize -called automatically from Cross.new-: it assigns the properties (checking that the parents are seed stock objecta and that f2 data are integers), increases the number of cross objects and stores the cross object
    #property: it returns the value for a property
    #property=(value): it assigns the value for a property

## gene_information.tsv

This file contains information about genes in the following format:

|Gene_ID|Gene_Name|Mutant_Phenotype|
|:------|:-------:|---------------:|


## seed_stock_data.tsv

This file contains information about seed stocks in the following format:

|Seed_Stock|Mutant_Gene_ID|Last_Planted|Storage|Grams_Remaining|
|:---------|:------------:|:----------:|:-----:|--------------:|

## cross_data.tsv

This file contains information about crosses between seed stocks in the following format:

|Parent1|Parent2|F2_Wild|F2_P1|F2_P2|F2_P1P2|
|:------|:-----:|:-----:|:---:|:---:|------:|

## new_stock_file.tsv

This is a newly generated file, with the same format as seed_stock_data.tsv but with modified content
