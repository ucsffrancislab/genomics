#!/usr/bin/env bash


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
dir=/francislab/data1/raw/20191008_Stanford71/trimmed/unpaired

threads=16
vmem=8
date=$( date "+%Y%m%d%H%M%S" )




#	for ext in mi_11 mt_11 hp_11 ; do
#	
#		#	produces kallisto.single.hp_11.sleuth.plots.pdf
#	
#		outbase=${dir}/kallisto.single.${ext}.sleuth
#		f=${outbase}.plots.pdf
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			qsub -N sleuth.${ext} -l vmem=4gb -o ${outbase}.${date}.out -e ${outbase}.${date}.err \
#				~/.local/bin/sleuth.bash -F "--suffix kallisto.single.${ext} --metadata /francislab/data1/raw/20191008_Stanford71/metadata.csv"
#		fi
#	
#	done




for bambase in subread-dna subread-rna bowtie2-e2e ; do

	for feature in miRNA miRNA_primary_transcript ; do

		outbase="${dir}/${bambase}.hsa.featureCounts.${feature}"

		f="${outbase}.csv"
		fcid=''
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			fcid=$( qsub -N ${feature} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-o ${outbase}.${date}.out.txt \
				-e ${outbase}.${date}.err.txt \
				~/.local/bin/featureCounts.bash -F \
					"-T ${threads} -t ${feature} -g Name -a ${FASTA}/hg38.chr.hsa.gff3 \
					-o ${f} ${dir}/??.h38au.${bambase}.bam" )
			echo $fcid
		fi

		counts=${f}
		outbase=${f}.deseq
		f=${outbase}.plots.pdf
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			#echo "Creating $f"
			if [ ! -z ${fcid} ] ; then
				depend="-W depend=afterok:${fcid}"
			else
				depend=""
			fi
			qsub ${depend} -N deseq.${feature} -l vmem=4gb -o ${outbase}.${date}.out -e ${outbase}.${date}.err \
				~/.local/bin/deseq.bash -F \
				"-f ${counts} -m /francislab/data1/raw/20191008_Stanford71/metadata.csv"
		fi

	done	#	for feature in miRNA miRNA_primary_transcript ; do


	for feature in exon CDS start_codon stop_codon ; do

		outbase="${dir}/${bambase}.genes.featureCounts.${feature}"

		f="${outbase}.csv"
		fcid=''
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			fcid=$( qsub -N ${feature} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-o ${outbase}.${date}.out.txt \
				-e ${outbase}.${date}.err.txt \
				~/.local/bin/featureCounts.bash -F \
					"-T ${threads} -t ${feature} -g gene_id \
					-a ${REFS}/Homo_sapiens/UCSC/hg38/Annotation/Genes/genes.gtf \
					-o ${f} ${dir}/??.h38au.${bambase}.bam" )
			echo $fcid
		fi

		counts=${f}
		outbase=${f}.deseq
		f=${outbase}.plots.pdf
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			#echo "Creating $f"
			if [ ! -z ${fcid} ] ; then
				depend="-W depend=afterok:${fcid}"
			else
				depend=""
			fi
			qsub ${depend} -N deseq.${feature} -l vmem=4gb -o ${outbase}.${date}.out -e ${outbase}.${date}.err \
				~/.local/bin/deseq.bash -F \
				"-f ${counts} -m /francislab/data1/raw/20191008_Stanford71/metadata.csv"
		fi

	done	#	for feature in exon CDS start_codon stop_codon ; do

done	#	for bambase in subread-dna subread-rna ; do

