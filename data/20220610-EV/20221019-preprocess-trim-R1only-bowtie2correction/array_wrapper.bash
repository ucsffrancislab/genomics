#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails	#	why unset?
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools/1.13 bowtie2/2.4.4 picard
	#bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


DIR="/francislab/data1/working/20220610-EV/20221019-preprocess-trim-R1only-bowtie2correction"
OUT="${DIR}/out"

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
#	this metadata has a header line so add 1
sample=$( sed -n "$((line+1))"p ${DIR}/metadata.csv | awk -F, '{print $1}' )
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


#b1=${s}.quality.R1.fastq.gz
#b2=${s}.quality.R2.fastq.gz
#echo $b1
#echo $b2


#for quality in 15 20 25 30 ; do
for quality in 15 ; do

	#inbase=${outbase}
	#outbase="${inbase}.format"	#	"${OUT}/${s}.quality??.format"
	outbase="${OUT}/${s}.format"
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		${PWD}/format_filter.bash \
			${r1} ${r2} \
			${outbase}.R1.fastq.gz \
			${outbase}.R2.fastq.gz
			#${inbase}.R1.fastq.gz \
			#${inbase}.R2.fastq.gz \
	fi


	#	I can't find any aligner that will create a tag from the UMI
	#	so, add to read name NO SPACES so it ends up in the bam
	#	THEN, cut it off the read name and add a tag (RX) as is UmiAwareMarkDuplicatesWithMateCigar's default
	
	length=18
	
	inbase=${outbase}
	#outbase="${inbase}.umi"	#	"${OUT}/${s}.quality??.format.umi
	outbase="${inbase}.umi"	#	"${OUT}/${s}.format.umi
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Adding UMI to read name"
		paste <( zcat ${inbase}.R1.fastq.gz | paste - - - - ) <( zcat ${inbase}.R2.fastq.gz | paste - - - - ) |
		awk -F"\t" -v b=${outbase} -v l=${length} '{
			gsub(/ /,"-",$1)
			umi=substr($6,0,l)
			print $1"-"umi >> b".R1.fastq"
			print $2 >> b".R1.fastq"
			print $3 >> b".R1.fastq"
			print $4 >> b".R1.fastq"
		}'
			#print $5"-"umi >> b".R2.fastq"
			#print $6 >> b".R2.fastq"
			#print $7 >> b".R2.fastq"
			#print $8 >> b".R2.fastq"
#	ERROR: Error in sequence file at unknown line: Reads are improperly paired. Read name 'A00887:505:HCVJ3DRX2:1:2101:5330:1016-1:N:0:CGGTAATC+NTGGACTG-TATGTGACTGCTTCGGTG' in file 1 does not match 'A00887:505:HCVJ3DRX2:1:2101:5330:1016-2:N:0:CGGTAATC+NTGGACTG-TATGTGACTGCTTCGGTG' in file 2.
		gzip ${outbase}.R1.fastq
		#gzip ${outbase}.R2.fastq
		chmod -w ${outbase}.R1.fastq.gz
		#chmod -w ${outbase}.R2.fastq.gz
	fi
	

	inbase=${outbase}
	outbase="${inbase}.quality${quality}"	#	"${OUT}/${s}.format.umi.quality15
	#outbase="${OUT}/${s}.quality${quality}"
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#~/.local/bin/bbduk.bash in1=${r1} in2=${r2} \
		#	out1=${outbase}.R1.fastq.gz out2=${outbase}.R2.fastq.gz \
		#	minavgquality=${quality} threads=${SLURM_NTASKS:-auto}

		#~/.local/bin/bbduk.bash in1=${r1} in2=${r2} \
		#	out1=${outbase}.R1.fastq.gz out2=${outbase}.R2.fastq.gz \
		#~/.local/bin/bbduk.bash in1=${r1} \
		~/.local/bin/bbduk.bash in1=${inbase}.R1.fastq.gz \
			out1=${f} \
			qtrim=r trimq=${quality} threads=${SLURM_NTASKS:-auto}

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


