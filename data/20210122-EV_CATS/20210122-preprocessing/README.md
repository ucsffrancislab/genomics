

Below is FTP download info for the CATS sequencing data from our Diagenode D-plex libraries.

 

The samples in this run are;

*SFHH001A – index GCCAAT (index #6)

*SFHH001B – index CTTGTA (index #12)

 

These libraries contain UMI’s.   Data analysis recommendations start on pg 32 of the manual (attached).

 

From Diagenode's D-Plex Small RNA-seq Kit: Small RNA library preparation kit for Illumina® sequencing

Data analysis recommendations

The D-Plex libraries contain special sequences that need particular
treatment in order to get the best results out of your datasets. These
special sequences are the UMI, the polyA tail, and the template switch
motif. This guide will take you through the basic processes of trimming,
alignment and counting, complemented with an optional UMI processing,
using software tools and settings that we validated. Though naturally
other tools and methods can also be used, please pay attention to finding
the optimal settings for your experiments, e.g. do not run a paired-end
pipeline for single reads. If the UMIs are not of interest, these two optional
steps can safely be skipped and the rest of the pipeline will not change.
In such a case, the UMI sequences will be only removed from the reads
during trimming and will be ignored for the rest of the analysis. The
recommended software package for UMI processing can be downloaded
from the link at the end of this chapter (or can be installed with conda;
please see the readme file of the software package for the installation
instructions). In our example commands we assume that the necessary
software tools are in the PATH.

NOTE: The links for the tools used in the example pipeline are at the end of this section.

UMI-preprocessing (optional)
If you want to process the UMIs, the first thing you need to do is to copy
the UMI sequence to the read ID. The first 12 bases in the read (from
the 5’ end) are the Unique Molecular Identifier. In the fumi-tools package
the copy_umi command can copy (not move!) these bases to the correct
lines in the fastq file. You don’t need to use all the 12 bases if you don’t
want to and you can copy less, which can reduce the data processing time
and resource need at the expense of a reduced UMI complexity. The tool
expects a fastq file as input (which can be gzip compressed), and it will
output a fastq file, which will be either gzip compressed or uncompressed,
based on the extension set on the commandline (.gz for compression).

Besides the input, the command needs one mandatory option: the length
of the UMI (to copy from the read to the ID line). A typical example is
below, using all the 12 UMI bases and 10 threads for compression:

fumi_tools copy_umi --threads 10 --umi-length 12 -i reads.fastq.gz -o reads_w_umi.fastq.gz

Trimming
Trimming is mandatory for the reads generated with the D-Plex small
RNA-seq kit, because the read length is often longer than the targeted
small RNAs, so in many cases the polyA tail and the 3’ adapter are also
sequenced. In addition, the 5’ end contains other sequences that were
originally not part of the RNA: the UMI and the template switch motif. The
aim of trimming is to remove these artificial sequences that will likely
hamper downstream analyses.
In our example below, we use cutadapt to demonstrate how to properly
do the trimming for D-Plex reads and get a readset as clean as possible.
To minimize the effect of ambiguously read bases, we trim the Ns and
allow IUPAC codes in the reads. We cut off 16 bases from the 5’ end (12
for the UMI, 4 for the template switch motif) and then from the 3’ end we
remove first the 3’ adapter, then the polyA tail. For the former, we use
the standard Illumina TruSeq Universal Adapter sequence; for the latter
we are looking for a pattern consisting of 8 As and we allow a three times
repetition of this pattern. We found that this combination of parameters
prevents excessive overtrimming and read loss, while reliably and fully
cleans up the readset coming from an average Illumina sequencing
run. Finally we filter the remaining reads by length, and we discard the
ones below 15 nucleotides, as they might be difficult to map uniquely.
The example command with cutadapt is below. Note that the input file
raw_reads.fastq.gz can mean both the UMI-preprocessed reads – see the
previous step – or the reads directly coming from the sequencer without
the UMI pre-processing. The trimming command is the same in either
case, with or without considering the UMIs.

cutadapt --trim-n --match-read-wildcards -u 16 -n 3 -a AGATCGGAAGAGCACACGTCTG -a AAAAAAAA -m 15 -o trimmed_reads.fastq.gz raw_reads.fastq.gz

Alignment
Aligning the trimmed reads needs no special treatment as you can use any
aligner that is suitable for mapping RNA-seq reads. First and foremost,
we recommend aligning to the genome (instead of the transcriptome).
Indeed, D-Plex tends to generate a very high-complexity library which often
include small RNAs that are not identified yet and therefore would not
map to a transcriptome consisting of only known transcripts. Of course,
in addition to the genome alignment, the mapped reads can be assigned
to known transcripts as well for expression analysis of the known genes.
In our example below, we will use the software STAR which does exactly
that: it aligns the reads to the hg19 genome (assuming we are dealing
with a human sample, and the hg19 genome index for STAR has already
been prepared), then assigns them to known transcripts, using the gtf
annotation file. We also assume that the reads were 50 bases long and
STAR was run in multithreading mode on 10 cores.

STAR --runThreadN 10 --readFilesCommand zcat --genomeDir /genomes/hg19/ --sjdbGTFfile /genomes/ hg19/hg19.gtf --sjdbOverhang 49 --readFilesIn trimmed_reads.fastq.gz --quantMode TranscriptomeSAM --quantTranscriptomeBAMcompression -1 --outSAMtype BAM SortedByCoordinate --outSAMunmapped Within --outFileNamePrefix ./MySample_

Deduplication based on UMIs (optional)
This is where you can exploit the UMIs (if you have performed the UMI
pre-processing at the beginning of the pipeline). They enable the distinction
between duplicate reads that are coming from different molecules, thus
having different UMIs (e.g. the same gene transcribed multiple times in
the sample), and duplicates that are essentially artifacts, such as the ones
resulting from PCR amplification. These have the same UMIs in their read
IDs (after the pre-processing), and consequently they can be recognized
and removed until only one copy remains. This way the subsequent
counting will be more precise and you will get a more realistic picture of
the expression levels, which will not be biased by artificial duplicates.
You can deduplicate both the genome and the transcriptome alignments
of course. The example commands below show you how to do it in both
cases, using the STAR outputs from the previous step. Do not forget
however, that the transcriptome alignment is not sorted (though the
reads with the same names, e.g. multimapping reads follow each other
in consecutive lines, which is required by most counting software). As the
UMI deduplication tool needs a coordinate sorted alignment for input, you
need to sort the transcriptome alignment first, for example with samtools
(assuming 10 cores, just as in the STAR example):

samtools sort -@ 10 -o MySample_Aligned.toTranscriptome.sorted.out.bam MySample_Aligned.toTranscriptome.out.bam

The genome alignment from the above STAR command is already sorted
by coordinates and it needs no more sorting. Now you can deduplicate both
the genome and the transcriptome alignment with the UMI deduplication
command of fumi-tools called dedup (again running it on 10 cores and
assigning 10 GB RAM):

fumi_tools dedup --threads 10 --memory 10G -i MySample_Aligned.toTranscriptome.sorted.out.bam -o MySample_deduplicated_transcriptome.bam
fumi_tools dedup --threads 10 --memory 10G -i MySample_Aligned.sortedByCoord.out.bam -o MySample_deduplicated_genome.bam

Note that fumi-tools outputs name-sorted bam files, which can be directly
used for example with counting software tools, but remember to sort them
if you want to use them for another application that needs a different
sorting, e.g. sorting by coordinates.


Counting
The counting, or expression level calculation is the last step in this guide.
As written above, counting software usually requires that the reads in
the input bam file with the same name follow each other on consecutive
lines. Therefore both the STAR output (transcriptome alignment) and
the fumi-tools output (deduplicated transcriptome alignment) are ready
to use with counting tools without further modifications. So this step is
again independent of the UMI processing and it is the same whether you
considered UMIs or not.
We provide an example command below, using RSEM for counting,
continuing our example pipeline. We assume that the hg19 index for RSEM
has been prepared beforehand, and we run the counting on 10 cores. The
other options specify that we do not want a bam output and we start from
an alignment file (RSEM can also do the alignment, but we have already
done it with STAR); the minimum read length is 15 (as we specified during
trimming), and the reads are originating from the forward strand (D-Plex
produces stranded libraries). In the end (among other RSEM outputs) we
will obtain the expression levels of known genes as TPM/FPKM values.

rsem-calculate-expression -p 10 --strandedness forward --seed-length 15 --no-bam-output --alignments MySample_transcriptome_alignment.bam /transcriptomes/hg19/hg19 MySample



Downloaded linux fumi_tools https://ccb-gitlab.cs.uni-saarland.de/tobias/fumi_tools/uploads/629c0b2b48bb8e4634d0582889627108/fumi_tools_0.18.1_static_linux_x86_64.tar.gz

ll bin/
total 10916
-rwxr-x--- 1 gwendt francislab   14797 Dec  8 07:55 fumi_tools
-rwxr-x--- 1 gwendt francislab   16893 Dec  8 07:55 fumi_tools_copy_umi
-rwxr-x--- 1 gwendt francislab 4116496 Dec  8 07:56 fumi_tools_dedup
-rwxr-x--- 1 gwendt francislab 3470272 Dec  8 07:56 fumi_tools_demultiplex
-rwxr-x--- 1 gwendt francislab 3546216 Dec  8 07:56 fumi_tools_fix_flags

It is for python3

This version had some issues with the dedup step.
compiling from source.


```BASH
samtools flags UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY


for f in output/*fastq.gz ; do
zcat $f | paste - - - - | wc -l > $f.read_count
zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
done


for f in ${PWD}/*/*.trimmed.fastq.gz ; do

	basename=$( basename $f .fastq.gz )

	sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
		--output=${PWD}/${basename}.sbatch.bowtie2phiX.output.txt \
		~/.local/bin/bowtie2.bash --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -U $f -o ${PWD}/${basename}.bowtie2phiX.bam

done


for f in output/*out.bam ; do
samtools view -c -F 3844 $f > $f.aligned_count
done



for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
done

for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' > ${f}.transcript_ids
awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv ${f}.transcript_ids | sort | uniq -c | sort -rn > ${f}.gene_count
done

awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv output/*.toTranscriptome.out.bam.transcript_ids | sort | uniq -c | sort -rn > gene_count




for f in ${PWD}/output/*unmapped.fasta.gz ; do
  base=${f%.fasta.gz}
  basename=$(basename $base)
  echo $f
  for m in 0 1 ; do

    sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
      --output=${base}.sbatch.diamond.nr.masking${m}.output.txt \
      ~/.local/bin/diamond.bash blastx --query ${f} --threads 8 --db /francislab/data1/refs/diamond/nr \
        --outfmt 100 --out ${base}.nr.masking${m}.daa --masking ${m}

done ; done
```




|    | SFHH001A_R1 | SFHH001B_R1 | Undetermined_R1 |
| --- | --- | --- | --- |
| Raw Read Count | 213052 | 217755 | 133027 |
| Raw Read Length | 301 | 301 | 301 |
| Trimmed Read Count | 137184 | 147265 | 131457 |
| Trimmed Ave Read Length | 53.7021 | 51.3464 | 274.183 |
| STAR Aligned to Transcriptome | 11688 | 13525 | 244 |
| STAR Aligned to Transcriptome % | 8.51 | 9.18 | .18 |
| STAR Aligned to Genome | 65017 | 67542 | 1349 |
| STAR Aligned to Genome % | 47.39 | 45.86 | 1.02 |
| Bowtie Aligned to phiX | 9359 | 10504 | 128249 |
| Bowtie Aligned to phiX % | 6.82 | 7.13 | 97.55 |
| MECP2 | 3090 | 4280 | 60 |
| P2RX6 | 2793 | 2730 | 63 |
| NAALADL2 | 2380 | 2040 |  |
| FGD2 | 2002 | 1209 | 26 |
| PACS2 | 1425 | 1035 | 45 |
| ESRRB | 850 | 1490 | 40 |
| ILDR2 | 929 | 777 | 8 |
| PPP6R3 | 744 | 868 |  |
| L1CAM | 612 | 944 | 20 |
| GRB10 | 846 | 705 | 15 |
| FOXO3 | 693 | 819 | 9 |
| SIK3 | 731 | 763 |  |
| LOC105374102 | 664 | 788 | 16 |
| EDEM3 | 690 | 741 | 30 |
| RNA45SN2 | 680 | 686 | 14 |
| RNA45SN4 | 676 | 682 | 14 |
| RNA45SN3 | 672 | 681 | 14 |
| RNA45SN5 | 672 | 678 | 14 |
| RNA45SN1 | 672 | 677 | 14 |
| AK9 | 648 | 666 | 36 |





```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210201 20210122-EV_CATS 20210122-preprocessing"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*daa ;do curl -netrc -T $f "${BOX}/" ; done
```


locally on my laptop
```BASH
for f in *daa ; do echo $f ;/Applications/MEGAN/tools/daa-meganizer --in ${f} --mapDB ~/megan/megan-map-Jul2020-2.db --threads 8; done
```



