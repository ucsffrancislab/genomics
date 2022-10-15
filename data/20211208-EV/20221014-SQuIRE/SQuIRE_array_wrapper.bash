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
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
set -x  #       print expanded command before executing it

#SALMON="/francislab/data1/refs/salmon"
#index=${SALMON}/REdiscoverTE.k15
#cp -r ${index} ${TMPDIR}/
#scratch_index=${TMPDIR}/$( basename ${index} )


#	The .fqgz extension confuses STAR and it seems to expect it to be uncompressed so link with a different extension.
#SUFFIX="quality.format.t1.t3.notphiX.notviral.1.fqgz"
#IN="/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi"
SUFFIX="R1.fastq.gz"
IN="/francislab/data1/working/20211208-EV/20221014-SQuIRE/raw"

OUT="/francislab/data1/working/20211208-EV/20221014-SQuIRE/out"


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

#fasta=$( ls -tr1d ${IN}/*fa.gz | sed -n "$line"p )
#fasta=$( ls -1 ${IN}/*fa.gz | sed -n "$line"p )
r1=$( ls -1 ${IN}/*.${SUFFIX} | sed -n "$line"p )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

base=$( basename ${r1} .${SUFFIX} )


#out_base=${OUT}/${base}




# The .fqgz is confusing Map





MAPPED=${OUT}/mapped
mkdir -p ${MAPPED}
f=${MAPPED}/${base}.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Mapping"
	r2=${r1/.1./.2.}
	#read_length=$( zcat $r1 | head -2 | tail -1 | tr -d "\n" | wc -c )
	read_length=151

	#	Our data has varying lengths so not sure what to do with this. Just grabbing first which could be anything.
	#	Actually just using 151

	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE-20221014.img squire Map \
		--name $base --read1 $r1 --read2 $r2 \
		--map_folder ${MAPPED} \
		--fetch_folder /francislab/data1/refs/SQuIRE/fetched \
		--read_length ${read_length} \
		--pthreads ${SLURM_NTASKS:-8} --build hg38 --verbosity

	if [ $? -eq 0 ] ; then
		chmod -w ${f}
		chmod -w ${f}.bai
	fi

fi


#COUNTED=${OUT}/counted101
COUNTED=${OUT}/counted
mkdir -p ${COUNTED}
f=${COUNTED}/${base}_TEcounts.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Counting"

	#strandedness = '0' if unstranded, 1 if first-strand eg Illumina Truseq, dUTP, NSR, NNSR, 2 if second-strand, eg Ligation, Standard
	#
	#EM = desired number of EM iterations other than auto
	#
	mkdir -p ${COUNTED}/${base}-temp
	#read_length=$( zcat $r1 | head -2 | tail -1 | tr -d "\n" | wc -c )
	read_length=151

	#	Our data has varying lengths so not sure what to do with this. Just grabbing first which could be anything.
	#	Actually just using 151


	#	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE-20221014.img squire Count -h
	#	usage: squire Count [-h] [-m <folder>] [-c <folder>] [-o <folder>]
	#	                    [-t <folder>] [-f <folder>] -r <int> [-n <str>]
	#	                    [-b <build>] [-p <int>] [-s <int>] [-e EM] [-v]
	#	
	#	Arguments:
	#	  -h, --help            show this help message and exit
	#	  -m <folder>, --map_folder <folder>
	#	                        Folder location of outputs from SQuIRE Map (optional,
	#	                        default = 'squire_map')
	#	  -c <folder>, --clean_folder <folder>
	#	                        Folder location of outputs from SQuIRE Clean
	#	                        (optional, default = 'squire_clean')
	#	  -o <folder>, --count_folder <folder>
	#	                        Destination folder for output files(optional, default
	#	                        = 'squire_count')
	#	  -t <folder>, --tempfolder <folder>
	#	                        Folder for tempfiles (optional; default=count_folder')
	#	  -f <folder>, --fetch_folder <folder>
	#	                        Folder location of outputs from SQuIRE Fetch
	#	                        (optional, default = 'squire_fetch)'
	#	  -r <int>, --read_length <int>
	#	                        Read length (if trim3 selected, after trimming;
	#	                        required).
	#	  -n <str>, --name <str>
	#	                        Common basename for input files (required if more than
	#	                        one bam file in map_folder)
	#	  -b <build>, --build <build>
	#	                        UCSC designation for genome build, eg. 'hg38'
	#	                        (required if more than 1 build in clean_folder)
	#	  -p <int>, --pthreads <int>
	#	                        Launch <int> parallel threads(optional; default='1')
	#	  -s <int>, --strandedness <int>
	#	                        '0' if unstranded eg Standard Illumina, 1 if first-
	#	                        strand eg Illumina Truseq, dUTP, NSR, NNSR, 2 if
	#	                        second-strand, eg Ligation, Standard SOLiD
	#	                        (optional,default=0)
	#	  -e EM, --EM EM        Run estimation-maximization on TE counts given number
	#	                        of times (optional, specify 0 if no EM desired;
	#	                        default=auto)
	#	  -v, --verbosity       Want messages and runtime printed to stderr (optional;
	#	                        default=False)


	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/SQuIRE-20221014.img squire Count \
		--map_folder ${MAPPED} --clean_folder /francislab/data1/refs/SQuIRE/cleaned \
		--count_folder ${COUNTED} --temp_folder ${COUNTED}/${base}-temp \
		--fetch_folder /francislab/data1/refs/SQuIRE/fetched \
		--read_length $read_length \
		--name ${base} --build hg38 --strandedness 2 --EM auto --verbosity

	if [ $? -eq 0 ] ; then
		chmod -w ${COUNTED}/${base}_abund.txt
		chmod -w ${COUNTED}/${base}.gtf
		chmod -w ${COUNTED}/${base}_refGenecounts.txt
		chmod -w ${COUNTED}/${base}_subFcounts.txt
		chmod -w ${COUNTED}/${base}_TEcounts.txt
	fi

fi













#
###	Draw
#
#
#```
#chmod -R 500 ${PWD}/called
#mkdir ${PWD}/drawed
#
#threads=8
#mem=60G
#
#for file in ${PWD}/mapped/*.bam ; do
#basefile=$(basename $file)
#base=${basefile//.bam/}
#sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=s${base} --time=1440 --nodes=1 --ntasks=${threads} --mem=${mem} \
#  --output=${PWD}/drawed/${base}.txt \
#  --wrap "singularity exec --bind /francislab,/scratch --no-home \
#  /francislab/data1/refs/singularity/SQuIRE-20221014.img squire Draw \
#  --map_folder ${PWD}/mapped --clean_folder ${PWD}/cleaned --count_folder ${PWD}/counted --temp_folder ${PWD}/${base}-temp \
#  --fetch_folder ${PWD}/fetched \
#  --draw_folder ${PWD}/drawed --name $base --build hg38 --pthreads ${threads} --strandedness 2 --verbosity"
#done
#
#```
#
#After ...
#
#```
#chmod -R 500 ${PWD}/drawed
#```








echo "Done"
date

exit


ll /francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi/*quality.format.t1.t3.notphiX.notviral.hg38.bam | wc -l
13





mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%1 --job-name="SQuIRE" --output="${PWD}/logs/SQuIRE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/SQuIRE_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083

