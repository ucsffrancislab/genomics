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
#set -x  #       print expanded command before executing it


IN="/francislab/data1/working/20211208-EV/20211216-REdiscoverTE/raw"
OUT="/francislab/data1/working/20211208-EV/20211216-REdiscoverTE/out"

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

r1=$( ls -1 ${IN}/SF*.R1.fastq.gz | sed -n "$line"p )
echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi



date=$( date "+%Y%m%d%H%M%S" )


echo $r1
r2=${r1/.R1./.R2.}
echo $r2
s=$( basename $r1 .R1.fastq.gz )
#s=$( basename $r1 ) # SFHH009L_S7_L001_R1_001
#s=${s%%_*}          # SFHH009L


#b1=${s}.quality.R1.fastq.gz
#b2=${s}.quality.R2.fastq.gz
#echo $b1
#echo $b2
#
#outbase="${OUT}/${s}.quality"
##f=${outbase}.R1.fastq.gz
##if [ -f $f ] && [ ! -w $f ] ; then
##	echo "Write-protected $f exists. Skipping."
##else
##	~/.local/bin/bbduk.bash in1=${r1} in2=${r2} out1=${outbase}.R1.fastq.gz out2=${outbase}.R2.fastq.gz minavgquality=15
##
##	#	could also use this with cutadapt, although never tested ...
##	#  -q [5'CUTOFF,]3'CUTOFF, --quality-cutoff [5'CUTOFF,]3'CUTOFF
##	#                        Trim low-quality bases from 5' and/or 3' ends of each read before adapter
##	#                        removal. Applied to both reads if data is paired. If one value is given, only
##	#                        the 3' end is trimmed. If two comma-separated cutoffs are given, the 5' end is
##	#                        trimmed with the first cutoff, the 3' end with the second.
##	#
##	#	Look into this? As some polyAs are salted with Gs. Is this for that?
##	#  --nextseq-trim 3'CUTOFF
##	#                        NextSeq-specific quality trimming (each read). Trims also dark cycles appearing
##	#                        as high-quality G bases.
##
##fi
#
#
#inbase=${outbase}
#outbase="${inbase}.format"	#	"${OUT}/${s}.quality.format"
##f=${outbase}.R1.fastq.gz
##if [ -f $f ] && [ ! -w $f ] ; then
##	echo "Write-protected $f exists. Skipping."
##else
##	${PWD}/format_filter.bash \
##		${inbase}.R1.fastq.gz \
##		${inbase}.R2.fastq.gz \
##		${outbase}.R1.fastq.gz \
##		${outbase}.R2.fastq.gz
##fi
#
#
#
##inbase=${outbase}
##outbase="${inbase}.consolidate"	#	"${OUT}/${s}.quality.format.consolidate"
##f=${outbase}.R1.fastq.gz
##if [ -f $f ] && [ ! -w $f ] ; then
##	echo "Write-protected $f exists. Skipping."
##else
##	${PWD}/consolidate_umi.bash \
##		9 \
##		${inbase}.R1.fastq.gz \
##		${inbase}.R2.fastq.gz \
##		${outbase}.R1.fastq.gz \
##		${outbase}.R2.fastq.gz
##fi
#
#
#
#
#
#inbase=${outbase}
#outbase="${inbase}.t1"	#	"${OUT}/${s}.quality.format.consolidate.t1"
#
#
#
#
#outbase=${outbase/out/out_noumi}
#
#
#
#
#f=${outbase}.R1.fastq.gz
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/cutadapt.bash \
#		--cores 8 \
#		--match-read-wildcards -n 4 \
#		-a CTGTCTCTTATACACATCTC \
#		-A CTGTCTCTTATACACATCTC \
#		-U 10 \
#		-m 15 --trim-n \
#		-o ${outbase}.R1.fastq.gz \
#		-p ${outbase}.R2.fastq.gz \
#		${inbase}.R1.fastq.gz \
#		${inbase}.R2.fastq.gz
#fi
#
##	Stop trimming short reads as lose the mate pair? Check this.
##	Add another script that checks lengths, drops short reads, keeps mates as singles.
#
#
#
#
#
#
#
##	Using the full adapter is more accurate, but there are misses. Shortening from 34bp to 20bp
##				-a CTGTCTCTTATACACATCTC \ 		#CGAGCCCACGAGAC \
##				-A CTGTCTCTTATACACATCTC \ 		#CGAGCCCACGAGAC \
##	AATGATACGGCGACCACCGAGATCTACAC[i5 index]TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGGGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAA[UMI]CTGTCTCTTATACACATCTCCGAGCCCACGAGAC[i7 index]ATCTCGTATGCCGTCTTCTGCTTG
##	R1 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAA[UMI]CTGTCTCTTATACACATCTCCGAGCCCACGAGAC[i7 index]ATCTCGTATGCCGTCTTCTGCTTG
##	R2 (RC of) AATGATACGGCGACCACCGAGATCTACAC[i5 index]TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG GGG XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAA[UMI]
##
##	R1 Trailing UMI and CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
##	# R2 Trailing GGG and GACAGAGAATATGTGTAGAGGCTCGGGTGCTCTG
##	#   ( The first GGG (CCC actually) doesn't appear to ever exist?
##	R2 Trailing CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
#
#
#
#
#
##	THIS ONLY TRIMS THE ACTUAL 9BP UMI
#
##	VERY SLOW
#
##	REWRITE USING CUTADAPT? CAN'T AS EACH READ UMI ARE DIFFERENT.
#
#
#
##inbase=${outbase}
##outbase="${outbase}.t2" #"${OUT}/${s}.quality.format.consolidate.t1"
##f=${outbase}.R1.fastq.gz
##if [ -f $f ] && [ ! -w $f ] ; then
##	echo "Write-protected $f exists. Skipping."
##else
##	${PWD}/trim_rc_umi_from_end.bash \
##		${inbase}.R1.fastq.gz \
##		${outbase}.R1.fastq.gz
##fi
#
#
#
#inbase=${outbase}
#outbase="${outbase}.t3"
#f=${outbase}.R1.fastq.gz
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/cutadapt.bash \
#		--cores 8 \
#		--match-read-wildcards -n 5 \
#		--error-rate 0.20 \
#		-a A{10} \
#		-a A{150} \
#		-G T{10} \
#		-G T{150} \
#		-m 15 --trim-n \
#		-o ${outbase}.R1.fastq.gz \
#		-p ${outbase}.R2.fastq.gz \
#		${inbase%.t2}.R1.fastq.gz \
#		${inbase%.t2}.R2.fastq.gz
#		#	NOTE that R2 is from TWO steps prior.
#fi
#
#
##	Filter out phiX
#inbase=${outbase}
#outbase="${outbase}.phiX"	#.fastq.gz"
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/phiX \
#		--very-sensitive-local -1 ${inbase}.R1.fastq.gz -2 ${inbase}.R2.fastq.gz -o ${f} --un-conc-gz ${outbase%.phiX}.notphiX.fqgz
#
#	chmod -w ${outbase%.phiX}.notphiX.?.fqgz
#	count_fasta_reads.bash ${outbase%.phiX}.notphiX.?.fqgz
#
#fi
#
###################################################
#
##	outbase=SFHH009N.quality.format.t1.t3.phiX
#
#r1r=${outbase%.phiX}.notphiX.1.fqgz
#r2r=${outbase%.phiX}.notphiX.2.fqgz
#outbase=${outbase%.phiX}.notphiX.hg38
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/bowtie2.bash --sort --threads 8 \
#		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
#		--very-sensitive-local -1 ${r1r} -2 ${r2r} -o ${f} --un-conc-gz ${outbase%.hg38}.nothg38.fqgz
#
#	chmod -w ${outbase%.hg38}.nothg38.?.fqgz
#	count_fasta_reads.bash ${outbase%.hg38}.nothg38.?.fqgz
#
#fi
#
#r1r=${outbase%.hg38}.nothg38.1.fqgz
#r2r=${outbase%.hg38}.nothg38.2.fqgz
#outbase=${outbase%.hg38}.nothg38.viral
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/bowtie2.bash --threads 8 \
#		-x /francislab/data1/working/20211122-Homology-Paper/bowtie2/RMhg38masked \
#		--very-sensitive-local -1 ${r1r} -2 ${r2r} -o ${f} --un-conc-gz ${outbase%.viral}.notviral.fqgz
#
#	chmod -w ${outbase%.viral}.notviral.?.fqgz
#	count_fasta_reads.bash ${outbase%.viral}.notviral.?.fqgz
#
#fi
#
###################################################
#
##	outbase=SFHH009N.quality.format.t1.t3.phiX
#
#outbase="${OUT}/${s}.quality.format.t1.t3.phiX"
#outbase=${outbase/out/out_noumi}
#
#r1r=${outbase%.phiX}.notphiX.1.fqgz
#r2r=${outbase%.phiX}.notphiX.2.fqgz
#outbase=${outbase%.phiX}.notphiX.viral
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/bowtie2.bash --threads 8 \
#		-x /francislab/data1/working/20211122-Homology-Paper/bowtie2/RMhg38masked \
#		--very-sensitive-local -1 ${r1r} -2 ${r2r} -o ${f} --un-conc-gz ${outbase%.viral}.notviral.fqgz
#
#	chmod -w ${outbase%.viral}.notviral.?.fqgz
#	count_fasta_reads.bash ${outbase%.viral}.notviral.?.fqgz
#
#fi
#
#
#r1r=${outbase%.viral}.notviral.1.fqgz
#r2r=${outbase%.viral}.notviral.2.fqgz
#outbase=${outbase%.viral}.notviral.hg38
#f=${outbase}.bam
#if [ -f $f ] && [ ! -w $f ] ; then
#	echo "Write-protected $f exists. Skipping."
#else
#	~/.local/bin/bowtie2.bash --sort --threads 8 \
#		-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
#		--very-sensitive-local -1 ${r1r} -2 ${r2r} -o ${f} --un-conc-gz ${outbase%.hg38}.nothg38.fqgz
#
#	chmod -w ${outbase%.hg38}.nothg38.?.fqgz
#	count_fasta_reads.bash ${outbase%.hg38}.nothg38.?.fqgz
#
#fi











