

#	TEProF2


https://outrageous-gateway-589.notion.site/TSTEA-Code-Compilation-5b781e1b979f46afb80991c7b0d41886



##	Prep

https://github.com/twlab/TEProf2Paper#2-reference-files



wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/reference_merged_candidates.gtf


```
~/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o- > reference_merged_candidates.gff3
Command line was:
/c4/home/gwendt/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o-
Warning: discarding suspicious 'transcript' record (ID=TCONS_00033598)
Warning: discarding suspicious 'transcript' record (ID=TCONS_00033599)
   .. loaded 128407 genomic features from /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf

```

This produces 3 header lines but the next step apparently is expecting there to be only 2.

```
##gff-version 3
# gffread v0.12.7
# /c4/home/gwendt/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o-
chr1	Cufflinks	transcript	11869	14409	.	+	.	ID=TCONS_00000001;geneID=XLOC_000001;gene_name=DDX11L1
```


```
~/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o- | tail -n +2 | head -3
Command line was:
/c4/home/gwendt/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o-
Warning: discarding suspicious 'transcript' record (ID=TCONS_00033598)
Warning: discarding suspicious 'transcript' record (ID=TCONS_00033599)
   .. loaded 128407 genomic features from /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf

# gffread v0.12.7
# /c4/home/gwendt/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o-
chr1	Cufflinks	transcript	11869	14409	.	+	.	ID=TCONS_00000001;geneID=XLOC_000001;gene_name=DDX11L1
```

```
~/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o- | tail -n +2 > reference_merged_candidates.gff3
chmod -w reference_merged_candidates.gff3
```



(5/8) Annotate Merged Transcripts

```
/c4/home/gwendt/github/twlab/TEProf2Paper/bin/rmskhg38_annotate_gtf_update_test_tpm_cuff.py \
  /francislab/data1/refs/TEProf2/reference_merged_candidates.gff3 /francislab/data1/refs/TEProf2/TEProF2.arguments.txt \
chmod -w reference_merged_candidates.gff3_annotated_test_all
chmod -w reference_merged_candidates.gff3_annotated_filtered_test_all
```





##	20230727


```
wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/Expression%20of%20Transcripts%20Across%20Cell%20Line%20Samples-%202297.csv

wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/Expression%20of%20Transcripts%20Across%20TCGA%20Samples-%202297.csv

wget https://wangftp.wustl.edu/~nshah/rnapipeline_public_link/rnapipelinerefhg38.tar.gz
```






##	20230731

Rename count columns and merge

```
20200720-TCGA-GBMLGG-RNA_bam/20230629-TEProF2/subjectsStatistics.presence.???.counts.csv
20200909-TARGET-ALL-P2-RNA_bam/20230710-TEProF2/subjectsStatistics.presence.ALL.counts.csv
20220804-RaleighLab-RNASeq/20230512-TEProF2/subjectsStatistics.presence.ALL.counts.csv
20230628-Costello/20230707-TEProF2/subjectsStatistics.presence.ALL.counts.csv
```

```
ll {20200720-TCGA-GBMLGG-RNA_bam,20200909-TARGET-ALL-P2-RNA_bam,20220804-RaleighLab-RNASeq,20230628-Costello}/*-TEProF2/subjectsStatistics.presence.???.counts.csv
```


```
python3 ./merge.py --int -o merged.subjectsStatistics.presence.counts.csv subjectsStatistics.presence.* 

join --header -t, /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/select_protein_accessions_IN_S10_S2_ProteinSequences.blastp.e0.05.trimandsort.species.TCONS.csv merged.subjectsStatistics.presence.counts.csv > merged.subjectsStatistics.presence.species.counts.csv

```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged.subjectsStatistics.presence.species.counts.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




##	20230828


```
awk -F, '(NR>1){print $8}' TABLE_TCGAID.csv | tr -d \" | cut -c 6- | uniq > their_sample_list

ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*R1.fastq.gz | xargs -I% basename % _R1.fastq.gz | cut -d+ -f1 | uniq > our_sample_list

join our_sample_list their_sample_list > shared_sample_list1
comm -12 our_sample_list their_sample_list > shared_sample_list2

wc -l *sample_list*
   726 our_sample_list
   704 shared_sample_list1
   704 shared_sample_list2
 11086 their_sample_list

diff shared_sample_list*
```



```
head -1 TABLE_TCGAID.csv | cut -d, -f10,13,8 | tr -d \" > TABLE_TCGAID.select.csv
awk 'BEGIN{FS=OFS=","}(NR>1){split($13,a,"-");print $10,a[2]"-"a[3]"-"a[4],$8}' TABLE_TCGAID.csv | sort -t, -k1,2 | tr -d \" >> TABLE_TCGAID.select.csv
```


