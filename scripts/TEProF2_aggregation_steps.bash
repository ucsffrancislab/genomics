#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails			#	can be problematic when piping through head.
set -u  #       Error on usage of unset variables
set -o pipefail
set -x  #       print expanded command before executing it

CPC2=/c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py
TEPROF2=/c4/home/gwendt/github/ucsffrancislab/TEProf2Paper/bin
ARGUMENTS=/francislab/data1/refs/TEProf2/TEProF2.arguments.txt
threads=${SLURM_NTASKS:-32}
strand=""
using_reference=false
time="14-0"

while [ $# -gt 0 ] ; do
	case $1 in
		--arguments)
			shift; ARGUMENTS=$1; shift;;
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		--time)
			shift; time=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
		-r|--reference_merged_candidates_gtf)
			using_reference=true
			shift; reference_merged_candidates_gtf=$1; shift;;
		-s|--strand)
			shift; strand=$1; shift;;
			#	I really don't know which is correct
			# --rf assume stranded library fr-firststrand
			# --fr assume stranded library fr-secondstrand - guessing this is correct, but its a guess
			#	5' ------------------------------> 3'
			#	   /2 ----->            <----- /1 - fr-firststrand
			#	   /1 ----->            <----- /2 - fr-secondstrand
			#	unstranded
			#	second-strand = directional, where the first read of the read pair (or in case of single end reads, the only read) is from the transcript strand
			#	first-strand = directional, where the first read (or the only read in case of SE) is from the opposite strand.
		-h|--help)
			echo
			echo $0
			echo
			exit;;
		*)
			echo "Unknown param :${1}:"; exit ;;
	esac
done


