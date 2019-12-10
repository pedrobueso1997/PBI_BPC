# ASSIGNMENT 4

In order to run this program, write one of these commands in the Linux shell (both files must be available in the same folder):

*$ ruby br_hit.rb proteome1.fa proteome2.fa*

## proteome1.fa and proteome2.fa

These are multifasta files. They can contain either DNA or protein sequences.

## br_hit.rb

This file searches for orthologs between two given proteomes

### Steps 

1.  It retrieves the number of sequences per proteome and create two files (short_proteome.fa, long_proteome.fa).
2.  It determines the type of molecule (DNA or protein) and the type of blast (blast, blastp, blastx, tblastn) for each file.
3.  It creates the index files necessary to do blast.
4.  It blasts the short proteome on the long proteome (keeping only the best alignment if the evalue is lower than 1e-6).
5.  It stores the pairs query - best hit in a dictionary.
6.  It filters, from the file long.fa, those sequences that were hits in the blast analysis
7.  It blasts the long proteome on the short proteome (keeping only the best alignment if the evalue is lower than 1e-6).
8.  It stores the pairs query - best hit in a dictionary.
7.  It finds the orthologs (sequences that are the best hit of their best hit)

### Results

The results obtained when running this program include:

- orthologs.txt: a file with the pairs of orthologs from both proteomes.
- proteome1.fa.blast_report.txt: a file with the blast results on the proteome1.fa file. 
- proteome2.fa.blast_report.txt: a file with the blast results on the proteome2.fa file. 

### Gems required

It uses these gems (you might need to install them):

**stringio**

**bio**
