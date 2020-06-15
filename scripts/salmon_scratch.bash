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
		-1|--mates1)
			shift; r1=$1; shift;;
		-2|--mates2)
			shift; r2=$1; shift;;
		-i|--index)
			shift; index=$1; shift;;
		-o)
			shift; f=$1; shift;;
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
	cp -r ${index} ${SCRATCH_JOB}/

	scratch_r1=${SCRATCH_JOB}/$( basename ${r1} )
	scratch_r2=${SCRATCH_JOB}/$( basename ${r2} )
	scratch_index=${SCRATCH_JOB}/$( basename ${index} )
	scratch_out=${SCRATCH_JOB}/outdir

	mkdir -p ${scratch_out}/
	cd ${scratch_out}/

	salmon.bash ${SELECT_ARGS} --index ${scratch_index} -1 ${scratch_r1} -2 ${scratch_r2} -o ${scratch_out}

	#	GOTTA move an existing dir or we'll move this INTO it.
	if [ -d ${f} ] ; then
		date=$( date "+%Y%m%d%H%M%S" --date="$( stat --printf '%z' ${f} )" )
		mv ${f} ${f}.${date}
	fi
	mv --update ${scratch_out} ${f}
	# unnecessary as salmon.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
