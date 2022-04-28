


https://www.science.org/doi/10.1126/science.abg0928


WGS
https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA736483

RNASeq
https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA682434


https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE162632
ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE162nnn/GSE162632/suppl/GSE162632_RAW.tar
https://www.ncbi.nlm.nih.gov/bioproject/PRJNA682434
https://www.ncbi.nlm.nih.gov/sra?term=SRP295709
https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=682434




file:///Users/jake/Downloads/science.abg0928_sm.pdf

Single-cell RNA-sequencing mapping, demultiplexing, and initial cell filtering

FASTQ files from each multiplexed capture library were mapped to a custom reference containing GRCh38 and the Cal/04/09 IAV reference genome (downloaded from NCBI, created using cellranger mkref) using the cellranger (v3.0.2) (10X Genomics) count function (53). souporcell (v2.0, Singularity v3.4.0) (54) in --skip_remap mode (-k 6) was used to demultiplex cells into samples based on genotypes from a common variants file (1000GP samples filtered to SNPs with >= 2% allele frequency in the population, downloaded from https://github.com/wheaton5/souporcell). Briefly, souporcell clusters cells based on cell allele counts in common variants, assigning all cells with similar allele counts to a single cluster corresponding to one individual, while also estimating singlet/doublet/negative status for that cell.  For each batch, hierarchical clustering of the true genotypes known for each individual (obtained from low-pass whole-genome-sequencing) and the cluster genotypes estimated from souporcell was used to assign individual IDs to souporcell cell clusters. All 89 individuals were successfully assigned to a single cluster.
After demultiplexing cells into samples, Seurat (v3.1.5, R v3.6.3) (55) was used to perform quality control filtering of cells. In total, we captured 255,731 cells prior to filtering (range of cells recovered per capture: min. = 5,534, max. = 10,805). Cells were considered "high-quality" and retained for downstream analysis if they had: 1) a "singlet" status called by souporcell, 2) between 200 – 2500 genes detected (nFeature_RNA), and 3) a mitochondrial reads percentage < 10%, leaving 236,993 cells (n = 19,248 genes).


```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=13aebUpEKrtjliyT9rYzRijtkNJVUk5F_' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=13aebUpEKrtjliyT9rYzRijtkNJVUk5F_" -O common_variants_grch38.vcf && rm -rf /tmp/cookies.txt
mv common_variants_grch38.vcf common_variants_grch38.original.vcf
sed -n -e '/^#/p' -e '/^#/! s/^/chr/p' common_variants_grch38.original.vcf > common_variants_grch38.vcf


```



A quick check of the flu RNAseq data. It contains

120 paired end samples B\*-c\*-10X\_L00\*\_R1\_001.fastq.gz . The 10X data has R1 with 29 bp and R2 with 289 bp.
89 single end samples HMN\*\_flu\_R1\_001.fastq.gz at 121 bp
89 single end samples HMN\*\_NI\_R1\_001.fastq.gz at 121 bp
10 (of the above single end samples) also with mock, 2hr, 6hr, 12hr, 18hr, 24hr, 30hr, 36hr, 48hr  HMN\*\_48hr\_\*\_R1\_001.fastq.gz
Looking at the reads and read names give no immediate indication of single cell identifiers. Perhaps they've already been consolidated?

Still digging.



Looks like the 120 paired end samples are the single cell data. R1 are the cellular and molecular barcode sequences.
Cellranger corrects them and they end up in CR/CB and UR/UB tags in the output bam file.
I don't understand why there are 120.

https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/output/bam



https://www.gencodegenes.org/human/release_38.html
https://www.gencodegenes.org/human/release_19.html


https://www.fludb.org/brc/fluStrainDetails.spg?strainName=A/California/07/2009(H1N1)&decorator=influenza

