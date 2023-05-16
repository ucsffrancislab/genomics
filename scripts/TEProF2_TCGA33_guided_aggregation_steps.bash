#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails			#	can be problematic when piping through head.
set -u  #       Error on usage of unset variables
set -o pipefail
set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
#arguments_file=${PWD}/${script}.arguments

threads=${SLURM_NTASKS:-32}
#extension="_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"
strand=""

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
#		-e|--extension)
#			shift; extension=$1; shift;;
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
			echo "Good question"
			echo
			exit;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

mem=$[threads*7]
scratch_size=$[threads*28]

if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r/4.2.3 samtools cufflinks bedtools2
			# bwa bedtools2 star/2.7.7a

		#	http://ccb.jhu.edu/software/stringtie/dl/		gffread / stringtie / gffcompare 
		#	http://ccb.jhu.edu/software/stringtie/dl/gffread-0.12.7.Linux_x86_64.tar.gz
		#	http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz
	fi
	
	date
	

	mkdir -p ${OUT}
	cd ${OUT}


#	f=${OUT}/filter_combined_candidates.tsv
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "(3/8) Aggregate Annotations"
#
#		cd ${OUT}
#		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/aggregateProcessedAnnotation.R -a /francislab/data1/refs/TEProf2/TEProF2.arguments.txt
#
#		chmod -w ${f} 
#		chmod -w ${OUT}/initial_candidate_list.tsv
#		chmod -w ${OUT}/Step4.RData
#	fi
#
#
#	f=${OUT}/filterreadcommands.txt
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		cd ${OUT}
#		mkdir filterreadstats
#		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/commandsmax_speed.py filter_combined_candidates.tsv ${OUT}/
#		chmod -w ${f}
#	fi
#
#
#	#	Not real sure how to check this. There are about 88,000 commands in this
#
#	f=${OUT}/filterreadcommands.complete
#	echo "(4/8) Filter based on Reads"
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		\rm ${f}
#		echo "Running 'parallel' on MANY, MANY commands"
#		parallel -j $threads < ${OUT}/filterreadcommands.txt
#		touch ${f}
#		chmod -w ${f}
#	fi
#
#	#	creates a whole bunch of files like ...
#	#	out/filterreadstats/MIR3_127855022_None_None_None_ENG_exon_1_127815016--455v03.unique.stats
#
#	#	All are 
#	#	0	0	0	pe
#	#	Guessing this is pretty useless.
#
#
#	f=${OUT}/filter_read_stats.txt
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		find ${OUT}/filterreadstats -name "*.stats" -type f -maxdepth 1 -print0 | xargs -0 -n128 -P1 grep -H e > ${OUT}/resultgrep_filterreadstatsdone.txt
#		cat ${OUT}/resultgrep_filterreadstatsdone.txt | sed 's/\:/\t/g' > ${f}
#		chmod -w ${f}
#	fi
#
#	echo "filterReadCandidates.R"
#	#	Step6.RData candidate_transcripts.gff3 read_filtered_candidates.tsv
#	f=${OUT}/candidate_transcripts.gff3
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/filterReadCandidates.R -r 5
#		chmod -w ${f}
#	fi
#
#
#	echo "gffread 1"
#	f=${OUT}/candidate_transcripts.gtf
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/gffread -E ${OUT}/candidate_transcripts.gff3 \
#			-T -o ${f}
#		chmod -w ${f}
#	fi
#
#
#
#
#	f=${OUT}/reference_merged_candidates.gtf
#	echo "cuffmerge"
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo ${OUT}/candidate_transcripts.gtf > ${OUT}/cuffmergegtf.list
#		#	example wasn't gzipped. will gzipped work?
#		cuffmerge -o ${OUT}/merged_asm_full \
#			-g /francislab/data1/refs/sources/gencodegenes.org/gencode.v43.basic.annotation.gtf \
#			${OUT}/cuffmergegtf.list
#
#		mv ${OUT}/merged_asm_full/merged.gtf ${f}
#		chmod -w ${f}
#	fi
#
#
#
#	f=${OUT}/reference_merged_candidates.gff3
#	echo "gffread 2"
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		~/.local/bin/gffread -E ${OUT}/reference_merged_candidates.gtf -o- > ${f}
#
#		#	MODIFY THIS TO EXPECT THREE HEADER LINES AROUND LINE 453 (OR TRIM LINE OFF TOP OF GFF?)
#		# to avoid editing their code, should trim a header line off of reference_merged_candidates.gff3
#		#	Perhaps, a newer version of gff-read is responsible for the additional line.
#		##gff-version 3
#		# gffread v0.12.7
#		# /c4/home/gwendt/.local/bin/gffread \
#		#		-E /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out/reference_merged_candidates.gtf -o-
#
#		mv ${f} ${f}.original
#		tail -n +2 ${f}.original > ${f}
#		chmod -w ${f}
#	fi
#
#
#
#	echo "(5/8) Annotate Merged Transcripts"
#
#	f=${OUT}/reference_merged_candidates.gff3_annotated_filtered_test_all
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/rmskhg38_annotate_gtf_update_test_tpm_cuff.py \
#			${OUT}/reference_merged_candidates.gff3 \
#			/francislab/data1/refs/TEProf2/TEProF2.arguments.txt	
#		chmod -w ${f}
#	fi


	f=${OUT}/quantificationCommands.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		#	tries to create new gtf files of the same name that I started. Added "JAKE"
		#	I think that this assumes if "fr"
		#find ${OUT} -name "*bam" | while read file ; do xbase=${file##*/}; echo "samtools view -q 255 -h "$file" | stringtie - -o "${xbase%.*}".JAKE.gtf -e -b "${xbase%.*}"_stats -p 2 --fr -m 100 -c 1 -G reference_merged_candidates.gtf" >> ${OUT}/quantificationCommands.txt ; done ;

		\rm -f ${f}
		#find ${OUT} -name "*bam" | while read file ; do
		find ${IN} -name "*bam" | while read file ; do
			xbase=${file##*/}
			#echo "samtools view -q 255 -h "$file" | stringtie - -o "${xbase%.*}".JAKE.gtf -e -b "${xbase%.*}"_stats -p 2 ${strand} -m 100 -c 1 -G reference_merged_candidates.gtf" >> ${f}
			#	Don't need "JAKE" when IN and OUT are different
			echo "samtools view -q 255 -h "$file" | stringtie - -o "${OUT}/${xbase%.*}".gtf -e -b "${OUT}/${xbase%.*}"_stats -p 2 ${strand} -m 100 -c 1 -G /francislab/data1/refs/TEProf2/reference_merged_candidates.gtf" >> ${f}
		done

		#	they have a special script that passes rf
		#	find ../aligned -name "*bam" | while read file ; do xbase=${file##*/}; echo "samtools view -q 255 -h "$file" | stringtie - -o "${xbase%.*}".gtf -e -b "${xbase%.*}"_stats -p 2 --rf -m 100 -c 1 -G reference_merged_candidates.gtf" >> quantificationCommands.txt ; done ;

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

	echo "mergeAnnotationProcess_Ref.R"
	#f=${OUT}/reference_merged_candidates.gff3_annotated_filtered_test_all
	f=${OUT}/Step10.RData 
	#	candidate_introns.txt candidate_introns.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#/c4/home/gwendt/github/twlab/TEProf2Paper/bin/mergeAnnotationProcess.R
		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/mergeAnnotationProcess_Ref.R \
			-f /francislab/data1/refs/TEProf2/reference_merged_candidates.gff3_annotated_filtered_test_all \
			-a /francislab/data1/refs/TEProf2/TEProF2.arguments.txt

		# README says to use -g, but script actually uses -f
			
		chmod -w ${f}
	fi


	echo "ctab_i.txt 1"
	f=${OUT}/ctab_i.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		find ${OUT} -name "*i_data.ctab" > ${f}
		chmod -w ${f}
	fi


	echo "ctab_i.txt 2"
	f=${OUT}/ctab_i.2.complete
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat ctab_i.txt | while read ID ; do
			fileid=$(echo "$ID" | awk -F "/" '{print $2}')
			cat <(printf 'chr\tstrand\tstart\tend\t'${fileid/_stats/}'\n') <(grep -f candidate_introns.txt $ID | awk -F'\t' '{ print $2"\t"$3"\t"$4"\t"$5"\t"$6 }') > ${ID}_cand
		done
		touch ${f}
		chmod -w ${f}
	fi

	date

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
		ls ${OUT}/*stats/t_data.ctab > ctablist.txt
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
			echo "/c4/home/gwendt/github/twlab/TEProf2Paper/bin/stringtieExpressionFrac.py $file" >> ${f}
		done
		chmod -w ${f}
	fi

	date

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
		#cat <(echo "TranscriptID") <(find . -name "*ctab_frac_tot" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > ${f}
		cat <(echo "TranscriptID") <(find ${OUT} -name "*ctab_frac_tot" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > ${f}
		cat ctab_frac_tot_files.txt | while read file ; do
			fileid=$(echo "$file" | awk -F "/" '{print $2}')
			paste -d'\t' <(cat table_frac_tot) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_frac_tot_temp
			mv table_frac_tot_temp ${f}
		done
		chmod -w ${f}
	fi

	date

	echo "(7/8) Transcript Quantification 4"
	f=${OUT}/table_tpm
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#cat <(echo "TranscriptID") <(find . -name "*ctab_tpm" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_tpm
		cat <(echo "TranscriptID") <(find ${OUT} -name "*ctab_tpm" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_tpm
		cat ctab_tpm_files.txt | while read file ; do
			fileid=$(echo "$file" | awk -F "/" '{print $2}')
			paste -d'\t' <(cat table_tpm) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_tpm_temp
			mv table_tpm_temp ${f}
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
		chmod -w ${f}
	fi

	date

	echo "(7/8) Transcript Quantification 7"
	f=${OUT}/table_tpm_cand
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cat <(head -1 table_tpm) <(grep -Ff candidate_names.txt table_tpm) > ${f}
		chmod -w ${f}
	fi

	date

	echo "(8/8) Final Stats Calculations"
	f=${OUT}/Step11_FINAL.RData
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/finalStatisticsOutput.R #-e $TREATMENTLABEL
		chmod -w ${f}
	fi

	date


	dependency_id=${SLURM_JOB_ID}

	echo /c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart1.R 
	f=${OUT}/candidates.fa
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		date=$( date "+%Y%m%d%H%M%S%N" )
		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
			--job-name="translationPart1" \
			--time=20160 --nodes=1 --ntasks=4 --mem=30G \
			--output=${OUT}/translationPart1.${date}.out.log \
			--parsable --dependency=${dependency_id} \
			--chdir=${OUT} \
			--wrap="/c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart1.R;chmod -w ${f}" )

		##	takes a while and is single threaded
		#/c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart1.R 
		#chmod -w ${f}
	fi


	#	candidates_cpcout.fa is NOT a FASTA file. It is a tsv

	echo /c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py -i candidates.fa -o candidates_cpcout.fa
	f=${OUT}/candidates_cpcout.fa
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		date=$( date "+%Y%m%d%H%M%S%N" )
		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
			--job-name="CPC2" \
			--time=20160 --nodes=1 --ntasks=4 --mem=30G \
			--output=${OUT}/CPC2.${date}.out.log \
			--parsable --dependency=${dependency_id} \
			--chdir=${OUT} \
			--wrap="/c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py -i candidates.fa -o ${f};chmod -w ${f}" )

		#/c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py -i candidates.fa -o ${f}
		#chmod -w ${f}
	fi


	echo /c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart2.R
	f=${OUT}/Step13.RData
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		date=$( date "+%Y%m%d%H%M%S%N" )
		dependency_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
			--job-name="translationPart2" \
			--time=20160 --nodes=1 --ntasks=4 --mem=30G \
			--output=${OUT}/translationPart2.${date}.out.log \
			--parsable --dependency=${dependency_id} \
			--chdir=${OUT} \
			--wrap="/c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart2.R;chmod -w ${f}" )

		#	takes a while and is single threaded
		#/c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart2.R
		#chmod -w ${f}
	fi

	date


else

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	strand_option=""
	[ -n "${strand}" ] && strand_option="--strand ${strand}"
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="$(basename $0)" \
		--time=20160 --nodes=1 --ntasks=${threads} --mem=${mem}G --gres=scratch:${scratch_size}G \
		--output=${PWD}/logs/$(basename $0).${date}.out.log \
			$( realpath ${0} ) --in ${IN} --out ${OUT} ${strand_option}

fi





#	TEProF2_array_wrapper.bash
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
#	--extension .STAR.hg38.Aligned.out.bam
#	--threads 8

