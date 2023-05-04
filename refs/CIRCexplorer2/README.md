
#	CircExplorer2


https://circexplorer2.readthedocs.io/en/latest/tutorial/setup/


##	Install

```
python3 -m pip install --upgrade --user circexplorer2

```


##	Download

Download human RefSeq gene annotation file ( Downloads refFlat.txt.gz and gunzips to hg38_ref.txt )

```
fetch_ucsc.py hg38 ref hg38_ref.txt
chmod -w hg38_ref.txt refFlat.txt.gz
```

hg38 and mm10 only have RefSeq and KnownGenes (GENCODE) gene annotations, and does not support Ensembl gene annotations.


Download human KnownGenes gene annotation file ( knownGene.txt.gz and kgXref.txt.gz then creates hg38_kg.txt )

```
fetch_ucsc.py hg38 kg hg38_kg.txt
chmod -w hg38_kg.txt kgXref.txt.gz
```



Concatenate all

```
cat hg38_ref.txt hg38_kg.txt > hg38_ref_all.txt
chmod -w hg38_ref_all.txt
```


Convert gene annotation file to GTF format (require genePredToGtf from kentutils)

```
cut -f2-11 hg38_ref_all.txt | genePredToGtf file stdin hg38_ref_all.gtf
chmod -w hg38_ref_all.gtf
```




Download human reference genome sequence file chromFa.tar.gz (roughly 1GB) (983726049)
( chromFa.tar.gz opened to hg38.fa and hg38.fa.fai )
Much Faster on c4/c4-dt1 but still takes about 2.5 hours

```
fetch_ucsc.py hg38 fa hg38.fa
chmod -w chromFa.tar.gz hg38.fa hg38.fa.fai
ln -s hg38.fa bowtie1_index.fa
ln -s hg38.fa bowtie2_index.fa
```



##	Prepare Indices


Skip these steps until you understand / decide how you're going to align.


CIRCexploer2 TopHat2/TopHat-Fusion pipeline requires Bowtie and Bowtie2 index files for reference genome. You could use bowtie-build and bowtie2-build to index relevant genome. Or you could use CIRCexplorer2 align to automatically index the genome file (See Alignment).



index genome for Bowtie
```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="bowtie-build" \
 --time=20160 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie-build.out.log \
 --wrap "module load bowtie/1.3.1; bowtie-build --threads 64 ${PWD}/bowtie1_index.fa ${PWD}/bowtie1_index; chmod -w ${PWD}/bowtie1_index*"

```


index genome for Bowtie2
```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="bowtie2-build" \
 --time=20160 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/bowtie2-build.out.log \
 --wrap "module load bowtie2/2.4.1; bowtie2-build --threads 64 ${PWD}/bowtie2_index.fa ${PWD}/bowtie2_index; chmod -w ${PWD}/bowtie2_index*"

```


index genome for STAR
```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="STAR" \
 --time=20160 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/STAR-genomeGenerate.out.log \
 --wrap "module load star/2.7.7a; STAR --runMode genomeGenerate --runThreadN 64 --genomeFastaFiles ${PWD}/hg38.fa --sjdbGTFfile ${PWD}/hg38_ref_all.gtf --genomeDir ${PWD}/hg38-ref_all-2.7.7a; chmod -R -w ${PWD}/hg38-ref_all-2.7.7a"

```



##	Align


Align - Parse - Annotate can be run on paired end data by aligning with STAR instead of Circexplorer

Tophat does seem to support paired end alignment so perhaps align that way rather than with CIRCexplorer2's align


Aligning with CIRCexplorer2 takes a while. 
Seems like it creates its own indexes from these indexes and gtf
Should probably create a good index and use STAR instead.
This would also facilitate paired end alignment.