```
#cat /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa /francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/?/*fa > ${PWD}/hg38_iav.fa
#cat /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa > ${PWD}/hg38_iav.fa
#awk -F. '{print $1}' /francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/?/*fa >> ${PWD}/hg38_iav.fa


#wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz
#mkdir GCF_000001405.40_GRCh38.p14_genomic/
#faSplit byname GCF_000001405.40_GRCh38.p14_genomic.fna.gz GCF_000001405.40_GRCh38.p14_genomic/


wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_genomic.gff.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_genomic.gtf.gz
mkdir GCA_000001405.29_GRCh38.p14_genomic
faSplit byname GCA_000001405.29_GRCh38.p14_genomic.fna.gz GCA_000001405.29_GRCh38.p14_genomic/

mkdir GCA_000001405.29_GRCh38.p14_genomic-select







#hg19 has the appropriate matching alternates

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.14_GRCh37.p13/GCA_000001405.14_GRCh37.p13_genomic.fna.gz
mkdir GCA_000001405.14_GRCh37.p13_genomic
faSplit byname GCA_000001405.14_GRCh37.p13_genomic.fna.gz GCA_000001405.14_GRCh37.p13_genomic/

mkdir GCA_000001405.14_GRCh37.p13_genomic-select
cd GCA_000001405.14_GRCh37.p13_genomic-select
for a in $( samtools view -H /francislab/data1/raw/20220303-FluPaper/PRJNA736483/SRR14773640/HMN83551_alignment_bam.bam | grep "SN:GL" | awk -F: '{print $2}' | awk '{print $1}' ); do echo $a ; ls ../GCA_000001405.14_GRCh37.p13_genomic/${a}.fa; ln -s ../GCA_000001405.14_GRCh37.p13_genomic/${a}.fa; done

zcat ../GCA_000001405.14_GRCh37.p13_genomic.fna.gz | grep "^>" > sequences.txt

grep "Homo sapiens chromosome" sequences.txt | grep "GRCh37 primary reference assembly"

while read -r a c ; do echo $a; echo $c; sed "1s/${a}/${c}/" ../GCA_000001405.14_GRCh37.p13_genomic/${a}.fa > ${c}.fa ; done < <( grep "Homo sapiens chromosome" sequences.txt | grep "GRCh37 primary reference assembly" | sed -e 's/^>//' -e 's/ Homo sapiens chromosome//' -e 's/,.*$//' )

sed '1s/J01415.2/MT/' ../GCA_000001405.14_GRCh37.p13_genomic/J01415.2.fa > MT.fa

cd ..

cat GCA_000001405.14_GRCh37.p13_genomic-select/[1-9].fa > GCA_000001405.14_GRCh37.p13_genomic-select.fa
cat GCA_000001405.14_GRCh37.p13_genomic-select/1?.fa >> GCA_000001405.14_GRCh37.p13_genomic-select.fa
cat GCA_000001405.14_GRCh37.p13_genomic-select/2?.fa >> GCA_000001405.14_GRCh37.p13_genomic-select.fa
cat GCA_000001405.14_GRCh37.p13_genomic-select/[XY].fa >> GCA_000001405.14_GRCh37.p13_genomic-select.fa
cat GCA_000001405.14_GRCh37.p13_genomic-select/MT.fa >> GCA_000001405.14_GRCh37.p13_genomic-select.fa
cat GCA_000001405.14_GRCh37.p13_genomic-select/GL000*fa >> GCA_000001405.14_GRCh37.p13_genomic-select.fa

cp GCA_000001405.14_GRCh37.p13_genomic-select.fa GCA_000001405.14_GRCh37.p13_genomic-select_iav.fa
awk -F. '{print $1}' /francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/?/*fa >> GCA_000001405.14_GRCh37.p13_genomic-select_iav.fa


wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf.gz
zcat gencode.v19.chr_patch_hapl_scaff.annotation.gtf.gz | sed -e 's/^chrM/MT/' -e 's/^chr//' > gencode.v19.chr_patch_hapl_scaff.annotation.gtf
```



```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=bcftools --time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/bcftools.${date}.txt ${PWD}/bcftools.bash
```











cellranger uses STAR?

```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=mkrefcellranger --time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/cellranger_mkref.${date}.txt ${PWD}/cellranger_mkref.bash
```


Questioning whether I need to add lines to the GTF that somehow describe the flu segments

```
for f in /francislab/data1/raw/20220303-FluPaper/PRJNA682434/*/B*-c*-10X_L00*; do
echo $f
l=$( basename $f )
l=${l/10X/10X_S0}
ln -s $f $l
done
```


```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=countcellranger --time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/cellranger_count.${date}.txt ${PWD}/cellranger_count.bash
```




```
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=souporcell --time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/souporcell.${date}.txt ${PWD}/souporcell.bash
```


Is it the .? I trimmed the fasta read names at the . and am remaking the reference.
```
***** WARNING: File souporcelltest/depth_merged.bed has inconsistent naming convention for record:
FJ966080.1	1	632
```


```
***** WARNING: File souporcelltest/depth_merged.bed has inconsistent naming convention for record:
FJ966080	1	1443

***** WARNING: File souporcelltest/depth_merged.bed has inconsistent naming convention for record:
FJ966080	1	1443
```

Still get the warning. Confused as to what the inconsistency is.
Gonna try adding the new sequences to the gtf file.

```
tail -14 hg38_iav.fa.fai | awk 'BEGIN{FS=OFS="\t"}{ print $1,"ncbiRefSeq","transcript",1,$2,".","+",".","gene_id \""$1"\"; transcript_id \""$1"\"; gene_name \""$1"\";"; print $1,"ncbiRefSeq","exon",1,$2,".","+",".","gene_id \""$1"\"; transcript_id \""$1"\"; exon_number \""$1"\"; exon_id \""$1"\"; gene_name \""$1"\";"; }'
```


Still! Cause it doesn't start with chr?
Does it make any difference?

```
***** WARNING: File /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out/B1-c1/souporcell/depth_merged.bed has inconsistent naming convention for record:
FJ966080	1	632

***** WARNING: File /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out/B1-c1/souporcell/depth_merged.bed has inconsistent naming convention for record:
FJ966080	1	632
```







