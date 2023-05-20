
#	Test run of TEProF2 on STRANDED data

/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/





I think that the last line makes it "stranded", "--fr" or "fr-firststrand". NOPE.




Running RseQC returns all like ...

Fraction of reads explained by "1+-,1-+,2++,2--": 0.9568

https://chipster.csc.fi/manual/library-type-summary.html

This suggests fr-firststrand

Stringtie
--rf	Assumes a stranded library fr-firststrand.






```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out \
  --extension .Aligned.sortedByCoord.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out

```




This took nearly 6 days
```

TEProF2_TCGA33_guided_aggregation_steps.bash --threads 64 --strand --rf \
  --in  /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out-guided

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





Strand was not being passed ...
```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out-strandtest \
  --extension .Aligned.sortedByCoord.out.bam

```



```

TEProF2_TCGA33_guided_aggregation_steps.bash --threads 64 --strand --rf \
  --in  /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out-strandtest \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out-strandtest-guided

```


```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}/TCGA33_guided"
for f in out-guided/{Step10.RData,Step11_FINAL.RData,Step12.RData,Step13.RData,candidates_cpcout.fa,candidates_proteinseq.fa} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```





Rerunning AGAIN due to my filename parsing change

```

/bin/rm -f ctab_i.txt candidateCommands.txt candidateCommands.complete table_i_all ctablist.txt stringtieExpressionFracCommands.txt stringtieExpressionFracCommands.complete ctab_frac_tot_files.txt ctab_tpm_files.txt table_frac_tot table_tpm table_frac_tot_cand table_tpm_cand "All TE-derived Alternative Isoforms Statistics.csv" allCandidateStatistics.tsv merged_transcripts_all.refBed Step11_FINAL.RData translationPart?.2023*.out.log CPC2.2023*.out.log

```



```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf \
  --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf \
  --in  /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out-strandtest \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out-strandtest-guided

```

```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}/TCGA33_guided_restranded"
for f in out-strandtest-guided/{Step10.RData,Step11_FINAL.RData,Step12.RData,Step13.RData,candidates_cpcout.fa,candidates_proteinseq.fa} ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```






grep "^>" ../../20230426-PanCancerAntigens/20230426-explore/select_S10_All_ProteinSequences.fa | tr -d ">"



Prepping to view final R data
```
R

> load("out-strandtest-guided/Step13.RData")

> tpmexpressiontable[0:5,0:5]
  TranscriptID TCONS_00000050 TCONS_00000056 TCONS_00000058 TCONS_00000059
2       260v01    0.009950144    0.018558406      0.0000000      0.4937565
3       260v02    0.075301157    0.000000000      0.5414942      0.0000000
4       260v03    0.486996922    0.037251096      0.3591145      0.0000000
5       260v04    0.625168363    0.000000000      1.6914543      0.0000000
6       260v05    2.446610945    0.003706618      0.2736372      0.2831258
> fracexpressiontable[0:5,0:5]
  TranscriptID TCONS_00000050 TCONS_00000056 TCONS_00000058 TCONS_00000059
2       260v01    0.009640321      1.0000000    0.000000000    0.010020929
3       260v02    0.054937220      0.0000000    0.009046515    0.000000000
4       260v03    0.450950605      1.0000000    0.007922222    0.000000000
5       260v04    0.678077664      0.0000000    0.023327575    0.000000000
6       260v05    0.862667303      0.2370568    0.004774411    0.004939967
> dim(tpmexpressiontable)
[1]   178 27136
> dim(fracexpressiontable)
[1]   178 27136


```








