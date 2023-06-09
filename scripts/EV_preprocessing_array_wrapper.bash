#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo $0 *fastq.gz
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension=".fastq.gz"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; mkdir -p ${OUT}; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done

	echo "extension :${extension}:"


	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools #star/2.7.7a
	fi
	
	date
	

	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	echo "Using array_file :${array_file}:"

	line=$( sed -n "$line_number"p ${array_file} )
	echo $line

	if [ -z "${line}" ] ; then
		echo "No line at :${line_number}:"
		exit
	fi

	base=$( basename $line ${extension} )
	#bam=${line}

	echo
	echo "base : ${base}"
	#echo "bam : $bam"
	echo "line : ${line}"
	echo 

	fastq=${line}



	#	SFHH006aa
	labkit_number=$( echo ${base} | cut -c7 )

	case ${labkit_number} in
		5) labkit="D-plex";;
		6) labkit="Lexogen";; 
	esac
	echo "labkit :${labkit}:"

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x



	out_base=${OUT}/${base}
	f=${out_base}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	These are long list of 1-base offset adapters.

		if [ ${labkit} == "D-plex" ] ; then
			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTG"
			#AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
			#trim_options="-a AGATCGGAAGAGCACACGTCTG"
			#trim_options="-u 16 -a AGATCGGAAGAGCA -a AGATCGGAAGAGCACACGTC -a GATCGGAAGAGCACACGTCT -a ATCGGAAGAGCACACGTCTG -a TCGGAAGAGCACACGTCTGA -a CGGAAGAGCACACGTCTGAA -a GGAAGAGCACACGTCTGAAC -a GAAGAGCACACGTCTGAACT -a AAGAGCACACGTCTGAACTC -a AGAGCACACGTCTGAACTCC -a GAGCACACGTCTGAACTCCA -a AGCACACGTCTGAACTCCAG -a GCACACGTCTGAACTCCAGT -a CACACGTCTGAACTCCAGTC -a ACACGTCTGAACTCCAGTCA"
			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a CCAACTAATCTCGTATGCCGTCTTCTGCTTG"
			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG"

			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG"
			#	GAACTCCAGTCACCAACTAATCTCGTATGCCGTCTTCTGCTTG

			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG"

			trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA \
				-a GAACTCCAGTCAC -a ATCTCGTATGCCGTCTTCTGCTTG"

			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"

		elif [ ${labkit} == "Lexogen" ] ; then
			#TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC
			#trim_options="-a TGGAATTCTCGGGTGCCAAGGA"
			#trim_options="-a TGGAATTCTCGGGT -a TGGAATTCTCGGGTGCCAAG -a GGAATTCTCGGGTGCCAAGG -a GAATTCTCGGGTGCCAAGGA -a AATTCTCGGGTGCCAAGGAA -a ATTCTCGGGTGCCAAGGAAC -a TTCTCGGGTGCCAAGGAACT -a TCTCGGGTGCCAAGGAACTC -a CTCGGGTGCCAAGGAACTCC -a TCGGGTGCCAAGGAACTCCA -a CGGGTGCCAAGGAACTCCAG -a GGGTGCCAAGGAACTCCAGT -a GGTGCCAAGGAACTCCAGTC -a GTGCCAAGGAACTCCAGTCA -a TGCCAAGGAACTCCAGTCAC"
			trim_options="-a TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC"
		else
			trim_options=""
		fi

		#  --action {trim,retain,mask,lowercase,none}
		#                        What to do if a match was found. trim: trim adapter and up- or downstream
		#                        sequence; retain: trim, but retain adapter; mask: replace with 'N' characters;
		#                        lowercase: convert to lowercase; none: leave unchanged. Default: trim

		#  -a ADAPTER, --adapter ADAPTER
		#                        Sequence of an adapter ligated to the 3' end (paired data: of the first read).
		#                        The adapter and subsequent bases are trimmed. If a '$' character is appended
		#                        ('anchoring'), the adapter is only found if it is a suffix of the read.
		
		#  -e E, --error-rate E, --errors E
		#                        Maximum allowed error rate (if 0 <= E < 1), or absolute number of errors for
		#                        full-length adapter match (if E is an integer >= 1). Error rate = no. of errors
		#                        divided by length of matching region. Default: 0.1 (10%)
		
		#  -q [5'CUTOFF,]3'CUTOFF, --quality-cutoff [5'CUTOFF,]3'CUTOFF
		#                        Trim low-quality bases from 5' and/or 3' ends of each read before adapter
		#                        removal. Applied to both reads if data is paired. If one value is given, only
		#                        the 3' end is trimmed. If two comma-separated cutoffs are given, the 5' end is
		#                        trimmed with the first cutoff, the 3' end with the second.

		#  -m LEN[:LEN2], --minimum-length LEN[:LEN2]
		#                        Discard reads shorter than LEN. Default: 0

		#  -n COUNT, --times COUNT
		#                        Remove up to COUNT adapters from each read. Default: 1

		#  --match-read-wildcards
		#                        Interpret IUPAC wildcards in reads. Default: False

		#	 --trim-n              Trim N's on ends of reads.


		#	No quality filtering?

		#~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
		~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards --times 4 \
			--cores ${threads} --error-rate 0.1 \
			-a "A{10}" -a "G{10}" --minimum-length 15 \
			${trim_options} \
			-o ${f} ${fastq}
	fi

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array ${array_file} "
	
	threads=4

	while [ $# -gt 0 ] ; do
		case $1 in
			-o|--out|-e|--extension)
				array_options="${array_options} $1 $2"; shift; shift;;
			-@|-t|--threads)
				shift; threads=$1; shift;;
			-h|--help)
				usage;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks $1 >> ${array_file}; shift;;
		esac
	done

	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		# using M so can be more precise-ish
		mem=$[threads*7500]M
		scratch_size=$[threads*28]G	#	not always necessary

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		#--gres=scratch:${scratch_size}G \

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%8 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )
	
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

