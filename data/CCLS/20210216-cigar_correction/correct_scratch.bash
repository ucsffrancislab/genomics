#!/usr/bin/env bash
#SBATCH --export=NONE		#	required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools
fi
set -x	#	print expanded command before executing it

echo "Correct $1 to $2"
echo $TMPDIR

cp $1 $TMPDIR/

#samtools view -h ${TMPDIR}/$( basename $1 ) | awk 'BEGIN{FS=OFS="\t"}(/^@/){print;next}(!/^@/){if($6 !~ /[M\*]/){$6="*"};print}' | samtools view -o $TMPDIR/out.bam -

log=${TMPDIR}/$( basename $1 ).corrected.sam

samtools view -h ${TMPDIR}/$( basename $1 ) | awk 'BEGIN{FS=OFS="\t"}(/^@/){print;next}(!/^@/){ if($6 !~ /[M\*]/){print >>"'$log'";$6="*"};print}' | samtools view -o $TMPDIR/out.bam -

mv $log $( dirname $2 )/
chmod -w $( dirname $2 )/$( basename $log )

mv $TMPDIR/out.bam $2
chmod -w $2


