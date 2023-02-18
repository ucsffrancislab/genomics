
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




MELT_1_array_wrapper.bash
MELT_2.bash
MELT_3_array_wrapper.bash
MELT_4.bash



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
gzip allele_frequencies.csv
```







```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl  --silent --ftp-create-dirs -netrc -T allele_frequencies.csv.gz "${BOX}/"
```







