#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
sorted=false
r2=""
scratch_r2=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		--readFilesIn)
			shift; r1=$1; shift;
			if [[ ! $1 =~ ^-- ]]; then
				r2=$1; shift;
			fi;;
		--outFileNamePrefix)
			shift; outFileNamePrefix=$1; shift;;
		--genomeDir)
			shift; genomeDir=$1; shift;;
		--outSAMtype)
			shift; outSAMtype=$1;
			if [ $2 == "SortedByCoordinate" ] ; then
				sorted=true
			fi
			SELECT_ARGS="${SELECT_ARGS} --outSAMtype $1";
			shift;;
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


if $sorted; then
	f="${outFileNamePrefix}Aligned.sortedByCoord.out.${outSAMtype,,}"
else
	f="${outFileNamePrefix}Aligned.out.${outSAMtype,,}"
fi

if [ -f $f ] && [ ! -w $f ] ; then
#if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${r1} ${SCRATCH_JOB}/
	scratch_r1=${SCRATCH_JOB}/$( basename ${r1} )

	if [ -n "${r2}" ] ; then
		cp ${r2} ${SCRATCH_JOB}/
		scratch_r2=${SCRATCH_JOB}/$( basename ${r2} )
	fi

	cp -r ${genomeDir} ${SCRATCH_JOB}/
	scratch_genomeDir=${SCRATCH_JOB}/$( basename ${genomeDir} )

	scratch_out=${SCRATCH_JOB}/outdir

	mkdir -p ${scratch_out}/
	cd ${scratch_out}/

	STAR.bash ${SELECT_ARGS} --genomeDir ${scratch_genomeDir} \
		--readFilesIn ${scratch_r1} ${scratch_r2} \
		--outFileNamePrefix ${scratch_out}/$( basename ${outFileNamePrefix} )

	mv --update ${scratch_out}/* $( dirname ${f} )
	#	unnecessary as STAR.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
