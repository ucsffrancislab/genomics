#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#threads=""
SELECT_ARGS=""
r1=""
r2=""
#u=""
while [ $# -gt 0 ] ; do
	case $1 in
		-1)
			shift; r1=$1; shift;;
		-2)
			shift; r2=$1; shift;;
#		-U)
#			shift; u=$1; shift;;
		-o)
			shift; f=$1; shift;;
		-r|--ref)
			shift; ref=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	scratch_inputs=""
	if [ -n "${r1}" ] ; then
		cp ${r1} ${TMPDIR}/
		scratch_inputs="${scratch_inputs} -1 ${TMPDIR}/$( basename ${r1} )"
	fi
	if [ -n "${r2}" ] ; then
		cp ${r2} ${TMPDIR}/
		scratch_inputs="${scratch_inputs} -2 ${TMPDIR}/$( basename ${r2} )"
	fi
#	if [ -n "${u}" ] ; then
#		cp ${u} ${TMPDIR}/
#		scratch_inputs="${scratch_inputs} -U ${TMPDIR}/$( basename ${u} )"
#	fi

	#	Quick test script so assuming that ${x} includes FULL PATH
	cp ${ref}.?.bt2 ${ref}.rev.?.bt2 ${TMPDIR}/

	mkdir -p ${TMPDIR}/out
	scratch_out=${TMPDIR}/out
	scratch_bam=${scratch_out}/$( basename ${f} )
	scratch_ref=${TMPDIR}/$( basename ${ref} )


	#	Obviously, this requires that the outfile ends with .fa.gz
	#scratch_bam=${scratch_out%.fa.gz}.bam

	threads=${PBS_NUM_PPN:-1}

	bowtie2.bash ${SELECT_ARGS} --threads ${threads} -x ${scratch_ref} -o ${TMPDIR}/tmp.bam ${scratch_inputs}


	#	select reads where read or mate aligned
	#samtools view ${TMPDIR}/tmp.bam | awk -F"\t" '( and($2,4) && !and($2,8) ){print ">"$1"-"$3; print $10}' | gzip > ${scratch_out}

	#		( xor ( !and($2,4), !and($2,8) ) ){ print }
#	Flags:
#		1    0x1   PAIRED        .. paired-end (or multiple-segment) sequencing technology
#		2    0x2   PROPER_PAIR   .. each segment properly aligned according to the aligner
#		4    0x4   UNMAP         .. segment unmapped
#		8    0x8   MUNMAP        .. next segment in the template unmapped
#		16   0x10  REVERSE       .. SEQ is reverse complemented
#		32   0x20  MREVERSE      .. SEQ of the next segment in the template is reversed
#		64   0x40  READ1         .. the first segment in the template
#		128  0x80  READ2         .. the last segment in the template
#		256  0x100 SECONDARY     .. secondary alignment
#		512  0x200 QCFAIL        .. not passing quality controls
#		1024 0x400 DUP           .. PCR or optical duplicate
#		2048 0x800 SUPPLEMENTARY .. supplementary alignment
#

	samtools view -h ${TMPDIR}/tmp.bam | gawk -F"\t" '
			( /^@/ ){ print; next; }
			( !and($2,4) || !and($2,8) ){ print }' | \
		samtools sort --threads $((threads-1)) -n -o ${scratch_bam} -


#			( !and($2,4) || !and($2,8) ){ print }' > ${TMPDIR}/select.sam

#	samtools sort --threads $((threads-1)) -n -o ${scratch_bam} select.sam
#			( or ( !and($2,4), !and($2,8) ) ){ print }' | \

	#	Assuming output file is a .bam file
	scratch_base=${scratch_bam%.bam}

	samtools fastq -1 ${scratch_base}_R1.fastq.gz -2 ${scratch_base}_R2.fastq.gz \
		-0 ${scratch_base}_RO.fastq.gz -s ${scratch_base}_SI.fastq.gz -N ${scratch_bam}

	mv --update ${scratch_out}/* $( dirname ${f} )
#	mv --update ${scratch_out}.err.txt $( dirname ${f} )

	chmod a-w ${f}
fi
