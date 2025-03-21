
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

./vcf2genotypes.bash

./genotype_diffs.bash

dir=vcfallq60region
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


./merge_genotype_diffs.bash 


zcat merged_genotype_diffs.region.tsv.gz > merged_genotype_diffs.region.tsv


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl  --silent --ftp-create-dirs -netrc -T primary_recurrent_pairs_region_difference_counts_comparison.tsv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T primary_recurrent_pairs_difference_counts.tsv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T merged_genotype_diffs.region.tsv.gz "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T merged_genotype_diffs.region.tsv "${BOX}/"


awk 'BEGIN{FS=OFS="\t"}{s=0;for(i=4;i<=NF;i++){s+=$i};if(s>200)print $1,$2,$3,s}' merged_genotype_diffs.region.tsv | sort -k4n | tail -n 20

chr11 48367387 C/T->C/C 205
chrX 114425210 G/A->G/G 210
chr11 56468021 G/G->G/A 214
chr1 120612154 C/C->C/G 221
chr1 120612163 C/C->C/A 222
chrX 114425210 G/G->G/A 225
chr11 56468021 G/A->G/G 234
chr1 145112414 T/C->T/T 239
chr1 145112428 C/T->C/C 254


awk 'BEGIN{FS=OFS="\t"}{s=0;for(i=4;i<=NF;i++){s+=$i};c[$1][$2]+=s}END{for(i in c){for(j in c[i]){print i,j,c[i][j]}}}' merged_genotype_diffs.region.tsv | sort -k3n | tail -n 20

chr11	6567907	273
chr17	21204257	274
chr11	48346822	276
chr11	48346843	283
chrX	52891645	287
chr11	56468694	294
chr7	100552338	294
chr1	145112414	295
chr11	56468699	299
chr11	56468704	302
chr19	4511491	309
chr17	21204308	311
chr1	120612154	313
chrX	114425181	313
chr1	120612163	320
chr11	48347419	334
chr1	145112428	344
chr11	48367387	344
chrX	114425210	444
chr11	56468021	448

awk 'BEGIN{FS=",";OFS="\t"}(NR==FNR){ a[$1"-"$2"-"$3"-"$5]=$6 }(NR!=FNR){ b[$1"-"$2"-"$3"-"$5]=$6 } END{ for(k in b){print k,a[k],b[k]} }' primary_recurrent_pairs_difference_counts.tsv primary_recurrent_pairs_region_difference_counts.tsv > primary_recurrent_pairs_region_difference_counts_comparison.tsv


```



```
./merge_select_genotypes.bash

zcat select_genotypes.tsv.gz > select_genotypes.tsv


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl  --silent --ftp-create-dirs -netrc -T select_genotypes.tsv.gz "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T select_genotypes.tsv "${BOX}/"

```





#	20230612


```
grep -h -vs "\./\." MELT.Compare/*.*.*.*.genotype_diffs | awk '{print $1"\t"$2}' | sort -k1,1 -k2n | uniq > MELT_genotype_diff_positions.txt


for gd in MELT.Compare/*.genotype_diffs ; do
echo $gd
sed 's/[[:space:]]\+/\t/g' ${gd} | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4,$5"->"$11}' > ${gd}.tsv
done


for alu in MELT.Compare/*.*.*.ALU.genotype_diffs.tsv ; do
echo ${alu}
line1=${alu/.ALU./.LINE1.}
sva=${alu/.ALU./.SVA.}
all=${alu/.ALU./.ALL.}
cat ${alu} ${line1} ${sva} > ${all}
done


./merge_melt_genotype_diffs.py -o merged_normal_tumor_melt.csv MELT.Compare/*.ALL.genotype_diffs.tsv

awk 'BEGIN{FS=OFS="\t"}{c=0;for(i=5;i<=NF;i++){if($i~/->/){c+=1}}print $1,$2,$3,$4,c}' merged_normal_tumor_melt.csv > merged_normal_tumor_melt.mutation_counts.csv

awk 'BEGIN{FS=OFS="\t"}{c=0;for(i=5;i<=NF;i++){if(($i~/->/)&&($i!~/\./)){c+=1}}print $1,$2,$3,$4,c}' merged_normal_tumor_melt.csv > merged_normal_tumor_melt.nondot_mutation_counts.csv

sort -k5nr merged_normal_tumor_melt.nondot_mutation_counts.csv | head -20

chr17	78056052	G	<INS:ME:ALU>	391
chr10	105817214	C	<INS:ME:ALU>	336
chr19	9490504	G	<INS:ME:ALU>	319
chr16	89291389	G	<INS:ME:ALU>	317
chr13	111076811	T	<INS:ME:ALU>	313
chr2	11426375	T	<INS:ME:ALU>	309
chr1	93167530	T	<INS:ME:ALU>	306
chr5	78426549	C	<INS:ME:ALU>	304
chr3	56604955	T	<INS:ME:ALU>	294
chr13	45556073	A	<INS:ME:ALU>	280
chr8	68981808	T	<INS:ME:ALU>	275
chr7	82430525	T	<INS:ME:ALU>	274
chr1	112992009	T	<INS:ME:ALU>	262
chr8	42039906	T	<INS:ME:ALU>	262
chr4	42088056	T	<INS:ME:ALU>	254
chr18	74638701	T	<INS:ME:ALU>	248
chr17	72620217	C	<INS:ME:ALU>	246
chr7	157448787	T	<INS:ME:ALU>	246
chr7	76870796	C	<INS:ME:ALU>	244
chr3	50879175	T	<INS:ME:ALU>	242





BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl  --silent --ftp-create-dirs -netrc -T merged_normal_tumor_melt.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T merged_normal_tumor_melt.mutation_counts.csv "${BOX}/"
curl  --silent --ftp-create-dirs -netrc -T merged_normal_tumor_melt.nondot_mutation_counts.csv "${BOX}/"

```




##	20240522 - at Geno's request



```

echo "sample,chr10:129766800,chr12:109222793,chr3:52373789,chr8:11564661,chr6:31664357" > output.csv
for vcf in vcfallq60/*.vcf.gz ; do 
echo -n $( basename ${vcf} .vcf.gz )
for region in chr10:129766800 chr12:109222793 chr3:52373789 chr8:11564661 chr6:31664357 ; do
line=$( bcftools view --no-header ${vcf} ${region} | awk '{gsub(/0/,$4,$NF);gsub(/1/,$5,$NF);print $NF}' )
echo -n ",${line}"
done ; echo ; done >> output.csv

```

Those were hg38 coordinates, but these vcfs were created from hg19.

chr10	131565064	.	A	G	203.417	.	DP=13;VDB=0.90784;SGB=-0.683931;MQSBZ=0;FS=0;MQ0F=0;AC=2;AN=2;DP4=0,0,11,2;MQ=60	GT:PL	1/1:233,39,0


```

echo "sample,chr10:131565064,chr12:109660598,chr3:52407805,chr8:11422170,chr6:31632134" > hg19.csv
for vcf in vcfallq60/*.vcf.gz ; do 
echo -n $( basename ${vcf} .vcf.gz )
for region in chr10:131565064 chr12:109660598 chr3:52407805 chr8:11422170 chr6:31632134 ; do
line=$( bcftools view --no-header ${vcf} ${region} | awk '{split($NF,a,":");gt=a[1];gsub(/0/,$4,gt);gsub(/1/,$5,gt);print gt}' )
echo -n ",${line}"
done ; echo ; done >> hg19.csv &

```

