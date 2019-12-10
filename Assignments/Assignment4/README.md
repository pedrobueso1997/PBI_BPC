# ASSIGNMENT 4

In order to run this program, write this command in the Linux shell (both files must be available in the same folder):

*$ ruby orthologs_searcher.rb proteome1.fa proteome2.fa*

## proteome1.fa and proteome2.fa

These are multifasta files. They can contain either DNA or protein sequences.

## br_hit.rb

This file searches for orthologs between two given proteomes, using Best Reciprocal Hits (BRHs) approach.

### Steps 

1.  It retrieves the number of sequences per proteome and creates two files (short_proteome.fa, long_proteome.fa).
2.  It determines the type of molecule (DNA or protein) and the type of blast (blast, blastp, blastx, tblastn) for each file.
3.  It creates the index files necessary to do blast.
4.  It blasts the short proteome on the long proteome (keeping only the best hit if the evalue is lower than 1e-6).
5.  It stores the pairs query - best hit in a dictionary.
6.  It filters, from the file long.fa, those sequences that were best hits in the blast analysis.
7.  It blasts the long proteome on the short proteome (keeping only the best hit if the evalue is lower than 1e-6).
8.  It stores the pairs query - best hit in a dictionary.
7.  It finds the orthologs (sequences that are the best hit of their best hit).

### Results

The results obtained when running this program include:

- orthologs.txt: a file with the pairs of orthologs from both proteomes.
- proteome1.fa.blast_report.txt: a file with the blast results of proteome1.fa. 
- proteome2.fa.blast_report.txt: a file with the blast results of proteome2.fa. 

### Gems required

It uses these gems (you might need to install them):

**stringio**

**bio**

### Beyond the code

**How does my code approaches the search of BRHs?**

BRHs are found when the proteins enconded by two genes, each on a different genome, find each other as the best scoring match in the other genome. In my code, that best scoring match is obtained through the parameters "-max_target_seqs 1 -max_hsps 1", which results in the report showing only one hit per query sequence. Although this is not explicit in my code, the hit selection is done in terms of e-value. 

The e-value or expect value is a parameter that describes the number of hits one can expect to see by chance when searching a database of a particular size. For instance, an e-value of 1 can be interpreted in the following way: "in a database of the current size, it is expected to see 1 match with a similar score simply by chance". The lower the e-value, the more significant the match is; it can, therefore, be used as a threshold for reporting results. One thing to take into account is that the calculation of the e-value does not only considers the score of the alignment but also the length of the query sequences; this explains why virtually identical short alignments have high e-vales (shorter sequences have higher probability of ocurring in the database purely by chance).

You might have noticed my code also introduces a filter through the parameter "-evalue 1e-6". Although this is not considered in the strict definition of best reciprocal hits, not using such filter might lead to flawed detection of orthologs. It could happen that two proteins, which are actually not similar, found themselves as best hit. Tagging them as orthologs could then be erroneous. The threshold of 1e-6 has been purposed in previous experiments and I felt like it was reasonable. The most appropiate threshold, however, might depend on things like: species that are being compared, length of the proteomes...

Eventually, I would like to comment on how my program reduces computational power needed. This is achieved by blasting the shortest proteome always first and by blasting, from the longest proteome, only those sequences that were previous hits. In this specific case, following such strategy makes us blast less than 10.000 sequences instead of almost 40.000. In adittion, I chose to use the blast function that is called from the shell because it appears to work faster and the files produced have an easy-to-deal-with tabular format.

*The information was retrieved from the NCBI Blast webpage and the paper which I refer to is: "Moreno-Hagelsieb, G., & Latimer, K. (2007). Choosing BLAST options for better detection of orthologs as reciprocal best hits. Bioinformatics, 24(3), 319–324. doi:10.1093/bioinformatics/btm585"*

**How would I continue my analysis?**

Looking for BRHs is only the first step towards finding orthologs. It might be a good approximation for finding 1:1 relations, but it does not solve 1:many or many:many relations. In order to find them, we would have to build Clusters of Orthologous Groups (COGs). Both BRHs and COGs are methodologies based on sequence similarity, which is fine for identifying homologs but might not be the best solution for discerning between orthologs and paralogs.

Orthologs are homologs in different species that originated from an speciation event, paralogs are homologs that originated from a duplication event. Properly identifying both cases requires from having knowledge on the evolutionary history of the genes, which is why comparative genomics eventually relies on phylogenies. Therefore, my analysis should probably include a phylogenetic tree, which would make the identification of orthologs more consistant. There are several tools available for choosing the appropiate models and methodologies in such a task. Enventually, and as orthologs tend to conserve function (they do not always do), we could validate our results by doing some function comparison in the genes identified as orthologs.