#	#inbase=${OUT}/${s}.quality
#	#inbase=${OUT}/${s}.quality??.format.umi
#	inbase=${outbase}
#	outbase="${inbase}.t1"	#	"${OUT}/${s}.format.umi.quality15.t1
#	f=${outbase}.R1.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/cutadapt.bash \
#			--cores ${SLURM_NTASKS:-8} \
#			--match-read-wildcards -n 1 \
#			-m 10 --trim-n \
#			-U 24 \
#			-o ${f} \
#			-p ${outbase}.R2.fastq.gz \
#			${inbase}.R1.fastq.gz ${inbase}.R2.fastq.gz
#			#	-U 24 \ 18bp UMI - G - T{5}
#			#	-U 40 \ 18bp UMI - G - T{21}
#	fi

	inbase=${outbase}
	outbase="${inbase}.t2"	#	"${OUT}/${s}.format.umi.quality15.t2
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		~/.local/bin/cutadapt.bash \
			--cores ${SLURM_NTASKS:-8} \
			--match-read-wildcards -n 1 \
			-a CTGTCTCTTATACACATCT \
			-a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC \
			-m 10 --trim-n \
			-o ${f} \
			${inbase}.R1.fastq.gz
#			-p ${outbase}.R2.fastq.gz \
#			${inbase}.R1.fastq.gz ${inbase}.R2.fastq.gz
#			-A CTGTCTCTTATACACATCT \
#			-A CTGTCTCTTATACACATCTGACGCTGCCGACGA \
#			-A CTGTCTCTTATACACATCT \
#			-G GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAG \
#			-G                AGATGTGTATAAGAGACAG \
#      -A CTGTCTCTTATACACATCTCCGAGCCCACGAGAC \
	fi


	inbase=${outbase}
	#outbase="${inbase}.t3" #	"${OUT}/${s}.quality??.format.umi.t1.t2.t3"
	outbase="${inbase}.t3"	#	"${OUT}/${s}.format.umi.quality15.t2.t3
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		~/.local/bin/cutadapt.bash \
			--cores ${SLURM_NTASKS:-8} \
			--match-read-wildcards -n 5 \
			--error-rate 0.20 \
			-a A{10} \
			-a A{50} \
			-a A{150} \
			-m 10 --trim-n \
			-o ${f} \
			${inbase}.R1.fastq.gz
			#-G T{10} \
			#-G T{50} \
			#-G T{150} \
			#-p ${outbase}.R2.fastq.gz \
			#${inbase}.R1.fastq.gz ${inbase}.R2.fastq.gz
		#	Right trim polyA from R1
		#	Left trim polyT from R2
	fi
	
#	#	Filter out phiX ( not really necssary? )
#	inbase=${outbase}
#	outbase="${inbase}.phiX"	#.fastq.gz"
#	f=${outbase}.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/bowtie2.bash --sort --threads ${SLURM_NTASKS:-8} -x /francislab/data1/refs/bowtie2/phiX \
#			--very-sensitive-local -1 ${inbase}.R1.fastq.gz -2 ${inbase}.R2.fastq.gz -o ${f} --un-conc-gz ${outbase%.phiX}.notphiX.fqgz
#
#		chmod -w ${outbase%.phiX}.notphiX.?.fqgz
#		mv ${outbase%.phiX}.notphiX.1.fqgz ${outbase%.phiX}.notphiX.R1.fastq.gz
#		mv ${outbase%.phiX}.notphiX.2.fqgz ${outbase%.phiX}.notphiX.R2.fastq.gz
#		count_fasta_reads.bash ${outbase%.phiX}.notphiX.R?.fastq.gz
#	fi


