#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
#while [ $# -gt 1 ] ; do				#	SAVE THE LAST ONE
	case $1 in
		-1|--mates1)
			shift; r1=$1; shift;;
		-2|--mates2)
			shift; r2=$1; shift;;
		-i|--index)
			shift; index=$1; shift;;
		--unmatedReads)
			shift; unmatedReads=$1; shift;;
		-o)
			shift; f=$1; shift;;
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

	params=${SELECT_ARGS}

	if [ -n "${unmatedReads:-}" ] ; then
		cp ${unmatedReads} ${TMPDIR}/
		scratch_unmatedReads=${TMPDIR}/$( basename ${unmatedReads} )
		params="${params} --unmatedReads ${scratch_unmatedReads}"
	fi

	if [ -n "${r1:-}" ] ; then
		cp ${r1} ${TMPDIR}/
		scratch_r1=${TMPDIR}/$( basename ${r1} )
		params="${params} -1 ${scratch_r1}"
	fi

	if [ -n "${r2:-}" ] ; then
		cp ${r2} ${TMPDIR}/
		scratch_r2=${TMPDIR}/$( basename ${r2} )
		params="${params} -2 ${scratch_r2}"
	fi

	if [ -n "${index:-}" ] ; then
		cp -r ${index} ${TMPDIR}/
		scratch_index=${TMPDIR}/$( basename ${index} )
		params="${params} --index ${scratch_index}"
	fi

	scratch_out=${TMPDIR}/outdir

	mkdir -p ${scratch_out}/
	cd ${scratch_out}/

	#salmon.bash ${SELECT_ARGS} --index ${scratch_index} -1 ${scratch_r1} -2 ${scratch_r2} -o ${scratch_out}
	salmon.bash ${params} -o ${scratch_out}

	#	GOTTA move an existing dir or we'll move this INTO it.
	if [ -d ${f} ] ; then
		date=$( date "+%Y%m%d%H%M%S" --date="$( stat --printf '%z' ${f} )" )
		mv ${f} ${f}.${date}
	fi
#	chmod +w ${scratch_out}	#	so script can move and delete the contents (not crucial but stops error messages)
#	
#	#	+ mv --update /scratch/1834101.cclc01.som.ucsf.edu/outdir /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200808-REdiscoverTE/out/02-0047-01A-01R-1849-01+1.salmon.REdiscoverTE
#	#	mv: cannot remove `/scratch/1834101.cclc01.som.ucsf.edu/outdir/aux_info': Permission denied
#	#	mv: cannot remove `/scratch/1834101.cclc01.som.ucsf.edu/outdir/lib_format_counts.json': Permission denied
#	#	mv: cannot remove `/scratch/1834101.cclc01.som.ucsf.edu/outdir/cmd_info.json': Permission denied
#	#	mv: cannot remove `/scratch/1834101.cclc01.som.ucsf.edu/outdir/libParams': Permission denied
#	#	mv: cannot remove `/scratch/1834101.cclc01.som.ucsf.edu/outdir/quant.sf': Permission denied
#	#	mv: cannot remove `/scratch/1834101.cclc01.som.ucsf.edu/outdir/logs': Permission denied
#
#	mv --update ${scratch_out} ${f}
#	# unnecessary as salmon.bash will chmod files if successful (which I just undid)
#	chmod -R a-w ${f}

	chmod -R a-w ${scratch_out}
	cp --archive ${scratch_out} $( dirname ${f} )
fi