```
head -1 Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.csv | tr -d \" > Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.sorted.csv 
tail -n +2 Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.csv | sort -k1,2 | tr -d \" >> Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.sorted.csv &
```


```
echo "File,Transcript Name,paper TPM,paper Intron Read Count,paper Present" > TCGA_Expression.select.translated.csv
join --header -t, TCGA_Expression.select.csv Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.sorted.csv | awk 'BEGIN{FS=OFS=","}(NR>1){print $2,$4,$5,$6,$7}' | sort -k1,2 >> TCGA_Expression.select.translated.csv &

sed 's/,/:/' TCGA_Expression.select.translated.csv > TCGA_Expression.select.translated.tojoin.csv

```



##	20231031


Try to recreate published table based on 


Select only those present.
```
echo "Transcript,Sample,Study,sampletype,paper TPM,paper Intron Read Count,paper Present" > TCGA_Expression.select.translated.present.csv
join --header -t, TABLE_TCGAID.select.csv Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.sorted.csv | awk 'BEGIN{FS=OFS=","}((NR>1)&&($NF>0)){print $6,$2,$4,$5,$7,$8,$9}' | sort -t, -k1,2 >> TCGA_Expression.select.translated.present.csv

head -3 TCGA_Expression.select.translated.present.csv
Transcript,Sample,Study,sampletype,paper TPM,paper Intron Read Count,paper Present
TCONS_00000246,05-4382-01,LUAD,Tumor,6.28514899638549,3,1
TCONS_00000246,2G-AAF4-01,TGCT,Tumor,4.75528879394282,1,1
```



Count those present
```
echo "Transcript,Study,sampletype,Count" > TCGA_Expression.select.translated.present.sample_aggregated_by_study.csv
awk 'BEGIN{FS=OFS=","}(NR>1){ a[$1][$3][$4]++ }END{for(i in a){for(j in a[i]){for(k in a[i][j]){print i,j,k,a[i][j][k]}}}}' TCGA_Expression.select.translated.present.csv | sort -t, -k1,3 >> TCGA_Expression.select.translated.present.sample_aggregated_by_study.csv

head -3 TCGA_Expression.select.translated.present.sample_aggregated_by_study.csv
Transcript,Study,sampletype,Count
TCONS_00000246,LUAD,Tumor,5
TCONS_00000246,STAD,Tumor,1
```


Convert into a table
```
awk 'BEGIN{FS=OFS=","}(NR>1){tcons[$1]++;study[$2]++;tn[$3]++;a[$1][$2][$3]=$4}END{s="Transcript ID";for(j in study){for(k in tn){s=s","j"_"k}}print s; for(i in tcons){s=i;for(j in study){for(k in tn){v=a[i][j][k];v=(v>0)?v:0;s=s","v}}print s}}' TCGA_Expression.select.translated.present.sample_aggregated_by_study.csv > tmp1
head -1 tmp1 > tmp2
tail -n +2 tmp1 | sort -t, -k1,1 >> tmp2
cat tmp2 | datamash transpose -t, > tmp3
head -1 tmp3 > tmp4
tail -n +2 tmp3 | sort -t, -k1,1 >> tmp4
cat tmp4 | datamash transpose -t, > TCGA_Expression.select.translated.present.sample_aggregated_by_study.table.csv
\rm tmp?
```




Prep S1 for comparison
```
tail -n +2 41588_2023_1349_MOESM3_ESM/S1.csv | cut -d, -f1,10-75 | head -1 | sed -e 's/_tumor/_Tumor/g' -e 's/_normal/_Normal/g' > S1.sorted.csv
tail -n +3 41588_2023_1349_MOESM3_ESM/S1.csv | cut -d, -f1,10-75 | sort -t, -k1,1 >> S1.sorted.csv

wc -l S1.sorted.csv TCGA_Expression.select.translated.present.sample_aggregated_by_study.table.csv
  26817 S1.sorted.csv
   2298 TCGA_Expression.select.translated.present.sample_aggregated_by_study.table.csv
  29115 total
```