```
export BOWTIE_INDEXES=/francislab/data1/refs/CIRCexplorer2
export BOWTIE2_INDEXES=/francislab/data1/refs/CIRCexplorer2

unset BOWTIE_INDEXES
unset BOWTIE2_INDEXES
export PATH="${HOME}/.local/tophat-2.1.0.Linux_x86_64:${PATH}"
module load tophat bowtie/1.3.1 bowtie2/2.4.1 bedtools2/2.30.0

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="align" \
--time=20160 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/CIRCexplorer2-align.out.log \
--wrap="CIRCexplorer2 align -G /francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf --thread 64 --bowtie1 bowtie1_index --bowtie2 bowtie2_index -f /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz"

```




--bowtie1 and --bowtie2 are the NAMES of the indexes in the BOWTIE_INDEX / BOWTIE2_INDEXES folder

```
[2023-04-27 09:13:10] Beginning TopHat run (v2.1.1)
-----------------------------------------------
[2023-04-27 09:13:10] Checking for Bowtie
		  Bowtie version:	 2.4.1.0
[2023-04-27 09:13:11] Checking for Bowtie index files (genome)..
[2023-04-27 09:13:11] Checking for reference FASTA file
	Warning: Could not find FASTA file /francislab/data1/refs/bowtie2/francislab/data2/refs/CIRCexplorer2/alignment/bowtie2_index/bowtie2_index.fa
[2023-04-27 09:13:11] Reconstituting reference FASTA file from Bowtie index
  Executing: /software/c4/cbi/software/bowtie2-2.4.1/bowtie2-inspect /francislab/data2/refs/CIRCexplorer2/alignment/bowtie2_index/bowtie2_index > /francislab/data2/refs/CIRCexplorer2/alignment/tophat/tmp/bowtie2_index.fa
[2023-04-27 09:17:15] Generating SAM header for /francislab/data2/refs/CIRCexplorer2/alignment/bowtie2_index/bowtie2_index
[2023-04-27 09:17:41] Reading known junctions from GTF file
[2023-04-27 09:18:19] Preparing reads
	 left reads: min. length=76, max. length=76, 57201535 kept reads (71936 discarded)
[2023-04-27 09:35:57] Building transcriptome data files /francislab/data2/refs/CIRCexplorer2/alignment/tophat/tmp/hg38_ref_all
[2023-04-27 09:37:13] Building Bowtie index from hg38_ref_all.fa

```

Canceled as have paired data so will be using STAR anyway.

Apparently uses environment variable BOWTIE2_INDEXES to locate bowtie2 index and not the path provided.

/francislab/data1/refs/bowtie2/francislab/data2/refs/CIRCexplorer2/alignment/bowtie2_index/bowtie2_index.fa






Align paired end with STAR, but will not be able to run Assemble or Denovo steps

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="STAR" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/STAR-align.out.log \
--wrap "module load star/2.7.7a; \
STAR --chimSegmentMin 10 --runMode alignReads \
--runThreadN 16 \
--readFilesCommand zcat \
--readFilesIn /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz \
/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz \
--genomeDir /francislab/data1/refs/CIRCexplorer2/hg38-ref_all-2.7.7a  \
--readFilesType Fastx \
--outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix /francislab/data1/refs/CIRCexplorer2/02-0047-01A."

```


64 failed. Trying 32 thread. Failed. Trying 16. 16 works. Guess all the extra threads results in too many open files.

```
BAMoutput.cpp:27:BAMoutput: exiting because of *OUTPUT FILE* error: could not create output file /francislab/data1/refs/CIRCexplorer2/02-0047-01A._STARtmp//BAMsort/19/46
SOLUTION: check that the path exists and you have write permission for this file. Also check ulimit -n and increase it to allow more open files.

Apr 27 11:34:38 ...... FATAL ERROR, exiting

```









Trying to align paired with tophat so can run all pipelines.

Not sure if running paired make much difference

```

gtf_juncs /francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf  > /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.juncs
chmod -w /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.juncs

