#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-base|--base)
			shift; base=$1; shift;;
		-1)
			shift; r1=$1; shift;;
		-2)
			shift; r2=$1; shift;;
		--dir)
			shift; f=$1; shift;;
		--index_dir)
			shift; index_dir=$1; shift;;
		--human)
			shift; human=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1


## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT



#if [ -f $f ] && [ ! -w $f ] ; then
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${r1} ${SCRATCH_JOB}/
	cp ${r2} ${SCRATCH_JOB}/
	cp -r ${index_dir} ${SCRATCH_JOB}/
	cp ${human}.?.bt2 ${SCRATCH_JOB}/
	cp ${human}.rev.?.bt2 ${SCRATCH_JOB}/

	scratch_r1=${SCRATCH_JOB}/$( basename ${r1} )
	scratch_r2=${SCRATCH_JOB}/$( basename ${r2} )
	scratch_index_dir=${SCRATCH_JOB}/$( basename ${index_dir} )
	scratch_out=${SCRATCH_JOB}/outdir
	scratch_human=${SCRATCH_JOB}/$( basename ${human} )

	mkdir -p ${scratch_out}/${base}
	cd ${scratch_out}/${base}

	for hkle in ${scratch_index_dir}/*.rev.1.bt2 ; do
		hkle=${hkle%.rev.1.bt2}
		echo $hkle

		chimera_paired_local.bash --human ${scratch_human} --threads ${PBS_NUM_PPN} \
			--viral ${hkle} -1 ${r1} -2 ${r2}

		chimera_unpaired_local.bash --human ${scratch_human} --threads ${PBS_NUM_PPN} \
			--viral ${hkle} ${r1},${r2}


#		bowtie2 --very-sensitive-local --threads ${PBS_NUM_PPN} \
#			-x ${hkle} \
#			-1 ${r1} -2 ${r2} | samtools view -G 12 - 
# 
# #   Select end aligned reads that are soft clipped
# 
# #   Trim off the aligned region
# 
# #   Align the soft clipped sequences to hg38
# 
# #   Extract positions of alignments


#	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
#		--normalBam ${scratch_normal} \
#		--tumorBam ${scratch_tumor} \
#		--referenceFasta ${scratch_reference} \
#		--indelCandidates ${scratch_indels} \
#		--runDir ${SCRATCH_JOB}/runDir \
#		${SELECT_ARGS}
#
#	${SCRATCH_JOB}/runDir/runWorkflow.py --jobs=${PBS_NUM_PPN} --memGb=${memGb} --mode=local


	done

	#	GOTTA move an existing dir or we'll move this INTO it.
	if [ -d ${f} ] ; then
		date=$( date "+%Y%m%d%H%M%S" --date="$( stat --printf '%z' ${f} )" )
		mv ${f} ${f}.${date}
	fi
	mv --update ${scratch_out} ${f}
#	mkdir -p $( dirname ${f} )	#	just in case
#	mv --update ${SCRATCH_JOB}/outdir/* $( dirname ${f} )
	chmod -R a-w ${f}
fi
