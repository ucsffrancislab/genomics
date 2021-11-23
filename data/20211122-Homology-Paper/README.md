
# Masking homologous reference regions to minimize ambiguous alignments


```
1  accession
2  description
3  length
4  raw Ns
5  raw Ns %
6  masked Ns
7  masked Ns %
8  vsl-25 Ns
9  vsl-25 Ns %
10 masked vsl-25 Ns
11 masked vsl-25 Ns %
12 RM vsl-25 missed Ns
13 RM vsl-25 missed Ns %
```


```
awk -F, '( $2 ~ /[Hh]uman/ ) && ( $12 > 0 )' /francislab/data1/working/20211111-hg38-viral-homology/report.csv
AC_000005.1,Human mastadenovirus A  complete genome,34125,0,0,208,.60,49,.14,257,.75,49,.14
AC_000007.1,Human adenovirus 2  complete genome,35937,0,0,321,.89,147,.40,370,1.02,49,.13
AC_000017.1,Human adenovirus type 1  complete genome,36001,0,0,354,.98,147,.40,403,1.11,49,.13
AC_000018.1,Human adenovirus type 7  complete genome,35514,0,0,199,.56,98,.27,248,.69,49,.13
AC_000019.1,Human adenovirus type 35  complete genome,34794,0,0,274,.78,49,.14,323,.92,49,.14
NC_000898.1,Human herpesvirus 6B  complete genome,162114,0,0,2543,1.56,2238,1.38,2863,1.76,320,.19
NC_001352.1,Human papillomavirus - 2  complete genome,7860,0,0,105,1.33,49,.62,154,1.95,49,.62
NC_001357.1,Human papillomavirus - 18  complete genome,7857,0,0,55,.70,49,.62,104,1.32,49,.62
NC_001405.1,Human adenovirus C  complete genome,35937,0,0,321,.89,147,.40,370,1.02,49,.13
NC_001460.1,Human adenovirus A  complete genome,34125,0,0,208,.60,49,.14,257,.75,49,.14
NC_001587.1,Human papillomavirus type 34  complete genome,7723,0,0,180,2.33,172,2.22,229,2.96,49,.63
NC_001593.1,Human papillomavirus type 53  complete genome,7856,0,0,194,2.46,49,.62,243,3.09,49,.62
NC_001664.4,Human betaherpesvirus 6A  variant A DNA  complete virion genome  isolate U1102,159378,0,0,3249,2.03,2262,1.41,3721,2.33,472,.29
NC_001716.2,Human herpesvirus 7  complete genome,153080,0,0,2519,1.64,9803,6.40,10934,7.14,8415,5.49
NC_001798.2,Human herpesvirus 2 strain HG52  complete genome,154675,0,0,5884,3.80,2342,1.51,6896,4.45,1012,.65
NC_001806.2,Human herpesvirus 1 strain 17  complete genome,152222,0,0,4143,2.72,1859,1.22,5089,3.34,946,.62
NC_006273.2,Human herpesvirus 5 strain Merlin  complete genome,235646,0,0,3141,1.33,637,.27,3190,1.35,49,.02
NC_006577.2,Human coronavirus HKU1  complete genome,29926,0,0,215,.71,49,.16,264,.88,49,.16
NC_007605.1,Human gammaherpesvirus 4  complete genome,171823,0,0,1139,.66,796,.46,1861,1.08,722,.42
NC_009333.1,Human herpesvirus 8 strain GK18  complete genome,137969,0,0,357,.25,568,.41,876,.63,519,.37
NC_009334.1,Human herpesvirus 4  complete genome,172764,0,0,1365,.79,473,.27,1838,1.06,473,.27
NC_011203.1,Human adenovirus B1  complete genome,35343,0,0,166,.46,98,.27,215,.60,49,.13
NC_020890.1,Human polyomavirus 12 strain hu1403  complete genome,5033,0,0,32,.63,49,.97,81,1.60,49,.97
NC_028459.1,Human associated gemyvongvirus 1 isolate DB1  complete genome,2272,0,0,43,1.89,98,4.31,92,4.04,49,2.15
NC_038524.1,Human papillomavirus type 175 isolate SE87  complete genome,7226,0,0,21,.29,74,1.02,95,1.31,74,1.02
NC_038889.1,Human papillomavirus type 30 genomic DNA,7852,0,0,181,2.30,49,.62,230,2.92,49,.62
```


