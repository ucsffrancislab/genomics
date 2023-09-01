
#	20200603-TCGA-GBMLGG-WGS/20230831-RMHMViral


Searching for novel viral insertions


Align raw data to viral

minimize intermediate files so think I need to develope a chimera pipeline wrapper



```
bowtie2_array_wrapper.bash --extension _R1.fastq.gz --very-sensitive -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM --outdir ${PWD}/out --threads 8 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230803-cutadapt/out/02-*_R1.fastq.gz

```

--un-conc <path>
--un-conc-gz <path>
--un-conc-bz2 <path>
--un-conc-lz4 <path>
Write paired-end reads that fail to align concordantly to file(s) at <path>. These reads correspond to the SAM records with the FLAGS 0x4 bit set and either the 0x40 or 0x80 bit set (depending on whether it's mate #1 or #2). .1 and .2 strings are added to the filename to distinguish which file contains mate #1 and mate #2. If a percent symbol, %, is used in <path>, the percent symbol is replaced with 1 or 2 to make the per-mate filenames. Otherwise, .1 or .2 are added before the final dot in <path> to make the per-mate filenames. Reads written in this way will appear exactly as they did in the input files, without any modification (same sequence, same name, same quality string, same quality encoding). Reads will not necessarily appear in the same order as they did in the inputs.



