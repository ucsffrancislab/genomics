
#	MELT

https://melt.igs.umaryland.edu


##	CloudMELT

Cloud MELT is a modified version of MELT designed to be run on AWS.
It looks overcomplicated and uses CWL to control the workflow.

https://genome.cshlp.org/content/31/12/2225.long

https://github.com/Scott-Devine/CloudMELT


Given that I am finding differences between versions of MELT and aligner and 
as we are intending to compare these results to CloudMELTs output, we should use what they used.
They used MELT 2.1.5(fast) SPLIT.


##	Prep


Many filenames are duplicated so need to link to dirname and filename as filename.


```
mkdir in
for f in /costellolab/data3/jocostello/LG3/exomes_recal/*/*.bwa.realigned.rmDups.recal.bam ;do
b=$( basename $f .bwa.realigned.rmDups.recal.bam )
d=$( basename $( dirname $f ))
echo $f
echo $b
echo $d
if [ -s $f ] ; then
ln -s $f in/${d}.${b}.bam
ln -s $f.bai in/${d}.${b}.bam.bai
fi
done
```


Oddities

```
\rm in/PatientWU1.K00001.bam.bai
ln -s /costellolab/data3/jocostello/LG3/exomes_recal/PatientWU1/K00001.bwa.realigned.rmDups.recal.bai in/PatientWU1.K00001.bam.bai
\rm in/PatientWU1.K00002.bam.bai
ln -s /costellolab/data3/jocostello/LG3/exomes_recal/PatientWU1/K00002.bwa.realigned.rmDups.recal.bai in/PatientWU1.K00002.bam.bai
\rm in/PatientWU1.K00003.bam.bai
ln -s /costellolab/data3/jocostello/LG3/exomes_recal/PatientWU1/K00003.bwa.realigned.rmDups.recal.bai in/PatientWU1.K00003.bam.bai
```



MELT_1_array_wrapper.bash
MELT_2.bash
MELT_3_array_wrapper.bash
MELT_4.bash



Something is WAY off with GBM02.Z00384.bam.
mosdepth only returns 0.01 and its real fast.
Doesn't match the file size.
I copied CloudMELT's command.






##	Analyze (testing)


```
vcf_reference_check.bash out/DISCOVERYVCF/SVA.final_comp.vcf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa
22	267	0.082397


vcf_reference_check.bash out/DISCOVERYVCF/LINE1.final_comp.vcf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa
10181	36643	0.277843

vcf_reference_check.bash out/DISCOVERYVCF/ALU.final_comp.vcf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/20200117/hg19.chrXYMT_alts.fa
11295	35637	0.316946
```


```
correct_vcf_reference_values.bash out/DISCOVERYVCF/SVA.final_comp.vcf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.chrXYMT_alts.fa | gzip > out/DISCOVERYVCF/SVA.final_comp.corrected.vcf.gz

correct_vcf_reference_values.bash out/DISCOVERYVCF/LINE1.final_comp.vcf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.chrXYMT_alts.fa | gzip > out/DISCOVERYVCF/LINE1.final_comp.corrected.vcf.gz

correct_vcf_reference_values.bash out/DISCOVERYVCF/ALU.final_comp.vcf.gz /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.chrXYMT_alts.fa | gzip > out/DISCOVERYVCF/ALU.final_comp.corrected.vcf.gz

```


```
module load picard

picard CreateSequenceDictionary \
	R=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa \
	O=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.dict

for vcf in out/DISCOVERYVCF/*final_comp.corrected.vcf.gz ; do
echo $vcf
picard LiftoverVcf I=${vcf} O=${vcf%.vcf.gz}.hg38.vcf.gz CHAIN=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz R=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa REJECT=${vcf%.vcf.gz}.hg38.rejected.vcf.gz
done >> liftover.log 2>&1 &

```







```
module load bcftools

./create_AF_tables.bash 
```




```
ln -s /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230202-bwa-MELT-2.1.5-SPLIT/allele_frequencies.csv tcga.allele_frequencies.csv
```











WAIT UNTIL THE RERUN HAS COMPLETED








merge with the TCGA run.
```
./merge_AF_tables.py --output allele_frequencies.csv *.combined.tsv

vi allele_frequencies.csv
```


```
head -1 allele_frequencies.csv 

CHR	POS	MEI Type	1kGP2504_AF	1kGP698_AF	Amish_AF	JHS_AF	GTEx100bp_AF	GTEx150bp_AF	UKBB50k_AF	BT2_LGG-01_AF	BT2_LGG-02_AF	BT2_LGG-10_AF	BT2_GBM-01_AF	BT2_GBM-02_AF	BT2_GBM-10_AF	BWA_LGG-01_AF	BWA_LGG-02_AF	BWA_LGG-10_AF	BWA_GBM-01_AF	BWA_GBM-02_AF	BWA_GBM-10_AF	Normal-npr_AF	Normal-tn_AF	Primary-npr_AF	Recurrent-npr_AF	Tumor-tn_AF	Unset-npr_AF	Unset-tn_AF
```



```
cat allele_frequencies.csv | gzip > allele_frequencies.csv.gz
```


##	Share

```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in out/*VCF/*vcf.gz allele_frequencies.csv allele_frequencies.csv.gz ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```



