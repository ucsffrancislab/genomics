
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
b=$(basename $f .bwa.realigned.rmDups.recal.bam)
d=$( basename $( dirname $f ))
echo $f
echo $b
echo $d
#ln -s $f in/${d}.${b}.bam
ln -s $f.bai in/${d}.${b}.bam.bai
done
```


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







---





##	Share

```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in out/*VCF/*vcf.gz ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




##	Analyze (testing)



```
module load bcftools

./create_AF_tables.bash 
```


merge with the bowtie2 run.
```
./merge_AF_tables.py --output allele_frequencies.csv *.combined.tsv

vi allele_frequencies.csv
```


```
CHR	POS	MEI Type	1kGP2504_AF	1kGP698_AF	Amish_AF	JHS_AF	GTEx100bp_AF	GTEx150bp_AF	UKBB50k_AF	LGG-01_AF	LGG-02_AFLGG-10_AF	GBM-01_AF	GBM-02_AF	GBM-10_AF
```









```
#awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){c=0;for(i=4;i<=NF;i++){if($i!=".")c+=1};if(c>6)print}' allele_frequencies.csv > allele_frequencies.common.csv
#
#awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if($13>=0.25 || $16>=0.25)print}' allele_frequencies.csv > allele_frequencies.tcga_normal.csv
#
#awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){c=0;for(i=4;i<=NF;i++){if($i!=".")c+=1};if(c>6)print}' allele_frequencies.tcga_normal.csv > allele_frequencies.tcga_normal.shared.csv
#
#awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if(( $11!=".") && ($4>=0.05 || $5>=0.05 || $6>=0.05 || $7>=0.05 || $8>=0.05 || $9>=0.05 || $10>=0.05))print}' allele_frequencies.csv > allele_frequencies.control0.05.csv
```


```
CHR	POS	MEI Type	 (1-3)
1kGP2504_AF	1kGP698_AF	Amish_AF	JHS_AF	GTEx100bp_AF	GTEx150bp_AF	UKBB50k_AF	(4-10)
BT2_LGG-01_AF	BT2_LGG-02_AF	BT2_LGG-10_AF	BT2_GBM-01_AF	BT2_GBM-02_AF	BT2_GBM-10_AF (11-16)
BWA_LGG-01_AF	BWA_LGG-02_AF	BWA_LGG-10_AF	BWA_GBM-01_AF	BWA_GBM-02_AF	BWA_GBM-10_AF (17-22)
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
gzip allele_frequencies.csv
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
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.csv.gz "${BOX}/"
```







