#/usr/bin/env bash


#	pip install --upgrade --user pysam==0.15.2
#	export PATH="$HOME/.local/tophat-2.1.0/:$PATH"
#	module load samtools/1.7
#	module load bowtie2/2.3.4.1
#	module load bowtie/1.2.2
#	module load python/2.7.10


OUT=${PWD}/CIRCexplorer2

mkdir -p ${OUT}

TXT=/francislab/data1/refs/CIRCexplorer2/hg38_ref_all.txt
GTF=/francislab/data1/refs/CIRCexplorer2/hg38_ref_all.gtf
GEN=/francislab/data1/refs/CIRCexplorer2/hg38.fa
BT1=/francislab/data1/refs/CIRCexplorer2/bowtie1_index
BT2=/francislab/data1/refs/CIRCexplorer2/bowtie2_index


INDIR=/francislab/data1/raw/20201127-EV_CATS/output

for f in ${INDIR}/trimmed*q.gz ; do
	base=${f%_001.fastq.gz}
	base=${base/_S?_L001/}
	base=${base/trimmed_/}
	basename=$(basename $base)
	mkdir -p ${OUT}/$basename
	echo $f
	echo $basename

	align=$( qsub -N ${basename}align -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
		-o ${OUT}/${basename}-align.out \
		-e ${OUT}/${basename}-align.err \
		~/.local/bin/CIRCexplorer2 \
		-F "align --thread=8 --gtf=$GTF --bowtie1=$BT1 --bowtie2=$BT2 --fastq=${f} --output=${OUT}/${basename} --bed=${OUT}/${basename}/back_spliced_junction.bed" )
	echo $align



	if [ ! -z ${align} ] ; then
		depend="-W depend=afterok:${align}"
	else
		depend=""
	fi
	parse=$( qsub -N ${basename}parse -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
		${depend} \
		-o ${OUT}/${basename}-parse.out \
		-e ${OUT}/${basename}-parse.err \
		~/.local/bin/CIRCexplorer2 \
		-F "parse -t TopHat-Fusion ${OUT}/${basename}/tophat_fusion/accepted_hits.bam \
			--bed=${OUT}/${basename}/back_spliced_junction.bed" )
	echo $parse



	if [ ! -z ${parse} ] ; then
		depend="-W depend=afterok:${parse}"
	else
		depend=""
	fi
	annotate=$( qsub -N ${basename}annotate -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
		${depend} \
		-o ${OUT}/${basename}-annotate.out \
		-e ${OUT}/${basename}-annotate.err \
		~/.local/bin/CIRCexplorer2 \
		-F "annotate -r $TXT -g $GEN -b ${OUT}/${basename}/back_spliced_junction.bed -o ${OUT}/${basename}/circularRNA_known.txt" )
	echo $annotate



	if [ ! -z ${annotate} ] ; then
		depend="-W depend=afterok:${annotate}"
	else
		depend=""
	fi
	assemble=$( qsub -N ${basename}assemble -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
		${depend} \
		-o ${OUT}/${basename}-assemble.out \
		-e ${OUT}/${basename}-assemble.err \
		~/.local/bin/CIRCexplorer2 \
		-F "assemble --thread=8 --ref=$TXT --tophat=${OUT}/${basename}/tophat --output=${OUT}/${basename}/assemble" )
	echo $assemble



	if [ ! -z ${assemble} ] ; then
		depend="-W depend=afterok:${assemble}"
	else
		depend=""
	fi
	denovo=$( qsub -N ${basename}denovo -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
		${depend} \
		-o ${OUT}/${basename}-denovo.out \
		-e ${OUT}/${basename}-denovo.err \
		~/.local/bin/CIRCexplorer2 \
		-F "denovo --ref=$TXT --genome=$GEN --bed=${OUT}/${basename}/back_spliced_junction.bed --abs=abs --as=as --tophat=${OUT}/${basename}/tophat --pAplus=pAplus_tophat --cuff=${OUT}/${basename}/assemble --output=${OUT}/${basename}/denovo" )
	echo $denovo


	echo
done

