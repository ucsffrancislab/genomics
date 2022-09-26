



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






