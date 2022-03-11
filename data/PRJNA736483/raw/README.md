


https://www.science.org/doi/10.1126/science.abg0928

https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA736483



```
aws-adfs login

aws s3 ls s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/nih-20220303-sync/

aws s3 sync --exclude "*" --include "*_alignment_bam.bam" s3://francislab-backup-73-3-r-us-west-2.sec.ucsf.edu/nih-20220303-sync/ ./
```


89 bam files for 1.1TB 

