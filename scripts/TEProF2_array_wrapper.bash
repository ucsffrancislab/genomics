#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
#if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

threads=${SLURM_NTASKS:-8}
extension="_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
		-e|--extension)
			shift; extension=$1; shift;;
		-h|--help)
			echo
			echo "Good question"
			echo
			exit;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

mem=$[threads*7]
scratch_size=$[threads*28]

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
#if [ $( basename ${0} ) == "slurm_script" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools bwa bedtools2 cufflinks star/2.7.7a
	fi
	
	date
	
	#		#IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
	#		OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"
	#		
	#		#while [ $# -gt 0 ] ; do
	#		#	case $1 in
	#		#		-d|--dir)
	#		#			shift; OUT=$1; shift;;
	#		#		*)
	#		#			echo "Unknown params :${1}:"; exit ;;
	#		#	esac
	#		#done

	mkdir -p ${OUT}

	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	line=$( sed -n "$line_number"p ${arguments_file} )
	echo $line

	if [ -z "${line}" ] ; then
		echo "No line at :${line_number}:"
		exit
	fi

	base=$( basename $line ${extension} )
	bam=${line}
	#R1=${line}
	#R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	#echo "r1 : $R1"
	#echo "r2 : $R2"
	echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x

	#export PATH="${PATH}:${HOME}/.local/RepeatMasker/"
	##	ngs_te_mapper2 converts "+" to "plus"
	#base=${base//+/plus}


	#	QC: Using software such as FASTQC


	#	Adapter Trimming


	#	Alignment: We normally user and prefer STAR. Make sure that the -XS tag will be outputted since the splice-aware assembly software such as stringtie has the information it needs. HISAT2 can also be used, but HISAT uses 60 instead of 255 for uniquelly mapped reads which will interfere with code in future steps.
	#	Note: Future steps require sorted and indexed bam files. Thus, outputting sorted BAM files will be beneficial.
	#	Sorting and Indexing: The BAM files need to be sorted by position (samtools sort) and need to be indexed (samtools index)
	#	Pretty sure that STAR will produce sorted bam with index

#/francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a


#	##		inbase=${outbase}
#	outbase=${OUT}/${base}
#	f=${outbase}.Aligned.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Running STAR"
#		set -x  #       print expanded command before executing it
#
#		trap "{ chmod -R +w $TMPDIR ; }" EXIT
#
#		#	STAR_scratch.bash
#
##		f="${outprefix}Aligned.sortedByCoord.out.${outtype,,}"
#
##	runMode                         alignReads
##	
##runThreadN                      1
##    int: number of threads to run STAR
##
##genomeDir                   ./GenomeDir/
##    string: path to the directory where genome files are stored (for --runMode alignReads) or will be generated (for --runMode generateGenome)
##
##readFilesType               Fastx
##    string: format of input read files
##                            Fastx       ... FASTA or FASTQ
##                            SAM SE      ... SAM or BAM single-end reads; for BAM use --readFilesCommand samtools view
##                            SAM PE      ... SAM or BAM paired-end reads; for BAM use --readFilesCommand samtools view
##
##readFilesIn                 Read1 Read2
##    string(s): paths to files that contain input read1 (and, if needed,  read2)
##
##
##
##readFilesCommand             -
##    string(s): command line to execute for each of the input file. This command should generate FASTA or FASTQ text and send it to stdout
##               For example: zcat - to uncompress .gz files, bzcat - to uncompress .bz2 files, etc.
##outFileNamePrefix               ./
##    string: output files name prefix (including full or relative path). Can only be defined on the command line.
##
##
##outStd                          Log
##    string: which output will be directed to stdout (standard out)
##                                Log                    ... log messages
##                                SAM                    ... alignments in SAM format (which normally are output to Aligned.out.sam file), normal standard output will go into Log.std.out
##                                BAM_Unsorted           ... alignments in BAM format, unsorted. Requires --outSAMtype BAM Unsorted
##                                BAM_SortedByCoordinate ... alignments in BAM format, unsorted. Requires --outSAMtype BAM SortedByCoordinate
##                                BAM_Quant              ... alignments to transcriptome in BAM format, unsorted. Requires --quantMode TranscriptomeSAM
##
##### Output: SAM and BAM
##outSAMtype                      SAM
##    strings: type of SAM/BAM output
##                                1st word:
##                                BAM  ... output BAM without sorting
##                                SAM  ... output SAM without sorting
##                                None ... no SAM/BAM output
##                                2nd, 3rd:
##                                Unsorted           ... standard unsorted
##                                SortedByCoordinate ... sorted by coordinate. This option will allocate extra memory for sorting which can be specified by --limitBAMsortRAM.
##
##
##outFilterScoreMin               0
##    int: alignment will be output only if its score is higher than or equal to this value.
##
##
##alignEndsType           Local
##    string: type of read ends alignment
##                        Local             ... standard local alignment with soft-clipping allowed
##                        EndToEnd          ... force end-to-end read alignment, do not soft-clip
##                        Extend5pOfRead1   ... fully extend only the 5p of the read1, all other ends: local alignment
##                        Extend5pOfReads12 ... fully extend only the 5p of the both read1 and read2, all other ends: local alignment
##
##
#
#
#
#	#	ngs_te_mapper2 --thread ${threads} \
#	#		--reads ${R1},${R2} \
#	#		--library ${transposon_fasta} \
#	#		--reference ${human_fasta} \
#	#		--out ${TMPDIR}
#
#	#	ls -l ${TMPDIR}
#
#	#	mv ${TMPDIR}/$(basename $f) ${OUT}
#	#	mv ${TMPDIR}/$(basename $f .ref.bed).nonref.bed ${OUT}
#		chmod -w ${f}
#	fi








	#	Filtering: Due to problems with mapping to repetitive elements, we usually will filter to only include uniquelly mapped reads.

	outbase=${OUT}/${base}
	f=${outbase}.filtered.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Selecting only uniquely mapped reads"

		echo samtools view -q 60 -o ${f} ${bam}
		echo chmod -w ${f}
	fi




	#	Assembly: STRINGTIE Default parameters will work if unstranded, but you should look at stringtie documentation to adjust paramaters based on type of sequencing run. For discovering low coverage transcripts we sometimes set the following flags (-c 1 -m 100). Note, future steps will require being able to map the gtf file to the bam file, so the easiest way to do this would be to just change the extension of the files from *.bam to *.gtf (test1.bam to test1.gtf).


	infile=${f}
	outbase=${OUT}/${base}
	f=${outbase}.filtered.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Stringtie"

		echo stringtie ${bam} -p ${threads} -o ${f}
		echo chmod -w ${f}
	fi














	date


else

	ls -1 ${IN}/*${extension} | head > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%4 \
		--parsable --job-name="$(basename $0)" \
		--time=20160 --nodes=1 --ntasks=${threads} --mem=${mem}G --gres=scratch:${scratch_size}G \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) --out ${OUT} --extension ${extension} )


	echo "Throttle with ..."
	echo "scontrol update ArrayTaskThrottle=8 JobId=${array_id}"

fi

#	TEProF2_array_wrapper.bash
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
#	--extension .STAR.hg38.Aligned.out.bam
#	--threads 8




