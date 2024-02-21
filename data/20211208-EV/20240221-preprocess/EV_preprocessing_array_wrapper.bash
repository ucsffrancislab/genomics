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
	echo $0 *fastq.gz
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension=".fastq.gz"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; mkdir -p ${OUT}; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done

	echo "extension :${extension}:"


	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools star/2.7.10b picard htslib
	fi
	
	date
	

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
	#bam=${line}

	echo
	echo "base : ${base}"
	#echo "bam : $bam"
	echo "line : ${line}"
	echo 

	fastq=${line}
	r1=${line}
	r2=${r1/_R1./_R2.}


	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x





	out_base="${OUT}/${base}"

	UMI_LENGTH=9

	if [ ${r1} != ${r2} ] ; then #	paired-end
	
		in_base=${out_base}
		out_base=${in_base}.format
		f=${out_base}.R1.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
	
			\rm -f ${out_base}.R1.fastq ${out_base}.R2.fastq ${out_base}.R1.fastq.gz ${out_base}.R2.fastq.gz
	
			out1=${out_base}.R1.fastq.gz
			out2=${out_base}.R2.fastq.gz
			paste <( zcat ${r1} | paste - - - - ) <( zcat ${r2} | paste - - - - ) |
				awk -F"\t" -v l=${UMI_LENGTH} -v o1=${out1%.gz} -v o2=${out2%.gz} '( $6 ~ "^.{"l"}GTT" ){
					print $1 >> o1
					print $2 >> o1
					print $3 >> o1
					print $4 >> o1
					print $5 >> o2
					print $6 >> o2
					print $7 >> o2
					print $8 >> o2
				}'
	
			bgzip ${out1%.gz}
			bgzip ${out2%.gz}
	
			chmod -w $out1 $out2
	
			count_fasta_reads.bash $out1 $out2
			average_fasta_read_length.bash $out1 $out2
	
		fi

	#	else	#	single-end

	#	Not sure if this had an expected format

	fi





	######################################################################

	#	I can't find any aligner that will create a tag from the UMI
	#	Need spaces before cutadapt. Then replaces spaces with dashes before aligning ( FIXED
	#	so, add to read name NO SPACES so it ends up in the bam
	#	THEN, cut it off the read name and add a tag (RX) as is UmiAwareMarkDuplicatesWithMateCigar's default

	#	Actually, doing it a bit differently now.

	in_base=${out_base}
	out_base=${in_base}.umi

	if [ ${r1} != ${r2} ] ; then #	paired-end

		f=${out_base}.R1.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			\rm -f ${out_base}.R1.fastq ${out_base}.R2.fastq ${out_base}.R1.fastq.gz ${out_base}.R2.fastq.gz
	
			echo "Adding UMI to read name"

			#length=18

			paste <( zcat ${in_base}.R1.fastq.gz | paste - - - - ) <( zcat ${in_base}.R2.fastq.gz | paste - - - - ) |
				awk -F"\t" -v b=${out_base} -v l=${UMI_LENGTH} '{
					#gsub(/ /,"-",$1)
					split($1,readname1," ")
					split($5,readname2," ")
					umi=substr($6,0,l)
					#print $1" "umi >> b".R1.fastq"
					print readname1[1]":"umi" "readname1[2]>> b".R1.fastq"
					print $2 >> b".R1.fastq"
					print $3 >> b".R1.fastq"
					print $4 >> b".R1.fastq"
					print readname2[1]":"umi" "readname2[2]>> b".R2.fastq"
					print $6 >> b".R2.fastq"
					print $7 >> b".R2.fastq"
					print $8 >> b".R2.fastq"
				}'

			#		print readname1[1]"-"umi" "readname1[2]>> b".R1.fastq"
			#		print readname2[1]"-"umi" "readname2[2]>> b".R2.fastq"
			#
			#	cutadapt cannot ignore unmatching read names (anything before the first space)
			#	so need to separate by space before trimming with cutadapt
			#	but STAR will delete everything after first space so after trimming need to replace the space
			#
			#	ERROR: Error in sequence file at unknown line: Reads are improperly paired. 
			#	Read name 'A00887:505:HCVJ3DRX2:1:2101:5330:1016-1:N:0:CGGTAATC+NTGGACTG-TATGTGACTGCTTCGGTG' in file 1 
			#	does not match 'A00887:505:HCVJ3DRX2:1:2101:5330:1016-2:N:0:CGGTAATC+NTGGACTG-TATGTGACTGCTTCGGTG' in file 2.
	
			#	That's all fine and dandy, but why not put the UMI at the end of the FIRST PART OF BOTH R1 AND R2 instead of after the second.
	
			#	NOT A00887:505:HCVJ3DRX2:1:2101:5330:1016-1:N:0:CGGTAATC+NTGGACTG-TATGTGACTGCTTCGGTG'
			#     A00887:505:HCVJ3DRX2:1:2101:5330:1016-2:N:0:CGGTAATC+NTGGACTG-TATGTGACTGCTTCGGTG
			#	BUT A00887:505:HCVJ3DRX2:1:2101:5330:1016-TATGTGACTGCTTCGGTG 1:N:0:CGGTAATC+NTGGACTG'
			#     A00887:505:HCVJ3DRX2:1:2101:5330:1016-TATGTGACTGCTTCGGTG 2:N:0:CGGTAATC+NTGGACTG'
			#	cutadapt is happy. STAR will keep. Done
	
			bgzip ${out_base}.R1.fastq
			bgzip ${out_base}.R2.fastq
	
			chmod -w ${out_base}.R1.fastq.gz
			chmod -w ${out_base}.R2.fastq.gz
	
			count_fasta_reads.bash ${out_base}.R1.fastq.gz ${out_base}.R2.fastq.gz
		fi

	else	#	single-end

		f=${out_base}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
	
			#	extract the UMI into the read name
	
			#	Looks like the UMI is 12bp and there are 4bp more of U turn something
			# previous runs did the umi after trimming for some reason
	
			#zcat ${OUT}/${base}.fastq.gz | paste - - - - \
			#	| awk -F"\t" '{split($1,a," ");print a[1]":"substr($2,1,12)" "a[2];print substr($2,17); print $3;print substr($4,17)}' \
			zcat ${fastq} | paste - - - - \
				| awk -F"\t" '{split($1,a," ");print a[1]":"substr($2,1,12)" "a[2];print $2; print $3; print $4}' \
				| bgzip > ${f}

			chmod a-w ${f}

			count_fasta_reads.bash ${f}
	
		fi

	fi

	######################################################################

	in_base=${out_base}
	out_base=${in_base}.trim

	if [ ${r1} != ${r2} ] ; then #	paired-end

		#	Source
		#
		#	AATGATACGGCGACCACCGAGATCTACAC[i5 index]TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGGG
		#     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAAC[UMI]
		#         CTGTCTCTTATACACATCTCCGAGCCCACGAGAC[i7 index]ATCTCGTATGCCGTCTTCTGCTTG 
		#
		#	TTACTATGCCGCTGGTGGCTCTAGATGTG[i5 index]AGCAGCCGTCGCAGTCTACACATATTCTCTGTCCCC
		#     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXVTTTTTTTTTTTTTTTTTTTTTG[UMI]
		#         GACAGAGAATATGTGTAGAGGCTCGGGTGCTCTG[i7 index]TAGAGCATACGGCAGAAGACGAAC
		#
		#	Returned fastq
		#
		#	R1 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBAAAAAAAAAAAAAAAAAAAAAC[UMI]
		#		    CTGTCTCTTATACACATCT CCGAGCCCACGAGAC[i7 index]ATCTCGTATGCCGTCTTCTGCTTG 
		#
		#	R2 - [UMI] GTTTTTTTTTTTTTTTTTTTTTVXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
		#		CCC CTGTCTCTTATACACATCT GACGCTGCCGACGA[i5 index]GTGTAGATCTCGGTGGTCGCCGTATCATT
		#
		#	Right trim CTGTCTCTTATACACATCT CCGAGCCCACGAGAC from R1
		#	Trim UMI from R2
		#	Left trim TTTT from R2
		#	Right trim CCC CTGTCTCTTATACACATCT GACGCTGCCGACGA from R2
		#	N{3}CTGTCTCTTATACACATCT GACGCTGCCGACGA

		f=${out_base}.R1.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
	
			#  --action {trim,retain,mask,lowercase,none}
			#                        What to do if a match was found. trim: trim adapter and up- or downstream
			#                        sequence; retain: trim, but retain adapter; mask: replace with 'N' characters;
			#                        lowercase: convert to lowercase; none: leave unchanged. Default: trim
	
			#  -a ADAPTER, --adapter ADAPTER ( right trim )
			#                        Sequence of an adapter ligated to the 3' end (paired data: of the first read).
			#                        The adapter and subsequent bases are trimmed. If a '$' character is appended
			#                        ('anchoring'), the adapter is only found if it is a suffix of the read.
			#
			#  -A ADAPTER            3' adapter to be removed from R2 ( right trim )
			#
			#  -G ADAPTER            5' adapter to be removed from R2 ( left trim )
			
			#  -e E, --error-rate E, --errors E
			#                        Maximum allowed error rate (if 0 <= E < 1), or absolute number of errors for
			#                        full-length adapter match (if E is an integer >= 1). Error rate = no. of errors
			#                        divided by length of matching region. Default: 0.1 (10%)
			
			#  -q [5'CUTOFF,]3'CUTOFF, --quality-cutoff [5'CUTOFF,]3'CUTOFF
			#                        Trim low-quality bases from 5' and/or 3' ends of each read before adapter
			#                        removal. Applied to both reads if data is paired. If one value is given, only
			#                        the 3' end is trimmed. If two comma-separated cutoffs are given, the 5' end is
			#                        trimmed with the first cutoff, the 3' end with the second.
	
			#  -m LEN[:LEN2], --minimum-length LEN[:LEN2]
			#                        Discard reads shorter than LEN. Default: 0
	
			#  -n COUNT, --times COUNT
			#                        Remove up to COUNT adapters from each read. Default: 1
	
			#  --match-read-wildcards
			#                        Interpret IUPAC wildcards in reads. Default: False
	
			#  --trim-n              Trim N's on ends of reads.
	
			#  -O MINLENGTH, --overlap MINLENGTH
	    #                    Require MINLENGTH overlap between read and adapter for an adapter to be found.
	    #                    Default: 3
	
			#~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
			#-a    CTGTCTCTTATACACATCTCCGAGCCCACGAGAC \
			#-A CCCCTGTCTCTTATACACATCTGACGCTGCCGACGA \
	
			#	paired end
			~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards --times 15 \
				--cores ${threads} --error-rate 0.1 \
				--overlap 5 --minimum-length 15 --quality-cutoff 25 \
				-a    CTGTCTCTTATACACATCT \
				-a "A{10}" \
				-A CCCCTGTCTCTTATACACATCT \
				-G "T{10}" \
				-U $[UMI_LENGTH+3] \
				-o ${out_base}.R1.fastq.gz -p ${out_base}.R2.fastq.gz \
				${in_base}.R1.fastq.gz ${in_base}.R2.fastq.gz
	
			#	trim polyA and polyT from both reads so can compare kmers in single-end and paired-end data
	
		fi

	else	#	single-end

		f=${out_base}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
	
			#  --action {trim,retain,mask,lowercase,none}
			#                        What to do if a match was found. trim: trim adapter and up- or downstream
			#                        sequence; retain: trim, but retain adapter; mask: replace with 'N' characters;
			#                        lowercase: convert to lowercase; none: leave unchanged. Default: trim
	
			#  -a ADAPTER, --adapter ADAPTER ( right trim )
			#                        Sequence of an adapter ligated to the 3' end (paired data: of the first read).
			#                        The adapter and subsequent bases are trimmed. If a '$' character is appended
			#                        ('anchoring'), the adapter is only found if it is a suffix of the read.
			#
			#  -A ADAPTER            3' adapter to be removed from R2 ( right trim )
			#
			#  -G ADAPTER            5' adapter to be removed from R2 ( left trim )
			
			#  -e E, --error-rate E, --errors E
			#                        Maximum allowed error rate (if 0 <= E < 1), or absolute number of errors for
			#                        full-length adapter match (if E is an integer >= 1). Error rate = no. of errors
			#                        divided by length of matching region. Default: 0.1 (10%)
			
			#  -q [5'CUTOFF,]3'CUTOFF, --quality-cutoff [5'CUTOFF,]3'CUTOFF
			#                        Trim low-quality bases from 5' and/or 3' ends of each read before adapter
			#                        removal. Applied to both reads if data is paired. If one value is given, only
			#                        the 3' end is trimmed. If two comma-separated cutoffs are given, the 5' end is
			#                        trimmed with the first cutoff, the 3' end with the second.
	
			#  -m LEN[:LEN2], --minimum-length LEN[:LEN2]
			#                        Discard reads shorter than LEN. Default: 0
	
			#  -n COUNT, --times COUNT
			#                        Remove up to COUNT adapters from each read. Default: 1
	
			#  --match-read-wildcards
			#                        Interpret IUPAC wildcards in reads. Default: False
	
			#  --trim-n              Trim N's on ends of reads.
	
			#  -O MINLENGTH, --overlap MINLENGTH
	    #                    Require MINLENGTH overlap between read and adapter for an adapter to be found.
	    #                    Default: 3
	
	
			#	trim polyA and polyT from both reads so can compare kmers in single-end and paired-end data

			#	single end ( UMI trimming occurred previously so no need for a -u or -U )
			~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards --times 7 \
				--cores ${threads} --error-rate 0.1 \
				--overlap 5 --minimum-length 15 --quality-cutoff 25 \
				-a "A{10}" \
				-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
				-a AGATCGGAAGAGCACA \
				-a      GGAAGAGCACACGTCTGAACTCCAGTCA \
				-a                      GAACTCCAGTCAC \
				-a ATCTCGTATGCCGTCTTCTGCTTG \
				-u $[UMI_LENGTH+3] \
				-o ${out_base}.fastq.gz \
				${in_base}.fastq.gz

				#	AGATCGGAAGAG
				#	     GGAAGAGCACAC
				#       GAAGAGCACACG
	
		fi

	fi

	######################################################################

	in_base=${out_base}
	out_base=${in_base}
	f=${out_base}.Aligned.sortedByCoord.out.bam

	if [ ${r1} != ${r2} ] ; then #	paired-end
		STAR_readFilesIn="--readFilesIn ${in_base}.R1.fastq.gz ${in_base}.R2.fastq.gz "
	else	#	single-end
		STAR_readFilesIn="--readFilesIn ${in_base}.fastq.gz "
	fi

	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	align with STAR
		#	--genomeDir /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
		#	--genomeDir /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.p13.genome \

		#	TESTING BASIC TWO PASS MODE

		STAR.bash --runMode alignReads ${STAR_readFilesIn} \
			--twopassMode Basic \
			--genomeDir /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
			--runThreadN ${threads} \
			--readFilesType Fastx \
			--outSAMtype BAM SortedByCoordinate \
			--outSAMstrandField intronMotif \
			--readFilesCommand zcat \
			--outFileNamePrefix ${out_base}.  \
			--outSAMattrRGline ID:${base} SM:${base} \
			--outFilterMultimapNmax 1 \
			--outSAMunmapped Within KeepPairs \
			--outSAMattributes Standard XS

		#	Mode twopass?

		#	Try this sometime and compare
		#
		#### 2-pass Mapping
		#twopassMode                 None
		#    string: 2-pass mapping mode.
		#                            None        ... 1-pass mapping
		#                            Basic       ... basic 2-pass mapping, with all 1st pass junctions inserted into the genome indices on the fly

		chmod a-w ${f} ${f/.R1./.R2.}

	fi

	in_base=${out_base}.Aligned.sortedByCoord.out
	out_base=${in_base}.umi_tag
	f=${out_base}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	move UMI into a tag

		samtools view -h ${in_base}.bam \
			| awk 'BEGIN{FS=OFS="\t"}
			(/^@/){print;next}
			{	last_colon_index=match($1, /:[^:]*$/)
				umi=substr($1,last_colon_index+1)
				$1=substr($1,1,last_colon_index-1)
				print $0"\tRX:Z:"umi
			}' | samtools view -o ${f} -

			#{	last_dash_index=match($1, /-[^-]*$/)
			#	umi=substr($1,last_dash_index+1)
			#	$1=substr($1,1,last_dash_index-1)
			#	print $0"\tRX:Z:"umi
			#}' | samtools view -o ${f} -

		chmod a-w ${f}

	fi

	in_base=${out_base}
	out_base=${in_base}.fixmate
	f=${out_base}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	copy mate's cigar string into the MC tag.
		java -jar $PICARD_HOME/picard.jar FixMateInformation \
			--INPUT ${in_base}.bam \
			--OUTPUT ${f}
		chmod -w ${f}
	fi

	in_base=${out_base}
	out_base=${in_base}.deduped
	f=${out_base}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#	mark duplicates

		#	could have just ...
		#--REMOVE_DUPLICATES <Boolean> If true do not write duplicates to the output file instead of writing them with
		#                              appropriate flags set.  Default value: false. Possible values: {true, false} 

		#--MAX_EDIT_DISTANCE_TO_JOIN / -MAX_EDIT_DISTANCE_TO_JOIN
		#Largest edit distance that UMIs must have in order to be considered as coming from distinct source molecules.

		#	I thoughht that UMIs were only used in RNA-seq data????
		#
		#	Note also that this tool will not work with alignments that have large gaps or deletions, such as those from RNA-seq data.This is due to the need to buffer small genomic windows to ensure integrity of the duplicate marking, while large skips(ex. skipping introns) in the alignment records would force making that window very large, thus exhausting memory.


		#	Not sure what this does with unaligned. Nothing I gues.

		module unload picard
		module load gatk

		gatk UmiAwareMarkDuplicatesWithMateCigar \
			--INPUT ${in_base}.bam \
			--METRICS_FILE ${out_base}.metrics_file.txt \
			--UMI_METRICS_FILE ${out_base}.umi_metrics_file.txt \
			--MAX_EDIT_DISTANCE_TO_JOIN 2 \
			--OUTPUT ${f}

			#--REMOVE_DUPLICATES true \
		chmod a-w ${f}

	fi

	date


	#	again, single ended failure expected?

	#	Want ONLY reads pairs with at least 1 alignment 

	in_base=${out_base}
	out_base=${in_base}
	f=${out_base}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		# Alignment flags: PAIRED,PROPER_PAIR,UNMAP,MUNMAP,REVERSE,MREVERSE,READ1,READ2,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY

		#bamtofastq gz=1 collate=1 inputformat=bam filename=${in_base}.bam \
		#	exclude="DUP,SECONDARY,SUPPLEMENTARY" \
		
		samtools view -h -F3328 -O SAM ${in_base}.bam \
			| awk '(/^@/)||(!and($2,4))||(!and($2,8))' \
			| bamtofastq gz=1 collate=1 inputformat=sam \
				F=${out_base}.R1.fastq.gz \
				F2=${out_base}.R2.fastq.gz \
				S=${out_base}.S0.fastq.gz \
				O=${out_base}.O1.fastq.gz \
				O2=${out_base}.O2.fastq.gz

		count_fasta_reads.bash ${out_base}.{R1,R2,S0,O1,O2}.fastq.gz

		chmod a-w ${out_base}.{R1,R2,S0,O1,O2}.fastq.gz

	fi

	date



	in_base=${out_base}
	out_base=${in_base}
	f=${out_base}.bam.deduped_read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		#   0x1     1  PAIRED         paired-end / multiple-segment sequencing technology
		#   0x2     2  PROPER_PAIR    each segment properly aligned according to aligner
		#   0x4     4  UNMAP          segment unmapped
		#   0x8     8  MUNMAP         next segment in the template unmapped
		#  0x10    16  REVERSE        SEQ is reverse complemented
		#  0x20    32  MREVERSE       SEQ of next segment in template is rev.complemented
		#  0x40    64  READ1          the first segment in the template
		#  0x80   128  READ2          the last segment in the template
		# 0x100   256  SECONDARY      secondary alignment
		# 0x200   512  QCFAIL         not passing quality controls or other filters
		# 0x400  1024  DUP            PCR or optical duplicate
		# 0x800  2048  SUPPLEMENTARY  supplementary alignment

		# 2048 + 256 = 2304
		# 2048 + 1024 + 256 = 3328

		#  -f, --require-flags FLAG   ...have all of the FLAGs present
		#  -F, --excl[ude]-flags FLAG ...have none of the FLAGs present
		#      --rf, --incl-flags, --include-flags FLAG

		samtools view -c -F 3328 ${in_base}.bam > ${out_base}.bam.deduped_read_count.txt

		samtools view -c -F 2304 ${in_base}.bam > ${out_base}.bam.read_count.txt

		samtools view -c -f 1024 -F 2304 ${in_base}.bam > ${out_base}.bam.dup_read_count.txt


		chmod a-w ${out_base}.bam.deduped_read_count.txt

		chmod a-w ${out_base}.bam.read_count.txt

		chmod a-w ${out_base}.bam.dup_read_count.txt

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
			-o|--out|-e|--extension)
				array_options="${array_options} $1 $2"; shift; shift;;
			-@|-t|--threads)
				shift; threads=$1; shift;;
			-h|--help)
				usage;;
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

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		#--gres=scratch:${scratch_size}G \

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )
	
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

