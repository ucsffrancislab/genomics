
#	gencodegenes.org/release_25

https://www.gencodegenes.org/human/release_25.html


These may be my go to reference set


```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_25/GRCh38.primary_assembly.genome.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_25/gencode.v25.primary_assembly.annotation.gtf.gz
```


Make STAR references


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL   --job-name="STARgenerate" \
 --time=10080 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STARgenerate.log --export=None \
 --wrap="module load star/2.7.7a && STAR --runThreadN 64 --runMode genomeGenerate \
  --genomeFastaFiles ${PWD}/GRCh38.primary_assembly.genome.fa \
  --sjdbGTFfile ${PWD}/gencode.v25.primary_assembly.annotation.gtf \
  --genomeDir ${PWD}/GRCh38.primary_assembly.genome"
```





This is essentially only for TEProF2 comparison.

