


https://github.com/VistaSohrab/TEfinder

https://github.com/ucsffrancislab/TEfinder




```
faSplit byname hg38.fa chromosomes/
for c in $( seq 1 22 ) X Y Un ; do
cat chromosomes/chr${c}.fa
cat chromosomes/chr${c}_*.fa
done > hg38.resorted.fa

awk 'BEGIN{FS=OFS="\t"}{s=substr($1,4); split(s,d,"_"); c=d[1]; if(c=="X")c=23; if(c=="Y")c=24; if(c=="Un")c=25; print c,s,$1,$2,$3,$4,$5,$6,$7,$8,$9}' hg38_rmsk_LTR.gtf | sort -k1n,1 -k2,2 -k6n,6 | awk 'BEGIN{FS=OFS="\t"}{print $3,$4,$5,$6,$7,$8,$9,$10,$11}' > hg38_rmsk_LTR.resorted.gtf

```


Oddly, the output IS NOT sorted the same way

```
awk -F '\t' '{print $9}' /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_LTR.resorted.gtf | awk -F '"' '{print $2}' | grep ERV | sort | uniq > hg38_rmsk_LTR.ERV.txt

```




```

for bam in /francislab/data1/raw/20200909-TARGET-ALL-P2-RNA_bam/bam/10-PAUB*bam ; do
  base=$( basename $bam .bam )
  sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=${base} --time=1440 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab /francislab/data1/refs/singularity/TEfinder.img TEfinder -threads 16 -alignment ${bam} -fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.resorted.fa -gtf /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_LTR.resorted.gtf -te ${PWD}/hg38_rmsk_LTR.ERV.txt -workingdir ${PWD}/${base} -alreadySorted -maxHeapMem 100000"
done

```



10-PAUBRD-09A-01R running on n1 is taking forever. Not sure if its the sample or the node.