```

awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if(( $11!=".") && ($4>=0.05 || $5>=0.05 || $6>=0.05 || $7>=0.05 || $8>=0.05 || $9>=0.05 || $10>=0.05))print}' allele_frequencies.csv > allele_frequencies.control0.05.csv
# OR
awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if(($4>=0.05 || $5>=0.05 || $6>=0.05 || $7>=0.05 || $8>=0.05 || $9>=0.05 || $10>=0.05))print}' allele_frequencies.csv > allele_frequencies.control0.05.csv

awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if( ($11>=0.05 || $12>=0.05 || $13>=0.05 || $14>=0.05 || $15>=0.05 || $16>=0.05 ))print}' allele_frequencies.csv > allele_frequencies.tcgabt20.05.csv

awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if( ($17>=0.05 || $18>=0.05 || $19>=0.05 || $20>=0.05 || $21>=0.05 || $22>=0.05 ))print}' allele_frequencies.csv > allele_frequencies.tcgabwa0.05.csv


awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){ if(( $11!=".") && ( $17!=".")){ c=0;for(i=4;i<=10;i++){if($i!=".")c+=1};if(c>0)print }}' allele_frequencies.csv > allele_frequencies.shared.csv
```




```
./bam2vcf.bash

nohup ./file_check.bash > patient_ID_conversions.2022.exists.tsv &

(head -1 Covariates.csv && tail -n +2 Covariates.csv | tr -d "\r" | sort -t , -k2,2 ) > Covariates.sorted.csv 

(head -1 patient_ID_conversions.2022.exists.tsv && tail -n +2 patient_ID_conversions.2022.exists.tsv | sort -k3,3 ) | tr "\t" , > patient_ID_conversions.2022.exists.sorted.csv

join --header -t , -1 3 -2 2 -a 1 patient_ID_conversions.2022.exists.sorted.csv Covariates.sorted.csv > patient_ID_conversions.2022.exists.covariates.sorted.csv



for i in 9 10 12 13 15 16 18 19 21 22 24 25 ; do
awk -F"\t" -v c=$i '(NR>1){split($c,a,"");asort(a);s="";for(i in a){s=s""a[i]};print s}' patient_ID_conversions.2022.exists.tsv | sed 's/\///g' > $i
done

for i in 9 12 15 18 21 24 ; do
sdiff -s <(cat -n ${i}) <(cat -n $[i+1])
done


```

```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.shared.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.control0.05.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.tcgabt20.05.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.tcgabwa0.05.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.csv.gz "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T patient_ID_conversions.2022.exists.tsv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T patient_ID_conversions.2022.exists.covariates.sorted.csv "${BOX}/"
```



```
#for v in vcf/*vcf.gz ; do echo $v; row=$( bcftools view -H -r chr2:209113112-209113112 $v ); if [ -z "$row" ]; then echo "./."; else echo $row | awk '{gt=$NF;split(gt,gta,":");gsub(/0/,$4,gta[1]);gsub(/1/,$5,gta[1]);print gta[1]}'; fi ; done
```




##	Analysis

Compare tumor normal differences in MELT calls.

```
./extract_tumor_normal_pairs.py patient_ID_conversions.2022.exists.covariates.sorted.csv 

nohup ./compare.bash &
```

```
dir=MELT.Compare
while read patient normal tumor ; do
echo "$patient - $normal - $tumor"
for mei in ALU LINE1 SVA ; do
n=${dir}/${patient}.${normal}.${mei}.genotypes
t=${dir}/${patient}.${tumor}.${mei}.genotypes
if [ -f ${n} ] && [ -f ${t} ] ; then
sdiff -s ${n} ${t} > ${dir}/${patient}.${normal}.${tumor}.${mei}.genotype_diffs
fi
done
done < <( tail -n +2 tumor_normal_pairs.tsv )
```


Extracting genotypes from standard vcfs (takes quite a while)

```
./vcf2genotypes.bash 
```


```
dir=vcfallq60
while read patient normal tumor ; do
echo "$patient - $normal - $tumor"
n=${dir}/${patient}.${normal}.genotypes.gz
t=${dir}/${patient}.${tumor}.genotypes.gz
if [ -f ${n} ] && [ -f ${t} ] ; then
sdiff -s <( zcat ${n} ) <( zcat ${t} ) > ${dir}/${patient}.${normal}.${tumor}.genotype_diffs
fi
done < <( tail -n +2 tumor_normal_pairs.tsv | head -1 )
```





the libraries with IDs starting with X where produced using interval list

/home/jocostello/shared/LG3_Pipeline_HIDE/resources/xgen-exome-research-panel-targets_6bpexpanded.interval_list


and starting with Z

/home/jocostello/shared/LG3_Pipeline_HIDE/resources/SeqCap_EZ_Exome_v3_capture.interval_list


and older libraries starting with A

/home/jocostello/shared/LG3_Pipeline_HIDE/resources/Agilent_SureSelect_HumanAllExon50Mb.interval_list

/home/jocostello/shared/LG3_Pipeline_HIDE/resources/Agilent_SureSelect_HumanAllExonV4.interval_list

/home/jocostello/shared/LG3_Pipeline_HIDE/resources/Agilent_SureSelect_HumanAllExonV5.interval_list



```

./extract_primary_recurrent_pairs.py patient_ID_conversions.2022.exists.covariates.sorted.csv 


dir=vcfallq60
while read patient normal primary recurrent ; do
p=${dir}/${patient}.${normal}.${primary}.regions.genotype_snp_diffs.tsv
r=${dir}/${patient}.${normal}.${recurrent}.regions.genotype_snp_diffs.tsv
if [ -f ${p} ] && [ -f ${r} ] ; then
pc=$( tail -n +2 ${p} | wc -l )
rc=$( tail -n +2 ${r} | wc -l )
dc=$[rc-pc]
echo "${patient},${normal},${primary},${pc},${recurrent},${rc},${dc}"
fi
done < <( tail -n +2 primary_recurrent_pairs.tsv ) > primary_recurrent_pairs_difference_counts.tsv
```

```

./bed_intersection.bash




