
#	20230426-PanCancerAntigens/20230426-explore



Lets take the proteins in S2 (the filtered ones) and make a blastdb of the corresponding proteins from S10.  Lets at least keep the the transcript name (and any-other info possible) attached.

Select the "Protein Sequence" from S10 whose Transcript ID is in the list on S2.

Make blast db.




Lets Make a second blast db with all the proteins that are found in either the LGG or GBM samples (from s10). Thsi will be much bigger but worth a search.






then, lets take the VZV proteins and search against these databases to see if there are any solid hits.



```


blastp -db /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences -query /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.fa > Human_alphaherpesvirus_3_proteins_IN_S10_All_ProteinSequences.blastp.txt

blastp -db /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.fa -query /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences.fa > S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.blastp.txt


blastp -db /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences -query /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.fa -evalue 0.05 > Human_alphaherpesvirus_3_proteins_IN_S10_All_ProteinSequences.blastp.e0.05.txt

blastp -db /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.fa -query /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences.fa -evalue 0.05 > S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.blastp.e0.05.txt


```









Run this again on CMV, EBV and HSV1 as well

HHV-1 NC_001806.2 also known as Herpes Simplex type 1 (HSV-1) ( _Human_alphaherpesvirus_1.fa )

HHV-3 NC_001348.1 also known as Varicella Zoster (VZV) ( _Human_alphaherpesvirus_3.fa )

HHV-4 NC_007605.1 also known as Epstein-Barr virus (EBV) ( _Human_gammaherpesvirus_4.fa )

HHV-5 NC_006273.2 also known as Human Cytomegalovirus (HCMV) ( _Human_betaherpesvirus_5.fa )


```
for s in Human_alphaherpesvirus_1 Human_alphaherpesvirus_3 Human_gammaherpesvirus_4 Human_betaherpesvirus_5 ; do
  echo ${s}
  mkdir ${s}
  cat /francislab/data1/refs/refseq/viral-20220923/viral.protein/*_${s}.fa | sed  -e 's/,//g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' > ${s}/proteins.fa
  makeblastdb -in ${s}/proteins.fa -input_type fasta -dbtype prot -out ${s} -title ${s} -parse_seqids
  blastp -db /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences \
    -query ${s}/proteins.fa -evalue 0.05 > ${s}_proteins_IN_S10_All_ProteinSequences.blastp.e0.05.txt
  blastp -query /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences.fa \
    -db ${s} -evalue 0.05 > S10_All_ProteinSequences_IN_${s}_proteins.blastp.e0.05.txt
  blastp -db /francislab/data1/raw/20230426-PanCancerAntigens/S10_S1Brain_ProteinSequences \
    -query ${s}/proteins.fa -evalue 0.05 > ${s}_proteins_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.txt
  blastp -query /francislab/data1/raw/20230426-PanCancerAntigens/S10_S1Brain_ProteinSequences.fa \
    -db ${s} -evalue 0.05 > S10_S1Brain_ProteinSequences_IN_${s}_proteins.blastp.e0.05.txt
done
```


```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in *.blastp.*txt ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done


```



```
/francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Human_alphaherpesvirus_3_proteins_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.txt


Query= NP_040188.1_serine-threonine_protein_kinase_US3_Hu

Length=393
                                                                      Score        E
Sequences producing significant alignments:                          (Bits)     Value

TCONS_00011565_MLT1A0_AKT3_-_233 unnamed protein product              89.4       2e-21
TCONS_00092541_MLT2B2_EPHA5_-_195 unnamed protein product             68.2       2e-14
TCONS_00036289_MLT1E2_PRKD1_-_134 unnamed protein product             66.6       7e-14
TCONS_00000820_L2b_EPHB2_+_9 unnamed protein product                  65.1       2e-13
TCONS_00105490_L1PA5_MAP3K7_-_130 unnamed protein product             47.4       6e-08
TCONS_00012449_MIRb_RET_+_458 unnamed protein product                 44.3       2e-07
```


Not entirely certain why these 6 were selected.

NP_040188.1_serine-threonine_protein_kinase_US3_Hu
TCONS_00011565_MLT1A0_AKT3_-_233
TCONS_00092541_MLT2B2_EPHA5_-_195
TCONS_00036289_MLT1E2_PRKD1_-_134
TCONS_00000820_L2b_EPHB2_+_9
TCONS_00105490_L1PA5_MAP3K7_-_130
TCONS_00012449_MIRb_RET_+_458

```
module load samtools

cp /francislab/data1/working/20230413-VZV/Human_alphaherpesvirus_3_proteins.trim.sam_header S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.Human_alphaherpesvirus_3_proteins.sam

blast2sam.pl S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.blastp.e0.05.txt >> S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.Human_alphaherpesvirus_3_proteins.sam
samtools sort -o S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.Human_alphaherpesvirus_3_proteins.bam S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.Human_alphaherpesvirus_3_proteins.sam
samtools index S10_All_ProteinSequences_IN_Human_alphaherpesvirus_3_proteins.Human_alphaherpesvirus_3_proteins.bam
```







```
cat <<EOF > S10_All_ProteinSequences 
TCONS_00011565_MLT1A0_AKT3_-_233
TCONS_00092541_MLT2B2_EPHA5_-_195
TCONS_00036289_MLT1E2_PRKD1_-_134
TCONS_00000820_L2b_EPHB2_+_9
TCONS_00105490_L1PA5_MAP3K7_-_130
TCONS_00012449_MIRb_RET_+_458
EOF


grep -f S10_All_ProteinSequences -A1 --no-group-separator /francislab/data1/raw/20230426-PanCancerAntigens/S10_All_ProteinSequences.fa 



```



```
wget http://www.sbg.bio.ic.ac.uk/~maxcluster/maxcluster64bit
chmod +x maxcluster64bit
```



