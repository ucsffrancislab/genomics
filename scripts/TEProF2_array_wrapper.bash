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

TEPROF2=/c4/home/gwendt/github/twlab/TEProf2Paper/bin
ARGUMENTS=/francislab/data1/refs/TEProf2/TEProF2.arguments.txt
threads=${SLURM_NTASKS:-4}
extension="_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"
strand=""

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
		-s|--strand)
			shift; strand=$1; shift;;
			#	I really don't know which is correct
			# --rf assume stranded library fr-firststrand
			# --fr assume stranded library fr-secondstrand - guessing this is correct, but its a guess
			#	5' ------------------------------> 3'
			#	   /2 ----->            <----- /1 - fr-firststrand
			#	   /1 ----->            <----- /2 - fr-secondstrand
			#	unstranded
			#	second-strand = directional, where the first read of the read pair (or in case of single end reads, the only read) is from the transcript strand
			#	first-strand = directional, where the first read (or the only read in case of SE) is from the opposite strand.
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
##
##outSAMstrandField               None
##    string: Cufflinks-like strand field flag
##                                None        ... not used
##                                intronMotif ... strand derived from the intron motif. This option changes the output alignments: reads with inconsistent and/or non-canonical introns are filtered out.
##
##outSAMattributes                Standard
##    string: a string of desired SAM attributes, in the order desired for the output SAM. Tags can be listed in any combination/order.
##                                XS          ... alignment strand according to --outSAMstrandField.
##
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
	f=${outbase}.unique.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Selecting only uniquely mapped reads"

		samtools view -h -q 250 ${bam} | samtools sort --threads $[threads-1] -o ${f} -
		samtools index ${f}
		chmod -w ${f} ${f}.bai
	fi

#	samtools view -q 255 -h EGAR00001163970_636782_1_1.rnaseq.fastqAligned.sortedByCoord.out.bam | stringtie - -o EGAR00001163970_636782_1_1.rnaseq.fastqAligned.sortedByCoord.out.gtf -m 100 -c 1


	#	Op BAM Description Consumes query Consumes reference
	#	M 0 alignment match (can be a sequence match or mismatch) yes yes
	#	I 1 insertion to the reference yes no
	#	D 2 deletion from the reference no yes
	#	N 3 skipped region from the reference no yes
	#	S 4 soft clipping (clipped sequences present in SEQ) yes no
	#	H 5 hard clipping (clipped sequences NOT present in SEQ) no no
	#	P 6 padding (silent deletion from padded reference) no no
	#	= 7 sequence match yes yes
	#	X 8 sequence mismatch yes yes



	#	Assembly: STRINGTIE Default parameters will work if unstranded, but you should look at stringtie documentation to adjust paramaters based on type of sequencing run. For discovering low coverage transcripts we sometimes set the following flags (-c 1 -m 100). Note, future steps will require being able to map the gtf file to the bam file, so the easiest way to do this would be to just change the extension of the files from *.bam to *.gtf (test1.bam to test1.gtf).

	date

	infile=${f}
	outbase=${OUT}/${base}
	f=${outbase}.unique.gtf
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#echo "Stringtie : ASSUMING --rf IS CORRECT. WITHOUT IT, NOTHING GETS ANNOTATED."

		echo stringtie ${infile} -p ${threads} -o ${f} -m 100 -c 1 ${strand}
		stringtie ${infile} -p ${threads} -o ${f} -m 100 -c 1 ${strand}

		chmod -w ${f}
	fi

	date

	#(1) <gtffile>_annotated_test_all
	#(2) <gtffile>_annotated_filtered_test_all
	#(3) <gtffile>_annotated_test*
	#(4) <gtffile>_annotated_filtered_test*

	infile=${f}
	outbase=${OUT}/${base}
	f=${outbase}.unique.gtf_annotated_test_all
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "rmskhg38_annotate_gtf_update_test_tpm"

		${TEPROF2}/rmskhg38_annotate_gtf_update_test_tpm.py ${infile} ${ARGUMENTS}

		chmod -w ${f}
	fi

	date

	outbase=${OUT}/${base}
	#for s in annotated_filtered_test_all annotated_test_all ; do
	for s in annotated_filtered_test_all ; do

		#(1) <gtffile>annotated_filtered_test(all)_c

		f=${outbase}.unique.gtf_${s}_c
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "annotationtpmprocess.py filtered"

			${TEPROF2}/annotationtpmprocess.py ${infile}_${s}

			chmod -w ${f}
		fi

	done

	date



#		#(1) filter_combined_candidates.tsv: A file with every TE-gene transcript. This file is used for calculating read information in subsequent steps.
#		#
#		#(2) initial_candidate_list.tsv: A summary of filter_combined_candidates.tsv for each unique candidate. 
#		#			Also lists the treatment and untreated files that the candidate is present in.
#		#
#		#(3) Step4.RData: Workspace file with data loaded from R session. Subsequent steps load this to save time.
#
#		f=${outbase}.unique.gtf_${s}_c
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "annotationtpmprocess.py filtered"
#
#			${TEPROF2}/aggregateProcessedAnnotation.R <options>
#
#			chmod -w ${f}
#		fi



	date


else

	ls -1 ${IN}/*${extension} > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	strand_option=""
	[ -n "${strand}" ] && strand_option="--strand ${strand}"
	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%20 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem}G --gres=scratch:${scratch_size}G \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) --out ${OUT} --extension ${extension} ${strand_option} )


	echo "Throttle with ..."
	echo "scontrol update ArrayTaskThrottle=8 JobId=${array_id}"

fi

#	TEProF2_array_wrapper.bash --threads 4
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
#	--extension .STAR.hg38.Aligned.out.bam




