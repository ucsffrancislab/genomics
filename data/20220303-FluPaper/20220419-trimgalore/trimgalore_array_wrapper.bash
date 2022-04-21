#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI trimgalore
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/raw/20220303-FluPaper/PRJNA682434"
OUT="/francislab/data1/working/20220303-FluPaper/20220419-trimgalore/out"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

r1=$( ls -1 ${IN}/SRR13*/HMN*{flu,NI}_R1_001.fastq.gz | sed -n "$line"p )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi



date=$( date "+%Y%m%d%H%M%S" )



#r2=${r1/_R1./_R2.}
#echo $r2
s=$( basename $r1 _R1_001.fastq.gz )
#s=$( basename $r1 ) # SFHH009L_S7_L001_R1_001
#s=${s%%_*}          # SFHH009L
echo $s



out_base=${OUT}/${s}
f=${out_base}_trimmed.fq.gz
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
#
#--polyA \ This really messes things up.
#
#POLY-A TRIMMING MODE; EXPERIMENTAL!!
#
#  >>> Now performing single-end Poly-A trimming for with the sequence: 'AGATCGGAAGAGC' from file /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13917504/HMN83552_flu_R1_001.fastq.gz <<< 
#gzip: /francislab/data1/working/20220303-FluPaper/20220419-trimgalore/out//francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13917504/HMN83552_flu_R1_001.fastq.gz: No such file or directory
#This is cutadapt 3.7 with Python 3.6.8
#Command line parameters: -j 8 -e 0.1 -O 1 -a AGATCGGAAGAGC /francislab/data1/working/20220303-FluPaper/20220419-trimgalore/out//francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13917504/HMN83552_flu_R1_001.fastq.gz
#Processing reads on 8 cores in single-end mode ...
#ERROR: Traceback (most recent call last):
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib64/python3.6/site-packages/cutadapt/pipeline.py", line 669, in run
#    with self._opener.xopen(self.path, "rb") as f:
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib64/python3.6/site-packages/cutadapt/utils.py", line 205, in xopen
#    xopen, path, mode, compresslevel=self.compression_level, threads=threads
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib64/python3.6/site-packages/cutadapt/utils.py", line 51, in open_raise_limit
#    f = func(*args, **kwargs)
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib/python3.6/site-packages/xopen/__init__.py", line 821, in xopen
#    opened_file = _open_gz(filename, mode, compresslevel, threads, **text_mode_kwargs)
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib/python3.6/site-packages/xopen/__init__.py", line 695, in _open_gz
#    return igzip.open(filename, mode, **text_mode_kwargs)
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib64/python3.6/site-packages/isal/igzip.py", line 92, in open
#    binary_file = IGzipFile(filename, gz_mode, compresslevel)
#  File "/software/c4/cbi/software/cutadapt-3.7/venv/lib64/python3.6/site-packages/isal/igzip.py", line 151, in __init__
#    super().__init__(filename, mode, compresslevel, fileobj, mtime)
#  File "/usr/lib64/python3.6/gzip.py", line 163, in __init__
#    fileobj = self.myfileobj = builtins.open(filename, mode or 'rb')
#FileNotFoundError: [Errno 2] No such file or directory: '/francislab/data1/working/20220303-FluPaper/20220419-trimgalore/out//francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13917504/HMN83552_flu_R1_001.fastq.gz'
#
#ERROR: Traceback (most recent call last):

	trim_galore -q 20 --phred33 --illumina \
		--cores ${SLURM_NTASKS:-1} \
		--basename ${s} \
		--output_dir ${OUT} \
		${r1}
	chmod -w ${f}
fi



echo "Done"
date

exit



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-178%2 --job-name="trimgalore" --output="${PWD}/logs/trimgalore.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G ${PWD}/trimgalore_array_wrapper.bash

178

scontrol update ArrayTaskThrottle=6 JobId=352083

