
#	MELT

https://melt.igs.umaryland.edu


##	CloudMELT

Cloud MELT is a modified version of MELT designed to be run on AWS.
It looks overcomplicated and uses CWL to control the workflow.

https://genome.cshlp.org/content/31/12/2225.long

https://github.com/Scott-Devine/CloudMELT


##	Trial run

Trial run of the standard version of MELT.


###	Example from manual

7.4.6. Example MELT-SPLIT Workflow

As a simulated example to demonstrate MELT-SPLIT based MEI discovery, suppose we have sequenced four human individuals (Person1.sorted.bam, Person2.sorted.bam, Person3.sorted.bam, Person4.sorted.bam) to approximately 30x coverage. We then used bwa-mem to align them to the Hg19 human reference sequence. We now want to know if they have any LINE1 non-reference Mobile Element Insertions. We first want to run Preprocess on all four samples to ensure MELT has the proper information to discover MEIs:

```
java -Xmx2G -jar MELT.jar Preprocess /path/to/Person1.sorted.bam

java -Xmx2G -jar MELT.jar Preprocess /path/to/Person2.sorted.bam

java -Xmx2G -jar MELT.jar Preprocess /path/to/Person3.sorted.bam

java -Xmx2G -jar MELT.jar Preprocess /path/to/Person4.sorted.bam
```

Next, we want to do initial MEI site discovery in all 4 genomes (only required options shown):

```
java -Xmx6G -jar MELT.jar IndivAnalysis \
    -bamfile /path/to/Person1.sorted.bam \
    -w ./LINE1DISCOVERY/ \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa;

java -Xmx6G -jar MELT.jar IndivAnalysis \
    -bamfile /path/to/Person2.sorted.bam \
    -w ./LINE1DISCOVERY/ \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa;

java -Xmx6G -jar MELT.jar IndivAnalysis \
    -bamfile /path/to/Person3.sorted.bam \
    -w ./LINE1DISCOVERY/ \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa;

java -Xmx6G -jar MELT.jar IndivAnalysis \
    -bamfile /path/to/Person4.sorted.bam \
    -w ./LINE1DISCOVERY/ \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa;
```

Next, we want to combine the initial discovery across these four genomes into a single piece of information to aid genotyping and filtering of false positive hits:

```
java -Xmx4G -jar MELT.jar GroupAnalysis \
    -discoverydir ./LINE1DISCOVERY/ \
    -w ./LINE1DISCOVERY/ \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa \
    -n /path/to/human_annotation.bed;
```

Next, we will genotype each of the samples using the merged MEI information file:

```
java -Xmx2G -jar MELT.jar Genotype \
    -bamfile /path/to/Person1.sorted.bam \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa \
    -w ./LINE1DISCOVERY/ \
    -p ./LINE1DISCOVERY/;

java -Xmx2G -jar MELT.jar Genotype \
    -bamfile /path/to/Person2.sorted.bam \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa \
    -w ./LINE1DISCOVERY/ \
    -p ./LINE1DISCOVERY/;

java -Xmx2G -jar MELT.jar Genotype \
    -bamfile /path/to/Person3.sorted.bam \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human_reference.fa \
    -w ./LINE1DISCOVERY/ \
    -p ./LINE1DISCOVERY/;

java -Xmx2G -jar MELT.jar Genotype \
    -bamfile /path/to/Person4.sorted.bam \
    -t /path/to/LINE_MELT.zip \
    -h /path/to/human\_reference.fa \
    -w ./LINE1DISCOVERY/ \
    -p ./LINE1DISCOVERY/;
```

Finally, we provide the genotyping directory from Genotype (as -genotypingdir) to MakeVCF to generate the final VCF file:

```
java -Xmx2G -jar MELT.jar MakeVCF \
    -genotypingdir ./LINE1DISCOVERY/ \
    -h /path/to/human_reference.fa \
    -t /path/to/LINE_MELT.zip \
    -w ./LINE1DISCOVERY/ \
    -p ./LINE1DISCOVERY/LINE1.pre_geno.tsv;
```

This will result in a final VCF file in the directory provided to -o, or by default in your current directory: ./LINE1.final_comp.vcf.



###	Testing

Poor syntax in example above

Looks like references can't be gzipped or bgzipped.

Any way to control thread count?




