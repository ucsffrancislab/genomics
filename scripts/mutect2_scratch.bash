#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

raw_inputs=""
scratch_inputs=""
SELECT_ARGS=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-I|--input)
			#	This is tricky as multiple --input's are used.
			#	I could copy them here, but that would be too early as don't know if output exists already.
			#	Creating new array which I'm not sure is the best way, but it seems to work.
			#	I think that I should've prepared a command string to copy all here
			#		and set scratch_inputs values
			#	raw_inputs="${raw_inputs} ${1} ${1}.bai"
			#	scratch_inputs="${scratch_inputs} --input ${TMPDIR}/$( basename ${1} )"
			#	...
			#	cp ${raw_inputs} ${TMPDIR}/
			shift; inputs+=("${1}"); shift;;
		-O|--output)
			shift; output=$1; shift;;
		-R|--reference)
			shift; reference=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done
#input=$1


###	creating arrays
#$ x=(1 "2 3" "my file path" 4 "5 6 7")
#$ for f in "${x[@]}" ; do echo $f; done
#1
#2 3
#my file path
#4
#5 6 7
#Syntax	Result
#arr=()	Create an empty array
#arr=(1 2 3)	Initialize array
#${arr[2]}	Retrieve third element
#${arr[@]}	Retrieve all elements
#${!arr[@]}	Retrieve array indices
#${#arr[@]}	Calculate array size
#arr[0]=3	Overwrite 1st element
#arr+=(4)	Append value(s)
#str=$(ls)	Save ls output as a string
#arr=( $(ls) )	Save ls output as an array of files
#${arr[@]:s:n}	Retrieve n elements starting at index s

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

f=$output
if [ -f $f ] && [ ! -w $f ] ; then
#if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	cp ${reference} ${TMPDIR}/
	cp ${reference}.fai ${TMPDIR}/
	cp ${reference%.*}.dict ${TMPDIR}/
	scratch_reference=${TMPDIR}/$( basename ${reference} )

	for input in "${inputs[@]}" ; do
		cp ${input} ${TMPDIR}/
		cp ${input}.bai ${TMPDIR}/
		scratch_inputs="${scratch_inputs} --input ${TMPDIR}/$( basename ${input} )"
	done

	scratch_outdir=${TMPDIR}/out
	mkdir -p ${scratch_outdir}
	scratch_output=${scratch_outdir}/$( basename ${output} )

	#	Not keeping
	scratch_unfiltered=${TMPDIR}/unfiltered.vcf.gz

	gatk Mutect2 ${SELECT_ARGS} ${scratch_inputs} --reference ${scratch_reference} --output ${scratch_unfiltered}

	ls -l ${TMPDIR}

	gatk FilterMutectCalls --variant ${scratch_unfiltered} --output ${scratch_output}

	ls -l ${TMPDIR}

	chmod -R a-w ${scratch_outdir}
	#mv --update ${scratch_outdir}/* $( dirname ${f} )/
	cp ${scratch_outdir}/* $( dirname ${f} )/

	#	Too often files are left behind that are write-protected so ...
	chmod -R a+w ${TMPDIR}
fi
