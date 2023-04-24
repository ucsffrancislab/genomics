#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
#if [ -n "${SLURM_JOB_NAME}" ] ; then
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

while [ $# -gt 0 ] ; do
	case $1 in
#		-i|--in)
#			shift; IN=$1; shift;;
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

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
#if [ $( basename ${0} ) == "slurm_script" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI r samtools 
			# bwa bedtools2 cufflinks star/2.7.7a
	fi
	
	date
	

#	outbase=${OUT}/${base}
	f=${OUT}/filter_combined_candidates.tsv
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "(3/8) Aggregate Annotations"

		cd ${OUT}
		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/aggregateProcessedAnnotation.R -a /francislab/data1/refs/TEProf2/TEProF2.arguments.txt

		chmod -w ${f} 
		chmod -w ${OUT}/initial_candidate_list.tsv
		chmod -w ${OUT}/Step4.RData
	fi




	f=${OUT}/filterreadcommands.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cd ${OUT}
		mkdir filterreadstats
		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/commandsmax_speed.py filter_combined_candidates.tsv ${OUT}
		chmod -w ${f}
	fi


	#	Not real sure how to check this. There are about 88,000 commands in this

	echo "(4/8) Filter based on Reads"
	parallel -j $threads < ${OUT}/filterreadcommands.txt



#	find ./filterreadstats -name "*.stats" -type f -maxdepth 1 -print0 | xargs -0 -n128 -P1 grep -H e > resultgrep_filterreadstatsdone.txt
#	cat resultgrep_filterreadstatsdone.txt | sed 's/\:/\t/g' > filter_read_stats.txt
#	
#	module load R/3.4.1
#	
#	filterReadCandidates.R -r 5
#	
#	gffread -E candidate_transcripts.gff3 -T -o candidate_transcripts.gtf
#	echo candidate_transcripts.gtf > cuffmergegtf.list
#	cuffmerge -o ./merged_asm_full -g ~/reference/Gencode/gencode.v25.basic.annotation.gtf cuffmergegtf.list
#	mv ./merged_asm_full/merged.gtf reference_merged_candidates.gtf
#	gffread -E reference_merged_candidates.gtf -o- > reference_merged_candidates.gff3
#	
#	echo "(5/8) Annotate Merged Transcripts"
#	rmskhg38_annotate_gtf_update_test_tpm_cuff.py reference_merged_candidates.gff3
#	
#	
#	find ../aligned -name "*bam" | while read file ; do xbase=${file##*/}; echo "samtools view -q 255 -h "$file" | stringtie - -o "${xbase%.*}".gtf -e -b "${xbase%.*}"_stats -p 2 --fr -m 100 -c 1 -G reference_merged_candidates.gtf" >> quantificationCommands.txt ; done ;
#	
#	
#	echo "(6/8) Transcript Quantification"
#	parallel_GNU -j $MAXJOBS < quantificationCommands.txt
#	
#	module load R/3.4.1
#	
#	mergeAnnotationProcess.R
#	
#	find . -name "*i_data.ctab" > ctab_i.txt
#	
#	cat ctab_i.txt | while read ID ; do fileid=$(echo "$ID" | awk -F "/" '{print $2}'); cat <(printf 'chr\tstrand\tstart\tend\t'${fileid/_stats/}'\n') <(grep -f candidate_introns.txt $ID | awk -F'\t' '{ print $2"\t"$3"\t"$4"\t"$5"\t"$6 }') > ${ID}_cand ; done ;
#	
#	cat <(find . -name "*i_data.ctab_cand" | head -1 | while read file ; do cat $file | awk '{print $1"\t"$2"\t"$3"\t"$4}' ; done;) > table_i_all
#	
#	find . -name "*i_data.ctab_cand" | while read file ; do paste -d'\t' <(cat table_i_all) <(cat $file | awk '{print $5}') > table_i_all_temp; mv table_i_all_temp table_i_all; done ;
#	
#	ls ./*stats/t_data.ctab > ctablist.txt
#	
#	cat ctablist.txt | while read file ; do echo "stringtieExpressionFrac.py $file" >> stringtieExpressionFracCommands.txt ; done;
#	
#	echo "(7/8) Transcript Quantification"
#	parallel_GNU -j $MAXJOBS < stringtieExpressionFracCommands.txt
#	
#	ls ./*stats/t_data.ctab_frac_tot > ctab_frac_tot_files.txt
#	ls ./*stats/t_data.ctab_tpm > ctab_tpm_files.txt
#	
#	cat <(echo "TranscriptID") <(find . -name "*ctab_frac_tot" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_frac_tot
#	cat ctab_frac_tot_files.txt | while read file ; do fileid=$(echo "$file" | awk -F "/" '{print $2}') ; paste -d'\t' <(cat table_frac_tot) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_frac_tot_temp; mv table_frac_tot_temp table_frac_tot; done ;
#	
#	cat <(echo "TranscriptID") <(find . -name "*ctab_tpm" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_tpm
#	cat ctab_tpm_files.txt | while read file ; do fileid=$(echo "$file" | awk -F "/" '{print $2}') ; paste -d'\t' <(cat table_tpm) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_tpm_temp; mv table_tpm_temp table_tpm; done ;
#	
#	cat <(head -1 table_frac_tot) <(grep -Ff candidate_names.txt table_frac_tot) > table_frac_tot_cand
#	cat <(head -1 table_tpm) <(grep -Ff candidate_names.txt table_tpm) > table_tpm_cand
#	
#	module load R/3.4.1
#	
#	echo "(8/8) Final Stats Calculations"
#	finalStatisticsOutput.R -e $TREATMENTLABEL


	date


else

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="$(basename $0)" \
		--time=20160 --nodes=1 --ntasks=${threads} --mem=${mem}G --gres=scratch:${scratch_size}G \
		--output=${PWD}/logs/$(basename $0).${date}.out.log \
			$( realpath ${0} ) --out ${OUT}

fi





#	TEProF2_array_wrapper.bash
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
#	--extension .STAR.hg38.Aligned.out.bam
#	--threads 8

