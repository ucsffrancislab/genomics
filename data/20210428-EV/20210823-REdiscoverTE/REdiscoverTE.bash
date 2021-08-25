#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20210428-EV/20210518-preprocessing/output"
#DIR="/francislab/data1/working/20210428-EV/20210823-REdiscoverTE/output"
DIR="${PWD}/output"

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable "
date=$( date "+%Y%m%d%H%M%S" )

mkdir -p ${DIR}

for raw in ${INDIR}/SFHH00*.{bbduk,cutadapt}?.fastq.gz ; do

	echo $raw
	basename=$( basename $raw .fastq.gz )
	echo $basename

	if [[ "${basename%.*}" =~ ^(SFHH005k|SFHH005v|SFHH005ag|SFHH005ar|SFHH006k|SFHH006v|SFHH006ag|SFHH006ar)$ ]]; then
		echo "Skipping ${basename}"
		continue
	fi
	echo "Processing ${basename}"

	jobbase=${basename%.*}
	trimmer=${basename#*.}
	jobbase=${jobbase}${trimmer:0:1}${trimmer: -1}

	in_base=${INDIR}/${basename}
	out_base=${DIR}/${basename}
	separate_id=""
	#f=${out_base}.gt31.fastq.gz
	f=${out_base}.lte31.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		separate_id=$( ${sbatch} --job-name=${jobbase}-sep --time=99 --ntasks=4 --mem=30G \
			--output=${out_base}.separate.${date}.txt \
			${PWD}/fastq_separate_by_length.bash ${raw} )
		echo ${separate_id}
	fi


	in_base=${DIR}/${basename}


	#	OUT OF MEMORY FAILURE - upped from 8/60 to 16/110
	#	19.bbduk1k15, 20.bbduk1k15, 23.bbduk1k15, 73.bbduk1k15, 68.bbduk1k15, 66.bbduk1k15, ...

	#	TIMEOUT - upped from 99 to 999
	#	70.bbduk2k31, 62.bbduk2k15, 61.bbduk2k31, 61.bbduk3k15, 59.bbduk3k15, 52.bbduk3k31, ...

	infile=${in_base}.lte31.fastq.gz
	out_base=${in_base}.salmon.REdiscoverTE.k15
	f=${out_base}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${separate_id} ] ; then
			depend="--dependency=afterok:${separate_id}"
		else
			depend=""
		fi

		threads=16
		mem=110

		#	infile won't exist immediately so reference raw file
		infile_size=$( stat --dereference --format %s ${raw} )
		index=${SALMON}/REdiscoverTE.k15
		index_size=$( du -sb ${index} | awk '{print $1}' )
	
		#	I'm not sure if C4 scratch uses node count

		#scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
		scratch=$( echo $(( (((3*${infile_size})+${index_size})/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output
	
		echo "Using scratch:${scratch}"
	
		${sbatch} ${depend} --mem=${mem}G --job-name=${jobbase}k15 --ntasks=${threads} --time=999 \
			--gres=scratch:${scratch}G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
				--libType A --unmatedReads ${infile} --validateMappings \
				-o ${out_base} --threads ${threads}
	fi


	infile=${in_base}.gt31.fastq.gz
	out_base=${in_base}.salmon.REdiscoverTE.k31
	f=${out_base}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${separate_id} ] ; then
			depend="--dependency=afterok:${separate_id}"
		else
			depend=""
		fi

		threads=16
		mem=110

		#	infile won't exist immediately so reference raw file
		infile_size=$( stat --dereference --format %s ${raw} )
		index=${SALMON}/REdiscoverTE.k31
		index_size=$( du -sb ${index} | awk '{print $1}' )
	
		#scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
		scratch=$( echo $(( (((3*${infile_size})+${index_size})/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output
	
		echo "Using scratch:${scratch}"
	
		${sbatch} ${depend} --mem=${mem}G --job-name=${jobbase}k31 --ntasks=${threads} --time=999 \
			--gres=scratch:${scratch}G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
				--libType A --unmatedReads ${infile} --validateMappings \
				-o ${out_base} --threads ${threads}
	fi

done

