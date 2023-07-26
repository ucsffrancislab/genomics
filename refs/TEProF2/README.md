

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


