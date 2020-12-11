#!/usr/bin/env bash


OUT=${PWD}/align
mkdir -p ${OUT}
mkdir -p ${OUT}/bowtie2
mkdir -p ${OUT}/STAR


for f in ${PWD}/output/trimmed*q.gz ; do
	base=${f%_001.fastq.gz}
	base=${base/_S?_L001/}
	base=${base/trimmed_/}
	basename=$(basename $base)
	echo $f

	for x in mirna hg38 ; do
	#for a in very-sensitive very-sensitive-local ; do
	for a in vs vsl ; do

		out=${basename}.${a}_${x}
		
		if [ $a == "vs" ] ; then
			b="very-sensitive"
		else
			b="very-sensitive-local"
		fi

		qsub -N ${out} -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
			-o ${OUT}/bowtie2/${out}.out \
			-e ${OUT}/bowtie2/${out}.err \
			~/.local/bin/bowtie2.bash \
			-F "--sort --${b} -x ${x} -U $f -o ${OUT}/bowtie2/${out}.bam"

	done ; done

#	qsub -N ${out} -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		-o ${OUT}/bowtie2/${out}.out \
#		-e ${OUT}/bowtie2/${out}.err \
#		~/.local/bin/bowtie2.bash \
#		-F "--sort --very-sensitive -x human_mirna -U $f -o ${OUT}/bowtie2/${base}.vs_mirna.bam"
#
#	qsub -N ${out} -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		-o ${OUT}/bowtie2/${out}.out \
#		-e ${OUT}/bowtie2/${out}.err \
#		~/.local/bin/bowtie2.bash \
#		-F "--sort --very-sensitive-local -x human_mirna -U $f -o ${OUT}/bowtie2/${base}.vsl_mirna.bam"
#
#	qsub -N ${out} -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		-o ${OUT}/bowtie2/${out}.out \
#		-e ${OUT}/bowtie2/${out}.err \
#		~/.local/bin/bowtie2.bash \
#		-F "--sort --very-sensitive -x hg38 -U $f -o ${OUT}/bowtie2/${base}.vs_hg38.bam"
#
#	qsub -N ${out} -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
#		-o ${OUT}/bowtie2/${out}.out \
#		-e ${OUT}/bowtie2/${out}.err \
#		~/.local/bin/bowtie2.bash \
#		-F "--sort --very-sensitive-local -x hg38 -U $f -o ${OUT}/bowtie2/${base}.vsl_hg38.bam"

	for ref in /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq /francislab/data1/refs/STAR/hg38-golden-none ; do 
		baseref=$(basename $ref)
		out=${basename}_${baseref}
		#command="STAR --twopassMode Basic --outSAMmultNmax 20 --outSAMprimaryFlag AllBestScore --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --runMode alignReads --outFileNamePrefix /francislab/data1/raw/20201127-EV_CATS/STAR/${out}. --outSAMtype BAM SortedByCoordinate --genomeDir ${ref} --runThreadN 16 --outSAMattrRGline ID:${out} SM:${out} --readFilesCommand zcat --outSAMunmapped Within --readFilesIn ${f}"
		#echo ${command}
		#echo ${command} | qsub -N ${out} -l nodes=1:ppn=16 -l vmem=125gb -l feature=nocommunal -o /francislab/data1/raw/20201127-EV_CATS/STAR/${out}.out -e /francislab/data1/raw/20201127-EV_CATS/STAR/${out}.err

		qsub -N ${out} -l nodes=1:ppn=8 -l vmem=62gb -l feature=nocommunal \
			-o ${OUT}/STAR/${out}.out \
			-e ${OUT}/STAR/${out}.err \
			~/.local/bin/STAR.bash -F "--twopassMode Basic --outSAMmultNmax 20 --outSAMprimaryFlag AllBestScore --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --runMode alignReads --outFileNamePrefix ${OUT}/STAR/${out}. --outSAMtype BAM SortedByCoordinate --genomeDir ${ref} --runThreadN 8 --outSAMattrRGline ID:${out} SM:${out} --readFilesCommand zcat --outSAMunmapped Within --readFilesIn ${f}"

done ; done




#	Compare read counts
#	
#	echo "sample,raw,trimmed,bowtie e2e,bowtie loc,STAR gtf,STAR none" > read_counts.csv
#	for l in 6 8; do
#	for r in 1 2; do
#	x=$( zcat output/L${l}_S?_L001_R${r}_001.fastq.gz | paste - - - - | wc -l )
#	c=$( zcat output/trimmed_L${l}_S?_L001_R${r}_001.fastq.gz | paste - - - - | wc -l )
#	echo -n "L${l}_R${r},${x},${c}"
#	for f in */trimmed_L${l}_R${r}*hg38*bam ; do
#	c=$( samtools view -F4 $f | awk '{print $1}' | sort | uniq | wc -l )
#	echo -n ",${c}"
#	done
#	echo
#	done ; done >> read_counts.csv



