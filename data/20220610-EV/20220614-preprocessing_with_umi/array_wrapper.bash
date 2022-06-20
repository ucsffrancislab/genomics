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
	module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


OUT="/francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/out"

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

#r1=$( ls -1 /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz | sed -n "$line"p )
sample=$( sed -n "$line"p /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/metadata.csv | awk -F, '{print $1}' )
r1=$( ls /francislab/data1/raw/20220610-EV/${sample}_*R1_001.fastq.gz )

#	Make sure that r1 is unique. NEEDS the UNDERSCORE AFTER SAMPLE!


echo $r1

if [ -z "${r1}" ] ; then
	echo "No line at :${line}:"
	exit
fi




#	/francislab/data1/working/20211001-EV/20211003-explore/process.bash 
#	/francislab/data1/working/20210428-EV/20210518-preprocessing/preprocess.bash 


date=$( date "+%Y%m%d%H%M%S" )


echo $r1
r2=${r1/_R1_/_R2_}
echo $r2
s=$( basename $r1 ) # SFHH009L_S7_L001_R1_001
s=${s%%_*}          # SFHH009L


b1=${s}.quality.R1.fastq.gz
b2=${s}.quality.R2.fastq.gz
echo $b1
echo $b2

outbase="${OUT}/${s}.quality"
f=${outbase}.R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	~/.local/bin/bbduk.bash in1=${r1} in2=${r2} out1=${outbase}.R1.fastq.gz out2=${outbase}.R2.fastq.gz minavgquality=15 threads=${SLURM_NTASKS:-auto}

	#	could also use this with cutadapt, although never tested ...
	#  -q [5'CUTOFF,]3'CUTOFF, --quality-cutoff [5'CUTOFF,]3'CUTOFF
	#                        Trim low-quality bases from 5' and/or 3' ends of each read before adapter
	#                        removal. Applied to both reads if data is paired. If one value is given, only
	#                        the 3' end is trimmed. If two comma-separated cutoffs are given, the 5' end is
	#                        trimmed with the first cutoff, the 3' end with the second.
	#
	#	Look into this? As some polyAs are salted with Gs. Is this for that?
	#  --nextseq-trim 3'CUTOFF
	#                        NextSeq-specific quality trimming (each read). Trims also dark cycles appearing
	#                        as high-quality G bases.

fi


#	inbase=${outbase}
#	outbase="${inbase}.format"	#	"${OUT}/${s}.quality.format"
#	f=${outbase}.R1.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		${PWD}/format_filter.bash \
#			${inbase}.R1.fastq.gz \
#			${inbase}.R2.fastq.gz \
#			${outbase}.R1.fastq.gz \
#			${outbase}.R2.fastq.gz
#	fi



inbase=${outbase}
outbase="${inbase}.consolidate"	#	"${OUT}/${s}.quality.format.consolidate"
f=${outbase}.R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	${PWD}/consolidate_umi.bash \
		18 \
		${inbase}.R1.fastq.gz \
		${inbase}.R2.fastq.gz \
		${outbase}.R1.fastq.gz \
		${outbase}.R2.fastq.gz
fi







inbase=${outbase}
#outbase="${inbase}.range5-5000"	#	"${OUT}/${s}.quality.format.consolidate"
outbase="${inbase}.range2-5000"	#	"${OUT}/${s}.quality.format.consolidate"
f=${outbase}.R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	${PWD}/consolidated_range.bash \
		2 5000 \
		${inbase}.R1.fastq.gz \
		${outbase}.R1.fastq.gz
fi







#cutadapt: error: You used an option that enabled paired-end mode (such as -p, -A, -G, -B, -U), but then you also need to provide two input files (you provided one) or use --interleaved.


inbase=${outbase}
outbase="${inbase}.t1"	#	"${OUT}/${s}.quality.format.consolidate.t1"
f=${outbase}.R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	~/.local/bin/cutadapt.bash \
		--cores ${SLURM_NTASKS:-8} \
		--match-read-wildcards -n 4 \
		-a CTGTCTCTTATACACATCTC \
		-m 15 --trim-n \
		-o ${outbase}.R1.fastq.gz \
		${inbase}.R1.fastq.gz