#	inbase=${outbase%.phiX}.notphiX
#	outbase="${inbase}.pear"
#	f=${outbase}.assembled.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/pear-0.9.11-linux-x86_64/bin/pear \
#			--forward-fastq ${inbase}.R1.fastq.gz --reverse-fastq ${inbase}.R2.fastq.gz \
#			-o ${outbase} \
#			--threads ${SLURM_NTASKS:-8}
#	
#		chmod -w ${outbase}.assembled.fastq
#		gzip ${outbase}.assembled.fastq
#		count_fasta_reads.bash  ${outbase}.assembled.fastq.gz
#	
#		chmod -w ${outbase}.unassembled.reverse.fastq
#		gzip ${outbase}.unassembled.reverse.fastq
#		count_fasta_reads.bash  ${outbase}.unassembled.reverse.fastq.gz
#	
#		chmod -w ${outbase}.unassembled.forward.fastq
#		gzip ${outbase}.unassembled.forward.fastq
#		count_fasta_reads.bash  ${outbase}.unassembled.forward.fastq.gz
#	fi


#	#inbase="${OUT}/${s}.quality${quality}.format.umi.t1.t2.t3.notphiX"
#	inbase="${OUT}/${s}.format.umi.quality15.t2.t3"
#	outbase="${inbase}.readname"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.readname
#	f=${outbase}.R1.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Adding UMI to read name"
##		paste <( zcat ${inbase}.R1.fastq.gz | paste - - - - ) <( zcat ${inbase}.R2.fastq.gz | paste - - - - ) |
##		awk -F"\t" -v b=${outbase} -v l=${length} '{
##			#umi=substr($6,0,l)
##			gsub(/ /,"-",$1)
##			print $1 >> b".R1.fastq"
##			print $2 >> b".R1.fastq"
##			print $3 >> b".R1.fastq"
##			print $4 >> b".R1.fastq"
##			gsub(/ /,"-",$5)
##			print $5 >> b".R2.fastq"
##			print $6 >> b".R2.fastq"
##			print $7 >> b".R2.fastq"
##			print $8 >> b".R2.fastq"
##		}'
##		gzip ${outbase}.R1.fastq
##		gzip ${outbase}.R2.fastq
##		chmod -w ${outbase}.R1.fastq.gz
##		chmod -w ${outbase}.R2.fastq.gz
#
#		paste <( zcat ${inbase}.R1.fastq.gz | paste - - - - ) |
#		awk -F"\t" -v b=${outbase} -v l=${length} '{
#			gsub(/ /,"-",$1)
#			print $1 >> b".R1.fastq"
#			print $2 >> b".R1.fastq"
#			print $3 >> b".R1.fastq"
#			print $4 >> b".R1.fastq"
#		}'
#		gzip ${outbase}.R1.fastq
#		chmod -w ${outbase}.R1.fastq.gz
#	fi
	





	inbase="${outbase}"
	#outbase="${inbase}.hg38"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.readname.hg38
	outbase="${inbase}.hg38"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.hg38
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#~/.local/bin/bowtie2.bash \  NON-RANDOMIZED
		${PWD}/bowtie2_nonrandomized.bash \
			--threads ${SLURM_NTASKS:-8} \
			--very-sensitive-local \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
			-U ${inbase}.R1.fastq.gz \
			--output ${f} \
			--rg-id ${sample} --rg SM:${sample} \
			--sort
			#-2 ${inbase}.R2.fastq.gz \
			#-U ${inbase}.R1.fastq.gz \
	fi




#		inbase="${outbase}"
#		outbase="${inbase}.rx"
#		f=${outbase}.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			samtools view -h ${inbase}.bam | awk 'BEGIN{FS=OFS="\t"}
#				( /^@/ ){print;next}
#				{ split($1,a,"-"); print $0,"RX:Z:"a[3] }' | samtools view -o ${f} -
#	#	keep the full read name with the lane and read name? Previously, I've tossed it. Putting it back.
#	#			{ split($1,a,"-"); $1=a[1]; print $0,"RX:Z:"a[3] }' | samtools view -o ${f} -
#	#	#	Would this sed command be faster?
#	#	#	samtools view -h SFHH011Z.quality.umi.t1.t3.hg38.bam | sed -r "s/^([^,]+)-([ACGTN]{18})(.*)$/\1\3\tRX:Z:\2/"
#			chmod -w ${f}
#		fi
#	
#		inbase="${outbase}"
#		outbase="${inbase}.name"
#		f=${outbase}.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			#	gotta make sure that the paired read names are the same
#			samtools view -h ${inbase}.bam | awk 'BEGIN{FS=OFS="\t"}
#				( /^@/ ){print;next}
#				{ sub(/-[12]:N:0:.*$/,"",$1); print $0 }' | samtools view -o ${f} -
#			chmod -w ${f}
#		fi