Over 90% of the transcripts were filtered out by the authors. Initially, 26,816 down to 2,297.
```
join --header -t, S1.sorted.csv TCGA_Expression.select.translated.present.sample_aggregated_by_study.table.csv | cut -d, -f1-67 > tmp1
cat tmp1 | datamash transpose -t, > tmp2
head -1 tmp2 > tmp3
tail -n +2 tmp2 | sort -t, -k1,1 >> tmp3
cat tmp3 | datamash transpose -t, > S1.sorted.select.csv
\rm tmp?

diff S1.sorted.select.csv TCGA_Expression.select.translated.present.sample_aggregated_by_study.table.csv
```
No differences!


I'm pretty sure that the numbers in this table are the number of SAMPLEs and not SUBJECTs as 
I've seen that their list contains subjects with multiple samples.
My code reproduced their table and didn't take that into account, so they likely didn't either.





Unique by subject's sample type



```
head -3 TCGA_Expression.select.translated.present.csv
Transcript,Sample,Study,sampletype,paper TPM,paper Intron Read Count,paper Present
TCONS_00000246,05-4382-01,LUAD,Tumor,6.28514899638549,3,1
TCONS_00000246,2G-AAF4-01,TGCT,Tumor,4.75528879394282,1,1

head -1 TCGA_Expression.select.translated.present.csv | cut -d, -f1,2,3,4,7 > TCGA_Expression.select.translated.present.uniq_sample.csv
tail -n +2 TCGA_Expression.select.translated.present.csv | cut -d, -f1,2,3,4,7 | sort | uniq >> TCGA_Expression.select.translated.present.uniq_sample.csv

wc -l TCGA_Expression.select.translated.present.csv TCGA_Expression.select.translated.present.uniq_sample.csv
  159712 TCGA_Expression.select.translated.present.csv
  159144 TCGA_Expression.select.translated.present.uniq_sample.csv

head -3 TCGA_Expression.select.translated.present.uniq_sample.csv
Transcript,Sample,Study,sampletype,paper Present
TCONS_00000246,05-4382-01,LUAD,Tumor,1
TCONS_00000246,2G-AAF4-01,TGCT,Tumor,1



echo "Transcript,Study,sampletype,Count" > TCGA_Expression.select.translated.present.sample_type_aggregated_by_study.csv
awk 'BEGIN{FS=OFS=","}(NR>1){ a[$1][$3][$4]++ }END{for(i in a){for(j in a[i]){for(k in a[i][j]){print i,j,k,a[i][j][k]}}}}' TCGA_Expression.select.translated.present.uniq_sample.csv | sort -t, -k1,3 >> TCGA_Expression.select.translated.present.sample_type_aggregated_by_study.csv

head -3 TCGA_Expression.select.translated.present.sample_type_aggregated_by_study.csv
Transcript,Study,sampletype,Count
TCONS_00000246,LUAD,Tumor,5
TCONS_00000246,STAD,Tumor,1
```


```
awk 'BEGIN{FS=OFS=","}(NR>1){tcons[$1]++;study[$2]++;tn[$3]++;a[$1][$2][$3]=$4}END{s="Transcript ID";for(j in study){for(k in tn){s=s","j"_"k}}print s; for(i in tcons){s=i;for(j in study){for(k in tn){v=a[i][j][k];v=(v>0)?v:0;s=s","v}}print s}}' TCGA_Expression.select.translated.present.sample_type_aggregated_by_study.csv > tmp1
head -1 tmp1 > tmp2
tail -n +2 tmp1 | sort -t, -k1,1 >> tmp2
cat tmp2 | datamash transpose -t, > tmp3
head -1 tmp3 > tmp4
tail -n +2 tmp3 | sort -t, -k1,1 >> tmp4
cat tmp4 | datamash transpose -t, > TCGA_Expression.select.translated.present.sample_type_aggregated_by_study.table.csv
\rm tmp?
```



```

box_upload.bash TCGA_Expression.select.translated.present.sample_type_aggregated_by_study.table.csv TCGA_Expression.select.translated.present.sample_aggregated_by_study.table.csv

```











##	20231101

Do something similar to count viral protein


