
#	MELT

https://melt.igs.umaryland.edu



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



