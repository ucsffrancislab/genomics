

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
awk 'BEGIN{FS=OFS=","}(NR>1){split($13,a,"-");print $10,a[2]"-"a[3]"-"a[4],$8}' TABLE_TCGAID.csv | sort -k1,2 | tr -d \" >> TABLE_TCGAID.select.csv
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




