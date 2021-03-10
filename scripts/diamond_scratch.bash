#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#threads=""
SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--db)
			shift; db=$1; shift;;
		--query)
			shift; query=$1; shift;;
		--out)
			shift; out=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

f="${out}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${query} ${TMPDIR}/
	cp ${db}.dmnd ${TMPDIR}/

	scratch_db=${TMPDIR}/$( basename ${db} )
	scratch_query=${TMPDIR}/$( basename ${query} )
	scratch_out=${TMPDIR}/$( basename ${out} )

	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	mv --update ${scratch_out} $( dirname ${out} )
	chmod a-w ${out}
fi
