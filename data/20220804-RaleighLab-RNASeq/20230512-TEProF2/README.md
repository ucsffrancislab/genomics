
#	TEProF2


/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/




```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/raw/20220804-RaleighLab-RNASeq/trimmed \
  --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/in \
  --extension .Aligned.sortedByCoord.out.bam

```



```

#TEProF2_TCGA33_guided_aggregation_steps.bash --threads 64 --strand --rf \
#  --in  /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/in \
#  --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/out

```



Rerunning AGAIN due to my filename parsing change

```

/bin/rm -f ctab_i.txt candidateCommands.txt candidateCommands.complete table_i_all ctablist.txt stringtieExpressionFracCommands.txt stringtieExpressionFracCommands.complete ctab_frac_tot_files.txt ctab_tpm_files.txt table_frac_tot table_tpm table_frac_tot_cand table_tpm_cand "All TE-derived Alternative Isoforms Statistics.csv" allCandidateStatistics.tsv merged_transcripts_all.refBed Step11_FINAL.RData translationPart?.2023*.out.log CPC2.2023*.out.log

```



```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/in \
  --out /francislab/data1/working/20220804-RaleighLab-RNASeq/20230512-TEProF2/out

```







```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in out/{Step10.RData,Step11_FINAL.RData,Step12.RData,Step13.RData,candidates_cpcout.fa,candidates_proteinseq.fa} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```


Prepping to view final R data
```
R

load("out/Step13.RData")

head(fracexpressiontable)

```

