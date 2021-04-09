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
		-base|--base)
			shift; base=$1; shift;;
		-1)
			shift; r1=$1; shift;;
		-2)
			shift; r2=$1; shift;;
		--dir)
			shift; f=$1; shift;;
		--index_dir)
			shift; index_dir=$1; shift;;
		--human)
			shift; human=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

#if [ -f $f ] && [ ! -w $f ] ; then
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${r1} ${TMPDIR}/
	cp ${r2} ${TMPDIR}/
	cp -r ${index_dir} ${TMPDIR}/
	cp ${human}.?.bt2 ${TMPDIR}/
	cp ${human}.rev.?.bt2 ${TMPDIR}/

	scratch_r1=${TMPDIR}/$( basename ${r1} )
	scratch_r2=${TMPDIR}/$( basename ${r2} )
	scratch_index_dir=${TMPDIR}/$( basename ${index_dir} )
	scratch_out=${TMPDIR}/outdir
	scratch_human=${TMPDIR}/$( basename ${human} )

	mkdir -p ${scratch_out}/${base}
	cd ${scratch_out}/${base}

	for hkle in ${scratch_index_dir}/*.rev.1.bt2 ; do
		hkle=${hkle%.rev.1.bt2}
		echo $hkle

		chimera_paired_local.bash --human ${scratch_human} --threads ${SLURM_NTASKS} \
			--viral ${hkle} -1 ${r1} -2 ${r2}

		chimera_unpaired_local.bash --human ${scratch_human} --threads ${SLURM_NTASKS} \
			--viral ${hkle} ${r1},${r2}

	done

	#	GOTTA move an existing dir or we'll move this INTO it.
	if [ -d ${f} ] ; then
		date=$( date "+%Y%m%d%H%M%S" --date="$( stat --printf '%z' ${f} )" )
		mv ${f} ${f}.${date}
	fi
	mv --update ${scratch_out}/${base} ${f}
#	mkdir -p $( dirname ${f} )	#	just in case
#	mv --update ${TMPDIR}/outdir/* $( dirname ${f} )
	chmod -R a-w ${f}
fi