```
/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_alphaherpesvirus_3.protein_translation_table.csv

accession,withversion,description
NP_040124,NP_040124.1,NP_040124.1_membrane_protein_V1
NP_040125,NP_040125.2,NP_040125.2_myristylated_tegument_protein_CIRC
NP_040126,NP_040126.1,NP_040126.1_nuclear_protein_UL55



/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv

TCONS,qaccver,saccver,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore
TCONS_00000246,TCONS_00000246_HERVFH21-int_TAS1R1_+_104|373-398,YP_081561.1_HHV5_regulatory_protein_IE2,47.619,21,11,0,5,25,515,535,0.031,24.6
TCONS_00000246,TCONS_00000246_HERVFH21-int_TAS1R1_+_104|374-399,YP_081561.1_HHV5_regulatory_protein_IE2,47.619,21,11,0,4,24,515,535,0.031,24.6
TCONS_00000246,TCONS_00000246_HERVFH21-int_TAS1R1_+_104|375-400,YP_081561.1_HHV5_regulatory_protein_IE2,47.619,21,11,0,3,23,515,535,0.031,24.6


head TCGA_Expression.select.translated.csv
File,Transcript Name,paper TPM,paper Intron Read Count,paper Present
02-0047-01,TCONS_00000246,0.512194505758609,0,0
02-0047-01,TCONS_00000346,0.074957936826869,0,0
02-0047-01,TCONS_00000372,0,0,0
02-0047-01,TCONS_00000424,0.00519445572778914,0,0
02-0047-01,TCONS_00000454,0.0380901549801443,0,0



TABLE_TCGAID.select.csv 

echo "encoded,sample,aliquot,project,sampletype" > TABLE_TCGAID.select.csv
awk 'BEGIN{FS=OFS=","}(NR>1){split($13,a,"-");print $10,a[2]"-"a[3]"-"a[4],$8,$9,$11}' TABLE_TCGAID.csv | sort -t, -k1,2 | tr -d \" >> TABLE_TCGAID.select.csv

head -3 TABLE_TCGAID.select.csv 
encoded,sample,aliquot,project,sampletype
0010df1b-fe25-4e4d-8be4-dd1c51e79a68_gdc_realn_rehead,CN-4727-01,TCGA-CN-4727-01A-01R-1436-07,HNSC,Tumor
0014fd07-1fff-479f-99c1-350dc4bc1310_gdc_realn_rehead,KN-8428-01,TCGA-KN-8428-01A-11R-2315-07,KICH,Tumor

head -3 Expression\ of\ Transcripts\ Across\ TCGA\ Samples-\ 2297.sorted.csv 
Sample,Transcript ID,TPM,Intron Read,Present
0010df1b-fe25-4e4d-8be4-dd1c51e79a68_gdc_realn_rehead,TCONS_00000246,1.05528361331982,0,0
0010df1b-fe25-4e4d-8be4-dd1c51e79a68_gdc_realn_rehead,TCONS_00000346,0.000783539302956411,0,0
```



```
echo "TCONS,accession" > TCONS_viral_protein_translation_table.csv
awk 'BEGIN{FS=OFS=","}(NR>1){split($3,a,".");print $1,a[1]}' /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.csv

head -3 TCONS_viral_protein_translation_table.csv
TCONS,accession
TCONS_00000246,NP_050190
TCONS_00000246,YP_081561
```



```
join --header -t, TCONS_viral_protein_translation_table.csv TCGA_Expression.select.translated.present.csv > TCGA_Expression.select.translated.present.protein.csv

head -3 TCGA_Expression.select.translated.present.protein.csv
TCONS,accession,Sample,Study,sampletype,paper TPM,paper Intron Read Count,paper Present
TCONS_00000246,NP_050190,05-4382-01,LUAD,Tumor,6.28514899638549,3,1
TCONS_00000246,NP_050190,2G-AAF4-01,TGCT,Tumor,4.75528879394282,1,1
```



```
wc -l TCGA_Expression.select.translated.*
  25464543 TCGA_Expression.select.translated.csv
    159712 TCGA_Expression.select.translated.present.csv
    115109 TCGA_Expression.select.translated.present.protein.csv
```





```
echo "accession,Sample,Study,sampletype,paper Present" > TCGA_Expression.select.translated.present.protein.uniq_sample.csv
tail -n +2 TCGA_Expression.select.translated.present.protein.csv | cut -d, -f2,3,4,5,8 | sort | uniq >> TCGA_Expression.select.translated.present.protein.uniq_sample.csv

head -3 TCGA_Expression.select.translated.present.protein.uniq_sample.csv
accession,Sample,Study,sampletype,paper Present
NP_040125,21-1072-01,LUSC,Tumor,1
NP_040125,25-1320-01,OV,Tumor,1


wc -l TCGA_Expression.select.translated.present.protein*.csv
  115109 TCGA_Expression.select.translated.present.protein.csv
  106264 TCGA_Expression.select.translated.present.protein.uniq_sample.csv
```




