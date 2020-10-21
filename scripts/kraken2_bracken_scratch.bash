#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
r2=""
scratch_r2=""
#report=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-1|--r1)
			shift; r1=$1; shift;;
		-2|--r2)
			shift; r2=$1; shift;;
		-d|--db)
			shift; db=$1; shift;;
		-o|--output)
			shift; f=$1; shift;;
		-r|--read_len)
			shift; r=$1; shift;;
#		--report)
#			shift; report=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

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
	cp --recursive --dereference ${db} ${TMPDIR}/
	scratch_db=${TMPDIR}/$( basename ${db} )

#	if [ -z "${report}" ] ; then
		#fbase=${f%.gz}
		#fbase=${fbase%.txt}
		fbase=$( basename $f .txt.gz )
		#kreport=${fbase}.kreport.txt.gz
		kreport=${fbase}.kreport.txt
		#	Don't gzip kraken report. Bracken doesn't know how to deal with it.
#	fi
	scratch_kreport=${TMPDIR}/$( basename ${kreport} )

	scratch_out=${TMPDIR}/$( basename ${f} )

	kraken2.bash ${SELECT_ARGS} --db ${scratch_db} \
		--report ${scratch_kreport} \
		--output ${scratch_out} ${scratch_r1} ${scratch_r2}

#  LEVEL          level to estimate abundance at [options: D,P,C,O,F,G,S] (default: S)
	for len in 75 100 150 ; do
		for lvl in D P C O F G S ; do
			scratch_bracken=${TMPDIR}/$( basename ${fbase} ).${len}.${lvl}.bracken.txt
			scratch_breport=${TMPDIR}/$( basename ${fbase} ).${len}.${lvl}.breport.txt
			bracken.bash -d ${scratch_db} -i ${scratch_kreport} \
				-o ${scratch_bracken} -w ${scratch_breport} -r ${len} -l ${lvl}
			mv --update ${scratch_breport} $( dirname ${f} )
			mv --update ${scratch_bracken} $( dirname ${f} )
		done
	done

	mv --update ${scratch_out} ${f}
	mv --update ${scratch_kreport} $( dirname ${f} )

#	if [ -n "${report}" ] ; then
#		mv --update ${scratch_report} ${report}
#	fi
	# unnecessary as kraken2.bash will chmod files if successfull
	#chmod -R a-w ${f}
fi
