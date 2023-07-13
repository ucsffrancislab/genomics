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
	echo $0 --threads 4
	echo --out /path/to/output/folder/
	echo --extension _R1.fastq.gz
	echo /path/to/raw/data/*_R1.fastq.gz
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	HVA=/c4/home/gwendt/github/TheSatoLab/Human_Virome_analysis
	extension="_R1.fastq.gz"
	strand=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
#			-s|--strand)
#				shift; strand=$1; shift;;
#				#	I really don't know which is correct
#				# --rf assume stranded library fr-firststrand
#				# --fr assume stranded library fr-secondstrand - guessing this is correct, but its a guess
#				#	5' ------------------------------> 3'
#				#	   /2 ----->            <----- /1 - fr-firststrand
#				#	   /1 ----->            <----- /2 - fr-secondstrand
#				#	unstranded
#				#	second-strand = directional, where the first read of the read pair (or in case of single end reads, the only read) is from the transcript strand
#				#	first-strand = directional, where the first read (or the only read in case of SE) is from the opposite strand.
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done
	
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools picard
		#module load CBI samtools bwa bedtools2 cufflinks star/2.7.7a
	fi
	
	date
	
	mkdir -p ${OUT}

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

	date

	#	# Human Virome analysis pipeline #
	#	## Kumata, Ito and Sato in prep ##
	#	#
	#	# input : RNA-seq data
	#	# output : viral read count
	#	
	#	##requirements##
	#	# Require the following programs
	#	#   trimmomatic
	#	#   STAR
	#	#   featureCount
	#	#   samtools
	#	#   picard
	#	#   python2
	#	#   blastn
	#	# Requiew the following genome
	#	#   Human genome
	#	#   prokaryota genome

	#	# set directory #
	#	path_to_input = ""
	#	path_to_STAR = ""
	#	path_to_unmapped = ""
	#	path_to_database = ""
	#	path_to_viral_hit_fasta = ""
	#	path_to_res_first_blast = ""
	#	path_to_res_first_blast = ""
	#	path_to_count = ""

	# set threshold
	threshold=1.0e-10
	
	#	# 1. trimming #
	#	java -Xms4g -jar trimmomatic \
	#	    PE \
	#	    -phred33 \
	#	    ${path_to_input}/input_1.fastq \
	#	    ${path_to_input}/input_2.fastq \
	#	    ${path_to_input}/input_1.fastq.trimmed \
	#	    ${path_to_input}/input_2.fastq.trimmed \
	#	    MINLEN:50 \
	#	    SLIDINGWINDOW:4:20
	#	
	#	
	#	# 2. STAR mapping to human genome #
	#	STAR \
	#	     --genomeDir path/to/human_genome \
	#	     --readFilesIn ${path_to_input}/input_1.fastq.trimmed \
	#	                   ${path_to_input}/input_2.fastq.trimmed \
	#	     --outFilterMultimapScoreRange 1 \
	#	     --outFilterMultimapNmax 10 \
	#	     --outFilterMismatchNmax 5 \		#	different that default 10
	#	     --alignIntronMax 500000 \		#	different that default 0
	#	     --alignMatesGapMax 1000000 \		#	different that default 0
	#	     --sjdbScore 2 \	#	different that default 2
	#	     --alignSJDBoverhangMin 1 \	#	different that default 3
	#	     --genomeLoad NoSharedMemory \
	#	     --limitBAMsortRAM 0 \
	#	     --outFilterMatchNminOverLread 0.33 \	#	different than default 0.66
	#	     --outFilterScoreMinOverLread 0.33 \	#	different than default 0.66
	#	     --sjdbOverhang 100 \
	#	     --outSAMstrandField intronMotif \
	#	     --outSAMattributes NH HI NM MD AS XS \
	#	     --outSAMunmapped Within \
	#	     --outSAMtype BAM Unsorted \
	#	     --outSAMheaderHD @HD VN:1.4
	
	
	
	
	#  -f, --require-flags FLAG   ...have all of the FLAGs present
	#  -F, --excl[ude]-flags FLAG ...have none of the FLAGs present
	
	#	samtools flags 12
	#	0xc	12	UNMAP,MUNMAP
	
	#	samtools flags 256
	#	0x100	256	SECONDARY
	
	#	# 3. extract unmapped reads
	#	samtools view -f 12 -F 256 ${path_to_STAR}/STAR_aligned.out.bam | \
	#	    java -Xms5g -Xmx5g -jar picard SamToFastq \
	#	    I=/dev/stdin \
	#	    FASTQ=${path_to_unmapped}/unmapped_1.fastq \
	#	    SECOND_END_FASTQ=${path_to_unmapped}/unmapped_2.fastq
	
	#	## convert fastq to fasta ##
	#	python2 fastq2fasta.py ${path_to_unmapped}/unmapped_1.fastq >
	#	 ${path_to_unmapped}/unmapped_1.fas
	
	
	#	python2 fastq2fasta.py ${path_to_unmapped}/unmapped_2.fastq >
	#	 ${path_to_unmapped}/unmapped_2.fas
	
	
	#	Why not just use Usage: samtools fasta [options...] <in.bam>
	#	Converts a SAM, BAM or CRAM to FASTA format.
	#	  -1 FILE      write reads designated READ1 to FILE
	#	  -2 FILE      write reads designated READ2 to FILE
	#	  -f INT       only include reads with all  of the FLAGs in INT present [0]
	#	  -F INT       only include reads with none of the FLAGS in INT present [0x900]
	
	
	#	BAM file is sorted by coordinate, but these are never treated as paired which is strange
	#
	#	samtools fasta -1 unmapped_1.fastq.gz -2 unmapped_2.fastq.gz -f 12 -F 256 ${path_to_STAR}/STAR_aligned.out.bam | \
	
	#	CHECK IF PAIREDNESS EVER USED LATER - it is
	
	#	Why not just put all into a single fasta file
	
	#	bam file is sorted by coordinate so use biobambam2's bamtofastq

	date

	outbase=${OUT}/${base}
	f=${outbase}_R1.fasta.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Extracting pairs of unmapped reads"

		samtools view -h -f 12 -F 256 --bam ${bam} \
			| bamtofastq fasta=1 F=${f} F2=${f/_R1./_R2.}
	
		#F=<[stdout]>                              : matched pairs first mates
		#F2=<[stdout]>                             : matched pairs second mates
		#collate=<[1]>                             : collate pairs
		#gz=<[0]>                                  : compress output streams in gzip format (default: 0)
		#level=<[-1]>                              : compression setting if gz=1 (-1=zlib default,0=uncompressed,1=fast,9=best)
		#fasta=<[0]>                               : output FastA instead of FastQ
	
		chmod -w ${f} ${f/_R1./_R2.}
	fi

	date


	#	makeblastdb -in virus_genome_for_first_blast.fas -input_type fasta -dbtype nucl -out virus_genome_for_first_blast \
	#		-title virus_genome_for_first_blast -parse_seqids


	#outbase=${OUT}/${base}
	f=${outbase}_R1.blast.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Blasting R1"

		zcat ${outbase}_R1.fasta.gz \
			| blastn -db ${HVA}/virus_genome_for_first_blast \
				-out ${f} -word_size 11 -outfmt 6 -num_threads ${threads}
		chmod -w ${f}

	fi

	date

	#outbase=${OUT}/${base}
	f=${outbase}_R2.blast.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Blasting R2"

		zcat ${outbase}_R2.fasta.gz \
			| blastn -db ${HVA}/virus_genome_for_first_blast \
				-out ${f} -word_size 11 -outfmt 6 -num_threads ${threads}
		chmod -w ${f}

	fi

	date

	#outbase=${OUT}/${base}
	f=${outbase}_R1.blast.viral.fa.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Extract viral hit reads from R1"

		python2 ${HVA}/code/extract_vread.py \
			${outbase}_R1.blast.txt \
			<( zcat ${outbase}_R1.fasta.gz ) | gzip > ${f}

		chmod -w ${f}
	fi

	date

	#outbase=${OUT}/${base}
	f=${outbase}_R2.blast.viral.fa.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Extract viral hit reads from R2"
		python2 ${HVA}/code/extract_vread.py \
			${outbase}_R2.blast.txt \
			<( zcat ${outbase}_R2.fasta.gz ) | gzip > ${f}

		chmod -w ${f}
	fi

	date

	#	makeblastdb -in virus_genome_for_second_blast.fas -input_type fasta -dbtype nucl -out virus_genome_for_second_blast \
	#		-title virus_genome_for_second_blast -parse_seqids

	#	This is odd since the description doesn't match the content

	#outbase=${OUT}/${base}
	f=${outbase}_R1.blast.viral.blast.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Blasting R1"

		## 6. Second blast search #
		#blastn -db ${path_to_database}/human_and_prokaryota_and_virus_genome.db \ # prepare blastn database from three fasta file: human genome, prokaryota genome, virus_genome_for_first_blast.fa

		zcat ${outbase}_R1.blast.viral.fa.gz \
			| blastn -db ${HVA}/virus_genome_for_second_blast \
				-out ${f} -word_size 11 -outfmt 6 -num_threads ${threads} -evalue 0.01

		chmod -w ${f}
	fi

	date

	#outbase=${OUT}/${base}
	f=${outbase}_R2.blast.viral.blast.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Blasting R2"

		zcat ${outbase}_R2.blast.viral.fa.gz \
			| blastn -db ${HVA}/virus_genome_for_second_blast \
				-out ${f} -word_size 11 -outfmt 6 -num_threads ${threads} -evalue 0.01

		chmod -w ${f}
	fi

	date

	#outbase=${OUT}/${base}
	f=${outbase}_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "count viral hit reads"

		python2 ${HVA}/code/count_reads_mapped_on_virus_rm_multi_mapped.py \
			${outbase}_R1.blast.viral.blast.txt \
			${outbase}_R2.blast.viral.blast.txt \
			${threshold} ${base} > ${f}

		#	This script doesn't take a 4th param as run_id
		#	it is pulled from the first filename
		#	run_Id = re.sub(r'.+\/(SRR[0-9]+)_.+',r'\1',argvs[1])

		#	outbase=${OUT}/${base}_R1.blast.viral.blast.txt

		#	This will take some mods as this is expecting SRR... . I may have to fork and edit.

		chmod -w ${f}
	fi

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array ${array_file} "
	
	threads=4

	while [ $# -gt 0 ] ; do
		case $1 in
			-t|--threads)
				shift; threads=$1; shift;;
			-o|--out|--outdir|-e|--extension)
				array_options="${array_options} $1 $2"; shift; shift;;
			-h|--help)
				usage;;
#			-*)
#				array_options="${array_options} $1"; shift;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks $1 >> ${array_file}; shift;;
		esac
	done

	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		# using M so can be more precise-ish
		mem=$[threads*7500]M
		scratch_size=$[threads*28]G	#	not always necessary

		#	ls -1 ${IN}/*${extension} > ${array_file}

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs
		#	date=$( date "+%Y%m%d%H%M%S%N" )

		set -x  #       print expanded command before executing it
		
		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%8 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

