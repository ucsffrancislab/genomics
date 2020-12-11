#/usr/bin/env bash



OUT=${PWD}/CIRCexplorer2

mkdir -p ${OUT}

TXT=/francislab/data1/refs/CIRCexplorer2/hg38_ref_all.txt
GTF=/francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf
GEN=/francislab/data1/refs/CIRCexplorer2/hg38.fa
BT1=/francislab/data1/refs/CIRCexplorer2/bowtie1_index
BT2=/francislab/data1/refs/CIRCexplorer2/bowtie2_index

for f in ${PWD}/output/trimmed*q.gz ; do
	base=${f%_001.fastq.gz}
	base=${base/_S?_L001/}
	base=${base/trimmed_/}
	basename=$(basename $base)
	echo $f
	echo $basename
	
	CIRCexplorer2 align --thread=10 --gtf=$GTF --bowtie1=$BT1 --bowtie2=$BT2 --fastq=${f} --output=${OUT}/${basename} > ${OUT}/${basename}-CIRCexplorer2_align.log

#	CIRCexplorer2 parse -t TopHat-Fusion tophat_fusion/accepted_hits.bam > ${OUT}/${basename}-CIRCexplorer2_parse.log

#	CIRCexplorer2 annotate -r $TXT -g $GEN -b back_spliced_junction.bed -o circularRNA_known.txt > ${OUT}/${basename}-CIRCexplorer2_annotate.log

#	CIRCexplorer2 assemble -r $TXT -m tophat -o assemble > ${OUT}/${basename}-CIRCexplorer2_assemble.log

#	CIRCexplorer2 denovo -r $TXT -g $GEN -b back_spliced_junction.bed --abs abs --as as -m tophat -n pAplus_tophat -o denovo > ${OUT}/${basename}-CIRCexplorer2_denovo.log

done