#		-A CTGTCTCTTATACACATCTC \
#		-U 21 \
#		-p ${outbase}.R2.fastq.gz \
#		${inbase}.R2.fastq.gz
fi


#	Stop trimming short reads as lose the mate pair? Check this.
#	Add another script that checks lengths, drops short reads, keeps mates as singles.
#	
#	
#	
#	
#	
#	
#	
#	#	Using the full adapter is more accurate, but there are misses. Shortening from 34bp to 20bp
#	#				-a CTGTCTCTTATACACATCTC \ 		#CGAGCCCACGAGAC \
#	#				-A CTGTCTCTTATACACATCTC \ 		#CGAGCCCACGAGAC \
#	#	AATGATACGGCGACCACCGAGATCTACAC[i5 index]TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGGGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAA[UMI]CTGTCTCTTATACACATCTCCGAGCCCACGAGAC[i7 index]ATCTCGTATGCCGTCTTCTGCTTG
#	#	R1 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAA[UMI]CTGTCTCTTATACACATCTCCGAGCCCACGAGAC[i7 index]ATCTCGTATGCCGTCTTCTGCTTG
#	#	R2 (RC of) AATGATACGGCGACCACCGAGATCTACAC[i5 index]TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG GGG XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAA[UMI]
#	#
#	#	R1 Trailing UMI and CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
#	#	# R2 Trailing GGG and GACAGAGAATATGTGTAGAGGCTCGGGTGCTCTG
#	#	#   ( The first GGG (CCC actually) doesn't appear to ever exist?
#	#	R2 Trailing CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
#	
#	
#	
#	
#	
#	#	THIS ONLY TRIMS THE ACTUAL 9BP UMI
#	
#	#	VERY SLOW
#	
#	#	REWRITE USING CUTADAPT? CAN'T AS EACH READ UMI ARE DIFFERENT.
#	
#	
#	
#	inbase=${outbase}
#	outbase="${outbase}.t2" #"${OUT}/${s}.quality.format.consolidate.t1"
#	f=${outbase}.R1.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		${PWD}/trim_rc_umi_from_end.bash \
#			${inbase}.R1.fastq.gz \
#			${outbase}.R1.fastq.gz
#	fi
#	



inbase=${outbase}
outbase="${outbase}.t3"
f=${outbase}.R1.fastq.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	~/.local/bin/cutadapt.bash \
		--cores ${SLURM_NTASKS:-8} \
		--match-read-wildcards -n 5 \
		--error-rate 0.20 \
		-a A{10} \
		-a A{150} \
		-m 15 --trim-n \
		-o ${outbase}.R1.fastq.gz \
		${inbase}.R1.fastq.gz
#		-G T{10} \
#		-G T{150} \
#		-p ${outbase}.R2.fastq.gz \
#		${inbase%.t2}.R2.fastq.gz
		#	NOTE that R2 is from TWO steps prior.
fi






#	#	Filter out phiX
#	inbase=${outbase}
#	outbase="${outbase}.phiX"	#.fastq.gz"
#	f=${outbase}.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/bowtie2.bash --sort --threads ${SLURM_NTASKS:-8} -x /francislab/data1/refs/bowtie2/phiX \
#			--very-sensitive-local -1 ${inbase}.R1.fastq.gz -2 ${inbase}.R2.fastq.gz -o ${f} --un-conc-gz ${outbase%.phiX}.notphiX.fqgz
#	
#		chmod -w ${outbase%.phiX}.notphiX.?.fqgz
#	
#		count_fasta_reads.bash ${outbase%.phiX}.notphiX.?.fqgz
#	
#	fi

