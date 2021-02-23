#!/usr/bin/env bash

#	Sometimes the files are huge and it just makes more sense to do both at the same time

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

threads=1

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
			shift; dir=$1; shift;;
		--memGb)
			shift; memGb=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

#if [ -f $f ] && [ ! -w $f ] ; then
if [ -d $dir ] && [ ! -w $dir ] ; then
	echo "Write-protected $dir exists. Skipping."
else
	echo "Creating $dir"

	cp ${normal} ${TMPDIR}/
	cp ${normal}.bai ${TMPDIR}/
	cp ${tumor} ${TMPDIR}/
	cp ${tumor}.bai ${TMPDIR}/

	cp ${reference} ${TMPDIR}/
	cp ${reference}.fai ${TMPDIR}/
	scratch_reference=${TMPDIR}/$( basename ${reference} )

	scratch_normal=${TMPDIR}/$( basename ${normal} )
	scratch_tumor=${TMPDIR}/$( basename ${tumor} )

	mkdir -p ${TMPDIR}/runDir	#	just in case

	~/.local/manta/bin/configManta.py \
		--referenceFasta ${scratch_reference} \
		--normalBam ${scratch_normal} \
		--tumorBam ${scratch_tumor} \
		--runDir ${TMPDIR}/runDir/manta \
		${SELECT_ARGS}

	#${TMPDIR}/runDir/manta/runWorkflow.py --jobs=${PBS_NUM_PPN} --memGb=${memGb} --mode=local
	${TMPDIR}/runDir/manta/runWorkflow.py --jobs=${threads} --memGb=${memGb} --mode=local

	scratch_indels=${TMPDIR}/runDir/manta/results/variants/candidateSmallIndels.vcf.gz

	~/.local/strelka/bin/configureStrelkaSomaticWorkflow.py \
		--referenceFasta ${scratch_reference} \
		--normalBam ${scratch_normal} \
		--tumorBam ${scratch_tumor} \
		--indelCandidates ${scratch_indels} \
		--runDir ${TMPDIR}/runDir/strelka \
		${SELECT_ARGS}

	#${TMPDIR}/runDir/strelka/runWorkflow.py --jobs=${PBS_NUM_PPN} --memGb=${memGb} --mode=local
	${TMPDIR}/runDir/strelka/runWorkflow.py --jobs=${threads} --memGb=${memGb} --mode=local

	mkdir -p ${dir}
	mv --update ${TMPDIR}/runDir/* ${dir}/
	chmod -R a-w ${dir}
fi