```
echo "Accession,Study,sampletype,Count" > TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.csv
awk 'BEGIN{FS=OFS=","}(NR>1){ a[$1][$3][$4]++ }END{for(i in a){for(j in a[i]){for(k in a[i][j]){print i,j,k,a[i][j][k]}}}}' TCGA_Expression.select.translated.present.protein.uniq_sample.csv | sort -t, -k1,3 >> TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.csv


head -3 TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.csv
Accession,Study,sampletype,Count
NP_040125,BRCA,Tumor,1,3
NP_040125,ESCA,Tumor,1,2
```



```
awk 'BEGIN{FS=OFS=","}(NR>1){tcons[$1]++;study[$2]++;tn[$3]++;a[$1][$2][$3]=$4}END{s="Accession";for(j in study){for(k in tn){s=s","j"_"k}}print s; for(i in tcons){s=i;for(j in study){for(k in tn){v=a[i][j][k];v=(v>0)?v:0;s=s","v}}print s}}' TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.csv > tmp1
head -1 tmp1 > tmp2
tail -n +2 tmp1 | sort -t, -k1,1 >> tmp2
cat tmp2 | datamash transpose -t, > tmp3
head -1 tmp3 > tmp4
tail -n +2 tmp3 | sort -t, -k1,1 >> tmp4
cat tmp4 | datamash transpose -t, > TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.table.csv
\rm tmp?
```




```
join --header -t, TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.table.csv \
  /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_alphaherpesvirus_3.protein_translation_table.csv \
  > TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.table.HHV3.csv

box_upload.bash TCGA_Expression.select.translated.present.protein.sample_type_aggregated_by_study.table.HHV3.csv

```














##	----

Let's create tighter tables based on bitscore limits????

```
head -3 /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv
TCONS,qaccver,saccver,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore
TCONS_00000246,TCONS_00000246_HERVFH21-int_TAS1R1_+_104|373-398,YP_081561.1_HHV5_regulatory_protein_IE2,47.619,21,11,0,5,25,515,535,0.031,24.6
TCONS_00000246,TCONS_00000246_HERVFH21-int_TAS1R1_+_104|374-399,YP_081561.1_HHV5_regulatory_protein_IE2,47.619,21,11,0,4,24,515,535,0.031,24.6
```

Filter on bitscore

```
echo "TCONS,accession" > TCONS_viral_protein_translation_table.bitscoregt40.csv
awk 'BEGIN{FS=OFS=","}((NR>1)&&($NF>40)){split($3,a,".");print $1,a[1]}' /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.bitscoregt40.csv

echo "TCONS,accession" > TCONS_viral_protein_translation_table.bitscoregt35.csv
awk 'BEGIN{FS=OFS=","}((NR>1)&&($NF>35)){split($3,a,".");print $1,a[1]}' /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.bitscoregt35.csv

echo "TCONS,accession" > TCONS_viral_protein_translation_table.bitscoregt30.csv
awk 'BEGIN{FS=OFS=","}((NR>1)&&($NF>30)){split($3,a,".");print $1,a[1]}' /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.bitscoregt30.csv

echo "TCONS,accession" > TCONS_viral_protein_translation_table.bitscoregt25.csv
awk 'BEGIN{FS=OFS=","}((NR>1)&&($NF>25)){split($3,a,".");print $1,a[1]}' /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.bitscoregt25.csv

wc -l TCONS_viral_protein_translation_table.*csv
  770 TCONS_viral_protein_translation_table.bitscoregt25.csv
  111 TCONS_viral_protein_translation_table.bitscoregt30.csv
   17 TCONS_viral_protein_translation_table.bitscoregt35.csv
    5 TCONS_viral_protein_translation_table.bitscoregt40.csv
 1984 TCONS_viral_protein_translation_table.csv

```