#	r1r=${outbase%.phiX}.notphiX.1.fqgz
#	r2r=${outbase%.phiX}.notphiX.2.fqgz
#	outbase=${outbase%.phiX}.notphiX.hg38
#	f=${outbase}.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/bowtie2.bash --sort --threads ${SLURM_NTASKS:-8} \
#			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
#			--very-sensitive-local -1 ${r1r} -2 ${r2r} -o ${f} --un-conc-gz ${outbase%.hg38}.nothg38.fqgz
#	
#		chmod -w ${outbase%.hg38}.nothg38.?.fqgz
#	
#		count_fasta_reads.bash ${outbase%.hg38}.nothg38.?.fqgz
#	
#	fi
#	
#	
#	
#	r1r=${outbase%.hg38}.nothg38.1.fqgz
#	r2r=${outbase%.hg38}.nothg38.2.fqgz
#	outbase=${outbase%.hg38}.nothg38.viral
#	f=${outbase}.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/bowtie2.bash --sort --threads 8 \
#			-x /francislab/data1/working/20211122-Homology-Paper/bowtie2/RMhg38masked \
#			--very-sensitive-local -1 ${r1r} -2 ${r2r} -o ${f} --un-conc-gz ${outbase%.viral}.notviral.fqgz
#	
#		chmod -w ${outbase%.viral}.notviral.?.fqgz
#	
#		count_fasta_reads.bash ${outbase%.viral}.notviral.?.fqgz
#		
#	fi
#	
#	
#	
#	
#	
#	#done
#	
#	#	minavgquality=10
#	#	out/SFHH008A.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	#	out/SFHH008B.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	#	out/SFHH008C.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	#	out/SFHH008D.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	#	out/SFHH008E.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	#	out/SFHH008F.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	#	
#	#	minavgquality=20
#	#	out/SFHH008A.out.txt:Total Removed:          	243854 reads (84.03%) 	36821954 bases (84.03%)
#	#	out/SFHH008B.out.txt:Total Removed:          	266204 reads (84.30%) 	40196804 bases (84.30%)
#	#	out/SFHH008C.out.txt:Total Removed:          	179040 reads (83.93%) 	27035040 bases (83.93%)
#	#	out/SFHH008D.out.txt:Total Removed:          	259432 reads (83.72%) 	39174232 bases (83.72%)
#	#	out/SFHH008E.out.txt:Total Removed:          	290410 reads (84.72%) 	43851910 bases (84.72%)
#	#	out/SFHH008F.out.txt:Total Removed:          	400742 reads (88.74%) 	60512042 bases (88.74%)
#	#	
#	#	minavgquality=15
#	#	out/SFHH008A.out.txt:Total Removed:          	3158 reads (1.09%) 	476858 bases (1.09%)
#	#	out/SFHH008B.out.txt:Total Removed:          	3578 reads (1.13%) 	540278 bases (1.13%)
#	#	out/SFHH008C.out.txt:Total Removed:          	2892 reads (1.36%) 	436692 bases (1.36%)
#	#	out/SFHH008D.out.txt:Total Removed:          	4174 reads (1.35%) 	630274 bases (1.35%)
#	#	out/SFHH008E.out.txt:Total Removed:          	4622 reads (1.35%) 	697922 bases (1.35%)
#	#	out/SFHH008F.out.txt:Total Removed:          	8422 reads (1.86%) 	1271722 bases (1.86%)
#	
#	
#	#				-m 15 --trim-n \
#	
#	#	cutadapt --trim-n --match-read-wildcards -n 5 -a AAAAAA -G TTTTTT -U 10 -o SFHH008A.quality.format.consolidate.trimmed2.R1.fastq.gz -p SFHH008A.quality.format.consolidate.trimmed2.R2.fastq.gz SFHH008A.quality.format.consolidate.R1.fastq.gz SFHH008A.quality.format.consolidate.R2.fastq.gz
#	







exit




ll /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz | wc -l
86


mkdir -p /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/logs
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="preproc" --output="/francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/logs/preprocess.${date}-%A_%a.out" --time=1440 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/array_wrapper.bash


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=6,7,10,11%1 --job-name="preproc2" --output="/francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/logs/preprocess.${date}-%A_%a.out" --time=1440 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20220610-EV/20220614-preprocessing_with_umi/array_wrapper.bash

scontrol update ArrayTaskThrottle=6 JobId=352083



