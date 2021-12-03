#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI htslib samtools bowtie2
fi
set -x	#	print expanded command before executing it

#threads=""
SELECT_ARGS=""
r1=""
r2=""
u=""
while [ $# -gt 0 ] ; do
	case $1 in
		-1)
			shift; r1=$1; shift;;
		-2)
			shift; r2=$1; shift;;
		-U)
			shift; u=$1; shift;;
		-o)
			shift; f=$1; shift;;
		-x)
			shift; x=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#trap "{ chmod -R a+w $TMPDIR ; }" EXIT
trap "{ chmod -R +w $TMPDIR ; }" EXIT

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	scratch_inputs=""
	if [ -n "${r1}" ] ; then
		cp ${r1} ${TMPDIR}/
		scratch_inputs="${scratch_inputs} -1 ${TMPDIR}/$( basename ${r1} )"
	fi
	if [ -n "${r2}" ] ; then
		cp ${r2} ${TMPDIR}/
		scratch_inputs="${scratch_inputs} -2 ${TMPDIR}/$( basename ${r2} )"
	fi
	if [ -n "${u}" ] ; then
		cp ${u} ${TMPDIR}/
		scratch_inputs="${scratch_inputs} -U ${TMPDIR}/$( basename ${u} )"
	fi

	#	Quick test script so assuming that ${x} includes FULL PATH
	cp ${x}.?.bt2 ${x}.rev.?.bt2 ${TMPDIR}/

	scratch_out=${TMPDIR}/$( basename ${f} )
	scratch_x=${TMPDIR}/$( basename ${x} )

#	diamond.bash $SELECT_ARGS --threads ${SLURM_NTASKS:-1} \
#		--db ${scratch_db} --query ${scratch_query} --out ${scratch_out}

	bowtie2.bash ${SELECT_ARGS} -x ${scratch_x} -o ${scratch_out} ${scratch_inputs}

	#	won't mv fail if files are write protected?
	#mv --update ${scratch_out}* $( dirname ${f} )
	cp --archive ${scratch_out}* $( dirname ${f} )

#	mv --update ${scratch_out} $( dirname ${f} )
#	mv --update ${TMPDIR}/*.err.txt $( dirname ${f} )

	#	unnecessary as bowtie2.bash will chmod files if successfull?
	#chmod a-w ${f}
fi
