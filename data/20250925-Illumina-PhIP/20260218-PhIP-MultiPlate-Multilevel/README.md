
#	20250925-Illumina-PhIP/20260218-PhIP-MultiPlate-Multilevel

Previous chat with Claude https://claude.ai/chat/5660c263-672b-4a27-bd10-39324110295c

Sample manifest
```bash
cp ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv ./
```

Get the raw counts matrix by peptide and sample id
```bash
f=../20250414-PhIP-MultiPlate/out.123456131415161718/Counts.csv
( head -1 ${f} && ( tail -n +10 ${f} | sort -t, -k1,1 ) ) | cut -d, -f1,3- > Counts.csv
gzip Counts.csv
```

Get the previous generated Z-scores with just peptide and sample id.

Does not include the blanks.

Does not include the 4 samples (2 subjects) that are on the secondary plate.
```bash
f=../20250414-PhIP-MultiPlate/out.123456131415161718/Zscores.t.csv 
( ( head -3 ${f} | tail -n 1 ) && ( tail -n +4 ${f} | sort -t, -k1,1 ) ) | cut -d, -f1,3- > Zscores.csv
gzip Zscores.csv
```

Generate a new simple Z-score matrix by peptide and sample id? 



Do not merge samples by subject. Do not call hits.



Can I somehow include the z-score bin by plate?



Prep VIR3 taxonomy tree reference 
```bash
ln -s /francislab/data1/refs/PhIP-Seq/VirScan-20260202/vir3_taxonomic_annotation_database_complete.csv
```



Do some differential analysis with varying z-score thresholds





PhIPseq

1. Phage Library (The "Baseline" or "Control")
  * Definition: This represents the library before any immunoprecipitation (IP) takes place. It is a direct sample of the raw phage library containing all synthesized peptides.
  * Purpose: It acts as the baseline measurement, telling you the relative abundance of every peptide in the original mix. It allows the computational analysis to account for uneven representation of peptides in the library, as some phages may replicate faster or have more efficient ligation than others.
  * What it reveals: Which peptides were present to begin with. 
2. Input Sample (The "Baseline Control")
  * Definition: This is sometimes used interchangeably with "Library Control" or refers to the "mock" IP control where the library is incubated with beads in the absence of antibody-containing serum (e.g., in PBS buffer).
  * Purpose: It measures the "background binding"—the amount of phage that sticks to the magnetic beads or walls of the tube non-specifically without antibody interaction.
  * What it reveals: The background signal level. 
3. Experimental Sample (The "Pull-down")
  * Definition: This is the sample that has gone through the full PhIP-Seq protocol: phage library incubated with the antibody-containing serum (e.g., patient serum, animal serum), followed by antibody-protein A/G bead immunoprecipitation.
  * Purpose: To capture the specific phages that have bound to the antibodies present in the sample.
  * What it reveals: The "hits" or peptides that are specifically enriched, indicating antibody reactivity. 


* Counts.csv.gz
  * Raw peptide aligment counts by sample, if needed




Edison Analysis Prompt:

We are doing a PhIPseq analysis covering multiple subject types, studies and groups and across multiple sequencing plates.  Each subject has 2 replicate samples, usually on the same plate.  Each sample was sequenced and aligned to the VIR3 VirScan reference with bowtie2 and only those alignments with a mapping quality of 40 or greater were kept. Each plate contained a number of input / blank / no serum samples. The counts of these input samples were used to bin the experimental data into bins containing about 300 peptides and then they were scaled creating z-scores.

In addition, each plate contained Phage Library samples containing just the raw phage library. Each plate also contain the same "commercial serum sample". Both of these could possibly be useful correcting or adjusting for plate effects.

I have attached 3 files:
* manifest.csv containing the following fields for each sample
  * sample
  * subject
  * type
  * study
  * group
  * age
  * sex
  * plate
* vir3_taxonomic_annotation_database_complete.csv.gz containing the following fields for each peptide
  * id
  * entry
  * original_species
  * original_organism
  * original_protein
  * oligo
  * peptide
  * start
  * end
  * alternate_uniprot_accession
  * uniparc_accession
  * uniprot_entry_name
  * refseq_protein
  * genbank_protein
  * gene_name
  * protein_name
  * ncbi_taxid
  * organism
  * species
  * genus
  * subfamily
  * family
  * order
  * class
  * phylum
  * kingdom
  * realm
* Zscores.csv.gz
  * Peptide z-scores by sample

I also have the raw counts should the z-score data be inadequate.

While it’s nice to be able to predict known virus seropositivity, there are already methods for this, and our overarching mission is to detect specific (single peptide/tile/antigen) and systematic (global shifts, pathway/virus-level patterns, communities/modules) seroreactivity differences between two groups of subjects. 

I need you to perform a number of differential analysis between the following subsets and subgroups of subjects.

Compare the 
* glioma serum
  * IPS cases to AGS controls
* glioma serum
  * PLCO cases to PLCO controls
* ALL maternal serum
  * cases to controls
* meningioma serum
  * Hypermitotic to Immune-enriched
  * Hypermitotic to Merlin-intact
  * Immune-enriched to Merlin-intact
* pemphigus serum
  * PF Patient to Endemic Control
  * PF Patient to Non Endemic Control
  * PF Patient to both Endemic Control and Non Endemic Control

In each subset analysis, use a variety of z-score thresholds when calling a sample / peptide reactive. Start with 3.5, 10, and 20. Evaluate the subset of data to assist in determining appropriate thresholds. Adjust as necessary. Drop any peptides that are reactive in more than 95% or less than 5% of samples. Adjust those thresholds as well if necessary. Be sure to adjust for sex, age and plate. Perform the differential analysis by individual peptide and then progress up the taxonomic levels combining the peptide reactivity in an appropriate fashion and perform differential analyses at each of the the peptide's species, genus, subfamily, family and order. 

I'm not sure when it is best to combine the sample replicates. Make an appropriate decision. Our subsets are rather small.

I am asking a lot. 9 pairs of case / controls. At least 3 z-score thresholds. 6 levels of taxonomy.

Evaluate the situation as a whole. Make a plan. Justify your decisions. Prepare to make a bunch of approprate publishable plots. Execute.







