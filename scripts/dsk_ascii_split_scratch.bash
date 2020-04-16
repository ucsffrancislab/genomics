#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
#		-infile)
#			shift; infile=$1; shift;;
		-outbase)
			shift; outbase=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


## 0. Create job-specific scratch folder that ...
SCRATCH_JOB=/scratch/$USER/job/$PBS_JOBID
mkdir -p $SCRATCH_JOB
##    ... is automatically removed upon exit
##    (regardless of success or failure)
#trap "{ cd /scratch/ ; rm -rf $SCRATCH_JOB/ ; }" EXIT
trap "{ chmod -R +w $SCRATCH_JOB/; \rm -rf $SCRATCH_JOB/ ; }" EXIT


#f="${outbase}.done"
#if [ -f $f ] && [ ! -w $f ] ; then
f="${outbase}"	#	DIRECTORY
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	## 1. Copy input files from global disk to local scratch
	#cp /data/$USER/sample.fq $SCRATCH_JOB/
	#cp /data/$USER/reference.fa $SCRATCH_JOB/

#	cp --archive ${infile} ${SCRATCH_JOB}/

	cp --archive ${outbase}.txt.gz ${SCRATCH_JOB}/
#	for of in ${outbase}.h5 ${outbase}.txt.gz ; do
#		[ -f $of ] && [ ! -w $of ] && cp --archive ${of} ${SCRATCH_JOB}/
#	done

	## 2. Process input files
	#cd $SCRATCH_JOB
	#/path/to/my_pipeline --cores=$PBS_NUM_PPN reference.fa sample.fq > output.bam

#	scratch_infile=${SCRATCH_JOB}/$( basename ${infile} )
	scratch_outbase=${SCRATCH_JOB}/$( basename ${outbase} )

#	dsk_to_split_ascii.bash $SELECT_ARGS -infile ${scratch_infile} -outbase ${scratch_outbase}
	dsk_ascii_split.bash $SELECT_ARGS -outbase ${scratch_outbase}


#	dsk.bash -nb-cores ${threads} -kmer-size ${k} -abundance-min 0 \
#		-max-memory ${mem} -file ${infile} -out ${outbase}.h5
#
#	dsk2ascii.bash -nb-cores ${threads} -file ${outbase}.h5 -out ${outbase}.txt.gz
#
#	if [ ${k} -gt ${u} ] ; then
#
#		zcat ${outbase}.txt.gz | awk -v l=$[k-u] -v outbase=${outbase} \
#			'{print $0 | "gzip > "outbase"-"substr($1,0,l)".txt.gz" }' 
#
#	fi
#
#	touch ${outbase}.done
#	chmod a-w ${outbase}.done



#	## 3. Move output files back to global disk
#	mv output.bam /data/$USER/

	#mv --update ${scratch_outbase}* $( dirname ${outbase} )
	#mkdir -p ${outbase}
	#mv --update ${scratch_outbase}-* ${outbase}/
	mv --update ${scratch_outbase} $( dirname ${outbase} )

fi

