



```
rsync -avz --progress rsync://ftp.ncbi.nih.gov/refseq/release/viral/ viral-20220923/

gunzip viral.1.protein.faa.gz
```

replace spaces, /, [, ]
```
vi viral.1.protein.faa
```


```
faSplit byname viral.1.protein.faa viral.1.protein/

mkdir viral.1.protein.Human_gammaherpesvirus_4

cat viral.1.protein/*Human_gammaherpesvirus_4* > viral.1.protein.Human_gammaherpesvirus_4/viral.1.protein.Human_gammaherpesvirus_4.fa


cd  viral.1.protein.Human_gammaherpesvirus_4

cp /francislab/data1/refs/fasta/viruses/herpes/NC_007605.1.fasta ./

makeblastdb -dbtype nucl -out NC_007605 -title NC_007605 -parse_seqids -in NC_007605.1.fasta 

tblastn -db NC_007605 -query viral.1.protein.Human_gammaherpesvirus_4.fa -outfmt 6 > viral.1.protein.Human_gammaherpesvirus_4-NC_007605.tsv
```



All sequences matched somewhere

```
grep -c "^>" viral.1.protein.Human_gammaherpesvirus_4.fa
94

cat viral.1.protein.Human_gammaherpesvirus_4-NC_007605.tsv | awk '{print $1}' | uniq | wc -l
94
```


```
'qaccver                                             saccver   pident length mismatch gapopen qstart qend sstart  send evalue bitscore'
YP_401714.1_protein_A73_Human_gammaherpesvirus_4	NC_007605.1	100.000	   28	    0	       0	    99	  126	159779 159862	0.10	  25.0

pident = 100
qstart = 1
qend = length
```


Not all aligned as perfectly expected?
```
cat viral.1.protein.Human_gammaherpesvirus_4-NC_007605.tsv | awk -F"\t" '( ($3>=100) && ($7==1) && ($8==$4) )' | awk '{print $1}' | uniq | wc -l
83
```


Several aligned perfectly several places
```
cat viral.1.protein.Human_gammaherpesvirus_4-NC_007605.tsv | awk -F"\t" '( ($3>=100) && ($7==1) && ($8==$4) )' | wc -l
140

cat viral.1.protein.Human_gammaherpesvirus_4-NC_007605.tsv | awk -F"\t" '( ($3>=100) && ($7==1) && ($8==$4) )' | uniq | wc -l
140
```

Several split gapped alignments?


YP_401636.1_nuclear_antigen_EBNA-LP_Human_gammaherpesvirus_4
YP_401652.1_large_tegument_protein_Human_gammaherpesvirus_4 - partial - confused
YP_401653.1_tegument_protein_UL37_Human_gammaherpesvirus_4
YP_401659.1_multifunctional_expression_regulator_Human_gammaherpesvirus_4
YP_401670.1_nuclear_antigen_EBNA-3B_Human_gammaherpesvirus_4
YP_401671.1_nuclear_antigen_EBNA-3C_Human_gammaherpesvirus_4
YP_401673.1_protein_Zta_Human_gammaherpesvirus_4
YP_401677.1_nuclear_antigen_EBNA-1_Human_gammaherpesvirus_4
others ...














##	PhIP-Seq Characterization of Serum Antibodies Using Oligonucleotide Encoded Peptidomes


###	Not using conda

python3 -m pip install --upgrade --user numpy scipy biopython==1.69 click tqdm pepsyn phip-stat


###	cd-hit

Info they provided is bad.

http://weizhong-cluster.ucsd.edu/cd-hit/
https://github.com/weizhongli/cdhit/releases

wget https://github.com/weizhongli/cdhit/releases/download/V4.8.1/cd-hit-v4.8.1-2019-0228.tar.gz


###	Input data

This protocol assumes the existence of a text file called input_orfs.fasta that contains the full protein library sequences in fasta format. We recommend the sequence identifiers for each protein sequence should be a simple, unique name, ideally without spaces or other punctuation other than underscores, periods, or dashes. Most tools in the pepsyn package accept "-" as the input and output files, which will read/write fasta data from stdin and stdout. This facilitates the modular integration of various tools into processing pipelines using the Unix pipe functionality. The protocol below is just one possible example that illustrates this principle, and the separate processing parts can be easily be swapped or varied. The computations are generally fast, allowing rapid iteration on designs. The commands below are executed in a bash shell.


###	Their instructions


Synthetic Peptidome Library Design. Timing: 1 day

1 Generate two sets of peptide sequences: one set that tiles across the whole protein and a separate set that is comprised of the C-terminal peptides, using the following commands in the pepsyn software package.

TILESIZE=56
OVERLAP=28

cat input_orfs.fasta \
| pepsyn x2ggsg - - \
| pepsyn tile -l $TILESIZE -p $OVERLAP - - \
| pepsyn disambiguateaa - - \
> orf_tiles.fasta

cat input_orfs.fasta \
| pepsyn x2ggsg - - \
| pepsyn ctermpep -l $TILESIZE --add-stop - - \
| pepsyn disambiguateaa - - \
> cterm_tiles.fasta