SALMON="/francislab/data1/refs/salmon"

#INDIR="/francislab/data1/working/20210428-EV/20210518-preprocessing/output"
##DIR="/francislab/data1/working/20210428-EV/20210823-REdiscoverTE/output"
#DIR="${PWD}/output"
#
#sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --parsable "
#date=$( date "+%Y%m%d%H%M%S" )
#
#mkdir -p ${DIR}
#
#for raw in ${INDIR}/SFHH00*.{bbduk,cutadapt}?.fastq.gz ; do
#
#	echo $raw
#	basename=$( basename $raw .fastq.gz )
#	echo $basename
#
#	if [[ "${basename%.*}" =~ ^(SFHH005k|SFHH005v|SFHH005ag|SFHH005ar|SFHH006k|SFHH006v|SFHH006ag|SFHH006ar)$ ]]; then
#		echo "Skipping ${basename}"
#		continue
#	fi
#	echo "Processing ${basename}"
#
#	jobbase=${basename%.*}
#	trimmer=${basename#*.}
#	jobbase=${jobbase}${trimmer:0:1}${trimmer: -1}
#
#	in_base=${INDIR}/${basename}
#	out_base=${DIR}/${basename}
#	separate_id=""
##	#f=${out_base}.gt31.fastq.gz
##	f=${out_base}.lte31.fastq.gz
##	if [ -f $f ] && [ ! -w $f ] ; then
##		echo "Write-protected $f exists. Skipping."
##	else
##		separate_id=$( ${sbatch} --job-name=${jobbase}-sep --time=99 --ntasks=4 --mem=30G \
##			--output=${out_base}.separate.${date}.txt \
##			${PWD}/fastq_separate_by_length.bash ${raw} )
##		echo ${separate_id}
##	fi
#
#	infile=${raw}
#	out_base=${out_base}.salmon.REdiscoverTE.k15
#	f=${out_base}
#	if [ -d $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
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
#	
#		${sbatch} ${depend} --mem=${mem}G --job-name=${jobbase}k15 --ntasks=${threads} --time=999 \
#			--gres=scratch:${scratch}G \
#			--output=${out_base}.${date}.txt \
#			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
#				--libType A --unmatedReads ${infile} --validateMappings \
#				-o ${out_base} --threads ${threads}
#	fi






out_base=${OUT}/${s}.salmon.REdiscoverTE.k15
f=${out_base}
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	index=${SALMON}/REdiscoverTE.k15
	threads=8
	~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
		--libType A --validateMappings \
		-1 ${r1} -2 ${r2} \
		-o ${out_base} --threads ${threads}
fi







exit


mkdir -p /francislab/data1/working/20211208-EV/20211216-REdiscoverTE/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%8 --job-name="REdiscoverTE" --output="/francislab/data1/working/20211208-EV/20211216-REdiscoverTE/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G /francislab/data1/working/20211208-EV/20211216-REdiscoverTE/REdiscoverTE_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083


