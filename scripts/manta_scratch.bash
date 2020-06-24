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
		--normalBam)
			shift; normal=$1; shift;;
		--tumorBam)
			shift; tumor=$1; shift;;
		--referenceFasta)
			shift; reference=$1; shift;;
		--dir)
			shift; f=$1; shift;;
		--memGb)
			shift; memGb=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1


## 0. Create job-specific scratch folder that ...
#SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
#mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
#trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT

SCRATCH_JOB=$TMPDIR

#if [ -f $f ] && [ ! -w $f ] ; then
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${normal} ${SCRATCH_JOB}/
	cp ${normal}.bai ${SCRATCH_JOB}/
	cp ${tumor} ${SCRATCH_JOB}/
	cp ${tumor}.bai ${SCRATCH_JOB}/
	cp ${reference} ${SCRATCH_JOB}/
	cp ${reference}.fai ${SCRATCH_JOB}/

	scratch_normal=${SCRATCH_JOB}/$( basename ${normal} )
	scratch_tumor=${SCRATCH_JOB}/$( basename ${tumor} )
	scratch_reference=${SCRATCH_JOB}/$( basename ${reference} )

#	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}
#	samtools_view.bash ${SELECT_ARGS} -o ${scratch_out} ${scratch_input}

	~/.local/manta/bin/configManta.py \
		--normalBam ${scratch_normal} \
		--tumorBam ${scratch_tumor} \
		--referenceFasta ${scratch_reference} \
		--runDir ${SCRATCH_JOB}/runDir \
		${SELECT_ARGS}

	${SCRATCH_JOB}/runDir/runWorkflow.py --jobs=${PBS_NUM_PPN} --memGb=${memGb} --mode=local

	mkdir -p $( dirname ${dir} )	#	just in case
	mv --update ${SCRATCH_JOB}/runDir/* $( dirname ${dir} )
	chmod -R a-w ${dir}
fi
