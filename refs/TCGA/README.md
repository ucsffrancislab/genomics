
#	TCGA References

Some of these may have been in ...

```
raw/20200603-TCGA-GBMLGG-WGS
raw/20200720-TCGA-GBMLGG-RNA_bam
raw/20200720-TCGA-GBMLGG-RNA_fastq
```



```
cp /c4/home/gwendt/github/ucsffrancislab/genomics/data/20200720-TCGA-GBMLGG-RNA_bam/raw/TCGA.Glioma.metadata.tsv ./

head -1 TCGA.Glioma.metadata.tsv

case_submitter_id	project_id	primary_diagnosis	race	ethnicity	gender	RE_names	IDH	x1p19q	TERT	IDH_1p19q_status	WHO_groups	Triple_group	Tissue_sample_location	MGMT	Age	Survival_months	Vital_status

```



awk -F"\t" '($3=="Brain Lower Grade Glioma"){print $1}' TCGA.Tissue_Source_Site_Codes.tsv > TCGA.LGG_codes.txt

awk -F"\t" '($3=="Glioblastoma multiforme"){print $1}' TCGA.Tissue_Source_Site_Codes.tsv > TCGA.GBM_codes.txt


