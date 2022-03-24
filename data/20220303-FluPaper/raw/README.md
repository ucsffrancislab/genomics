


https://www.science.org/doi/10.1126/science.abg0928


WGS
https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA736483

RNASeq
https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA682434


https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE162632
ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE162nnn/GSE162632/suppl/GSE162632_RAW.tar
https://www.ncbi.nlm.nih.gov/bioproject/PRJNA682434
https://www.ncbi.nlm.nih.gov/sra?term=SRP295709
https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=682434










```
aws-adfs login

aws s3 ls s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/nih-20220303-sync/

aws s3 sync --exclude "*" --include "*_alignment_bam.bam" s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/nih-20220303-sync/ ./
```


89 bam files for 1.1TB 




https://github.com/herandolph/IAV_population-variation


https://zenodo.org/record/4273999#.YjjM4BPMKDU



```
awk 'BEGIN{FS=OFS=","}(NR>1){print $2,$12}' inputs/6_calculate_cisRegression_effect/predicted_population_differences/individual_meta_data_for_GE_with_scaledCovars_with_geneProps.txt | sort | uniq > sample_ancestry.csv
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/PRJNA736483"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T sample_ancestry.csv "${BOX}/"
```



