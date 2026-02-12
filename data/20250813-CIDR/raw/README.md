
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






##	20250918


```
dxgroup,Tumor type at IPS study enrollment,encoded value,1A=newly diagnosed GBM,1B=newly diagnosed IDH mutant grade 4 astrocytoma,2=newly diagnosed lower grade glioma (lgg),"3=recurrent lgg, still lgg at enrollment","4=recurrent lgg, now grade 4 at enrollment","5=newly diagnosed glioma, uncertain type",,,,,,,
grade,Tumor grade per pathology report from study enrollment surgery,encoded value,2=tumor grade 2,3=tumor grade 3,4=tumor grade 4,blank=missing/unknown grade,,,,,,,,,
who2021,WHO2021 classification per enrollment surgery pathology report,encoded value,"1=Astrocytoma, IDH-mutant, CNS WHO grade 2","2=Astrocytoma, IDH-mutant, CNS WHO grade 3","3=Astrocytoma, IDH-mutant, CNS WHO grade 4","4=Diffuse glioma with molecular features of glioblastoma, IDH-wildtype, WHO grade 4","5=Giant cell glioblastoma, IDH-wildtype, WHO grade 4","6=Glioblastoma, IDH- and histone H3-wildtype, WHO grade 4","7=Glioblastoma, IDH-wildtype, CNS WHO grade 4","8=Gliosarcoma, IDH-wildtype, CNS WHO grade 4","9=Oligodendroglioma, IDH-mutant and 1p/19q codeleted, CNS WHO grade 2","10=Oligodendroglioma, IDH-mutant and 1p/19q codeleted, CNS WHO grade 3",13=Not in WHO 2021 Classification,14=Other,"15=Diffuse midline glioma, H3 K27-altered, WHO grade 4"
pq,Medical record/path review confirmation that tumor was 1p19q co-deleted. Only pulled and confirmed for oligodendroglioma patients,encoded value,0= 1p/19q intact  ,1= 1p/19q codeleted,blank=not abstracted,,,,,,,,,,
idhmut,IDH mutation status ,encoded value,1=mutated,0=wildtype, 9=unknown,,,,,,,,,,
```


```
cut -d, -f9 CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | sort | uniq -c
  count dxgroup
    209 1A   newly diagnosed GBM
     21 1B   newly diagnosed IDH mutant grade 4 astrocytoma
    112 2    newly diagnosed lower grade glioma (lgg)
     81 3    recurrent lgg, still lgg at enrollment
     22 4    recurrent lgg, now grade 4 at enrollment
      1 5    newly diagnosed glioma, uncertain type

cut -d, -f10 CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | sort | uniq -c
  count grade
      2      missing/unknown grade
    116 2    tumor grade 2
     76 3    tumor grade 3
    252 4    tumor grade 4

cut -d, -f11 CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | sort | uniq -c
  count who2021
     46 1    Astrocytoma, IDH-mutant, CNS WHO grade 2
     31 2    Astrocytoma, IDH-mutant, CNS WHO grade 3
     43 3    Astrocytoma, IDH-mutant, CNS WHO grade 4
     19 4    Diffuse glioma with molecular features of glioblastoma, IDH-wildtype, WHO grade 4
      1 5    Giant cell glioblastoma, IDH-wildtype, WHO grade 4
      2 6    Glioblastoma, IDH- and histone H3-wildtype, WHO grade 4
    175 7    Glioblastoma, IDH-wildtype, CNS WHO grade 4
      6 8    Gliosarcoma, IDH-wildtype, CNS WHO grade 4
     66 9    Oligodendroglioma, IDH-mutant and 1p/19q codeleted, CNS WHO grade 2
     44 10   Oligodendroglioma, IDH-mutant and 1p/19q codeleted, CNS WHO grade 3
      5 13   Not in WHO 2021 Classification
      4 14   Other
      4 15   Diffuse midline glioma, H3 K27-altered, WHO grade 4

cut -d, -f12 CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | sort | uniq -c
  count pq
    336      not abstracted
      0 0    1p/19q intact
    110 1    1p/19q codeleted

cut -d, -f13 CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | sort | uniq -c
  count idhmut
    215 0   wildtype
    230 1   mutated
      1 9   unknown





cut -d, -f18 CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | sort | uniq -c
      1 deceased
    205 0    alive as of last follow up
    241 1    deceased

```







```
awk 'BEGIN{OFS=","}{split($2,a,"-");print a[1],$1"_"$2}' CIDR.fam | sort -t, -k1,1 | sed '1ishort,IID' > CIDR_ids.csv

join --header -t, CIDR_ids.csv CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | cut -d, -f2,4- | head -1 > CIDR_case_covariates.csv
join --header -t, CIDR_ids.csv CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | cut -d, -f2,4- | tail -n +2 | sort -t, -k1,1 >> CIDR_case_covariates.csv

```


From Lucie

Hi Jake, yes we only abstracted the information for patients who were oligos. I would guess that the vast majority of the others can be assumed to be intact, but it is possible there are a few exceptions (we had a few tumors that were unusual). But for now, especially for the ones that could be diagnosed as an Astro or GBM, I think you can assume that is the case. Let me know if other questions come up.



##	20260212

merge with other covariates

CIDR_ids.csv CIDR_case_covariates.csv IPS_CIDR_446_RAD_TMZ_2025-10-10.csv CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv 


```bash
CIDR_case_covariates.csv

join --header -t, CIDR_ids.csv CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | head -1 > tmp1.csv
join --header -t, CIDR_ids.csv CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv | tail -n +2 | sort -t, -k3,3 >> tmp1.csv

join --header -t, -1 3 -2 1 tmp1.csv IPS_CIDR_446_RAD_TMZ_2025-10-10.csv  > tmp2.csv
cut -d, -f3- tmp2.csv > CIDR_case_covariates.20260212.csv
cat CIDR_case_covariates.20260212.csv | tr ',' '\t' > CIDR_case_covariates.20260212.tsv

```




