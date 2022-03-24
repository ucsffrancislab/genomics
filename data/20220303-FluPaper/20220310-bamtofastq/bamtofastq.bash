#!/usr/bin/env bash




#	replace with array wrapper script, although this script should still work
exit





set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

threads=8
vmem=60
scratch=50

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/raw/PRJNA736483"
OUTDIR="/francislab/data1/working/PRJNA736483/20220310-bamtofastq/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

for bam in ${INDIR}/SRR14773*/*_alignment_bam.bam ; do
#for bam in ${INDIR}/SRR14773640/*_alignment_bam.bam ; do

	echo ${bam}

	jobbase=$( basename ${bam} _alignment_bam.bam )
	echo ${jobbase}

	base=${OUTDIR}/${jobbase}
	#echo ${base}

	outbase="${base}"
	f=${outbase}_R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else

		#scratch=$( stat --dereference --format %s ${bam} | awk -v p=${threads} '{print int(1.7*$1/p/1000000000)}' )

		bam_size=$( stat --dereference --format %s ${bam} )
		#scratch=$( echo $(( ((${bam_size})/${threads}/1000000000*18/10)+1 )) )
		#scratch=$( echo $(( (${bam_size}/${threads}/1000000000*2)+1 )) )
		scratch=$( echo $(( (${bam_size}/1000000000*2)+1 )) )

		echo "Requesting ${scratch} scratch"
		#	gres=scratch should be about total needed divided by num threads

		sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --job-name=${jobbase} --time=1440 \
			--nodes=1 --ntasks=${threads} --mem=${vmem}G --gres=scratch:${scratch}G \
			--output=${outbase}.${date}.%j.txt \
			~/.local/bin/bamtofastq_scratch.bash \
				collate=1 \
				exclude=DUP,QCFAIL,SECONDARY,SUPPLEMENTARY \
				filename=${bam} \
				inputformat=bam \
				gz=1 \
				level=5 \
				T=${outbase}_TEMP \
				F=${outbase}_R1.fastq.gz \
				F2=${outbase}_R2.fastq.gz \
				S=${outbase}_S1.fastq.gz \
				O=${outbase}_O1.fastq.gz \
				O2=${outbase}_O2.fastq.gz

	fi

done	#	for bam in

