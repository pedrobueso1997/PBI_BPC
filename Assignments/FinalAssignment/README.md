# FINAL ASSIGNMENT

This assignment involves the creation of a webpage with bioinformatic purposes. I received 4 GFF files with the poly-A tail of thousands of transcript from Magnaporthe oryzae under various conditions. Since it is a bit tedius to retrieve information from these files, the website makes things much easier. Just write the gene id you are interested in and the webpage will show the polyA sites it contains and under which conditions they appear. It also includes some information on the gene, which might be of interest

The files included are the following:

- **database_creator.rb**: ruby script for creating the RDF document with all the required information.
- **functions.rb**: ruby script with some functions necessary for database_creator.rb.
- **classes.rb**: ruby script with the gene class whose structure and methods are necessary for database_creator.rb.
- **database.nt**: RDF file containing all the information necessary.
- **small_database.nt**: same as database.nt but smaller (just 100 polyA entries are considered).
- **polyA_searcher**: ruby cgi script that generates the webpage frontpage.
- **database explorer.rb**: ruby cgi script that does SPARQL queries on the database and generates the webpage results.

For the webpage to work, the last files (database.nt/small_database.nt, polyA_searcher, database_explorer.rb) need to be in the same folder. Their relations are relative, so they can be executed as long as they are together and inside html. By default, the program uses the small database, which only includes 100 entries and so it is faster. If you want to use it with the whole database you would have to uncomment the corresponding line in "database_explorer.rb". However, the file is so large that the search takes a insane time to work. The other 3 files (database_creator.rb, functions, classes) are actually not necessary once the RDF is created. They just come to show how the RDF was created.