if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r/4.2.3 samtools cufflinks bedtools2
			# bwa bedtools2 star/2.7.7a

		#module load WitteLab python3/3.9.1


		#	http://ccb.jhu.edu/software/stringtie/dl/		gffread / stringtie / gffcompare 
		#	http://ccb.jhu.edu/software/stringtie/dl/gffread-0.12.7.Linux_x86_64.tar.gz
		#	http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz
	fi
	
	date
	echo "IN:${IN}"
	echo "OUT:${OUT}"

	echo "IN and OUT should NOT be the same"

	mkdir -p ${OUT}
	cd ${OUT}

	#if [ -n "${reference_merged_candidates_gtf}" ] ; then
	if ! ${using_reference} ; then
		echo "Not Reference Guided"

		reference_merged_candidates_gtf="${OUT}/reference_merged_candidates.gtf"

		f=${OUT}/filter_combined_candidates.tsv
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "(3/8) Aggregate Annotations"
	
			cd ${OUT}
			${TEPROF2}/aggregateProcessedAnnotation.R -a ${ARGUMENTS}
	
			chmod -w ${f} 
			chmod -w ${OUT}/initial_candidate_list.tsv
			chmod -w ${OUT}/Step4.RData
		fi
	
		date
	
		f=${OUT}/filterreadcommands.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			cd ${OUT}
			mkdir filterreadstats
			${TEPROF2}/commandsmax_speed.py filter_combined_candidates.tsv ${OUT}/
			chmod -w ${f}
		fi
	
		date
	
		#	Not real sure how to check this. There are about 88,000 commands in this
	
		f=${OUT}/filterreadcommands.complete
		echo "(4/8) Filter based on Reads"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			\rm -f ${f}
			echo "Running 'parallel' on MANY, MANY commands"
			parallel -j $threads < ${OUT}/filterreadcommands.txt
			touch ${f}
			chmod -w ${f}
		fi
	
		#	creates a whole bunch of files like ...
		#	out/filterreadstats/MIR3_127855022_None_None_None_ENG_exon_1_127815016--455v03.unique.stats
	
		#	All are 
		#	0	0	0	pe
		#	Guessing this is pretty useless.
	
		date
	
		f=${OUT}/filter_read_stats.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			find ${OUT}/filterreadstats -name "*.stats" -type f -maxdepth 1 -print0 | xargs -0 -n128 -P1 grep -H e > ${OUT}/resultgrep_filterreadstatsdone.txt
			cat ${OUT}/resultgrep_filterreadstatsdone.txt | sed 's/\:/\t/g' > ${f}
			chmod -w ${f}
		fi
	
		date

		echo "filterReadCandidates.R"
		#	Step6.RData candidate_transcripts.gff3 read_filtered_candidates.tsv
		f=${OUT}/candidate_transcripts.gff3
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			${TEPROF2}/filterReadCandidates.R -r 5
			chmod -w ${f}
		fi
	
		date
	
		echo "gffread 1"
		f=${OUT}/candidate_transcripts.gtf
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			~/.local/bin/gffread -E ${OUT}/candidate_transcripts.gff3 -T -o ${f}
			chmod -w ${f}
		fi
	
		date
	
		f=${OUT}/reference_merged_candidates.gtf
		echo "cuffmerge"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo ${OUT}/candidate_transcripts.gtf > ${OUT}/cuffmergegtf.list
			#	example wasn't gzipped. will gzipped work?
			cuffmerge -o ${OUT}/merged_asm_full \
				-g /francislab/data1/refs/sources/gencodegenes.org/gencode.v43.basic.annotation.gtf \
				${OUT}/cuffmergegtf.list
	
			mv ${OUT}/merged_asm_full/merged.gtf ${f}
			chmod -w ${f}
		fi
	
		date
	
		f=${OUT}/reference_merged_candidates.gff3
		echo "gffread 2"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			~/.local/bin/gffread -E ${OUT}/reference_merged_candidates.gtf -o- > ${f}
	
			#	MODIFY THIS TO EXPECT THREE HEADER LINES AROUND LINE 453 (OR TRIM LINE OFF TOP OF GFF?)
			# to avoid editing their code, should trim a header line off of reference_merged_candidates.gff3
			#	Perhaps, a newer version of gff-read is responsible for the additional line.
			##gff-version 3
			# gffread v0.12.7
			# /c4/home/gwendt/.local/bin/gffread \
			#		-E /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out/reference_merged_candidates.gtf -o-
	
			mv ${f} ${f}.original
			tail -n +2 ${f}.original > ${f}
			chmod -w ${f}
		fi
	
		date
	
		echo "(5/8) Annotate Merged Transcripts"
	
		f=${OUT}/reference_merged_candidates.gff3_annotated_filtered_test_all
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			${TEPROF2}/rmskhg38_annotate_gtf_update_test_tpm_cuff.py \
				${OUT}/reference_merged_candidates.gff3 \
				${ARGUMENTS}
			chmod -w ${f}
		fi

	else
		echo "Using Reference Guided"
		echo "Skipping to (6/8) Transcript Quantification"
	fi

	date

	f=${OUT}/quantificationCommands.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		\rm -f ${f}

		find ${IN} -name "*bam" | while read file ; do
			xbase=${file##*/}
			echo "samtools view -q 255 -h "$file" | stringtie - -o "${OUT}/${xbase%.*}".gtf -e -b "${OUT}/${xbase%.*}"_stats -p 2 ${strand} -m 100 -c 1 -G ${reference_merged_candidates_gtf}"
		done > ${f}

		chmod -w ${f}
	fi

	date

	echo "(6/8) Transcript Quantification"
	f=${OUT}/quantificationCommands.complete
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		\rm -f ${f}
		parallel -j ${threads} < ${OUT}/quantificationCommands.txt
		touch ${f}
		chmod -w ${f}
	fi

	date

	if ${using_reference} ; then

		echo "mergeAnnotationProcess_Ref.R"
		f=${OUT}/Step10.RData 
		#	candidate_introns.txt candidate_names.txt?
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			gff3_annotated_filtered_test_all=${reference_merged_candidates_gtf%.gtf}.gff3_annotated_filtered_test_all
			${TEPROF2}/mergeAnnotationProcess_Ref.R \
				-f ${gff3_annotated_filtered_test_all} \
				-a ${ARGUMENTS}

			# README says to use -g, but script actually uses -f
	
			chmod -w ${f}
		fi

	else

		echo "mergeAnnotationProcess.R"
		f=${OUT}/Step10.RData
		# candidate_introns.txt candidate_names.txt?
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			${TEPROF2}/mergeAnnotationProcess.R
			chmod -w ${f}
		fi

	fi

	date

	echo "ctab_i.txt 1"
	f=${OUT}/ctab_i.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		find ${OUT} -name "*i_data.ctab" > ${f}
		chmod -w ${f}
	fi

	date

	echo "Split candidate introns by chromosome for greping list"
	f=${OUT}/candidate_introns.chrs.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		\rm -f ${f}
		awk '{print $1}' ${OUT}/candidate_introns.txt | uniq > ${f}
		for chr in $( cat ${f} ) ; do
			awk -v chr=${chr} '($1==chr)' ${OUT}/candidate_introns.txt > ${OUT}/candidate_introns.${chr}.txt
		done
		chmod -w ${f}
	fi

	date

	echo "Create separate chromosome specific grep commands to minimize memory usage"
	f=${OUT}/candidateCommands.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		\rm -f ${f}
		cat ctab_i.txt | while read ID ; do
			fileid=$( basename $(dirname "$ID" ) .unique_stats )
			#echo "cat <(printf \"chr\tstrand\tstart\tend\t${fileid}\n\")
			#		<(grep -f candidate_introns.txt $ID | awk 'BEGIN{FS=OFS=\"\t\"}{ print \$2,\$3,\$4,\$5,\$6 }') > ${ID}_cand"
			# Trying to make this more efficient, use less files and less memory
			#echo "grep -f candidate_introns.txt $ID | 
			#		awk 'BEGIN{FS=OFS=\"\t\";print \"chr\tstrand\tstart\tend\t${fileid}\"}{ print \$2,\$3,\$4,\$5,\$6 }' > ${ID}_cand"
			#	grep for shorter list to minimize memory?
			echo -e "chr\tstrand\tstart\tend\t${fileid}" > ${ID}_cand.0
			for chr in $( cat ${OUT}/candidate_introns.chrs.txt ) ; do
				echo -e "grep -f candidate_introns.${chr}.txt $ID | awk 'BEGIN{FS=OFS=\"\t\"}{ print \$2,\$3,\$4,\$5,\$6 }' > ${ID}_cand.${chr}"
			done
		done > ${f}
		chmod -w ${f}
	fi


#	echo "ctab_i.txt 2"
#	f=${OUT}/candidateCommands.txt
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		\rm -f ${f}
#		cat ctab_i.txt | while read ID ; do
#			fileid=$( basename $(dirname "$ID" ) .unique_stats )
#			#echo "cat <(printf \"chr\tstrand\tstart\tend\t${fileid}\n\") <(grep -f candidate_introns.txt $ID | awk 'BEGIN{FS=OFS=\"\t\"}{ print \$2,\$3,\$4,\$5,\$6 }') > ${ID}_cand"
#			# Trying to make this more efficient, use less files and less memory
#			echo "grep -f candidate_introns.txt $ID | awk 'BEGIN{FS=OFS=\"\t\";print \"chr\tstrand\tstart\tend\t${fileid}\"}{ print \$2,\$3,\$4,\$5,\$6 }' > ${ID}_cand"
#		done > ${f}
#		chmod -w ${f}
#	fi

	date

	echo "Run the candidateCommands via parallel"
	f=${OUT}/candidateCommands.complete
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		\rm -f ${f}
		#	runs out of file handles and memory if run in full
		#parallel -j $[threads/2] < ${OUT}/candidateCommands.txt
		parallel -j ${threads} < ${OUT}/candidateCommands.txt
		touch ${f}
		chmod -w ${f}
	fi

	date

	echo "Merge each of the chromosome results"
	f=${OUT}/candidate_introns.merged
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		\rm -f ${f}
		cat ctab_i.txt | while read ID ; do
			cat ${ID}_cand.* > ${ID}_cand
		done
		touch ${f}
		chmod -w ${f}
	fi

	date

	#	single threaded merging table. cannot parallelize

	echo "ctab_i.txt 3"
	f=${OUT}/table_i_all
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat <(find ${OUT} -name "*i_data.ctab_cand" | head -1 | while read file ; do cat $file | awk '{print $1"\t"$2"\t"$3"\t"$4}' ; done;) > ${f}
		#	This merges each column into a table using paste. kinda nice.
		find ${OUT} -name "*i_data.ctab_cand" | while read file ; do
			paste -d'\t' <(cat table_i_all) <(cat $file | awk '{print $5}') > table_i_all_temp
			mv table_i_all_temp ${f}
		done
		touch ${f}
		chmod -w ${f}
	fi

	date

	echo "ctab_i.txt 5"
	f=${OUT}/ctablist.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		ls ${OUT}/*stats/t_data.ctab > ${f}
		chmod -w ${f}
	fi

	date

	echo "ctab_i.txt 6"
	f=${OUT}/stringtieExpressionFracCommands.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		\rm -f ${f}
		cat ctablist.txt | while read file ; do
			echo "${TEPROF2}/stringtieExpressionFrac.py $file" >> ${f}
		done
		chmod -w ${f}
	fi

	date	#	merge these 2 steps.

	echo "(7/8) Transcript Quantification"
	f=${OUT}/stringtieExpressionFracCommands.complete
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		# usually called with 64 which causes ...
		#	OpenBLAS blas_thread_init: pthread_create failed for thread 62 of 64: Resource temporarily unavailable
		#	OpenBLAS blas_thread_init: RLIMIT_NPROC 4096 current, 2061315 max
		#	OpenBLAS blas_thread_init: pthread_create failed for thread 63 of 64: Resource temporarily unavailable
		#	OpenBLAS blas_thread_init: RLIMIT_NPROC 4096 current, 2061315 max
		#	cutting threads in half. testing.
		#	32 seems to be working without failure.

		\rm -f ${f}
		parallel -j $[threads/2] < stringtieExpressionFracCommands.txt
		touch ${f}
		chmod -w ${f}
	fi


	#	Nothing below here really needs the 64/490GB resources.
	#	Try to create sub jobs

	date

	echo "(7/8) Transcript Quantification 1a"
	f=${OUT}/ctab_frac_tot_files.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		ls ${OUT}/*stats/t_data.ctab_frac_tot > ${f}
		chmod -w ${f}
	fi

	date

	echo "(7/8) Transcript Quantification 1b"
	f=${OUT}/ctab_tpm_files.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		ls ${OUT}/*stats/t_data.ctab_tpm > ${f}
		chmod -w ${f}
	fi

	date

	echo "(7/8) Transcript Quantification 2"
	f=${OUT}/table_frac_tot
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat <(echo "TranscriptID") <(find ${OUT} -name "*ctab_frac_tot" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > ${f}
		cat ctab_frac_tot_files.txt | while read file ; do
			fileid=$( basename $( dirname "$file" ) .unique_stats )
			paste -d'\t' <(cat table_frac_tot) <(cat <(echo ${fileid}) <(sort $file | awk '{print $2}')) > table_frac_tot_temp
			mv table_frac_tot_temp table_frac_tot
		done
		chmod -w ${f}
	fi

	date

	echo "(7/8) Transcript Quantification 4"
	f=${OUT}/table_tpm
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat <(echo "TranscriptID") <(find ${OUT} -name "*ctab_tpm" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_tpm
		cat ctab_tpm_files.txt | while read file ; do
			fileid=$( basename $( dirname "$file" ) .unique_stats )
			paste -d'\t' <(cat table_tpm) <(cat <(echo ${fileid}) <(sort $file | awk '{print $2}')) > table_tpm_temp
			mv table_tpm_temp table_tpm
		done
		chmod -w ${f}
	fi

	date

	echo "(7/8) Transcript Quantification 6"
	f=${OUT}/table_frac_tot_cand
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat <(head -1 table_frac_tot) <(grep -Ff candidate_names.txt table_frac_tot) > ${f}
		#( head -1 table_frac_tot && grep -Ff candidate_names.txt table_frac_tot ) > ${f}
		chmod -w ${f}
	fi

	#	I don't think that the -F option is needed in these grep calls

	date

	echo "(7/8) Transcript Quantification 7"
	f=${OUT}/table_tpm_cand
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat <(head -1 table_tpm) <(grep -Ff candidate_names.txt table_tpm) > ${f}
		#( head -1 table_tpm && grep -Ff candidate_names.txt table_tpm ) > ${f}
		chmod -w ${f}
	fi

	date

	#	None of these really need the full 64/490GB resources.

	dependency_id=${SLURM_JOB_ID}

	echo "(8/8) Final Stats Calculations"
	f=${OUT}/Step11_FINAL.RData
	# -rw-r----- 1 gwendt francislab   3652873 May 18 11:20 All TE-derived Alternative Isoforms Statistics.csv
	# -rw-r----- 1 gwendt francislab 209808460 May 18 11:20 allCandidateStatistics.tsv
	# -rw-r----- 1 gwendt francislab   8259950 May 18 11:21 merged_transcripts_all.refBed
	# -r--r----- 1 gwendt francislab 170485021 May 18 11:21 Step11_FINAL.RData
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		date=$( date "+%Y%m%d%H%M%S%N" )
		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
			--job-name="finalStatisticsOutput" \
			--time=14-0 --nodes=1 --ntasks=4 --mem=30G \
			--output=${OUT}/finalStatisticsOutput.${date}.out.log \
			--parsable --dependency=${dependency_id} \
			--export=None --chdir=${OUT} \
			--wrap="module load r;${TEPROF2}/finalStatisticsOutput.R -a ${ARGUMENTS};chmod -w ${f}" )
			#-e $TREATMENTLABEL
	fi

#	My primary used output is from allCandidateStatistics.tsv


#	Never really use the output of any of this.

#	echo ${TEPROF2}/translationPart1.R 
#	f=${OUT}/candidates.fa
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		date=$( date "+%Y%m%d%H%M%S%N" )
#		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#			--job-name="translationPart1" \
#			--time=${time} --nodes=1 --ntasks=4 --mem=30G \
#			--output=${OUT}/translationPart1.${date}.out.log \
#			--parsable --dependency=${dependency_id} \
#			--chdir=${OUT} \
#			--wrap="${TEPROF2}/translationPart1.R;chmod -w ${f}" )
#	fi
#
#
#	#	candidates_cpcout.fa is NOT a FASTA file. It is a tsv
#
#	echo ${CPC2} -i candidates.fa -o candidates_cpcout.fa
#	f=${OUT}/candidates_cpcout.fa
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		date=$( date "+%Y%m%d%H%M%S%N" )
#		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#			--job-name="CPC2" \
#			--time=${time} --nodes=1 --ntasks=4 --mem=30G \
#			--output=${OUT}/CPC2.${date}.out.log \
#			--parsable --dependency=${dependency_id} \
#			--chdir=${OUT} \
#			--wrap="${CPC2} -i candidates.fa -o ${f};chmod -w ${f}" )
#	fi
#
#
#	echo ${TEPROF2}/translationPart2.R
#	f=${OUT}/Step13.RData
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		date=$( date "+%Y%m%d%H%M%S%N" )
#		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#			--job-name="translationPart2" \
#			--time=${time} --nodes=1 --ntasks=4 --mem=30G \
#			--output=${OUT}/translationPart2.${date}.out.log \
#			--parsable --dependency=${dependency_id} \
#			--chdir=${OUT} \
#			--wrap="${TEPROF2}/translationPart2.R;chmod -w ${f}" )
#	fi



  
	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )

	mkdir -p ${PWD}/logs

	mem=$[threads*7500]M
	scratch_size=$[threads*28]G

	reference_merged_candidates_gtf_option=""
	[ -n "${reference_merged_candidates_gtf}" ] && \
		reference_merged_candidates_gtf_option="--reference_merged_candidates_gtf ${reference_merged_candidates_gtf}"

	strand_option=""
	[ -n "${strand}" ] && strand_option="--strand ${strand}"

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="$(basename $0)" \
		--time=${time} --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}.out.log \
			$( realpath ${0} ) --time ${time} --arguments ${ARGUMENTS} --in ${IN} --out ${OUT} ${strand_option} ${reference_merged_candidates_gtf_option}

fi

echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

