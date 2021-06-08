#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-1)
			shift; r1=$1; shift;;
		-2)
			shift; r2=$1; shift;;
		-i|--index)
			shift; index=$1; shift;;
		-o)
			shift; f=$1; shift;;
		-m|--mem)
			shift; mem=${1^^}; shift;;
		--sort)
			shift; sortbam=true;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1
echo "r1:$r1"
echo "r2:$r2"
echo "index:$index"
echo "mem:$mem"
echo "output:$f"

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${r1} ${TMPDIR}/
	scratch_r1=${TMPDIR}/$( basename ${r1} )

	cp ${r2} ${TMPDIR}/
	scratch_r2=${TMPDIR}/$( basename ${r2} )

	cp -r ${index}.* ${TMPDIR}/
	scratch_index=${TMPDIR}/$( basename ${index} )

	scratch_out=${TMPDIR}/$( basename ${f} )

	bwa mem -t ${SLURM_NTASKS:-1} ${SELECT_ARGS} ${scratch_index} ${scratch_r1} ${scratch_r2} \
		| samtools view -o ${scratch_out} -

	if $sortbam; then
		mv ${scratch_out} ${scratch_out/%.bam/.unsorted.bam}
		sambamba sort -m $mem -t ${SLURM_NTASKS:-1} -o ${scratch_out} ${scratch_out/%.bam/.unsorted.bam}
		\rm ${scratch_out/%.bam/.unsorted.bam}
	fi

	sambamba index ${scratch_out}

	mv --update ${scratch_out}* $( dirname ${f} )
	chmod -R a-w ${f}*
fi
