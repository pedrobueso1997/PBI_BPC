# ASSIGNMENT 3

In order to run this program, write the following command in the Linux shell (both files must be available in the same folder):

*$ ruby target_sequence_searcher.rb ArabidopsisSubNetwork_GeneList.txt*

## ArabidopsisSubNetwork_GeneList.txt

This file contains a list of genes from Arabidopsis thaliana, each of them in one row.

## target_sequence_searcher.rb

This file looks for the presence of a specific sequence in a series of Arabidopsis thaliana genes

### Steps

1.  It creates a local file with ensemble information on the original list of genes.
2.  It creates biosequence objects from each of the file entries, adds "targeting vector" features and puts them in a gff3 format.
3.  It iterates this same process for the remote genes that appeared when searching the previous ones. 

### Results

The results obtained when running this program include:

- contig.gff3: a GFF3 file with the "targeting vector" features characterised, taking into consideration the contig coordinates.
- chromosome.gff3: a GFF3 file with the "targeting vector" features characterised, taking into consideration the chromosome coordinates. 
- no_target.txt: a list with the initial genes that did not have the target sequence.

### Gems required

It uses these gems (you might need to install them):

**rest-client**

**bio**

### Files required

It uses the following files (they need to be in the same folder):

**additional_functions.rb**

This file contains many functions which are used in the main programm (for connecting to web addresses safely, for creating and analysing the local file, for creating the output files...).