```
awk -F, '( $2 ~ /[Hh]uman/ ) && ( $12 > 0 )' /francislab/data1/working/20211111-hg38-viral-homology/report.csv | wc -l
26
```


```
awk -F, '( $2 ~ /[Hh]uman/ ) && ( $12 > 0 ){system("ls /francislab/data1/refs/refseq/viral-20210916/split/"$1"*.fa")}' /francislab/data1/working/20211111-hg38-viral-homology/report.csv
/francislab/data1/refs/refseq/viral-20210916/split/AC_000005.1_Human_mastadenovirus_A,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/AC_000007.1_Human_adenovirus_2,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/AC_000017.1_Human_adenovirus_type_1,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/AC_000018.1_Human_adenovirus_type_7,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/AC_000019.1_Human_adenovirus_type_35,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_000898.1_Human_herpesvirus_6B,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001352.1_Human_papillomavirus_-_2,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001357.1_Human_papillomavirus_-_18,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001405.1_Human_adenovirus_C,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001460.1_Human_adenovirus_A,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001587.1_Human_papillomavirus_type_34,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001593.1_Human_papillomavirus_type_53,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001664.4_Human_betaherpesvirus_6A,_variant_A_DNA,_complete_virion_genome,_isolate_U1102.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001716.2_Human_herpesvirus_7,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001798.2_Human_herpesvirus_2_strain_HG52,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_001806.2_Human_herpesvirus_1_strain_17,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_006273.2_Human_herpesvirus_5_strain_Merlin,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_006577.2_Human_coronavirus_HKU1,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_007605.1_Human_gammaherpesvirus_4,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_009333.1_Human_herpesvirus_8_strain_GK18,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_009334.1_Human_herpesvirus_4,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_011203.1_Human_adenovirus_B1,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_020890.1_Human_polyomavirus_12_strain_hu1403,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_028459.1_Human_associated_gemyvongvirus_1_isolate_DB1,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_038524.1_Human_papillomavirus_type_175_isolate_SE87,_complete_genome.fa
/francislab/data1/refs/refseq/viral-20210916/split/NC_038889.1_Human_papillomavirus_type_30_genomic_DNA.fa
```

```
awk -F, '( $2 ~ /[Hh]uman/ ) && ( $12 > 0 ){system("ls /francislab/data1/refs/refseq/viral-20210916/split/"$1"*.fa")}' /francislab/data1/working/20211111-hg38-viral-homology/report.csv > select_viruses.txt
```



/francislab/data1/working/20211111-hg38-viral-homology/


Run 1 by itself first as bbmap creates a reference set
```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211122-Homology-Paper/array_wrapper.bash
```



After the reference set is created, we can run all
```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-26%8 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211122-Homology-Paper/array_wrapper.bash
```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
```


```
mkdir bowtie2
module load bowtie2

ls out/raw/*.fasta | wc -l
ls out/split.vsl/*.?.split.25.mask.fasta | wc -l
ls out/split.vsl/*.masked.split.25.mask.fasta | wc -l
ls out/masks/*fasta | wc -l

cat out/raw/*.fasta > out/raw.fasta
bowtie2-build out/raw.fasta bowtie2/raw

cat out/split.vsl/*.?.split.25.mask.fasta > out/hg38masked.fasta
bowtie2-build out/hg38masked.fasta bowtie2/hg38masked

cat out/split.vsl/*.masked.split.25.mask.fasta > out/RMhg38masked.fasta
bowtie2-build out/RMhg38masked.fasta bowtie2/RMhg38masked

cat out/masks/*fasta > out/RM.fasta
bowtie2-build out/RM.fasta bowtie2/RM

chmod -w bowtie2/*
```



```

awk -F, '($2 ~ /^..-....-1/) && ($6 == "Broad Institute of MIT and Harvard") {
s=substr($2, 1, 20);
cmd="ls /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/"s"*R1.fastq.gz 2> /dev/null";
cmd|getline r1;
close(cmd);
if( r1 ){ print($0); }
}' /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv > metadata.csv


awk -F, '($2 ~ /^..-....-1/) && ($6 == "Broad Institute of MIT and Harvard") {
s=substr($2, 1, 20);
cmd="ls /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/"s"*R1.fastq.gz 2> /dev/null";
cmd|getline r1;
close(cmd);
if( r1 ){ print(s); }
}' /francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv > TCGA_normal_samples.txt

```




Did the bam files include unaligned?

Does this data include non-human?




