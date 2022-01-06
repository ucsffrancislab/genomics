#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools
fi
set -x

#	bam_to_fastq_by_refseq.bash *.viral.bam

#	Expecting sorted by name to preserve synchronicity of pair

while [ $# -gt 0 ] ; do

	echo $1

#  0x40    64  READ1          the first segment in the template
#  0x80   128  READ2          the last segment in the template

	mkdir -p ${1%.bam}

	samtools view $1 | gawk -F"\t" -v b=${1%.bam} '\
		( and($2,64) ){
			print "@"$1"/1" >> b"/"$3".R1.fastq"
			print $10   >> b"/"$3".R1.fastq"
			print "+"   >> b"/"$3".R1.fastq"
			print $11   >> b"/"$3".R1.fastq"
			if( $7 != "=" ){
				print "@"$1"/2" >> b"/"$7".R1.fastq"
				print $10   >> b"/"$7".R1.fastq"
				print "+"   >> b"/"$7".R1.fastq"
				print $11   >> b"/"$7".R1.fastq"
			}
		}
		( and($2,128) ){
			print "@"$1"/2" >> b"/"$3".R2.fastq"
			print $10   >> b"/"$3".R2.fastq"
			print "+"   >> b"/"$3".R2.fastq"
			print $11   >> b"/"$3".R2.fastq"
			if( $7 != "=" ){
				print "@"$1"/1" >> b"/"$7".R2.fastq"
				print $10   >> b"/"$7".R2.fastq"
				print "+"   >> b"/"$7".R2.fastq"
				print $11   >> b"/"$7".R2.fastq"
			}
		}'


	gzip ${1%.bam}/*fastq

	chmod a-w ${1%.bam}/*fastq.gz

	shift
done

