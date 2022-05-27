#	TEtools

https://github.com/l-modolo/TEtools





From https://www.biorxiv.org/content/biorxiv/early/2018/05/04/313999.full.pdf

TETools (Lerat et al. 2016)– We generated rosette files for hg38 and mm10 for TETools by taking
the Repeatmasker annotation from Clean for the first column and the repeat taxonomy for the second
column (subfamily:family:superfamily). We used the BED file from Clean with Seek to obtain TE
FASTA sequences for generation of a pseudogenome for TETools. TETools was run with the “-bowtie2”,
“–RNApair” and “–insert 250” parameters for simulated human data and “-bowtie2”,”-insert 76” for
mouse data. 


Hmmm?




```
singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/TEtools.img python3 /TEtools/TEcount.py
```




What is TE_fasta file?


```
TEcount.py -rosette [$]ROSETTE_FILE] -column [$]COUNT_COLUMN] -TE_fasta [FASTA_FILE] -count [OUTPUT_FILE] -RNA [FASTQ_FILE1 FASTQ_FILE2 ... FASTQ_FILEN]

Rscript TEdiff.R --args --FDR_level=[FDR_LEVEL] --count_column=[COUNT_COLUMN] --count_file=\"[COUNT_FILE]\" experiment_formula=\"[EXPERIMENT_FORMULA]\" --sample_names=\"[SAMPLE_NAMES]\" --outdir=\"[OUTPUT_HTML_FOLDER]\" --htmlfile=\"[OUTPUT_HTML_FILE]\"
```


