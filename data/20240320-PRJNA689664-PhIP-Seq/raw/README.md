
#	PRJNA689664

https://www.ebi.ac.uk/ena/browser/view/PRJNA689664


We provide raw sequence read data from Phage-Immunoprecipitation Sequencing (PhIP-Seq) experiments using serum samples obtained from 232 children.


Antibody repertoires in selected pediatric cohort


Contains 540 fastq files from Escherichia phage T7


No papers found using this dataset just yet.






Since we don't know exactly what was done, I could simple blastx to viral proteins?


```
mkdir fastq
cd fastq/
ena-file-download-read_run-PRJNA689664-fastq_ftp-20240320-2354.sh
fastx_count_array_wrapper.bash SRR1336*
```



