#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

SELECT_ARGS=""
#while [ $# -gt 0 ] ; do
while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-o|--output)
			shift; f=$1; shift;;
		--fasta-ref)
			shift; fasta_ref=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${input} ${TMPDIR}/

	scratch_fasta_option=""
	if [ -n "${fasta_ref}" ] ; then
		#	in mpileup
		cp ${fasta_ref} ${TMPDIR}/
		scratch_fasta=${TMPDIR}/$( basename ${fasta_ref} )
		scratch_fasta_option="--fasta-ref ${scratch_fasta}"
	fi

	scratch_input=${TMPDIR}/$( basename ${input} )
	scratch_out=${TMPDIR}/$( basename ${f} )

#	diamond.bash $SELECT_ARGS --threads ${PBS_NUM_PPN:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	bcftools.bash ${SELECT_ARGS} ${scratch_fasta_option} -o ${scratch_out} ${scratch_input}

	mv --update ${scratch_out} $( dirname ${f} )
	chmod a-w ${f}
fi