```
>FJ966080.1 Influenza A virus (A/California/04/2009(H1N1)) segment 2 polymerase PB1 (PB1) gene, complete cds
>FJ966081.1 Influenza A virus (A/California/04/2009(H1N1)) segment 3 polymerase PA (PA) gene, complete cds
>JF915188.1 Influenza A virus (A/California/04/2009(H1N1)) segment 3 polymerase PA (PA) gene, complete cds
>FJ966082.1 Influenza A virus (A/California/04/2009(H1N1)) segment 4 hemagglutinin (HA) gene, complete cds
>GQ280797.1 Influenza A virus (A/California/04/2009(H1N1)) segment 4 hemagglutinin (HA) gene, complete cds
>JF915184.1 Influenza A virus (A/California/04/2009(H1N1)) segment 4 hemagglutinin (HA) gene, complete cds
>KP406524.1 Influenza A virus (A/California/04/2009(H1N1)) segment 4 hemagglutinin (HA) gene, partial cds
>FJ966083.1 Influenza A virus (A/California/04/2009(H1N1)) segment 5 nucleocapsid protein (NP) gene, complete cds
>FJ966084.1 Influenza A virus (A/California/04/2009(H1N1)) segment 6 neuraminidase (NA) gene, complete cds
>KP406527.1 Influenza A virus (A/California/04/2009(H1N1)) segment 6 neuraminidase (NA) gene, partial cds
>FJ966085.1 Influenza A virus (A/California/04/2009(H1N1)) segment 7 matrix protein 2 (M2) and matrix protein 1 (M1) genes, partial cds
>FJ969513.1 Influenza A virus (A/California/04/2009(H1N1)) segment 7 matrix protein 2 (M2) and matrix protein 1 (M1) genes, complete cds
>FJ966086.1 Influenza A virus (A/California/04/2009(H1N1)) segment 8 nuclear export protein (NEP) and nonstructural protein 1 (NS1) genes, complete cds
>FJ969514.1 Influenza A virus (A/California/04/2009(H1N1)) segment 8 nuclear export protein (NEP) and nonstructural protein 1 (NS1) genes, complete cds
```



```
c4-n17
Slurm job id:489426:
Tue Apr 19 10:17:27 PDT 2022
Loading required modules
+ singularity exec --bind /francislab /francislab/data1/refs/singularity/souporcell_latest.sif souporcell_pipeline.py --bam /francislab/data1/raw/20220303-FluPaper/B1-c1/outs/possorted_genome_bam.bam --barcodes /francislab/data1/raw/20220303-FluPaper/B1-c1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz --fasta /francislab/data1/raw/20220303-FluPaper/hg38_iav.fa --common_variants /francislab/data1/raw/20220303-FluPaper/common_variants_grch38.vcf --threads 16 --out_dir souporcelltest --skip_remap SKIP_REMAP --clusters 6
***** WARNING: File souporcelltest/depth_merged.bed has inconsistent naming convention for record:
FJ966080.1	1	632

***** WARNING: File souporcelltest/depth_merged.bed has inconsistent naming convention for record:
FJ966080.1	1	632

checking modules
imports done
checking bam for expected tags
checking fasta
using common variants
16
running vartrix
running souporcell clustering
/opt/souporcell/souporcell/target/release/souporcell -k 6 -a souporcelltest/alt.mtx -r souporcelltest/ref.mtx --restarts 100 -b /francislab/data1/raw/20220303-FluPaper/B1-c1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz --min_ref 10 --min_alt 10 --threads 16
running souporcell doublet detection
Traceback (most recent call last):
  File "/opt/souporcell/souporcell_pipeline.py", line 596, in <module>
    doublets(args, ref_mtx, alt_mtx, cluster_file)
  File "/opt/souporcell/souporcell_pipeline.py", line 541, in doublets
    subprocess.check_call([directory+"/troublet/target/release/troublet", "--alts", alt_mtx, "--refs", ref_mtx, "--clusters", cluster_file], stdout = dub, stderr = err)
  File "/usr/local/envs/py36/lib/python3.6/subprocess.py", line 311, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/opt/souporcell/troublet/target/release/troublet', '--alts', 'souporcelltest/alt.mtx', '--refs', 'souporcelltest/ref.mtx', '--clusters', 'souporcelltest/clusters_tmp.tsv']' returned non-zero exit status 101.
[gwendt@c4-dev1 /francislab/data1/raw/20220303-FluPaper]$ 
```

Not sure why the failure. Reference not in gff?


```
singularity exec --bind /francislab /francislab/data1/refs/singularity/souporcell_latest.sif /opt/souporcell/troublet/target/release/troublet --alts souporcelltest/alt.mtx --refs souporcelltest/ref.mtx --clusters souporcelltest/clusters_tmp.tsv

souporcell_pipeline.py --bam /francislab/data1/raw/20220303-FluPaper/B1-c1/outs/possorted_genome_bam.bam --barcodes /francislab/data1/raw/20220303-FluPaper/B1-c1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz --fasta /francislab/data1/raw/20220303-FluPaper/hg38_iav.fa --common_variants /francislab/data1/raw/20220303-FluPaper/common_variants_grch38.vcf --threads 16 --out_dir souporcelltest --skip_remap SKIP_REMAP --clusters 6
```



