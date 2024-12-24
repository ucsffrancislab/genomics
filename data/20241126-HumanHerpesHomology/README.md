
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
for word_size in 07 08 09 10 11 12 ; do
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








##	20241223

/francislab/data1/working/20210610-hg38-viral-homology
/francislab/data1/working/20211012-hg38-complete-homology
/francislab/data1/working/20211111-hg38-viral-homology
/francislab/data1/working/20211122-Homology-Paper

cat /francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.bt2/NC_032111.1.split.25.summary.txt
cat /francislab/data1/working/20211111-hg38-viral-homology/out/raw.split.HM.bt2/NC_032111.1.split.25.mask.bed 
/francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_032111.1_BeAn_58058_virus__complete_genome.fa

```
module load blast
for word_size in 07 08 09 10 11 12 13 14 15 16 17 18 19 20 25 30 35 40 45 50; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=32111_${word_size} --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/NC_032111_${word_size}.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out NC_032111_HomologyGenome.ws${word_size}.tsv -word_size ${word_size} -outfmt 6 -query /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_032111.1_BeAn_58058_virus__complete_genome.fa"
done

```




```

awk '{print $7,$8}' NC_032111_HomologyGenome.ws10.tsv | sort -k1n,1 | uniq 
17 72
33 77
35 77
339 370
869 902
1101 1137
1741 1783
1743 1781
2312 2364
2325 2352
2328 2370
2328 2388
2333 2415
```


```
for word_size in 07 08 09 10 11 12 13 14 15 16 17 18 19 20 25 30 35 40 45 50; do
awk '{print $7,$8}' NC_032111_HomologyGenome.ws${word_size}.tsv | sort -k1n,1 | uniq | awk 'BEGIN{OFS="\t"}(s==""){s=$1;e=$2}{ if($1>e){ print("NC_032111.1",s,e); s=$1;e=$2 }else{ if(e<$2)e=$2 } }END{ print("NC_032111.1",s,e) }' > NC_032111_HomologyGenome.ws${word_size}.mask.bed
done

awk '{print $3-$2, $2, $3}' NC_032111_HomologyGenome.ws12.mask.bed | sort -k1n,1

```





```

awk '{print $3-$2, $2, $3}' NC_032111_HomologyGenome.ws25.mask.bed 
468 8191 8659
37 17234 17271
25 19207 19232
40 23082 23122
30 33040 33070
24 38706 38730
24 50744 50768
24 97883 97907
24 103721 103745
24 111817 111841
33 124016 124049
33 128045 128078


```

```


samtools faidx /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_032111.1_BeAn_58058_virus__complete_genome.fa NC_032111.1_BeAn_58058_virus__complete_genome:8191-8659
>NC_032111.1_BeAn_58058_virus__complete_genome:8191-8659
TATATATCATTATAATAATAAAAAAAATGTTATTAATTTATTTTTATAAA
ATCTTTATCAGATATATTTATTTTTTGCTAAGTTCAATAATATCATGACC
ACTTTCTTTAATAATAGGATTATCCTTTTTTTTTTTTTTTTTTTGAGACA
GAGTCTCACTCTGTTGCCCAGGCTGGAGTGCAGTGGCCTGATCTCCGCTC
ACTGCAACCTCCGCCTCCCGGGTTCAAGCTATTCTCCTGCCTCAGCCTCC
AGAGTAGCTGGGATTACAGGCAAAAGCCACCACGCCAAGCTAATTTTTGT
ATTTTTAGTAGAGAGAGGGTTTCACCATGTTGGCCAGGCTGGTCTCGAAC
TCCTGACCTCATGTGATCCACCTGCCTCGGCCTCCCAAAGTGCTGGGATT
ACAGGCATGAGCCACCGCGCCTGGCCCTTTAAAAAGTTTTCTTGGTTTTG
AATGTACATTATGAAGTTC

```







```
module load blast
for word_size in 50; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=32111_${word_size} --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/NC_032111_${word_size}.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out NC_032111_HomologyGenome.ws${word_size}.xml -word_size ${word_size} -outfmt 5 -query /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_032111.1_BeAn_58058_virus__complete_genome.fa"
done
```


```
for word_size in 50; do
xml=NC_032111_HomologyGenome.ws${word_size}.xml
blast2bam ${xml} /francislab/data1/refs/sources/gencodegenes.org/release_47/GRCh38.p14.genome.fa.gz /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_032111.1_BeAn_58058_virus__complete_genome.fa > ${xml%.xml}.sam
samtools view -h -F4 ${xml%.xml}.sam | samtools sort -o ${xml%.xml}.bam -
samtools index ${xml%.xml}.bam
done
```

blast2bam did't work


```
module load blast
for word_size in 50; do
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 --job-name=32111_${word_size} --time=14-0 --nodes=1 --ntasks=4 --mem=30GB --output=${PWD}/NC_032111_${word_size}.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log --wrap="blastn -db GRCh38.p14.genome -out NC_032111_HomologyGenome.ws${word_size}.txt -word_size ${word_size} -query /francislab/data1/refs/refseq/viral-20220923/viral.genomic/NC_032111.1_BeAn_58058_virus__complete_genome.fa"
done
```

```
samtools faidx /francislab/data1/refs/sources/gencodegenes.org/release_47/GRCh38.p14.genome.fa.gz

for word_size in 50; do
txt=NC_032111_HomologyGenome.ws${word_size}.txt
blast2sam.pl ${txt} > ${txt%.txt}.sam
samtools view -o tmp -ht /francislab/data1/refs/sources/gencodegenes.org/release_47/GRCh38.p14.genome.fa.gz.fai ${txt%.txt}.sam 
samtools sort -o ${txt%.txt}.bam tmp
samtools index ${txt%.txt}.bam
done
```






