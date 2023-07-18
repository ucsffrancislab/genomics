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
	mem=${SLURM_MEM_PER_NODE:-30000M}
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
		module load CBI samtools star/2.7.7a gatk
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
			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"



			#	best so far

			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA \
			#	-a GAACTCCAGTCAC -a ATCTCGTATGCCGTCTTCTGCTTG"



#	Truseq Single Index Library:
#	
#	5'- AATGATACGGCGACCACCGAGATCTACA-CTCTTTCCCTACACGACGCTCTTCCGATCT-insert-AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC-NNNNNNNN-ATCTCGTATGCCGTCTTCTGCTTG -3'
#	3'- TTACTATGCCGCTGGTGGCTCTAGATGT-GAGAAAGGGATGTGCTGCGAGAAGGCTAGA-insert-TCTAGCCTTCTCGTGTGCAGACTTGAGGTCAGTG-NNNNNNNN-TAGAGCATACGGCAGAAGACGAAC -5'
#	          Illumina P5                   Truseq Read 1                        Truseq Read 2                 i7        Illumina P7



			#	re-testing UMI (12bp + 4bp) so don't left trim 16bp

			#	Since removing 16bases, set minimum from 15 to 31.
			trim_options="-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG --minimum-length 31"




		elif [ ${labkit} == "Lexogen" ] ; then
			#TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC
			#trim_options="-a TGGAATTCTCGGGTGCCAAGGA"
			#trim_options="-a TGGAATTCTCGGGT -a TGGAATTCTCGGGTGCCAAG -a GGAATTCTCGGGTGCCAAGG -a GAATTCTCGGGTGCCAAGGA -a AATTCTCGGGTGCCAAGGAA -a ATTCTCGGGTGCCAAGGAAC -a TTCTCGGGTGCCAAGGAACT -a TCTCGGGTGCCAAGGAACTC -a CTCGGGTGCCAAGGAACTCC -a TCGGGTGCCAAGGAACTCCA -a CGGGTGCCAAGGAACTCCAG -a GGGTGCCAAGGAACTCCAGT -a GGTGCCAAGGAACTCCAGTC -a GTGCCAAGGAACTCCAGTCA -a TGCCAAGGAACTCCAGTCAC"
			trim_options="-a TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC --minimum-length 15"
		else
			trim_options="--minimum-length 15"
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
			-a "A{10}" -a "G{10}" \
			${trim_options} \
			-o ${f} ${fastq}
	fi








	if [ ${labkit} == "D-plex" ] ; then

		out_base=${OUT}/${base}.umi
		f=${out_base}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			#	extract the UMI into the read name

			zcat ${OUT}/${base}.fastq.gz | paste - - - - \
				| awk -F"\t" '{split($1,a," ");print a[1]":"substr($2,1,12)" "a[2];print substr($2,17); print $3;print substr($4,17)}' \
				| gzip > ${f}
			chmod a-w ${f}

		fi


		#out_base=${OUT}/${base}.umi
		out_base=${out_base}.umi
		f=${out_base}.Aligned.sortedByCoord.out.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			#	align with STAR

			STAR --runMode alignReads \
				--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a \
				--runThreadN ${threads} \
				--readFilesType Fastx \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMstrandField intronMotif \
				--readFilesCommand zcat \
				--readFilesIn ${OUT}/${base}.umi.fastq.gz \
				--outFileNamePrefix ${out_base}.  \
				--outSAMattrRGline ID:${base} SM:${base} \
				--outFilterMultimapNmax 1 \
				--outSAMunmapped Within KeepPairs \
				--outSAMattributes Standard XS

			chmod a-w ${f}

		fi

		#out_base=${OUT}/${base}.umi_tag
		out_base=${out_base}.umi_tag
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			#	move UMI into a tag

			samtools view -h ${OUT}/${base}.umi.Aligned.sortedByCoord.out.bam \
				| awk 'BEGIN{FS=OFS="\t"}
				(/^@/){print;next}
				{	last_colon_index=match($1, /:[^:]*$/)
					umi=substr($1,last_colon_index+1)
					$1=substr($1,1,last_colon_index-1)
					print $0"\tRX:Z:"umi
				}' | samtools view -o ${f} -

			chmod a-w ${f}

		fi


		#out_base=${OUT}/${base}.umi_tag.dups
		out_base=${out_base}.dups
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			#	mark duplicates

			gatk UmiAwareMarkDuplicatesWithMateCigar \
				--INPUT ${OUT}/${base}.umi_tag.bam \
				--METRICS_FILE ${out_base}.metrics_file.txt \
				--UMI_METRICS_FILE ${out_base}.umi_metrics_file.txt \
				--OUTPUT ${f}

			chmod a-w ${f}

		fi

		#	could have just ...
		#--REMOVE_DUPLICATES <Boolean> If true do not write duplicates to the output file instead of writing them with
		#                              appropriate flags set.  Default value: false. Possible values: {true, false} 

		#out_base=${OUT}/${base}.umi_tag.dups.deduped
		out_base=${out_base}.deduped
		f=${out_base}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			#	filter out duplicates

			#samtools view -F1024 -o ${f} ${OUT}/${base}.umi_tag.dups.bam
			samtools fastq -F1024 ${OUT}/${base}.umi_tag.dups.bam | gzip > ${f}

			chmod a-w ${f}

		fi

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

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%1 \
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

