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
			shift; dir=$1; shift;;
		--memGb)
			shift; memGb=$1; shift;;
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

	scratch_normal=${TMPDIR}/$( basename ${normal} )
	scratch_tumor=${TMPDIR}/$( basename ${tumor} )
	scratch_reference=${TMPDIR}/$( basename ${reference} )

#	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}
#	samtools_view.bash ${SELECT_ARGS} -o ${scratch_out} ${scratch_input}

	~/.local/manta/bin/configManta.py \
		--normalBam ${scratch_normal} \
		--tumorBam ${scratch_tumor} \
		--referenceFasta ${scratch_reference} \
		--runDir ${TMPDIR}/runDir \
		${SELECT_ARGS}

	${TMPDIR}/runDir/runWorkflow.py --jobs=${PBS_NUM_PPN} --memGb=${memGb} --mode=local

	#mkdir -p $( dirname ${dir} )	#	just in case
	#mv --update ${TMPDIR}/runDir/* $( dirname ${dir} )
	mkdir -p ${dir}
	mv --update ${TMPDIR}/runDir/* ${dir}/
	chmod -R a-w ${dir}
fi