```
for bitscore in 25 30 35 40 ; do

  echo "TCONS,accession" > TCONS_viral_protein_translation_table.bitscoregt${bitscore}.csv
  awk -v bitscore=${bitscore} 'BEGIN{FS=OFS=","}((NR>1)&&($NF>bitscore)){split($3,a,".");print $1,a[1]}' \
    /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv \
    | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.bitscoregt${bitscore}.csv

  join --header -t, TCONS_viral_protein_translation_table.bitscoregt${bitscore}.csv \
    TCGA_Expression.select.translated.present.csv \
    > TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.csv

  echo "accession,Sample,Study,sampletype,paper Present" > TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.uniq_sample.csv
  tail -n +2 TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.csv | cut -d, -f2,3,4,5,8 | sort | uniq \
    >> TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.uniq_sample.csv

  echo "Accession,Study,sampletype,Count" > TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.csv
  awk 'BEGIN{FS=OFS=","}(NR>1){ a[$1][$3][$4]++ }END{for(i in a){for(j in a[i]){for(k in a[i][j]){print i,j,k,a[i][j][k]}}}}' \
    TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.uniq_sample.csv | sort -t, -k1,3 \
    >> TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.csv

  awk 'BEGIN{FS=OFS=","}(NR>1){tcons[$1]++;study[$2]++;tn[$3]++;a[$1][$2][$3]=$4}END{s="Accession";for(j in study){for(k in tn){s=s","j"_"k}}print s; for(i in tcons){s=i;for(j in study){for(k in tn){v=a[i][j][k];v=(v>0)?v:0;s=s","v}}print s}}' \
    TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.csv > tmp1
  head -1 tmp1 > tmp2
  tail -n +2 tmp1 | sort -t, -k1,1 >> tmp2
  cat tmp2 | datamash transpose -t, > tmp3
  head -1 tmp3 > tmp4
  tail -n +2 tmp3 | sort -t, -k1,1 >> tmp4
  cat tmp4 | datamash transpose -t, > TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.table.csv
  \rm tmp?
  box_upload.bash TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.table.csv

  join --header -t, TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.table.csv \
    /francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/Human_alphaherpesvirus_3.protein_translation_table.csv \
    > TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.table.HHV3.csv

  box_upload.bash TCGA_Expression.select.translated.present.protein.bitscoregt${bitscore}.sample_type_aggregated_by_study.table.HHV3.csv
done

```






##	20231121 New Files available



On the same site (https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/), you should see three new files:

1. Expression_of_transcripts_Across_TCGA-ALL.csv
-This is the raw table with all the expression and counts for TCGA. These are the main columns that I think you will be interested i: 1) TranscriptID- File with label from TCGA, 2) variable- the TCONS transcript ID for the transcripts listed in the paper, 3) intronread- the number of reads for the unique intron unction closest to candidate gene. We used this as a filter and this had to be a t least 1 for a candidate to be present in a file, and 4) stringtieTPM- The tpm calculated from stringtie, this had to be at least 1 in our analysis. 
2. Expression_of_transcripts_Across_GTEx-ALL.csv
-This is the raw table with all the expression and counts for GTEx. These are the main columns that I think you will be interested i: 1) TranscriptID- File with label from GTEx, 2) variable- the TCONS transcript ID for the transcripts listed in the paper, 3) intronread- the number of reads for the unique intron unction closest to candidate gene. We used this as a filter and this had to be a t least 1 for a candidate to be present in a file, and 4) value The tpm calculated from stringtie, this had to be at least 1 in our analysis. 
-Note, due to memory issues we had filtered this already for transcripts that had TPM of 1, so it only has rows for transcripts that have TPM of at least 1 in a sample. I will have to see if I can get the original raw data. 
3. TCGALabels.csv
-This is the file with mappings that we used in the analysis for TCGA IDs and the IDs of the files. 

Hope this helps!

```
wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/Expression_of_transcripts_Across_GTEx-ALL.csv
chmod 400 Expression_of_transcripts_Across_GTEx-ALL.csv

wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/Expression_of_transcripts_Across_TCGA-ALL.csv
chmod 400 Expression_of_transcripts_Across_TCGA-ALL.csv

wget https://wangftp.wustl.edu/~nshah/ucsf/TCGA33Download/TCGALabels.csv
chmod 400 TCGALabels.csv

```







##	20240729



```
module load WitteLab python3/3.9.1

./merge.py -o S1.all.merged.csv /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.sorted.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.GBM.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.LGG.csv /francislab/data1/working/20240610-Stanford/20240717-TEProF2-hg38_v25/counts.csv /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240705-TEProF2_v25/counts.csv /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv 


./merge.py -o tmp.csv /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.sorted.S2.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.GBM.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.LGG.csv /francislab/data1/working/20240610-Stanford/20240717-TEProF2-hg38_v25/counts.csv /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240705-TEProF2_v25/counts.csv /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv 

join -t, --header /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt tmp.csv > S1.all.S2.merged.csv 
```



Why are there missing transcripts?

There are almost 1000 TCONS NEVER found by our runs. Guessing they aren't in the reference?

```
comm -23 <( tail -n +2 S1.all.merged.TranscriptIDs.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt ) | wc -l
917
```


Found by us but not in the paper?
```
comm -23 <( tail -n +2 S1.all.merged.TranscriptIDs.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt ) | head
TCONS_00000080
TCONS_00000090
TCONS_00000091
TCONS_00000219
TCONS_00000277
TCONS_00000766
TCONS_00000818
TCONS_00000861
TCONS_00000938
TCONS_00000958
```




