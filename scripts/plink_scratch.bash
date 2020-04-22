#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#	No easily computable output file so pick custom argument, pass on the rest

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--check)
			shift; check=$1; SELECT_ARGS="${SELECT_ARGS} --check $1"; shift;;
		--out)
			shift; out=$1; shift;;
		--bfile)
			shift; bfile=$1; shift;;
		--pheno)
			shift; pheno=$1; shift;;
		--covar)
			shift; covar=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
trap "{ cd /scratch/; chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT


f="${check}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	#mkdir ${SCRATCH_JOB}/

	cp --archive ${bfile}.{bed,bim,fam} ${SCRATCH_JOB}/
	cp --archive ${pheno} ${SCRATCH_JOB}/
	cp --archive ${covar} ${SCRATCH_JOB}/

	scratch_bfile=${SCRATCH_JOB}/$( basename ${bfile} )
	scratch_pheno=${SCRATCH_JOB}/$( basename ${pheno} )
	scratch_covar=${SCRATCH_JOB}/$( basename ${covar} )
	scratch_out=${SCRATCH_JOB}/$( basename ${out} )

	plink --out ${scratch_out} \
		--bfile ${scratch_bfile} \
		--pheno ${scratch_pheno} \
		--covar ${scratch_covar} \
		$SELECT_ARGS

	mv --update ${scratch_out}* $( dirname ${out} )
	chmod a-w ${out}*	#	probably unnecessary
fi