Note how the commands are stitched together into a pipeline, each one reading fasta data and writing fasta data, allowing for flexible and modular pipelines during the design phase. The first command (pepsyn x2ggsg) eliminates stretches of Xs by replacing them with glycine-serine linker sequence. The next command (either pepsyn tile or pepsyn ctermpep) chops up each ORF into short tiles with specified length. The tile version generates overlapping sequences, while ctermpep only takes the last amino acids of the sequences (i.e., "Cterminal peptide"). Finally, disambiguateaa removes ambiguous IUPAC amino acid codes (e.g., B for aspartic acid or asparagine) by generating all possible peptides. The peptides are written into orf_tiles.fasta and cterm_tiles.fasta. Note that we have elected to add amber stop codons to the C-terminal peptides to allow flexibility in whether native stop codons are incorporated into the peptide or not.

CRITICAL STEP: You can find usage notes by adding -h to any command (e.g., pepsyn -h or pepsyn tile -h). There are numerous additional tools that perform helpful operations in peptide design (e.g., pepsyn clip for trimming sequences, pepsyn builddbg for building a De Bruijn graph on k-mers).

2 The resulting files may contain peptides that are identical or highly similar to each other. Eliminate some of this redundancy using the cd-hit tool, similar to what is done in the UniProt database, using the following commands:

./cd-hit-v4.8.1-2019-0228/cd-hit -i orf_tiles.fasta -o orf_tiles_clustered.fasta -c 0.95 -G 0 -A 50 -M 0 -T 1 -d 0

./cd-hit-v4.8.1-2019-0228/cd-hit -i cterm_tiles.fasta -o cterm_tiles_clustered.fasta -c 0.95 -G 0 -aL 1.0 -aS 1.0 -M 0 -T 1 -d 0

In this particular case, we are clustering the peptide tiles to 95% (-c 0.95) local identity (-G 0) while controlling the alignment coverage (-A 50 requires the alignment to cover at least 50 amino acids). The C-terminal peptides are aligned more stringently to ensure that the final residues of the ORF are not lost (-aL 1.0 –aS 1.0 requires 100% of each sequence to be aligned with possible mismatches). Specifying –M 0 allows unlimited memory, -T 1 specifies one CPU thread, and –d 0 ensures sequence names are not truncated. See cd-hit documentation for more options (cd-hit.org). The clustered peptides are written to orf_tiles_clustered.fasta and cterm_tiles_clustered.fasta

3 The rest of the peptide processing is the same for the C-terminal and tiled peptides. Use the following commands to first concatenate the files (cat).  Because the results of the last step could generate some peptide sequences shorter than 56 amino acids, also pad the peptides to make them uniform length (pad).

cat orf_tiles_clustered.fasta cterm_tiles_clustered.fasta \
| pepsyn pad -l $TILESIZE --c-term - - \
> protein_tiles.fasta

The final peptide tiles are combined in protein_tiles.fasta.


4 To this point, we have been manipulating amino acid sequences. Now, reversetranslate the peptide sequences into DNA sequences using the revtrans command. This command randomly chooses codons according to the E. coli frequency table, dropping any codons that are more rare than a given frequency threshold. We use exclusively the amber stop codon. Add prefix/suffix sequences that will be used for PCR/cloning. Finally, search for any restriction sites that will be used for cloning within the coding sequence and recode them as necessary. The final oligonucleotides are presented in oligos.fasta


PREFIX=AGGAATTCCGCTGCGT
SUFFIX=GCCTGGAGACGCCATC
PREFIXLEN=${#PREFIX}
SUFFIXLEN=${#SUFFIX}
FREQTHRESH=0.01

cat protein_tiles.fasta \
| pepsyn revtrans --codon-freq-threshold $FREQTHRESH --amber-only - - \
| pepsyn prefix -p $PREFIX - - \
| pepsyn suffix -s $SUFFIX - - \
| pepsyn recodesite --site EcoRI --site HindIII --clip-left $PREFIXLEN \
--clip-right $SUFFIXLEN --codon-freq-threshold $FREQTHRESH \
--amber-only - - \
> oligos.fasta


?TROUBLESHOOTING		<----- What does this mean?


5 Finally, verify that the library is free of any EcoRI or HindIII sites, using the following command:

pepsyn findsite --site EcoRI --clip-left 3 oligos.fasta

pepsyn findsite --site HindIII oligos.fasta



6 Generate a bowtie index now, in preparation for aligning sequencing data later.  Generate a reference fasta file that contains just the DNA tiles without the adaptors using the following command:

pepsyn clip --left $PREFIXLEN --right $SUFFIXLEN oligos.fasta oligos-ref.fasta


Then create the bowtie index (or index for whichever aligner you prefer, such as bwa, bowtie2, or kallisto, among others) called "mylibrary" as follows:

bowtie-build -q oligos-ref.fasta bowtie_index/mylibrary














MGSLEMVPMGAGPPSPGGDPDGYDGGNNSQYPSASGSSGNTPTPPNDEERESNEEPPPPYEDPYWGNGDRHSDYQPLGTQDQSLYLGLQHDGNDGLPPPPYSPRDDSSQHIYEEAGRGSMNPVCLPVIVAPYLFWLAAIAASCFTASVSTVVTATGL
MGSLEMVPMGAGPPSPGGDPDGYDGGNNSQYPSASGSSGNTPTPPNDEERESNEEP
                            SQYPSASGSSGNTPTPPNDEERESNEEPPPPYEDPYWGNGDRHSDYQPLGTQDQSL
                                                        PPPYEDPYWGNGDRHSDYQPLGTQDQSLYLGLQHDGNDGLPPPPYSPRDDSSQHIY
                                                                                    YLGLQHDGNDGLPPPPYSPRDDSSQHIYEEAGRGSMNPVCLPVIVAPYLFWLAAIA







