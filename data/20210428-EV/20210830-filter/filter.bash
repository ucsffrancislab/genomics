#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20210428-EV/20210518-preprocessing/output"
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

	infile=${raw}

	alignid=""
	out_base=${out_base}.filtered
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


		alignid=$( ${sbatch} --job-name=${basename} --time=60 --nodes=1 --ntasks=4 --mem=30G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 --very-sensitive-local \
				-x /francislab/data1/refs/bowtie2/NC_001422.1 \
				--un ${out_base}.fastq \
				-U ${infile} --output ${f} )
		echo ${alignid}

#		bowtie2 doesn't actually gzip the --un file
#	doing it manually
#	would need to edit bowtie2.bash to check for --un and the extension and do it

	fi

	out_base=${out_base}.fastq
	f=${out_base}.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${alignid} ] ; then
			depend="--dependency=afterok:${alignid}"
		else
			depend=""
		fi

		${sbatch} --job-name=${basename} --time=60 --nodes=1 --ntasks=4 --mem=30G \
			--output=${out_base}.${date}.txt \
			--wrap="gzip -v ${f%.gz}; chmod -w ${f}"

	fi

done

