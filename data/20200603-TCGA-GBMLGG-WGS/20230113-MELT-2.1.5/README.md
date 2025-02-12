
#	MELT

https://melt.igs.umaryland.edu


##	CloudMELT

Cloud MELT is a modified version of MELT designed to be run on AWS.
It looks overcomplicated and uses CWL to control the workflow.

https://genome.cshlp.org/content/31/12/2225.long

https://github.com/Scott-Devine/CloudMELT


##	Trial run

Trial run of the standard version of MELT.






MELT_1_array_wrapper.bash
MELT_2.bash
MELT_3_array_wrapper.bash
MELT_4.bash










#####












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






Failures

```
-r--r----- 1 gwendt francislab  261350 Dec  4 18:52 HT-7472-01A-11D-2022.ALU.tsv
-r--r----- 1 gwendt francislab 1085820 Dec  4 18:56 FG-7636-10A-01D-2088.ALU.tsv
-r--r----- 1 gwendt francislab 1402941 Dec  4 18:57 FG-6689-01A-11D-1891.ALU.tsv
-r--r----- 1 gwendt francislab 1308773 Dec  4 18:57 HT-7468-01A-11D-2022.ALU.tsv
```









##	Analyze (testing)



```
module load bcftools

./create_AF_tables.bash 
```


```
./merge_AF_tables.py --output allele_frequencies.csv.gz *.combined.tsv
gunzip -k allele_frequencies.csv.gz
```


CHR	POS	MEI Type	1kGP2504_AF	1kGP698_AF	Amish_AF	JHS_AF	GTEx100bp_AF	GTEx150bp_AF	UKBB50k_AF	LGG-01_AF	LGG-02_AFLGG-10_AF	GBM-01_AF	GBM-02_AF	GBM-10_AF

```
awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){c=0;for(i=4;i<=NF;i++){if($i!=".")c+=1};if(c>6)print}' allele_frequencies.csv > allele_frequencies.common.csv

awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if($13>=0.25 || $16>=0.25)print}' allele_frequencies.csv > allele_frequencies.tcga_normal.csv

awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){c=0;for(i=4;i<=NF;i++){if($i!=".")c+=1};if(c>6)print}' allele_frequencies.tcga_normal.csv > allele_frequencies.tcga_normal.shared.csv

awk 'BEGIN{OFS=FS="\t"}(NR==1){print}(NR>1){if(( $11!=".") && ($4>=0.05 || $5>=0.05 || $6>=0.05 || $7>=0.05 || $8>=0.05 || $9>=0.05 || $10>=0.05))print}' allele_frequencies.csv > allele_frequencies.control0.05.csv
```






