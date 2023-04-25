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
		module load CBI r/4.0.0 samtools cufflinks bedtools2
			# bwa bedtools2 star/2.7.7a

		#	http://ccb.jhu.edu/software/stringtie/dl/		gffread / stringtie / gffcompare 
		#	http://ccb.jhu.edu/software/stringtie/dl/gffread-0.12.7.Linux_x86_64.tar.gz
		#	http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.2.1.Linux_x86_64.tar.gz
	fi
	
	date
	

	cd ${OUT}



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
		/c4/home/gwendt/github/twlab/TEProf2Paper/bin/commandsmax_speed.py filter_combined_candidates.tsv ${OUT}/
		chmod -w ${f}
	fi


	#	Not real sure how to check this. There are about 88,000 commands in this

	echo "(4/8) Filter based on Reads"
	echo "Running 'parallel' on MANY, MANY commands"
	parallel -j $threads < ${OUT}/filterreadcommands.txt


	#	creates a whole bunch of files like ...
	#	out/filterreadstats/MIR3_127855022_None_None_None_ENG_exon_1_127815016--455v03.unique.stats

	#	All are 
	#	0	0	0	pe
	#	Guessing this is pretty useless.


	find ${OUT}/filterreadstats -name "*.stats" -type f -maxdepth 1 -print0 | xargs -0 -n128 -P1 grep -H e > ${OUT}/resultgrep_filterreadstatsdone.txt
	cat ${OUT}/resultgrep_filterreadstatsdone.txt | sed 's/\:/\t/g' > ${OUT}/filter_read_stats.txt

	echo "filterReadCandidates.R"
	/c4/home/gwendt/github/twlab/TEProf2Paper/bin/filterReadCandidates.R -r 5


	echo "gffread 1"
	~/.local/bin/gffread -E ${OUT}/candidate_transcripts.gff3 \
		-T -o ${OUT}/candidate_transcripts.gtf

	echo ${OUT}/candidate_transcripts.gtf > ${OUT}/cuffmergegtf.list

	echo "cuffmerge"
	#	example wasn't gzipped. will gzipped work?
	cuffmerge -o ${OUT}/merged_asm_full \
		-g /francislab/data1/refs/sources/gencodegenes.org/gencode.v43.basic.annotation.gtf \
		${OUT}/cuffmergegtf.list

	mv ${OUT}/merged_asm_full/merged.gtf ${OUT}/reference_merged_candidates.gtf

	echo "gffread 2"
	~/.local/bin/gffread -E ${OUT}/reference_merged_candidates.gtf -o- > ${OUT}/reference_merged_candidates.gff3

	echo "(5/8) Annotate Merged Transcripts"

	#	MODIFY THIS TO EXPECT THREE HEADER LINES AROUND LINE 453 (OR TRIM LINE OFF TOP OF GFF?)
	# to avoid editing their code, should trim a header line off of reference_merged_candidates.gff3
	#	Perhaps, a newer version of gff-read is responsible for the additional line.
	##gff-version 3
	# gffread v0.12.7
	# /c4/home/gwendt/.local/bin/gffread -E /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-TEProF2/out/reference_merged_candidates.gtf -o-

	mv ${OUT}/reference_merged_candidates.gff3 ${OUT}/reference_merged_candidates.gff3.original
	tail -n +2 ${OUT}/reference_merged_candidates.gff3.original > ${OUT}/reference_merged_candidates.gff3

	/c4/home/gwendt/github/twlab/TEProf2Paper/bin/rmskhg38_annotate_gtf_update_test_tpm_cuff.py \
		${OUT}/reference_merged_candidates.gff3 \
		/francislab/data1/refs/TEProf2/TEProF2.arguments.txt	


	#	tries to create new gtf files of the same name that I started. Added "JAKE"
	find ${OUT} -name "*bam" | while read file ; do xbase=${file##*/}; echo "samtools view -q 255 -h "$file" | stringtie - -o "${xbase%.*}".JAKE.gtf -e -b "${xbase%.*}"_stats -p 2 --fr -m 100 -c 1 -G reference_merged_candidates.gtf" >> ${OUT}/quantificationCommands.txt ; done ;


	echo "(6/8) Transcript Quantification"
	parallel -j ${threads} < ${OUT}/quantificationCommands.txt

	echo "mergeAnnotationProcess.R"
	/c4/home/gwendt/github/twlab/TEProf2Paper/bin/mergeAnnotationProcess.R

	echo "ctab_i.txt 1"
	find . -name "*i_data.ctab" > ctab_i.txt

	echo "ctab_i.txt 2"
	cat ctab_i.txt | while read ID ; do fileid=$(echo "$ID" | awk -F "/" '{print $2}'); cat <(printf 'chr\tstrand\tstart\tend\t'${fileid/_stats/}'\n') <(grep -f candidate_introns.txt $ID | awk -F'\t' '{ print $2"\t"$3"\t"$4"\t"$5"\t"$6 }') > ${ID}_cand ; done ;

	echo "ctab_i.txt 3"
	cat <(find . -name "*i_data.ctab_cand" | head -1 | while read file ; do cat $file | awk '{print $1"\t"$2"\t"$3"\t"$4}' ; done;) > table_i_all
	
	echo "ctab_i.txt 4"
	find . -name "*i_data.ctab_cand" | while read file ; do paste -d'\t' <(cat table_i_all) <(cat $file | awk '{print $5}') > table_i_all_temp; mv table_i_all_temp table_i_all; done ;

	echo "ctab_i.txt 5"
	ls ./*stats/t_data.ctab > ctablist.txt

	echo "ctab_i.txt 6"
	cat ctablist.txt | while read file ; do echo "/c4/home/gwendt/github/twlab/TEProf2Paper/bin/stringtieExpressionFrac.py $file" >> stringtieExpressionFracCommands.txt ; done;

	echo "(7/8) Transcript Quantification"
	parallel -j ${threads} < stringtieExpressionFracCommands.txt

	echo "(7/8) Transcript Quantification 1"
	ls ./*stats/t_data.ctab_frac_tot > ctab_frac_tot_files.txt
	ls ./*stats/t_data.ctab_tpm > ctab_tpm_files.txt

	echo "(7/8) Transcript Quantification 2"
	cat <(echo "TranscriptID") <(find . -name "*ctab_frac_tot" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_frac_tot

	echo "(7/8) Transcript Quantification 3"
	cat ctab_frac_tot_files.txt | while read file ; do fileid=$(echo "$file" | awk -F "/" '{print $2}') ; paste -d'\t' <(cat table_frac_tot) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_frac_tot_temp; mv table_frac_tot_temp table_frac_tot; done ;

	echo "(7/8) Transcript Quantification 4"
	cat <(echo "TranscriptID") <(find . -name "*ctab_tpm" | head -1 | while read file ; do sort $file | awk '{print $1}' ; done;) > table_tpm

	echo "(7/8) Transcript Quantification 5"
	cat ctab_tpm_files.txt | while read file ; do fileid=$(echo "$file" | awk -F "/" '{print $2}') ; paste -d'\t' <(cat table_tpm) <(cat <(echo ${fileid/_stats/}) <(sort $file | awk '{print $2}')) > table_tpm_temp; mv table_tpm_temp table_tpm; done ;

	echo "(7/8) Transcript Quantification 6"
	cat <(head -1 table_frac_tot) <(grep -Ff candidate_names.txt table_frac_tot) > table_frac_tot_cand

	echo "(7/8) Transcript Quantification 7"
	cat <(head -1 table_tpm) <(grep -Ff candidate_names.txt table_tpm) > table_tpm_cand

	echo "(8/8) Final Stats Calculations"
	/c4/home/gwendt/github/twlab/TEProf2Paper/bin/finalStatisticsOutput.R #-e $TREATMENTLABEL



	echo /c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart1.R 
	/c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart1.R 



	echo /c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py -i candidates.fa -o candidates_cpcout.fa
	/c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py -i candidates.fa -o candidates_cpcout.fa



	echo /c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart2.R
	/c4/home/gwendt/github/twlab/TEProf2Paper/bin/translationPart2.R


	echo "ballgown prep?"
	mkdir ballgown
	cd ballgown
	ls -d ../*_stats | while read file ; do mkdir $(basename $file) ; cd $(basename $file) ; (ls ../${file}/*ctab | while read file2 ; do ln -s $file2 ; done ;) ; cd .. ; done ;


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

