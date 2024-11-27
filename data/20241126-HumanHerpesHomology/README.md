
#	20241126-HumanHerpesHomology



Prep

```
zcat /francislab/data1/refs/sources/gencodegenes.org/release_47/GRCh38.p14.genome.fa.gz | makeblastdb -title GRCh38.p14.genome -out GRCh38.p14.genome -dbtype nucl -parse_seqids 

zcat /francislab/data1/refs/sources/gencodegenes.org/release_47/gencode.v47.pc_translations.fa.gz | sed '/>/s/|.*$//' | makeblastdb -title gencode.v47 -out gencode.v47 -dbtype prot -parse_seqids 

zcat /francislab/data1/refs/refseq/mRNA_Prot-20241119/human.*.protein.faa.gz | makeblastdb -title human.protein -out human.protein -dbtype prot -parse_seqids 

#zcat viral.protein.faa.gz | sed '/^>/s/\(^.\{1,51\}\).*/\1/' | makeblastdb -input_type fasta -dbtype prot -title viral.protein -parse_seqids -out viral.protein

zcat /francislab/data1/refs/refseq/viral-20241126/viral.1.1.genomic.fna.gz | awk '( /^>/ ){ if( /Human/ && /herpes/ ){hh=1;print}else{hh=0} } (!/^>/){ if( hh==1 ){print} }' > human_herpes_genomes.fna

zcat /francislab/data1/refs/refseq/viral-20241126/viral.1.protein.faa.gz | awk '( /^>/ ){ if( /Human/ && /herpes/ ){hh=1;print}else{hh=0} } (!/^>/){ if( hh==1 ){print} }' > human_herpes_proteins.faa

```




```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHG06 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHG06.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out HumanHerpesHomologyGenome.ws06.tsv -word_size 6 -outfmt 6 -query human_herpes_genomes.fna"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHG08 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHG08.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out HumanHerpesHomologyGenome.ws08.tsv -word_size 8 -outfmt 6 -query human_herpes_genomes.fna"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHG10 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHG10.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out HumanHerpesHomologyGenome.ws10.tsv -word_size 10 -outfmt 6 -query human_herpes_genomes.fna"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHG11 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHG11.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out HumanHerpesHomologyGenome.ws11.tsv -word_size 11 -outfmt 6 -query human_herpes_genomes.fna"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHPG3 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHPG3.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastp -db gencode.v47 -out HumanHerpesHomologyGencode.ws3.tsv  -word_size 3 -outfmt 6 -query human_herpes_proteins.faa"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHPG4 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHPG4.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastp -db gencode.v47 -out HumanHerpesHomologyGencode.ws4.tsv  -word_size 4 -outfmt 6 -query human_herpes_proteins.faa"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHPR3 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHPR3.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastp -db human.protein -out HumanHerpesHomologyRefseq.ws3.tsv -word_size 3 -outfmt 6 -query human_herpes_proteins.faa"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=HHHPR4 --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/HHHPR4.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastp -db human.protein -out HumanHerpesHomologyRefseq.ws4.tsv -word_size 4 -outfmt 6 -query human_herpes_proteins.faa"
```


```
for f in HumanHerpesHomology*.ws?.tsv HumanHerpesHomology*.ws??.tsv ; do
awk '($12>60)' ${f} > ${f%.tsv}.bs60.tsv
done
```


```
for f in HumanHerpesHomology*.tsv ; do
sed -i "1iqaccver	saccver	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore" ${f}
done
```