```
cut -d, -f1 /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv > ALL.TranscriptIDs.found_by_us.txt

wc -l ALL.TranscriptIDs.found_by_us.txt 
26582 ALL.TranscriptIDs.found_by_us.txt

wc -l /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt
26817 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt

join --header /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt <( cut -d, -f1 /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv ) > S1.TranscriptIDs.found_by_us.txt

wc -l S1.TranscriptIDs.found_by_us.txt
25665 S1.TranscriptIDs.found_by_us.txt

wc -l /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt
2298 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt

join --header /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt <( cut -d, -f1 /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv ) > S2.TranscriptIDs.found_by_us.txt

wc -l S2.TranscriptIDs.found_by_us.txt
2216 S2.TranscriptIDs.found_by_us.txt


There are 1152 TCONS that the paper finds, that we NEVER find.

comm -13 <( tail -n +2 ALL.TranscriptIDs.found_by_us.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt ) | wc -l
1152

And we find 917 that are not in the paper.

comm -23 <( tail -n +2 ALL.TranscriptIDs.found_by_us.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.TranscriptIDs.txt ) | wc -l
917


82 of the S2 TCONS we NEVER find.

comm -13 <( tail -n +2 S2.TranscriptIDs.found_by_us.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt )  | wc -l
82


comm -13 <( tail -n +2 S2.TranscriptIDs.found_by_us.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt ) | head
TCONS_00000560
TCONS_00011670
TCONS_00013166
TCONS_00013168
TCONS_00013492
TCONS_00020682
TCONS_00021241
TCONS_00021242
TCONS_00023165
TCONS_00027845


```

WHY?


Using the first, TCONS_00000560, as an example.

Looks like 75 of these are not in the candidate_names.txt file which is created with their script and their reference file. 

Nothing to do with any data set.

Curious.

```
comm -13 <( tail -n +2 S2.TranscriptIDs.found_by_us.txt )  <( tail -n +2 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt )  > missing_S2_transcriptids


grep -f /francislab/data1/refs/TEProf2/missing_S2_transcriptids candidate_names.txt 
TCONS_00027845
TCONS_00059672
TCONS_00078774
TCONS_00101140
TCONS_00108523
TCONS_00112046
TCONS_00123813
```










##	20240801


```
tail -n +2 41588_2023_1349_MOESM3_ESM/S10.csv |head -1 | awk -F, '{for(i=1;i<=NF;i++){print i"-"$i}}'
1-Transcript ID
2-Subfam
3-Chr TE
4-Start TE
5-End TE
6-Location TE
7-Gene
8-Splice Target
9-Strand
10-Index of Start Codon
11-Frame
12-Frame Type
13-Protein Sequence
14-Original Protein Sequence
15-Strategy
16-
17-
18-
```

```
tail -n +3 41588_2023_1349_MOESM3_ESM/S10.csv | sort -k1,1 -k10n,10 | awk 'BEGIN{FS=OFS=","}($13!="None"){print ">"$1"-"$10;print $13}' > S10.faa

```


```
tail -n +2 41588_2023_1349_MOESM3_ESM/S1.csv |head -1 | awk -F, '{for(i=1;i<=NF;i++){print i"-"$i}}'
1-Transcript ID
2-Subfam
3-Chr TE
4-Start TE
5-End TE
6-Location TE
7-Gene
8-Splice Target
9-Strand
10-ACC_tumor
11-ACC_normal
12-BLCA_tumor
13-BLCA_normal
14-BRCA_tumor
15-BRCA_normal
16-CESC_tumor
17-CESC_normal
18-CHOL_tumor
19-CHOL_normal
20-COAD_tumor
21-COAD_normal
22-DLBC_tumor
23-DLBC_normal
24-ESCA_tumor
25-ESCA_normal
26-GBM_tumor
27-GBM_normal
28-HNSC_tumor
29-HNSC_normal
30-KICH_tumor
31-KICH_normal
32-KIRC_tumor
33-KIRC_normal
34-KIRP_tumor
35-KIRP_normal
36-LAML_tumor
37-LAML_normal
38-LGG_tumor
39-LGG_normal
40-LIHC_tumor
41-LIHC_normal
42-LUAD_tumor
43-LUAD_normal
44-LUSC_tumor
45-LUSC_normal
46-MESO_tumor
47-MESO_normal
48-OV_tumor
49-OV_normal
50-PAAD_tumor
51-PAAD_normal
52-PCPG_tumor
53-PCPG_normal
54-PRAD_tumor
55-PRAD_normal
56-READ_tumor
57-READ_normal
58-SARC_tumor
59-SARC_normal
60-SKCM_tumor
61-SKCM_normal
62-STAD_tumor
63-STAD_normal
64-TGCT_tumor
65-TGCT_normal
66-THCA_tumor
67-THCA_normal
68-THYM_tumor
69-THYM_normal
70-UCEC_tumor
71-UCEC_normal
72-UCS_tumor
73-UCS_normal
74-UVM_tumor
75-UVM_normal
76-Adipose Tissue_gtex
77-Ovary_gtex
78-Vagina_gtex
79-Breast_gtex
80-Salivary Gland_gtex
81-Adrenal Gland_gtex
82-Spleen_gtex
83-Esophagus_gtex
84-Prostate_gtex
85-Testis_gtex
86-Nerve_gtex
87-Brain_gtex
88-Thyroid_gtex
89-Lung_gtex
90-Skin_gtex
91-Blood_gtex
92-Blood Vessel_gtex
93-Pituitary_gtex
94-Heart_gtex
95-Colon_gtex
96-Pancreas_gtex
97-Stomach_gtex
98-Muscle_gtex
99-Small Intestine_gtex
100-Uterus_gtex
101-Kidney_gtex
102-Liver_gtex
103-Cervix Uteri_gtex
104-Bladder_gtex
105-Fallopian Tube_gtex
106-Tumor Total
107-Normal Total
108-GTEx Total
109-GTEx Total without Testis
```






