#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

f=${input}.length_hist.csv.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${input} ${TMPDIR}/

	scratch_input=${TMPDIR}/$( basename ${input} )
	scratch_out=${TMPDIR}/$( basename ${f} )

	read_length_hist.bash ${scratch_input}

	mv --update ${scratch_out} $( dirname ${f} )
	chmod a-w ${out}
fi