####	Step 1 Preprocess + IndivAnalysis



```
module load CBI samtools/1.13 bowtie2/2.4.4 

java -Xmx2G -jar ~/.local/MELTv2.2.2/MELT.jar Preprocess \
  -bamfile /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/TQ-A8XE-10A-01D-A367.bam \
  -h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa


Start time: Nov 29, 2022 9:13:58 AM

Performing MELT analysis...
All BAM Reference sequences are present in the provided reference.
Total reads processed     : 714755979
Total proper pairs        : 682142522
Supp reads filtered       : 0
Percent discordant        : 0.89
Total MC/MQ Discordant Reads   : 0
Percent MC/MQ Discordant Reads : 0
BAM has within the expected tolerance for improper pairs, safe to proceed with MELT analysis.
MC & MQ tags NOT detected in original bam file. This may result in substantially longer runtimes.
End time: Nov 29, 2022 9:59:17 AM
```

Creates 
```
.fq
.disc.bam.bai
.disc
```
in source dir. Perhaps best to create working dir with links to source bam/bai







```
module load CBI samtools/1.13 bowtie2/2.4.4 
java -Xmx6G -jar ~/.local/MELTv2.2.2/MELT.jar IndivAnalysis \
  -bamfile /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/TQ-A8XE-10A-01D-A367.bam \
  -h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
  -t ~/.local/MELTv2.2.2/me_refs/Hg38/LINE1_MELT.zip \
  -w ./LINE1DISCOVERY/


Start time: Nov 29, 2022 10:51:01 AM

Performing MELT analysis...

MQ and MC SAM tags NOT detected in original bam file... This may result in substantially longer runtimes..!
Calculated Coverage: 51.56297999999871

End time: Nov 29, 2022 11:32:03 AM
```






####	Step 2 GroupAnalysis

Not sure if this is the correct bed
Not sure if -discoverydir and -w should be the same

```
module load CBI samtools/1.13 bowtie2/2.4.4 
java -Xmx4G -jar ~/.local/MELTv2.2.2/MELT.jar GroupAnalysis \
  -discoverydir ${PWD}/out/LINE1DISCOVERY/ \
  -w ${PWD}/out/LINE1DISCOVERYGROUP/ \
  -t ~/.local/MELTv2.2.2/me_refs/Hg38/LINE1_MELT.zip \
  -h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
  -n ~/.local/MELTv2.2.2/add_bed_files/Hg38/Hg38.genes.bed

Command Line:
MELT.jar GroupAnalysis -discoverydir /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20221129-MELT/out/LINE1DISCOVERY/ -w /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20221129-MELT/out/LINE1DISCOVERYWORK/ -t /c4/home/gwendt/.local/MELTv2.2.2/me_refs/Hg38/LINE1_MELT.zip -h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa -n /c4/home/gwendt/.local/MELTv2.2.2/add_bed_files/Hg38/Hg38.genes.bed 

Start time: Nov 30, 2022 7:07:50 AM

Performing MELT analysis...
Records Analyzed : 2500
Records Analyzed : 5000
Records Analyzed : 7500
End time: Nov 30, 2022 8:04:21 AM

Wed Nov 30 08:04:21 PST 2022
```








####	Step 3 GenoType

```
java -Xmx2G -jar ~/.local/MELTv2.2.2/MELT.jar Genotype \
	-bamfile ${outbase}.bam \
	-t ~/.local/MELTv2.2.2/me_refs/Hg38/LINE1_MELT.zip \
	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
	-w ${OUT}/LINE1DISCOVERYGENO/ \
	-p ${OUT}/LINE1DISCOVERYGROUP/
```


####	Step 4 MakeVCF


```
java -Xmx4G -jar ~/.local/MELTv2.2.2/MELT.jar MakeVCF \
	-genotypingdir ${OUT}/LINE1DISCOVERYGENO/ \
	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
	-t ~/.local/MELTv2.2.2/me_refs/Hg38/LINE1_MELT.zip \
	-w ${OUT}/LINE1DISCOVERYVCF/ \
	-p ${OUT}/LINE1DISCOVERYGROUP/	#LINE1.pre_geno.tsv

#	Add ...?
# -o <arg>               Output directory for final VCF files. Will be in the form of -o/<MEI_NAME>.final_comp.vcf. [./].

```



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