Once RaleighLab is complete ...


```
module load WitteLab python3/3.9.1

./merge.py -o S1.all.merged.csv /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.sorted.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.GBM.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.LGG.csv /francislab/data1/working/20240610-Stanford/20240717-TEProF2-hg38_v25/counts.csv /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240705-TEProF2_v25/counts.csv /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv /francislab/data1/working/20220804-RaleighLab-RNASeq/20240725-TEProF2_v25/counts.csv /francislab/data1/working/20201006-GTEx/20240705-TEProF2_v25/counts.csv


./merge.py -o tmp.csv /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S1.sorted.S2.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.GBM.csv /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240621-TEProF2_v25/counts.LGG.csv /francislab/data1/working/20240610-Stanford/20240717-TEProF2-hg38_v25/counts.csv /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20240705-TEProF2_v25/counts.csv /francislab/data1/working/20230628-Costello/20240705-TEProF2_v25/counts.csv /francislab/data1/working/20220804-RaleighLab-RNASeq/20240725-TEProF2_v25/counts.csv /francislab/data1/working/20201006-GTEx/20240705-TEProF2_v25/counts.csv

join -t, --header /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S2.TranscriptIDs.txt tmp.csv > S1.all.S2.merged.csv 
```




annotatedcufftranscripts$uniqid <- paste(

annotatedcufftranscripts$subfamTE,
annotatedcufftranscripts$startTE,
annotatedcufftranscripts$gene1,
annotatedcufftranscripts$exonintron1, 
annotatedcufftranscripts$number1, 
annotatedcufftranscripts$gene2, 
annotatedcufftranscripts$exonintron2, 
annotatedcufftranscripts$number2,
annotatedcufftranscripts$transcriptstart2

,sep = "_")


22362 TCONS_00078773 L1MB7_18937350_ENSG00000283809_intron_4_ENSG00000283809_exon_5_18906238
22363 TCONS_00078774 L1MB7_18937350_ENSG00000283809_intron_4_ENSG00000283809_exon_5_18906238



31706 TCONS_00108522                     L1PA2_93586902_None_None_None_GNGT1_exon_1_93906586
31707 TCONS_00108523                     L1PA2_93586902_None_None_None_GNGT1_exon_1_93906586





##	20240802


I THINK that I missed again. I THINK that I used the old gff3_annotated_filtered_test_all

Creating from the new file.



```
~/.local/bin/gffread -E /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf -o- | tail -n +2 > reference_merged_candidates.gff3
chmod -w reference_merged_candidates.gff3
```

(5/8) Annotate Merged Transcripts

```
/c4/home/gwendt/github/ucsffrancislab/TEProf2Paper/bin/rmskhg38_annotate_gtf_update_test_tpm_cuff.py \
  /francislab/data1/refs/TEProf2/rnapipelinerefhg38/reference_merged_candidates.gff3 \
  /francislab/data1/refs/TEProf2/rnapipelinerefhg38/TEProF2.arguments.txt 

chmod -w /francislab/data1/refs/TEProf2/rnapipelinerefhg38/reference_merged_candidates.gff3*

```


