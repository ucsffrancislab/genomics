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
	#module load CBI samtools
	module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out"
OUT="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-MELT-2.2.2-SINGLE/out"

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
#sample=$( sed -n ${line}p to_run.txt )
#echo ${sample}

#bam=$( cat to_run.txt | sed -n ${line}p )
bam=$( ls -1 ${IN}/*bam | sed -n "$line"p )
echo $bam

if [ -z "${bam}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

basename=$( basename $bam .bam )
echo ${basename}


MELTJAR="/c4/home/gwendt/.local/MELTv2.2.2/MELT.jar"

outbase=${OUT}/${basename}
inbase=${outbase}
f=${outbase}.bam
if [ -h $f ] ; then
	#       -h file True if file exists and is a symbolic link.
	echo "Link $f exists. Skipping."
else
	ln -s ${bam} ${f}
	ln -s ${bam}.bai ${f}.bai
fi


f=${outbase}.bam.disc.bai
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	java -Xmx2G -jar ${MELTJAR} Preprocess \
		-bamfile ${inbase}.bam \
		-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa
	chmod -w ${f}
	chmod -w ${f%.bai}
	chmod -w ${f%.disc.bai}.fq
fi

inbase=${outbase}

for mei in ALU HERVK LINE1 SVA ; do

	#outbase=${OUT}/${mei}/${basename}.${mei}

	mkdir ${OUT}/${mei}/${basename}
	outbase=${OUT}/${mei}/${basename}/${basename}.${mei}
	f=${outbase}.tmp.bed
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		ave_read_length=$( samtools view ${inbase}.bam | head -100 | awk '{s+=length($10)}END{print s/NR}' )

		java -Xmx6G -jar ${MELTJAR} Single -k \
	  	-bamfile ${inbase}.bam \
	  	-h /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
			-n ~/.local/MELTv2.2.2/add_bed_files/Hg38/Hg38.genes.bed \
	  	-t ~/.local/MELTv2.2.2/me_refs/Hg38/${mei}_MELT.zip \
	  	-w $( dirname ${f} )/${mei}/${basename} \
			-r ${ave_read_length}

	  #	-w $( dirname ${f} ) \

		#	Missing required options: bamfile, h, w, t, n
		#	
		#	usage: java -jar MELT.jar Single <options>
		#	MELTv2.2.2 - MELT-Single - Perform transposon analysis on a single sample.
		#	
		#	 -a                Reads have been aligned with bwa-aln. [false]
		#	 -ac               Remove ac0 sites from final VCF file. [false]
		#	 -b <arg>          Exclusion list for chromosomes. A '/' seperated list: i.e. to exclude chromosomes 1,2, and 4, put -b 1/2/4. [null]
		#	 -bamfile <arg>    Bam file for MEI analysis.
		#	 -bowtie <arg>     Path to the bowtie2 binary if not in PATH [null].
		#	 -c <arg>          Coverage level of supplied bam file. Overides internal MELT coverage calculation if set. [null]
		#	 -cov <arg>        Standard deviation cutoff when calling final sites in integer format. [35]
		#	 -d <arg>          Minumum length of chromosome/contig size for calling elements. [1000000]
		#	 -e <arg>          Expected insert size between reads. [500]
		#	 -exome            Run MELT in exome mode (raises initial sensitivity of IndivAnalysis step). [false]
		#	 -h <arg>          Path to the reference sequence used to align reads.
		#	 -j <arg>          Total percentage of sites allowed to be no call (in integer form i.e. 25 percent would be -i 25, not .25). [25]
		#	 -k                BAM file(s) have already been processed for discordant pairs (suffixes .fq, .disc, and .disc.bai are already present for the bam file in -l). [false]
		#	 -mcmq <arg>       Allow MELT to use MC/MQ tags at greater than X percentage prevalance in the original bam file. [95.0]
		#	 -n <arg>          Path to the genome annotation.
		#	 -nocleanup        Do not cleanup MELT intermediate files after running. [false]
		#	 -q                Alignments are phred+64 quality encoding. [false]
		#	 -r <arg>          Read length of the supplied bam file(s). [100]
		#	 -s <arg>          Standard deviation cutoff for excluding sites with improper balance of readpairs in double format. [2.0]
		#	 -samtools <arg>   Path to samtools binary if not in PATH (i.e. /bin/samtools) [null].
		#	 -sr <arg>         Filter sites with less than X SRs during breakpoint ascertainment. Default, 0, is to not filter any such sites. [0]
		#	 -t <arg>          Path to the transposon ZIP file(s) to be used for this analysis.
		#	 -w <arg>          Path to the working root directory.
		#	 -z <arg>          Maximum reads to load into memory when iterating over sequence files. Setting higher increases run time, but may increase sensitivity in large (>60X coverage) bam files. Setting lower may decrease sensitivity in all bam files. [5000]

		chmod -w ${outbase}.*
	
		#-rw-r----- 1 gwendt francislab 31539463 Nov 29 11:03 TQ-A8XE-10A-01D-A367.LINE1.aligned.final.sorted.bam
		#-rw-r----- 1 gwendt francislab       96 Nov 29 11:03 TQ-A8XE-10A-01D-A367.LINE1.aligned.final.sorted.bam.bai
		#-rw-r----- 1 gwendt francislab 12526748 Nov 29 11:09 TQ-A8XE-10A-01D-A367.LINE1.aligned.pulled.sorted.bam
		#-rw-r----- 1 gwendt francislab  2394960 Nov 29 11:09 TQ-A8XE-10A-01D-A367.LINE1.aligned.pulled.sorted.bam.bai
		#-rw-r----- 1 gwendt francislab   707113 Nov 29 11:32 TQ-A8XE-10A-01D-A367.LINE1.hum_breaks.sorted.bam
		#-rw-r----- 1 gwendt francislab  1444464 Nov 29 11:32 TQ-A8XE-10A-01D-A367.LINE1.hum_breaks.sorted.bam.bai
		#-rw-r----- 1 gwendt francislab     5464 Nov 29 11:32 TQ-A8XE-10A-01D-A367.LINE1.tmp.bed
	fi

done



date
exit







ll /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220329-hg38/out/*bam | wc -l

mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-278%4 --job-name="MELT" --output="${PWD}/logs/MELT.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=4 --mem=30G ${PWD}/MELT_SINGLE_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083


ls -1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/*_R1.fastq.gz | xargs -I% basename % _R1.fastq.gz > to_run.txt
wc -l to_run.txt 
278 to_run.txt

