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

threads=8
extension="_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"

#			-l /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/D_mel_transposon_sequence_set_v10.1.fa \
#			-r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa 
while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
		-l|--transposon)
			shift; transposon_fasta=$1; shift;;
		-r|--human)
			shift; human_fasta=$1; shift;;
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
		module load CBI samtools bwa bedtools2
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
	R1=${line}
	R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	echo "r1 : $R1"
	echo "r2 : $R2"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	#	https://github.com/bergmanlab/ngs_te_mapper2

	#	Script to detect non-reference TEs from SINGLE END short read data

	#	Needs RepeatMasker, samtools, bwa, bedtools2, seqtk

	echo "Running"

	export PATH="${PATH}:${HOME}/.local/RepeatMasker/"


	#	ngs_te_mapper2 converts "+" to "plus"
	base=${base//+/plus}


	#		inbase=${outbase}
	outbase=${OUT}/${base}
	f=${outbase}.ref.bed
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running ngs_te_mapper2"
		set -x  #       print expanded command before executing it

		trap "{ chmod -R +w $TMPDIR ; }" EXIT

		ngs_te_mapper2 --thread ${threads} \
			--reads ${R1},${R2} \
			--library ${transposon_fasta} \
			--reference ${human_fasta} \
			--out ${TMPDIR}

		ls -l ${TMPDIR}

		mv ${TMPDIR}/$(basename $f) ${OUT}
		mv ${TMPDIR}/$(basename $f .ref.bed).nonref.bed ${OUT}
		chmod -w ${f} ${f%.ref.bed}.nonref.bed
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
			$( realpath ${0} ) -t ${threads} -l ${transposon_fasta} -r ${human_fasta} --out ${OUT} )

	#	transposon fasta cannot be gzipped

	#	Successfully created the directory /scratch/gwendt/1264046/intermediate_files 
	#	Traceback (most recent call last):
	#	  File "/c4/home/gwendt/.local/bin/ngs_te_mapper2", line 8, in <module>
	#	    sys.exit(main())
	#	  File "/c4/home/gwendt/.local/lib/python3.6/site-packages/ngs_te_mapper2/ngs_te_mapper2.py", line 189, in main
	#	    out_dir=tmp_dir,
	#	  File "/c4/home/gwendt/.local/lib/python3.6/site-packages/ngs_te_mapper2/utility.py", line 66, in parse_input
	#	    fix_fasta_header(library, library_fix)
	#	  File "/c4/home/gwendt/.local/lib/python3.6/site-packages/ngs_te_mapper2/utility.py", line 47, in fix_fasta_header
	#	    for record in SeqIO.parse(input, "fasta"):
	#	  File "/c4/home/gwendt/.local/lib/python3.6/site-packages/Bio/SeqIO/__init__.py", line 609, in parse
	#	    for r in i:
	#	  File "/c4/home/gwendt/.local/lib/python3.6/site-packages/Bio/SeqIO/FastaIO.py", line 122, in FastaIterator
	#	    for title, sequence in SimpleFastaParser(handle):
	#	  File "/c4/home/gwendt/.local/lib/python3.6/site-packages/Bio/SeqIO/FastaIO.py", line 43, in SimpleFastaParser
	#	    line = handle.readline()
	#	  File "/usr/lib64/python3.6/codecs.py", line 321, in decode
	#	    (result, consumed) = self._buffer_decode(data, self.errors, final)
	#	UnicodeDecodeError: 'utf-8' codec can't decode byte 0x8b in position 1: invalid start byte

	echo "Throttle with ..."
	echo "scontrol update ArrayTaskThrottle=8 JobId=${array_id}"

fi


