#!/usr/bin/env bash

hostname

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

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

f="${check}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	#mkdir ${TMPDIR}/

	cp --archive ${bfile}.{bed,bim,fam} ${TMPDIR}/
	cp --archive ${pheno} ${TMPDIR}/
	cp --archive ${covar} ${TMPDIR}/

	scratch_bfile=${TMPDIR}/$( basename ${bfile} )
	scratch_pheno=${TMPDIR}/$( basename ${pheno} )
	scratch_covar=${TMPDIR}/$( basename ${covar} )
	scratch_out=${TMPDIR}/$( basename ${out} )

	plink --out ${scratch_out} \
		--bfile ${scratch_bfile} \
		--pheno ${scratch_pheno} \
		--covar ${scratch_covar} \
		$SELECT_ARGS

	mv --update ${scratch_out}* $( dirname ${out} )
	chmod a-w ${out}*	#	probably unnecessary
fi

