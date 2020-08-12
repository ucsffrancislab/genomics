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
		-I|--input)
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



f=$output
if [ -f $f ] && [ ! -w $f ] ; then
#if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	scratch_inputs=""
	for input in "${inputs[@]}" ; do
		cp ${input} ${TMPDIR}/
		scratch_inputs="${scratch_inputs} --input ${TMPDIR}/$( basename ${input} )"
	done

	cp ${reference} ${TMPDIR}/
	scratch_reference=${TMPDIR}/$( basename ${reference} )

	scratch_output=${TMPDIR}/$( basename ${output} )

	echo gatk Mutect2 ${SELECT_ARGS} ${scratch_inputs} --reference ${scratch_reference} --output ${scratch_output}

	gatk Mutect2 ${SELECT_ARGS} ${scratch_inputs} --reference ${scratch_reference} --output ${scratch_output}


	mv --update ${scratch_output} ${f}
	chmod -R a-w ${f}
fi
