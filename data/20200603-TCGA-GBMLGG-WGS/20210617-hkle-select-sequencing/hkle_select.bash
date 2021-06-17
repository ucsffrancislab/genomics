#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2
DIAMOND=${REFS}/diamond
STAR=${REFS}/STAR
SALMON=${REFS}/salmon

INDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out"
DIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210617-hkle-select-sequencing/out"
mkdir -p ${DIR}

#	remember 64 cores and ~504GB mem
#threads=16
#vmem=125
#threads=8
#vmem=62
threads=4
vmem=30

date=$( date "+%Y%m%d%H%M%S" )

#for r1 in ${INDIR}/[0-9A-F]*_R1.fastq.gz ; do
#for r1 in ${INDIR}/[G-Z]*_R1.fastq.gz ; do
#for r1 in ${INDIR}/F*_R1.fastq.gz ; do
#for r1 in ${INDIR}/02*_R1.fastq.gz ; do

#	Only want to process the ALL files at the moment so ...
while IFS=, read -r sequencing length ; do

	if [ $length -lt 100 ] ; then
		echo "Skipping ${sequencing} as length ${length} is too short"
		continue
	fi

	if [ ${sequencing:8:2} != '01' ] && [ ${sequencing:8:2} != '10' ] ; then
		echo "Skipping ${sequencing} as not 01 or 10"
		continue
	fi

	#base=${r1%_R1.fastq.gz}
	r1=${INDIR}/${sequencing}_R1.fastq.gz
	echo $r1
	r2=${r1/_R1.fastq/_R2.fastq}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	index=${BOWTIE2}/SVAs_and_HERVs_KWHE
	#index=${BOWTIE2}/SVAs_and_HERVK113

	outbase="${DIR}/${base}.$( basename ${index} )"

	f=${outbase}.bam
	#f=${outbase}.fa.gz
	#if [ -d $f ] && [ ! -w $f ] ; then
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		
		r1_size=$( stat --dereference --format %s ${r1} )
		r2_size=$( stat --dereference --format %s ${r2} )

		index_size=$( stat --dereference --format %s ${index}.?.bt2 ${index}.rev.?.bt2 | awk '{s+=$1}END{print s}' )

		#scratch=$( echo $(( ((2*(${r1_size}+${r2_size})+${index_size})/${threads}/1000000000)+1 )) )
		#	c4 doesn't do thread-based scratch calculation. just job.
		scratch=$( echo $(( ((2*(${r1_size}+${r2_size})+${index_size})/1000000000)+1 )) )
		#	Add 1 in case files are small so scratch will be 1 instead of 0.
		#	11/10 adds 10% to account for the output

		echo "Using scratch:${scratch}"

		${sbatch} --time=999 --job-name="${base}.select" --ntasks=${threads} --mem=${vmem}G \
			--gres=scratch:${scratch}G \
			--output=${outbase}.${date}.out.txt \
			~/.local/bin/paired_reads_select_scratch.bash \
				--very-sensitive-local -r ${index} -1 ${r1} -2 ${r2} -o ${f}


#		qsub -N "${base}.select" -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#			-l feature=nocommunal \
#			-l gres=scratch:${scratch} \
#			-j oe -o ${outbase}.${date}.out.txt \
#			~/.local/bin/paired_reads_select_scratch.bash \
#				-F "--very-sensitive-local --score-min G,1,3 -r ${index} -1 ${r1} -2 ${r2} -o ${f}"

# latest version is bowtie2/2.4.2
#	which should include the fix I initiated.
#	https://github.com/BenLangmead/bowtie2/issues/321

#Some Bowtie 2 options specify a function rather than an individual number or setting. In these cases the user specifies three parameters: (a) a function type F, (b) a constant term B, and (c) a coefficient A. The available function types are constant (C), linear (L), square-root (S), and natural log (G). The parameters are specified as F,B,A - that is, the function type, the constant term, and the coefficient are separated by commas with no whitespace. The constant term and coefficient may be negative and/or floating-point numbers.


#	Running chimera on the raw data set finds more than on select.
#	Missing some matches? Lower min score threshold?
#	Default --score-min G,20,8 ( if read length = 100, min score is 56.8 )
#	Testing --score-min G,20,6 ( if read length = 100, min score is 47.6 )
#	Testing --score-min G,20,5 ( if read length = 100, min score is 43.0 )
#		Still misses UNPAIRED alignments
#	Testing --score-min G,20,4 ( if read length = 100, min score is 38.4 )
#	Testing --score-min G,20,3 ( if read length = 100, min score is 33.8 )
#	Testing --score-min G,10,4 ( if read length = 100, min score is 28.4 )
#		STILL MISSES UNPAIRED ALIGNMENTS!
#	Testing --score-min G,1,4  ( if read length = 100, min score is 19.4 )
#		STILL MISSES UNPAIRED ALIGNMENTS! Really not sure how at this point.
#	Testing --score-min G,0,3  ( if read length = 100, min score is 13.8 ) --- The 0 apparently doesn't work
#Error: the match penalty is greater than 0 (2) but the --score-min function can be less than or equal to zero.  Either let the match penalty be 0 or make --score-min always positive.
#	What?
#
#	Testing --score-min G,1,3  ( if read length = 100, min score is 14.8 )


#	Works much better, but still why needed?
#	--local -D 85 -R 5 -N 0 -L 10 -i S,1,0


	fi

done < read_lengths.csv
#done < <( sed 's/,/ /' read_lengths.csv )
#done