#	should do RX and NAME in one step ...
#	$1=a[1]
#	"LI:Z:"a[2]
#	"RX:Z:"a[3]
	inbase="${outbase}"
	#outbase="${inbase}.name"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.readname.hg38.name
	outbase="${inbase}.name"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.hg38.name
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gotta make sure that the paired read names are the same
		samtools view -h ${inbase}.bam | awk 'BEGIN{FS=OFS="\t"}
			( /^@/ ){print;next}
			{ split($1,a,"-"); $1=a[1]; print $0,"LI:Z:"a[2],"RX:Z:"a[3] }' | samtools view -o ${f} -
		chmod -w ${f}
	fi




#	inbase="${outbase}"
#	outbase="${inbase}.mated"
#	f=${outbase}.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		#	copy mate's cigar string into the MC tag.
#		java -jar $PICARD_HOME/picard.jar FixMateInformation \
#			--INPUT ${inbase}.bam \
#			--OUTPUT ${f}
#		chmod -w ${f}
#	fi

	inbase="${outbase}"
	#outbase="${inbase}.marked"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.readname.hg38.name.marked
	outbase="${inbase}.marked"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.hg38.name.marked
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	--MAX_EDIT_DISTANCE_TO_JOIN 1
		java -jar $PICARD_HOME/picard.jar UmiAwareMarkDuplicatesWithMateCigar \
			--TAGGING_POLICY All \
			--INPUT ${inbase}.bam \
			--CREATE_INDEX true \
			--OUTPUT ${f} \
			--METRICS_FILE ${outbase}.metrics.txt \
			--UMI_METRICS_FILE ${outbase}.umi_metrics.txt
		chmod -w ${outbase}.*
	
		samtools view -F 3844 -c ${f} > ${f}.F3844.aligned_count.txt
		chmod -w ${f}.F3844.aligned_count.txt
	
		samtools view -f 1024 -c ${f} > ${f}.f1024.aligned_count.txt
		chmod -w ${f}.f1024.aligned_count.txt

	fi

	inbase="${outbase}"
	outbase="${inbase}"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.hg38.name.marked
	f=${outbase}.bam.f1024.aligned_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools view -f 1024 -c ${f%.f1024.aligned_count.txt} > ${f}
		chmod -w ${f}
	fi

	inbase="${outbase}"
	#outbase="${inbase}.deduped"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.readname.hg38.name.marked.deduped
	outbase="${inbase}.deduped"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.hg38.name.marked.deduped
	f=${outbase}.fa.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		samtools fasta -F 3844 ${inbase}.bam | gzip > ${f}
		chmod -w ${f}
	fi





	inbase="${outbase}"
	outbase="${inbase}.hg38"	#	"${OUT}/${s}.format.umi.quality15.t2.t3.hg38.name.marked.deduped.hg38
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		~/.local/bin/bowtie2.bash \
			--threads ${SLURM_NTASKS:-8} \
			--very-sensitive-local \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
			-f -U ${inbase}.fa.gz \
			--output ${f} \
			--rg-id ${sample} --rg SM:${sample} \
			--sort
			#-2 ${inbase}.R2.fastq.gz \
			#-U ${inbase}.R1.fastq.gz \
	fi




#		inbase="${outbase}"
#		outbase="${inbase}.rx"
#		f=${outbase}.bam


done



echo "Done"
date

exit




ll /francislab/data1/raw/20220610-EV/SF*R1_001.fastq.gz | wc -l
86


mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%8 --job-name="preproc" --output="${PWD}/logs/preprocess.${date}-%A_%a.out" --time=1400 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083

