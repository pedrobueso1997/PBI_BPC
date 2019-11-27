# ASSIGNMENT 3

In order to run this program, write one of these commands in the Linux shell (both files must be available in the same folder):

*$ ruby target_sequence_searcher_remote.rb ArabidopsisSubNetwork_GeneList.txt*

*$ ruby target_sequence_searcher_local.rb ArabidopsisSubNetwork_GeneList.txt*

## ArabidopsisSubNetwork_GeneList.txt

This file contains a list of genes from Arabidopsis thaliana, each of them in one row.

## target_sequence_searcher_remote/local.rb

Both this file perform the same exact function. They look for the presence of a specific sequence in a list of Arabidopsis thaliana genes. They differ in the way they retrieve the information (see steps) and on their speed (the local solution is faster though it might entail problems with storage).

### Steps 

**target_sequence_searcher_remote.rb**
    
1.  It iterates over each gene in the list.
2.  It retrieves the ensembl genome file and converts it into a biosequence.

**target_sequence_searcher_local.rb**

1.  It retrieves the ensembl genome file for all the genes in the list and brings it to local.
2.  It iterates over each entry in the file and converts it to biosequence.

**target_sequence_searcher_remote.rb and target_sequence_searcher_local.rb**
    
3.  It retrieves the exon positions (where targets are valid) and stores the exons belonging to overlapping genes.
4.  It searches for the target using regular expressions on the sequence.
5.  It adds the new features found to the biosequence.
6.  It adds the updated biosequence to an array of biosequences.
7.  The same process is repeated for the overlapping genes, but the search is restricted to the overlapping exons.
8.  It creates the GFF3 files, both for genes and chromosomes, and the gene file with no targets

### Results

The results obtained when running this program include:

- contig.gff3: a GFF3 file with "targeting vector" features characterised, considering gene coordinates.
- chromosome.gff3: a GFF3 file with "targeting vector" features characterised, considering chromosome coordinates. 
- no_target.txt: a list with the initial genes that did not have the target sequence.

### Gems required

It uses these gems (you might need to install them):

**rest-client**

**bio**

### Files required

It uses the following files (they need to be in the same folder):

**functions.rb**

This file contains the functions which are used in the main programm.
