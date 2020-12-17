#/usr/bin/env bash



OUT=${PWD}/CIRCexplorer2

mkdir -p ${OUT}

TXT=/francislab/data1/refs/CIRCexplorer2/hg38_ref_all.txt
GTF=/francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf
GEN=/francislab/data1/refs/CIRCexplorer2/hg38.fa

#export BOWTIE_INDEXES=/francislab/data1/refs/CIRCexplorer2/
#export BOWTIE2_INDEXES=/francislab/data1/refs/CIRCexplorer2/

BT1=/francislab/data1/refs/CIRCexplorer2/bowtie1_index
BT2=/francislab/data1/refs/CIRCexplorer2/bowtie2_index
#BT1=bowtie1_index
#BT2=bowtie2_index

for f in ${PWD}/output/trimmed*q.gz ; do
#for f in ${PWD}/output/trimmed*L6*R1*q.gz ; do
	base=${f%_001.fastq.gz}
	base=${base/_S?_L001/}
	base=${base/trimmed_/}
	basename=$(basename $base)
	mkdir -p ${OUT}/$basename
	echo $f
	echo $basename

#	qsub -N ${basename} -l nodes=1:ppn=16 -l vmem=125gb -l feature=nocommunal \
#		-o ${OUT}/${basename}-CIRCexplorer2_align.out \
#		-e ${OUT}/${basename}-CIRCexplorer2_align.err \
#		~/.local/bin/CIRCexplorer2 \
#		-F "align --thread=16 --gtf=$GTF --bowtie1=$BT1 --bowtie2=$BT2 --fastq=${f} --output=${OUT}/${basename}"

#	echo
#	echo "~/.local/bin/CIRCexplorer2 align --thread=60 --gtf=$GTF --bowtie1=$BT1 --bowtie2=$BT2 --fastq=${f} --output=${OUT}/${basename} > ${OUT}/${basename}-CIRCexplorer2_align.out 2> ${OUT}/${basename}-CIRCexplorer2_align.err"


	mkdir -p ${OUT}/${basename}/tophat
	mkdir -p ${OUT}/${basename}/tophat_fusion
	echo "tophat2 -a 6 --microexon-search -m 2 -p 10 -G ${GTF} -o ${OUT}/${basename}/tophat ${BT2} ${f}"
	echo "bamToFastq -i ${OUT}/${basename}/tophat/unmapped.bam -fq ${OUT}/${basename}/tophat/unmapped.fastq"
	echo "tophat2 -o ${OUT}/${basename}/tophat_fusion -p 15 --fusion-search --keep-fasta-order --bowtie1 --no-coverage-search ${BT1} ${OUT}/${basename}/tophat/unmapped.fastq"
#
#	I just cannot get tophat2 / tophat fusion to run. At best, fails at fix_map_order (sp?) about missing header.
#
#	echo
#	#STAR --chimSegmentMin 10 --runThreadN 10 --genomeDir hg19_STAR_index --readFilesIn RNA_seq.fastq

#	echo "STAR --readFilesCommand zcat --chimSegmentMin 10 --runThreadN 60 --genomeDir /francislab/data1/refs/CIRCexplorer2/STAR --outFileNamePrefix ${OUT}/${basename}/ --readFilesIn ${f} > ${OUT}/${basename}-STAR.out 2> ${OUT}/${basename}-STAR.err"
#	echo "STAR --chimSegmentMin 10 --runThreadN 60 --genomeDir /francislab/data1/refs/CIRCexplorer2/STAR --outFileNamePrefix ${OUT}/${basename}/ --readFilesIn ${f} > ${OUT}/${basename}-STAR.out 2> ${OUT}/${basename}-STAR.err"







#	align=$( qsub -N ${basename}align -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		-o ${OUT}/${basename}-STAR.out \
#		-e ${OUT}/${basename}-STAR.err \
#		~/.local/bin/STAR.bash \
#		-F "--readFilesCommand zcat --outSAMtype BAM Unsorted --chimSegmentMin 10 --runThreadN 8 --genomeDir /francislab/data1/refs/CIRCexplorer2/STAR --outFileNamePrefix ${OUT}/${basename}/ --readFilesIn ${f}" )

	#	this pipeline doesn't use the bam output, but my script requires it

#	if [ ! -z ${align} ] ; then
#		depend="-W depend=afterok:${align}"
#	else
#		depend=""
#	fi
#	parse=$( qsub -N ${basename}parse -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		${depend} \
#		-o ${OUT}/${basename}-parse.out \
#		-e ${OUT}/${basename}-parse.err \
#		~/.local/bin/CIRCexplorer2 \
#		-F "parse -t STAR \
#			--bed=${OUT}/${basename}/back_spliced_junction.bed \
#			${OUT}/${basename}/Chimeric.out.junction" )
#	echo $parse



#	if [ ! -z ${parse} ] ; then
#		depend="-W depend=afterok:${parse}"
#	else
#		depend=""
#	fi
#	annotate=$( qsub -N ${basename}annotate -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		${depend} \
#		-o ${OUT}/${basename}-annotate.out \
#		-e ${OUT}/${basename}-annotate.err \
#		~/.local/bin/CIRCexplorer2 \
#		-F "annotate -r $TXT -g $GEN -b ${OUT}/${basename}/back_spliced_junction.bed -o ${OUT}/${basename}/circularRNA_known.txt" )
#	echo $annotate














#	IOError: [Errno 2] No such file or directory: 'tophat/junctions.bed'

#	if [ ! -z ${annotate} ] ; then
#		depend="-W depend=afterok:${annotate}"
#	else
#		depend=""
#	fi
#	assemble=$( qsub -N ${basename}assemble -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		${depend} \
#		-o ${OUT}/${basename}-assemble.out \
#		-e ${OUT}/${basename}-assemble.err \
#		~/.local/bin/CIRCexplorer2 \
#		-F "assemble --thread=8 --ref=$TXT -m tophat --output=${OUT}/${basename}/assemble" )
#	echo $assemble
##	CIRCexplorer2 assemble -r $TXT -m tophat -o assemble > ${OUT}/${basename}-CIRCexplorer2_assemble.log


#	if [ ! -z ${assemble} ] ; then
#		depend="-W depend=afterok:${assemble}"
#	else
#		depend=""
#	fi
#	denovo=$( qsub -N ${basename}denovo -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		${depend} \
#		-o ${OUT}/${basename}-denovo.out \
#		-e ${OUT}/${basename}-denovo.err \
#		~/.local/bin/CIRCexplorer2 \
#		-F "denovo -r $TXT -g $GEN -b back_spliced_junction.bed --abs abs --as as -m tophat -n pAplus_tophat -o denovo" )
#	echo $denovo

#	CIRCexplorer2 denovo -r $TXT -g $GEN -b back_spliced_junction.bed --abs abs --as as -m tophat -n pAplus_tophat -o denovo > ${OUT}/${basename}-CIRCexplorer2_denovo.log

	echo
done

