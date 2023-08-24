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
	echo $0 --threads 4 --extension _R1.fastq.gz
	echo	--out /francislab/data1/working/20230628-Costello/20230629-cutadapt/out
	echo	--trim-n --match-read-wildcards --times 7 
	echo	--error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25
	echo	-a "A{10}" -a "G{10}" -a "T{10}" -a "C{10}"
	echo	-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG
	echo	-A "A{10}" -A "G{10}" -A "T{10}" -A "C{10}"
	echo	-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT
	echo	/francislab/data1/raw/20230628-Costello/fastq/*R1.fastq.gz
	echo
	exit
}

#
#	The R1 index is mostly just in R1 and the R2 index is ONLY in R2.
#
#	zgrep -c ATCTCGTATGCCGTCTTCTGCTTG /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-00*R?.fastq.gz
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz:6712873
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz:117
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+2_R1.fastq.gz:6033234
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+2_R2.fastq.gz:67
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+1_R1.fastq.gz:2866230
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+1_R2.fastq.gz:682
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+2_R1.fastq.gz:2530981
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+2_R2.fastq.gz:353
#	
#	zgrep -c TGTAGATCTCGGTGGTCGCCGTATCATT /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-*R?.fastq.gz
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz:0
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz:524036
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+2_R1.fastq.gz:0
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+2_R2.fastq.gz:416211
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+1_R1.fastq.gz:0
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+1_R2.fastq.gz:324897
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+2_R1.fastq.gz:0
#	/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0055-01A-01R-1849-01+2_R2.fastq.gz:272519
#	

if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension=".fastq.gz"
	ARGS=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; mkdir -p ${OUT}; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				#echo "Unknown param :${1}:"; usage ;;
				echo "Unknown param :${1}:"
				ARGS="${ARGS} ${1}"
				shift;;
		esac
	done

	echo "extension :${extension}:"


	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools star/2.7.7a
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

	r1=${line}
	r2=${line/_R1./_R2.}

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x







	out_base=${OUT}/${base}
	f=${out_base}_R1.fastq.gz
	f2=${out_base}_R2.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	https://teichlab.github.io/scg_lib_structs/methods_html/Illumina.html

		#	Truseq Single Index Library:
		#	
		#	5'- AATGATACGGCGACCACCGAGATCTACA-CTCTTTCCCTACACGACGCTCTTCCGATCT-insert-AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC-NNNNNNNN-ATCTCGTATGCCGTCTTCTGCTTG -3'
		#	3'- TTACTATGCCGCTGGTGGCTCTAGATGT-GAGAAAGGGATGTGCTGCGAGAAGGCTAGA-insert-TCTAGCCTTCTCGTGTGCAGACTTGAGGTCAGTG-NNNNNNNN-TAGAGCATACGGCAGAAGACGAAC -5'
		#	          Illumina P5                   Truseq Read 1                        Truseq Read 2                 i7        Illumina P7

		#	
		#	5'-                                                             insert-AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC-NNNNNNNN-ATCTCGTATGCCGTCTTCTGCTTG -3'
		#	3'- TTACTATGCCGCTGGTGGCTCTAGATGT-GAGAAAGGGATGTGCTGCGAGAAGGCTAGA-insert

		#	echo TTACTATGCCGCTGGTGGCTCTAGATGT-GAGAAAGGGATGTGCTGCGAGAAGGCTAGA-insert | rev
		#	tresni-AGATCGGAAGAGCGTCGTGTAGGGAAAGAG-TGTAGATCTCGGTGGTCGCCGTATCATT

		#	
		#	R1 insert-AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC-NNNNNNNN-ATCTCGTATGCCGTCTTCTGCTTG
		#	R2 tresni-AGATCGGAAGAGCGTCGTGTAGGGAAAGAG-TGTAGATCTCGGTGGTCGCCGTATCATT



		#  --action {trim,retain,mask,lowercase,none}
		#                        What to do if a match was found. trim: trim adapter and up- or downstream
		#                        sequence; retain: trim, but retain adapter; mask: replace with 'N' characters;
		#                        lowercase: convert to lowercase; none: leave unchanged. Default: trim

		#  -a ADAPTER, --adapter ADAPTER
		#                        Sequence of an adapter ligated to the 3' end (paired data: of the first read).
		#                        The adapter and subsequent bases are trimmed. If a '$' character is appended
		#                        ('anchoring'), the adapter is only found if it is a suffix of the read.

		#  -A ADAPTER            3' adapter to be removed from R2
		
		#  -e E, --error-rate E, --errors E
		#                        Maximum allowed error rate (if 0 <= E < 1), or absolute number of errors for
		#                        full-length adapter match (if E is an integer >= 1). Error rate = no. of errors
		#                        divided by length of matching region. Default: 0.1 (10%)
		
		#  -q [5'CUTOFF,]3'CUTOFF, --quality-cutoff [5'CUTOFF,]3'CUTOFF
		#                        Trim low-quality bases from 5' and/or 3' ends of each read before adapter
		#                        removal. Applied to both reads if data is paired. If one value is given, only
		#                        the 3' end is trimmed. If two comma-separated cutoffs are given, the 5' end is
		#                        trimmed with the first cutoff, the 3' end with the second.
		#	https://cutadapt.readthedocs.io/en/stable/algorithms.html#quality-trimming-algorithm
		#	https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/QualityScoreEncoding_swBS.htm

		#  -m LEN[:LEN2], --minimum-length LEN[:LEN2]
		#                        Discard reads shorter than LEN. Default: 0

		#  -n COUNT, --times COUNT
		#                        Remove up to COUNT adapters from each read. Default: 1

		#  --match-read-wildcards
		#                        Interpret IUPAC wildcards in reads. Default: False

		#	 --trim-n              Trim N's on ends of reads.

		#  -O MINLENGTH, --overlap MINLENGTH
		#                        Require MINLENGTH overlap between read and adapter for an adapter to be found.
		#                        Default: 3

		#	https://dnatech.genomecenter.ucdavis.edu/wp-content/uploads/2019/03/illumina-adapter-sequences-2019-1000000002694-10.pdf

#		~/.local/bin/cutadapt.bash ${ARGS} --trim-n --match-read-wildcards --times 4 \
#			--cores ${threads} --error-rate 0.1 --overlap 5 \
#			-a "A{10}" -a "G{10}" \
#			-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
#			-A "T{10}" -A "C{10}" \
#			-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \
#			--minimum-length 15 \
#			--quality-cutoff 25 \
#			-o ${f} -p ${f2} ${r1} ${r2}

		~/.local/bin/cutadapt.bash ${ARGS} --cores ${threads} -o ${f} -p ${f2} ${r1} ${r2}

		chmod a-w ${f} ${f2}
	fi






#
#		out_base=${out_base}
#		f=${out_base}.Aligned.sortedByCoord.out.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#
#			#	align with STAR
#
#			STAR.bash --runMode alignReads \
#				--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a \
#				--runThreadN ${threads} \
#				--readFilesType Fastx \
#				--outSAMtype BAM SortedByCoordinate \
#				--outSAMstrandField intronMotif \
#				--readFilesCommand zcat \
#				--readFilesIn ${OUT}/${base}.fastq.gz \
#				--outFileNamePrefix ${out_base}.  \
#				--outSAMattrRGline ID:${base} SM:${base} \
#				--outFilterMultimapNmax 1 \
#				--outSAMunmapped Within KeepPairs \
#				--outSAMattributes Standard XS
#
#			chmod a-w ${f}
#
#		fi


	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
#			-o|--out|-e|--extension)
#				array_options="${array_options} $1 $2"; shift; shift;;
			-@|-t|--threads)
				shift; threads=$1; shift;;
			-h|--help)
				usage;;
			*)
				if [ -f ${1} ] ; then
					echo "Unknown param :${1}: Assuming file"; 
					realpath --no-symlinks $1 >> ${array_file}
				else
					echo "Unknown param :${1}: Not a file. Passing to job."; 
					array_options="${array_options} $1"
				fi
				shift;;
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

		set -x  #       print expanded command before executing it

		[ -z "${array}" ] && array="1-${max}"

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )
	
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

