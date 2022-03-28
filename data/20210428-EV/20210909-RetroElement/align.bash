#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "

INDIR=/francislab/data1/working/20210428-EV/20210830-filter/output
DIR=${PWD}/output
mkdir $DIR

for raw in ${INDIR}/*fastq.gz ; do

	echo $raw
	basename=$( basename $raw .filtered.fastq.gz )
	echo $basename

	#1_11,SFHH005k,SFHH006k,V01 control (S1)
	#3_11,SFHH005ag,SFHH006ag,V01 control (S1)

	#echo "${basename%%.*}"

	#if [[ ! "${basename%%.*}" =~ ^(SFHH005k|SFHH005v|SFHH005ag|SFHH005ar|SFHH006k|SFHH006v|SFHH006ag|SFHH006ar)$ ]]; then
	#if [[ ! "${basename%%.*}" =~ ^(SFHH005k|SFHH005ag|SFHH006k|SFHH006ag)$ ]]; then
	if [[ "${basename%%.*}" =~ ^(SFHH005v|SFHH005ar|SFHH006v|SFHH006ar)$ ]]; then
		echo "Skipping ${basename}"
		continue
	fi
	echo "Processing ${basename}"


#	align to hg38

	in_base=${INDIR}/${basename}
	out_base=${DIR}/${basename}

	infile=${raw}

	alignid=""
	out_base=${out_base}
	#f=${out_base}.fastq.gz
	f=${out_base}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
#		if [ ! -z ${separate_id} ] ; then
#			depend="--dependency=afterok:${separate_id}"
#		else
#			depend=""
#		fi
#
#		threads=16
#		mem=110
#
#		#	infile won't exist immediately so reference raw file
#		infile_size=$( stat --dereference --format %s ${raw} )
#		index=${SALMON}/REdiscoverTE.k15
#		index_size=$( du -sb ${index} | awk '{print $1}' )
#	
#		#	I'm not sure if C4 scratch uses node count
#
#		#scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
#		scratch=$( echo $(( (((3*${infile_size})+${index_size})/1000000000*12/10)+1 )) )
#		# Add 1 in case files are small so scratch will be 1 instead of 0.
#		# 11/10 adds 10% to account for the output
#		# 12/10 adds 20% to account for the output
#	
#		echo "Using scratch:${scratch}"
	
#		${sbatch} ${depend} --mem=${mem}G --job-name=${jobbase}k15 --ntasks=${threads} --time=999 \
#			--gres=scratch:${scratch}G \
#			--output=${out_base}.${date}.txt \
#			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
#				--libType A --unmatedReads ${infile} --validateMappings \
#				-o ${out_base} --threads ${threads}


		alignid=$( ${sbatch} --job-name=${basename} --time=180 --nodes=1 --ntasks=8 --mem=60G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 --very-sensitive-local \
				-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
				-U ${infile} --output ${f} )
		echo ${alignid}

	fi






done


