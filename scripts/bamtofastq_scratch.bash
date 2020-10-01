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
		filename=*)
			filename=${1#filename=}; shift;;
		F=*)
			F=${1#F=}; shift;;
		F2=*)
			F2=${1#F2=}; shift;;
		S=*)
			S=${1#S=}; shift;;
		O=*)
			O=${1#O=}; shift;;
		O2=*)
			O2=${1#O2=}; shift;;
		T=*)
			T=${1#T=}; shift;;
		inputformat=*)
			shift;;	#	replacing this with sam
#		outputdir=*)
#			outputdir=${1#outputdir=}; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#input=$1

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ -f $F ] && [ ! -w $F ] ; then
	echo "Write-protected $F exists. Skipping."
#if [ -d $dir ] && [ ! -w $dir ] ; then
#	echo "Write-protected $dir exists. Skipping."
else
	echo "Creating $F"

	cp ${filename} ${TMPDIR}/
	#cp ${normal}.bai ${TMPDIR}/

	scratch_filename=${TMPDIR}/$( basename ${filename} )

##	scratch_outputdir=${TMPDIR}/$( basename ${outputdir} )/out
#	scratch_outputdir=${TMPDIR}/out
#	mkdir -p ${scratch_outputdir}

#	bamtofastq ${SELECT_ARGS} filename=${scratch_filename} outputdir=${scratch_outputdir}

#	#mkdir -p $( dirname ${dir} )	#	just in case
#	#mv --update ${TMPDIR}/runDir/* $( dirname ${dir} )
#	mkdir -p ${outputdir}
#	mv --update ${scratch_outputdir}/* ${outputdir}/
#	#chmod -R a-w ${outputdir}


	scratch_out=${TMPDIR}/out
	mkdir -p ${scratch_out}

	#bamtofastq ${SELECT_ARGS} filename=${scratch_filename} \

#samtools view -h /francislab/data1/raw/20200720-TCGA-GBMLGG-RNA_bam/bam/08-0386-01A-01R-1849-01+2.bam | awk 'BEGIN{FS=OFS="\t"}(/^@/){print}(!/^@/){sub(/\/[12]$/, "", $1); print}' | head -100

	#	about half of the TCGA RNA-seq bam files include the /1 and /2 in the read name.
	#	biobambam's bamtofastq does not remove this so it never finds paired reads.
	#	removing the suffix and feeding bamtofastq through stdin. Testing.

	samtools view -h ${scratch_filename} \
	| awk 'BEGIN{FS=OFS="\t"}(/^@/){print}(!/^@/){sub(/\/[12]$/, "", $1); print}' \
	| bamtofastq ${SELECT_ARGS} \
		inputformat=sam \
		T=${TMPDIR}/$( basename $T ) \
		F=${scratch_out}/$( basename $F ) \
		F2=${scratch_out}/$( basename $F2 ) \
		S=${scratch_out}/$( basename $S ) \
		O=${scratch_out}/$( basename $O ) \
		O2=${scratch_out}/$( basename $O2 )

	outdir=$( dirname $F )
	mkdir -p ${outdir}
	chmod -R a-w ${scratch_out}/*
	mv --update ${scratch_out}/* ${outdir}/
fi

