
#	MELT

https://melt.igs.umaryland.edu



This time with bwa, instead of bowtie2, aligned data.


And with a priors list as well.

Better priors list with actualy REF and INFO data





Prior runs were the multi-step MELT-SPLIT.

```
ll ../20221129-MELT-2.2.2/out/*VCF/*vcf.gz
```



To simplify things, I'm trying MELT-SINGLE to compare.


```
java -Xmx6G -jar /MELT/MELTv2.2.2.jar Single \
	-t transposon.txt \
	-h /pwd/hg38.chrXYM_alts.fa \
	-n /pwd/MELT/add_bed_files/Hg38/Hg38.genes.bed \
	-bamfile /pwd/DU-6542-10A-01D-1891.bam \
	-w /pwd/DU-6542-10A-01D-1891-prior/





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





```
awk 'BEGIN{FS=OFS="\t"} (NR==1){print "CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO";next} ($3=="SVA"){print "chr"$1,$2,".","N",".",".","PASS","."}' ~/.local/MELTv2.2.2/me_refs/Hg38/Supplemental_Table_S1_A.tsv > ~/.local/MELTv2.2.2/me_refs/Hg38/Supplemental_Table_S1_A.SVA.vcf
```



