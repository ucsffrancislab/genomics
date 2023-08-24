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

	#HVA=/c4/home/gwendt/github/TheSatoLab/Human_Virome_analysis
	HVA=/c4/home/gwendt/github/ucsffrancislab/Human_Virome_analysis
	extension="_R1.fastq.gz"
	strand=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
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


#	Not sure why, but my local install is crashing.
#	Looks like I'm using a precompiled binary with links to nonexistant files locally.
#	Use a UCSF module instead
#+ blastn -db /francislab/data1/refs/blastn/nt -word_size 11 -outfmt 6 -num_threads 4 -evalue 0.01
#Error: NCBI C++ Exception:
#    T0 "/home/jrosen/code/RMBlast/ncbi-blast-2.10.0+-src/c++/src/serial/objistrasnb.cpp", line 499: Error: byte 70: overflow error ( at [].[].gi)
#    T0 "/home/jrosen/code/RMBlast/ncbi-blast-2.10.0+-src/c++/src/serial/member.cpp", line 770: Error: ncbi::CMemberInfoFunctions::ReadWithSetFlagMember() - error while reading seqid ( at Blast-def-line-set.[].[].seqid.[].[].gi)
	
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools blast
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
	
	#	Why not just put all into a single fasta file? Read pairs are selected later. Blast doesn't do paired.
	#	Why not just use bowtie2 or bwa to align paired rather than blast?
	

	#	https://bmcbiol.biomedcentral.com/articles/10.1186/s12915-020-00785-5


	#	Comparison of the performance of analytical pipelines
	#	To evaluate the performance of our pipeline, we used three published pipelines: Kraken (version 2.0.8) [35], 
	#	CLARK (version 1.2.6.1) [36], and Kaiju (version 1.7.3) [37]. As the viral sequence database, NCBI Viral 
	#	Genomes Resource [70] was downloaded through the command implemented in each pipeline (downloaded 24 
	#	February 2020). From 136 liver samples, the number of reads assigned to HCV taxonomy (taxid 11103 or 41856) 
	#	was quantified by three pipelines with default parameters and compared to our pipeline result 
	#	(Additional file 7: Figure S2).


	#	Extraction of RNA-Seq fragments disclosing similarity to viral sequences
	#	The analytical pipeline is illustrated in Fig. 1. First, RNA-Seq fragments that were not properly mapped to 
	#	the human reference genome were extracted using the “samtools view” [84] command with the options “-f 12 -F 256.” 
	#	Second, a 1st BLASTn search of the unmapped RNA-Seq reads was performed on the viral genome sequence database 
	#	prepared above. The word size and E value parameters were set at 11 and 1.0e−10, respectively. Regarding the 
	#	BLAST-hit reads, a 2nd BLASTn search was performed on the database comprising the human, bacterial, and viral 
	#	genome sequences prepared above. RNA-Seq fragments were assigned to the top-hit feature according to the bit 
	#	score. In the case of a tie, the reads were discarded. If a set of paired reads was assigned to the distinct 
	#	features, the reads were discarded. RNA-Seq fragments assigned to respective viruses were counted in each RNA-Seq 
	#	dataset, and a count matrix of the viral RNA-Seq fragments was generated.

	#	"database comprising the human, bacterial, and viral genome sequences" isn't entirely clear
	#	need to consult the linked spreadsheet in Table S7

	#	5139 viral accessions in Table S6
	#	284176 prokaryotic accessions in Table S7

	#	Construction of custom sequence databases
	#	A viral genomic sequence database was constructed as follows. First, of the viral sequences, sequence regions 
	#	that highly resemble the human or bacterial genomes were masked (i.e., replaced by the sequence “NNN …”). The 
	#	sequence regions to be masked were determined by a local sequence similarity search using BLASTn (in BLAST+ 
	#	version 3.9.0) [77]. The word size and E value parameters were set at 11 and 1.0e−3, respectively. As sources 
	#	of the human and bacterial genome sequences, the human reference genome (GRCh38/hg38) and the prokaryotic 
	#	representative genomes were used, respectively. Second, redundant viral sequences (i.e., sequences 
	#	disclosing > 90% global sequence identity with each other) were concatenated. The sequence identity was 
	#	calculated by Stretcher software (in EMBOSS version 6.6.0.0) [78]. The viral sequences included in the viral 
	#	sequence database are summarized in Additional file 11: Table S6. In addition, a sequence database comprising 
	#	(1) the human reference genome, (2) the prokaryotic representative genomes, and (3) the custom viral genomes 
	#	prepared above was also constructed.

	date

	outbase=${OUT}/${base}
	f=${outbase}_R1.fasta.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Extracting pairs of unmapped reads"

		#	select pairs of unmapped (-f 12), not secondary alignments (-F 256) (why would it be secondary if it were unmapped???)
		#	bam file is sorted by coordinate so use biobambam2's bamtofastq

		samtools view -h -f 12 -F 256 --bam ${bam} \
			| bamtofastq fasta=1 gz=1 F=${f} F2=${f/_R1./_R2.}
	
		chmod -w ${f} ${f/_R1./_R2.}
	fi

	date

	for RR in R1 R2 ; do

		#outbase=${OUT}/${base}
		f=${outbase}_${RR}.blast.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Blasting ${RR} to viral"

			#	makeblastdb -input_type fasta -dbtype nucl -parse_seqids \
			#		-in virus_genome_for_first_blast.fas \
			#		-out virus_genome_for_first_blast \
			#		-title virus_genome_for_first_blast 
	
			zcat ${outbase}_${RR}.fasta.gz \
				| blastn -db ${HVA}/virus_genome_for_first_blast \
					-word_size 11 -outfmt 6 -num_threads ${threads} | gzip > ${f}
					#-out ${f} 
			chmod -w ${f}
	
		fi
	
		date
	
		#outbase=${OUT}/${base}
		f=${outbase}_${RR}.blast.viral.fa.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Extract viral hit reads from ${RR}"


			#	R1 is ALWAYS TINY. R2 is pretty big.
	
			python2 ${HVA}/code/extract_vread.py \
				<( zcat ${outbase}_${RR}.blast.txt.gz ) \
				<( zcat ${outbase}_${RR}.fasta.gz ) | gzip > ${f}
	
			chmod -w ${f}
		fi
	
		date
	


		#	makeblastdb -in virus_genome_for_second_blast.fas -input_type fasta -dbtype nucl -out virus_genome_for_second_blast \
		#		-title virus_genome_for_second_blast -parse_seqids
	
		#	This is odd since the description doesn't match the content

		#	Is it correct?

		#	prokaryota = bacteria + archae (this'll be HUGE)
		#	https://ftp.ncbi.nih.gov/refseq/release/bacteria/ currently contains over 942 bacteria.*.genomic.fna.gz files, some several hundred MB
		#	https://ftp.ncbi.nih.gov/refseq/release/archaea/ is just a few

	
		#outbase=${OUT}/${base}
		f=${outbase}_${RR}.blast.viral.blast.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Blasting ${RR} to UNKNOWN?"
	
			## 6. Second blast search #
			#blastn -db ${path_to_database}/human_and_prokaryota_and_virus_genome.db \ # prepare blastn database from three fasta file: human genome, prokaryota genome, virus_genome_for_first_blast.fa

			# would nt work here?
			#	or do I really need to create one with just hg38, virus_genome_for_first_blast, prokaryota

			#	What is virus_genome_for_second_blast actually for it not to be used here?

			#	${HVA}/virus_genome_for_second_blast \
			#	Not sure if it'll work but trying nt here. Sadly enough reads aren't making it this far.
			#	nt doesn't return any matches. Odd.
			#	| blastn -db /francislab/data1/refs/blastn/nt \

			#	Creating db_for_second_blast

			zcat ${outbase}_${RR}.blast.viral.fa.gz \
				| blastn -db /francislab/data1/refs/Human_Virome_Analysis/db_for_second_blast \
					-word_size 11 -outfmt 6 -num_threads ${threads} -evalue 0.01 | gzip > ${f}
					#-out ${f} 
	
			chmod -w ${f}
		fi
	
		date

	done

	#outbase=${OUT}/${base}
	f=${outbase}.count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "count viral hit reads"

		python2 ${HVA}/code/count_reads_mapped_on_virus_rm_multi_mapped.py \
			<( zcat ${outbase}_R1.blast.viral.blast.txt.gz ) \
			<( zcat ${outbase}_R2.blast.viral.blast.txt.gz ) \
			${threshold} ${base} > ${f}

		chmod -w ${f}
	fi

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
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

		[ -z "${array}" ] && array="1-${max}"
		
		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

