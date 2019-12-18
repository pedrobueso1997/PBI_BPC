# ASSIGNMENT 5

This assignment consists on building SPARQL queries to retrieve data from some biological databases.

### PREFIXES

    PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#> 
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    PREFIX skos:<http://www.w3.org/2004/02/skos/core#> 
    PREFIX up:<http://purl.uniprot.org/core/>
    PREFIX uniprotkb:<http://purl.uniprot.org/uniprot/>
    PREFIX taxon:<http://purl.uniprot.org/taxonomy/>
    PREFIX atlasterms: <http://rdf.ebi.ac.uk/terms/expressionatlas/>
    PREFIX biopax3: <http://www.biopax.org/release/biopax-level3.owl#>
    
### UNIPROT QUERIES

**Number of protein records in UniProt?**

The SPARQL query is:

    SELECT (COUNT (DISTINCT ?protein) AS ?num_proteins)
    WHERE
    {
      ?protein rdf:type up:Protein .
    }

The result is: *"281303435"^^xsd:int*

**Number of Arabidopsis thaliana protein records in UniProt?**

The SPARQL query is:

    SELECT (COUNT (DISTINCT ?protein) AS ?num_proteins)
    WHERE 
    {
      ?protein rdf:type up:Protein .
      ?protein up:organism ?protein_organism .
      ?protein_organism up:scientificName "Arabidopsis thaliana" .
    }

The result is: *"89182"^^xsd:int*

**Description of the enzyme activity of UniProt Protein Q9SZZ8?**

The SPARQL query is:

    SELECT ?enzyme_activity_description
    WHERE
    {
      uniprotkb:Q9SZZ8 up:enzyme ?enzyme .
      ?enzyme up:activity ?enzyme_activity . 
      ?enzyme_activity rdfs:label ?enzyme_activity_description .
    }
    
The result is: *"Beta-carotene + 4 reduced ferredoxin [iron-sulfur] cluster + 2 H(+) + 2 O(2) = zeaxanthin + 4 oxidized ferredoxin [iron-sulfur] cluster + 2 H(2)O"^^xsd:string*

**Proteins id and date of submission for proteins that have been added to UniProt this year**

The SPARQL  query is:

    SELECT DISTINCT ?protein_id ?protein_date
    WHERE
    {
      ?protein rdf:type up:Protein .
      ?protein up:mnemonic ?protein_id .
      ?protein up:created ?protein_date .
      FILTER (?protein_date > "2019-01-01"^^xsd:dateTime) .
    }

The result is (one example out of 58202805): *"PLH20_FORAG"^^xsd:string	"2019-10-16"^^xsd:date*

**Number of species in the UniProt taxonomy**

The SPARQL query is:

    SELECT (COUNT (DISTINCT ?organism) AS ?num_organisms)
    WHERE
    {
        ?organism rdf:type up:Taxon .
        ?organism up:rank up:Species 
    }

The result is: *"1766921"^^xsd:int*

**Number of species in the UniProt taxonomy with at least one protein record**

The SPARQL query is:

    SELECT (COUNT (DISTINCT ?protein_organism) AS ?num_protein_organisms)
    WHERE
    {
        ?protein rdf:type up:Protein .
        ?protein up:organism ?protein_organism .
        ?protein_organism up:rank up:Species .
    }
       
The result is: *"984622"^^xsd:int*

**Gene codes and gene names for all Arabidopsis thaliana proteins that have a function annotation description that mentions “pattern formation”**

The SPARQL query is: 

    SELECT DISTINCT ?gene_code ?gene_name
    WHERE
    {
      ?protein rdf:type up:Protein .
      
      ?protein up:organism ?protein_organism .
      ?protein_organism up:scientificName "Arabidopsis thaliana" .
      
      ?protein up:annotation ?protein_annotation .
      ?protein_annotation rdf:type up:Function_Annotation .
      ?protein_annotation rdfs:comment ?protein_annotation_description .
      FILTER CONTAINS (?protein_annotation_description, "pattern formation") .
      
      ?protein up:encodedBy ?gene .
      ?gene up:locusName ?gene_code.
      ?gene skos:prefLabel ?gene_name .
    }

The result is (one example out of 15): *"At1g63700"^^xsd:string	"YDA"^^xsd:string*

### ATLAS GENE EXPRESSION QUERIES

**Experimental description for all experiments where Arabidopsis Apetala3 gene is DOWN regulated**

The SPARQL query is:

    SELECT DISTINCT ?gene_experiment_description
    WHERE
    {
      ?gene rdfs:label "AP3" .
      ?gene_experiment atlasterms:refersTo ?gene .
      ?gene_experiment rdfs:label ?gene_experiment_description .
      ?gene_experiment rdf:type atlasterms:DecreasedDifferentialExpressionRatio .
    }

The result is (one example out of 15): *"AP3 DOWN in 'RRM variant' vs 'wild type genotype' in '18 day'"^^xsd:string*

### REACTOME

**Number of Reactome pathways assigned to Arabidopsis thaliana?**

The SPARQL query is:

    SELECT (COUNT (DISTINCT ?pathway) AS ?number_pathways)
    WHERE 
    {
      ?pathway rdf:type biopax3:Pathway .
      ?pathway biopax3:organism ?pathway_organism .
      ?pathway_organism rdfs:label "Arabidopsis thaliana (Identifiers.org)" .
    }

The result is: *"809"^^xsd:int*

**PubMed references for the pathways with the name “Degradation of the extracellular matrix”**

The SPARQL query is:

    SELECT DISTINCT ?pathway_reference
    WHERE 
    {
      ?pathway rdf:type biopax3:Pathway .
      ?pathway biopax3:displayName "Degradation of the extracellular matrix"^^xsd:string .
      ?pathway biopax3:xref ?pathway_reference .
      ?pathway_reference biopax3:db "Pubmed"^^xsd:string .
    }

The result is (one example out of 7): *http://identifiers.org/pubmed/21087458*

**Proof that all Arabidopsis pathway annotations in Reactome are "inferred from electronic annotation"**

The SPARQL query is:

    SELECT (COUNT (?pathway) AS ?number_pathways) (COUNT(?pathway_description) AS ?number_pathway_descriptions)
    WHERE 
    {
      ?pathway rdf:type biopax3:Pathway .
      
      ?pathway biopax3:organism ?pathway_organism .
      ?pathway_organism rdfs:label "Arabidopsis thaliana (Identifiers.org)" .
      ?pathway biopax3:comment ?pathway_description .
      FILTER CONTAINS (?pathway_description, "electronic_inference") .
    }
    
The result is: *"809"^^xsd:integer   "809"^^xsd:integer*

This means that all pathways in Arabidopsis have the label "electronic_inference"  
