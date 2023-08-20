#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	#module load CBI star/2.7.7a samtools/1.10
	module load CBI star samtools
fi
set -x	#	print expanded command before executing it

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

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

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

	cp ${r1} ${TMPDIR}/
	scratch_r1=${TMPDIR}/$( basename ${r1} )

	if [ -n "${r2}" ] ; then
		cp ${r2} ${TMPDIR}/
		scratch_r2=${TMPDIR}/$( basename ${r2} )
	fi

	cp -r ${genomeDir} ${TMPDIR}/
	scratch_genomeDir=${TMPDIR}/$( basename ${genomeDir} )

	scratch_out=${TMPDIR}/outdir

	mkdir -p ${scratch_out}/
	cd ${scratch_out}/

	STAR.bash ${SELECT_ARGS} --genomeDir ${scratch_genomeDir} \
		--readFilesIn ${scratch_r1} ${scratch_r2} \
		--outFileNamePrefix ${scratch_out}/$( basename ${outFileNamePrefix} )

	#	won't mv fail if files are write protected?
	#mv --update ${scratch_out}/* $( dirname ${f} )
	cp --archive ${scratch_out}/* $( dirname ${f} )

	#	unnecessary as STAR.bash will chmod files if successfull?
	#chmod -R a-w ${f}
fi
