#!/usr/bin/env bash



for f in NC_00????.?.masked.fasta ; do

	echo $f

	b=$( basename $f .fasta )

	faSplit -oneFile -extra=25 size ${f} 25 split

	mv split.fa ${b}.split.fa

	bowtie2 -x hg38-noEBV -f -U ${b}.split.fa --very-sensitive --no-unal -S ${b}.split.e2e.sam

	bowtie2 -x hg38-noEBV -f -U ${b}.split.fa --very-sensitive-local --no-unal -S ${b}.split.loc.sam

	samtools view ${b}.split.e2e.sam | awk -v ref=${b%.masked} '{
		sub(/^split/,"",$1);
		a=1+25*$1
		b=a+49
		print ref"\t"a"\t"b
	}' > ${b}.e2e.mask.bed

	#	Above and below NEED the complete reference (with its version number as it is in the fasta)

	samtools view ${b}.split.loc.sam | awk -v ref=${b%.masked} '{
		sub(/^split/,"",$1);
		a=1+25*$1
		b=a+49
		print ref"\t"a"\t"b
	}' > ${b}.loc.mask.bed


	maskFastaFromBed -fi ${f} -fo ${b}.e2e-masked.fasta -bed ${b}.e2e.mask.bed -fullHeader

	maskFastaFromBed -fi ${f} -fo ${b}.loc-masked.fasta -bed ${b}.loc.mask.bed -fullHeader

done
