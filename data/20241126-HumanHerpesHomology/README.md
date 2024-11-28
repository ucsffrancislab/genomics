
#	20241126-HumanHerpesHomology



Prep

```
module load blast

zcat /francislab/data1/refs/sources/gencodegenes.org/release_47/GRCh38.p14.genome.fa.gz | makeblastdb -title GRCh38.p14.genome -out GRCh38.p14.genome -dbtype nucl -parse_seqids 

zcat /francislab/data1/refs/sources/gencodegenes.org/release_47/gencode.v47.pc_translations.fa.gz | sed '/>/s/|.*$//' | makeblastdb -title gencode.v47 -out gencode.v47 -dbtype prot -parse_seqids 

#zcat /francislab/data1/refs/refseq/mRNA_Prot-20241119/human.*.protein.faa.gz | makeblastdb -title human.protein -out human.protein -dbtype prot -parse_seqids 

zcat /francislab/data1/refs/refseq/mRNA_Prot-20241119/human.*.protein.faa.gz | sed -e '/^>/s/[],:\(\)\/'' []/_/g' -e '/^>/s/\(^.\{1,51\}\).*/\1/' | makeblastdb -title human.protein -out human.protein -dbtype prot -parse_seqids 

zcat /francislab/data1/refs/refseq/viral-20241126/viral.1.1.genomic.fna.gz | sed -e '/^>/s/[],:\(\)\/'' []/_/g' | awk '( /^>/ ){ if( /Human/ && /herpes/ ){hh=1;print}else{hh=0} } (!/^>/){ if( hh==1 ){print} }' > human_herpes_genomes.fna

zcat /francislab/data1/refs/refseq/viral-20241126/viral.1.protein.faa.gz | sed -e '/^>/s/[],:\(\)\/'' []/_/g' | awk '( /^>/ ){ if( /Human/ && /herpes/ ){hh=1;print}else{hh=0} } (!/^>/){ if( hh==1 ){print} }' > human_herpes_proteins.faa

```




```
for word_size in 06 07 08 09 10 11 12 ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHG${word_size} --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHG${word_size}.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out HumanHerpesHomologyGenome.ws${word_size}.tsv -word_size ${word_size} -outfmt 6 -query human_herpes_genomes.fna"
done

for word_size in 2 3 4 5 6 ; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHPR${word_size} --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHPR${word_size}.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastp -db human.protein -out HumanHerpesHomologyRefseq.ws${word_size}.tsv -word_size ${word_size} -outfmt 6 -query human_herpes_proteins.faa"
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHPG${word_size} --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHPG${word_size}.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastp -db gencode.v47 -out HumanHerpesHomologyGencode.ws${word_size}.tsv  -word_size ${word_size} -outfmt 6 -query human_herpes_proteins.faa"
done
```


```
for f in HumanHerpesHomology*.ws?.tsv HumanHerpesHomology*.ws??.tsv ; do
awk '($12>60)' ${f} > ${f%.tsv}.bs60.tsv
done
```


sed -i '1s/^.+$/qaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore/' ${f}
```
for f in HumanHerpesHomology*.tsv ; do
sed -i '1iqaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore' ${f}
done
```