gtf_to_fasta --min-anchor 8 --splice-mismatches 2 --min-report-intron 50 --max-report-intron 500000 --min-isoform-fraction 0.15 --output-dir /francislab/data2/refs/CIRCexplorer2/ --max-multihits 1 --max-seg-multihits 10 --segment-length 25 --segment-mismatches 2 --min-closure-exon 100 --min-closure-intron 50 --max-closure-intron 5000 --min-coverage-intron 50 --max-coverage-intron 20000 --min-segment-intron 50 --max-segment-intron 500000 --read-mismatches 2 --read-gap-length 2 --read-edit-dist 2 --read-realign-edit-dist 3 --max-insertion-length 3 --max-deletion-length 3 -z gzip -p64 --gtf-annotations /francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf --gtf-juncs /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.juncs --no-closure-search --no-coverage-search /francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf /francislab/data2/refs/CIRCexplorer2/bowtie2_index.fa /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.fa
chmod -w /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.fa
chmod -w /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.fa.tlst


bowtie2-build --threads 8 /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.fa /francislab/data2/refs/CIRCexplorer2/hg38_ref_all
chmod -w /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.*bt2
```




```
tophat -g 1 --microexon-search -m 2 -G /francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf -p 18 -o /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat /francislab/data2/refs/CIRCexplorer2/bowtie2_index /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz

#>prep_reads:
/software/c4/cbi/software/tophat-2.1.1/prep_reads --min-anchor 8 --splice-mismatches 2 --min-report-intron 50 --max-report-intron 500000 --min-isoform-fraction 0.15 --output-dir /francislab/data2/refs/CIRCexplorer2/alignment/tophat/ --max-multihits 1 --max-seg-multihits 10 --segment-length 25 --segment-mismatches 2 --min-closure-exon 100 --min-closure-intron 50 --max-closure-intron 5000 --min-coverage-intron 50 --max-coverage-intron 20000 --min-segment-intron 50 --max-segment-intron 500000 --read-mismatches 2 --read-gap-length 2 --read-edit-dist 2 --read-realign-edit-dist 3 --max-insertion-length 3 --max-deletion-length 3 -z gzip -p64 --gtf-annotations /francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf --gtf-juncs /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.juncs --no-closure-search --no-coverage-search --aux-outfile=/francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/prep_reads.info --index-outfile=/francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/left_kept_reads.bam.index --sam-header=/francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/bowtie2_index_genome.bwt.samheader.sam --outfile=/francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/left_kept_reads.bam /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz

/software/c4/cbi/software/tophat-2.1.1/bam2fastx --all /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/left_kept_reads.bam|/software/c4/cbi/software/bowtie2-2.4.1/bowtie2 -k 60 -D 15 -R 2 -N 0 -L 20 -i S,1,1.25 --gbar 4 --mp 6,2 --np 1 --rdg 5,3 --rfg 5,3 --score-min C,-14,0 -p 64 --sam-no-hd -x /francislab/data2/refs/CIRCexplorer2/hg38_ref_all -|/software/c4/cbi/software/tophat-2.1.1/fix_map_ordering --bowtie2-min-score 15 --read-mismatches 2 --read-gap-length 2 --read-edit-dist 2 --read-realign-edit-dist 3 --sam-header /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/hg38_ref_all.bwt.samheader.sam - - /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/left_kept_reads.m2g_um.bam | /software/c4/cbi/software/tophat-2.1.1/map2gtf --sam-header /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/bowtie2_index_genome.bwt.samheader.sam /francislab/data2/refs/CIRCexplorer2/hg38_ref_all.fa.tlst - /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/tmp/left_kept_reads.m2g.bam > /francislab/data2/refs/CIRCexplorer2/alignment-test/tophat/logs/m2g_left_kept_reads.out

```









##	Parse


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="CIRC-Parse" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/CIRCexplorer2-parse.out.log \
--wrap "CIRCexplorer2 parse -t STAR ${PWD}/02-0047-01A.Chimeric.out.junction"

```





