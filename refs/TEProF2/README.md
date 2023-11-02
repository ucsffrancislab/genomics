

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
echo "TCONS,accession" > TCONS_viral_protein_translation_table.csv
awk 'BEGIN{FS=OFS=","}(NR>1){split($3,a,".");print $1,a[1]}' 

/francislab/data1/working/20230426-PanCancerAntigens/20231011-focused_blasting/S10_All_ProteinSequences_fragments_in_Human_herpes_proteins.blastp.e0.05.TCONS.csv | sort -t, -k1,2 | uniq >> TCONS_viral_protein_translation_table.csv

head -3 TCONS_viral_protein_translation_table.csv
TCONS,accession
TCONS_00000246,NP_050190
TCONS_00000246,YP_081561
```





