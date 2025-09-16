
#	20250813-CIDR

Folder and metadata files on box now.

Still waiting for the data.



##	20250915 Data is now available

The following are the instructions for downloading your data via command line.

Aspera-cli will allow you to use your shares account to pull down data via the command line.
Documentation on how to install the aspera-cli (ascli) can be found here:
https://github.com/IBM/aspera-cli/blob/main/docs/Manual.pdf
Chapter 3, page 11 has information on how to install.

Here is an example of how to browse what shares you have access to:

```BASH
ascli shares files browse --url=https://jhg-aspera2.jhgenomics.jhu.edu --username=SharesE-MailAccount --password="YourPasswordYouSet" /
```

Here is an example to download a file Test.txt from ShareName to the folder Temp on the R: drive:

```BASH
ascli shares files down --url=https://jhg-aspera2.jhgenomics.jhu.edu --username=SharesE-MailAccount --password="YourPasswordYouSet" "/ShareName/Path/Test.txt" --to-folder=R:\Temp
```

You can add the following parameter to set transfer rate (to our Max of 300mbps) and resume policy

```BASH
--ts=@json:'{"target_rate_kbps":300000,"resume_policy":"sparse_csum"}'
```

Here is an example to download a folder to a folder Temp with the transfer rate and resume policy

```BASH
ascli shares files down --url=https://jhg-aspera2.jhgenomics.jhu.edu --username=SharesE-MailAccount --password="YourPasswordYouSet" "/ShareName/Path/Folder" --to-folder=R:\Temp --ts=@json:'{"target_rate_kbps":300000,"resume_policy":"sparse_csum"}'
```










The instructions only included `podman` instructions which wouldn't work for me.
`singularity` does though.


```BASH 
singularity build ascli.sif docker://martinlaurent/ascli

singularity exec --bind /francislab,/scratch ascli.sif ascli


singularity exec --bind /francislab,/scratch ascli.sif ascli shares files browse --url=https://jhg-aspera2.jhgenomics.jhu.edu --username=george.wendt@ucsf.edu --password=$( cat password ) /

singularity exec --bind /francislab,/scratch ascli.sif ascli shares files browse --url=https://jhg-aspera2.jhgenomics.jhu.edu --username=george.wendt@ucsf.edu --password=$( cat password ) /francis_2520




singularity exec --bind /francislab,/scratch ascli.sif ascli shares files down --url=https://jhg-aspera2.jhgenomics.jhu.edu --username=george.wendt@ucsf.edu --password=$( cat password ) / 
```


```BASH
FAM file format
1 Family ID ('FID')
2 Within-family ID ('IID'; cannot be '0')
3 Within-family ID of father ('0' if father isn't in dataset)
4 Within-family ID of mother ('0' if mother isn't in dataset)
5 Sex code ('1' = male, '2' = female, '0' = unknown)
6 Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)
```






```BASH
ln -s francis_2520/Post_Datacleaning/Post_DataCleaning/PLINK_Files/Francis_GDA_TOP_subject_level_long.bed CIDR.bed
ln -s francis_2520/Post_Datacleaning/Post_DataCleaning/PLINK_Files/Francis_GDA_TOP_subject_level_long.bim CIDR.bim
ln -s francis_2520/Post_Datacleaning/Post_DataCleaning/PLINK_Files/Francis_GDA_TOP_subject_level_long.fam CIDR.fam
```


```BASH

curl  -netrc -T "${1}" "${BOX}/"

```


The vcfs are denoted as hg38

```BASH
francis_2520/Post_Datacleaning/Post_DataCleaning/Imputation/Input_VCFs/Francis_GDA_plus_hg38_chr10.vcf.gz
```












##	Offset by 1?




Assuming hg19 or hg38 as no data available for hg18

```BASH
awk 'BEGIN{OFS=":"}{print $1,$4,$2}' CIDR.bim | sort > rsids
awk 'BEGIN{OFS=":"}{print $1,1+$4,$2}' CIDR.bim | sort > plusonersids


join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > hg19_common_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > hg38_common_plusonersids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > hg19_common_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > hg38_common_rsids

join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_rsids > hg19_All_plusonersids
join plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids > hg38_All_plusonersids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/All_rsids > hg19_All_rsids
join rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_rsids > hg38_All_rsids

wc -l *rsids
      484 hg19_All_plusonersids
      484 hg19_common_plusonersids
     7851 hg19_common_rsids
   854323 hg38_All_rsids
        0 hg38_common_plusonersids
   822167 hg38_common_rsids
  1904599 plusonersids
  1904599 rsids
  5494507 total

```

the rsids say that this is hg38