##	Annotate


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="CIRC-Anno" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/CIRCexplorer2-annotate.out.log \
--wrap "CIRCexplorer2 annotate --ref ${PWD}/hg38_ref_all.txt --genome ${PWD}/hg38.fa --bed ${PWD}/back_spliced_junction.bed --output ${PWD}/circularRNA_known.txt"

```




##	Assemble


Assemble - Denovo - doesn't really work with paired end data explicitly



Not sure how to assemble without having run "CIRCexplorer2 align"

The tophat directory is input which I don't have

FileNotFoundError: [Errno 2] No such file or directory: '/francislab/data1/refs/CIRCexplorer2/tophat/junctions.bed'



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="CIRC-Ass" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/CIRCexplorer2-assemble.out.log \
--wrap "module load cufflinks;CIRCexplorer2 assemble --ref ${PWD}/hg38_ref_all.txt --tophat ${PWD}/tophat --output ${PWD}/assemble"

```




##	Denovo






Usage: CIRCexplorer2 denovo [options] -r REF -g GENOME -b JUNC [-d CUFF] [-o OUT]

Options:
    -h --help                      Show help message.
    --version                      Show version.
    -r REF --ref=REF               Gene annotation.
    --as=AS                        Detect alternative splicing and output.
    --as-type=AS_TYPE              Only check certain type (CE/RI/ASS) of AS events.
    --abs=ABS                      Detect alternative back-splicing and output.
    -b JUNC --bed=JUNC             Input file.
    -d CUFF --cuff=CUFF            assemble folder output by CIRCexplorer2 assemble. [default: '']
    -m TOPHAT --tophat=TOPHAT      TopHat mapping folder.
    -n PLUS_OUT --pAplus=PLUS_OUT  TopHat mapping directory for p(A)+ RNA-seq.
    -o OUT --output=OUT            Output Folder. [default: denovo]
    -g GENOME --genome=GENOME      Genome FASTA file.
    --no-fix                       No-fix mode (useful for species with poor gene annotations).
    --rpkm                         Calculate RPKM for cassette exons.




```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="CIRC-denovo" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/CIRCexplorer2-denovo.out.log \
--wrap "CIRCexplorer2 denovo --ref ${PWD}/hg38_ref_all.txt --genome ${PWD}/hg38.fa --bed ${PWD}/back_spliced_junction.bed --abs abs --as as --tophat ${PWD}/tophat --pAplus pAplus_tophat --output ${PWD}/denovo"

```



























---

Weird errors.

CIRCexplorer2.fail/L6_R1/tophat_fusion.log 

[2020-12-11 08:27:06] Mapping left_kept_reads_seg6 to genome bowtie1_index with Bowtie (6/6)
[2020-12-11 08:27:08] Searching for junctions via segment mapping
[2020-12-11 08:28:21] Retrieving sequences for splices
[2020-12-11 08:29:23] Indexing splices
[2020-12-11 08:29:23] Mapping left_kept_reads_seg1 to genome segment_juncs with Bowtie (1/6)
	[FAILED]
Error running bowtie:
Error while flushing and closing output
terminate called after throwing an instance of 'int'




https://www.biostars.org/p/104269/

Suggests downgrading bowtie2 from 2.2.3 to 2.2.2 worked for them

Same results

tail /francislab/data1/raw/20201127-EV_CATS/CIRCexplorer2/L6_R1/tophat_fusion.log 
[2020-12-14 20:27:00] Mapping left_kept_reads_seg6 to genome bowtie1_index with Bowtie (6/6)
[2020-12-14 20:27:02] Searching for junctions via segment mapping
[2020-12-14 20:27:59] Retrieving sequences for splices
[2020-12-14 20:29:07] Indexing splices
[2020-12-14 20:29:08] Mapping left_kept_reads_seg1 to genome segment_juncs with Bowtie (1/6)
	[FAILED]
Error running bowtie:
Error while flushing and closing output
terminate called after throwing an instance of 'int'




