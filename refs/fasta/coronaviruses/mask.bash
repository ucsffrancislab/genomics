#!/usr/bin/env bash



for f in NC_0?????.?.masked.fasta ; do
for s in 25 50 ; do

	echo $f

	b=$( basename $f .fasta )

	faSplit -oneFile -extra=${s} size ${f} ${s} split

	mv split.fa ${b}.split${s}.fa

	bowtie2 -x hg38-noEBV -f -U ${b}.split${s}.fa --very-sensitive --no-unal -S ${b}.split${s}.e2e.sam

	bowtie2 -x hg38-noEBV -f -U ${b}.split${s}.fa --very-sensitive-local --no-unal -S ${b}.split${s}.loc.sam

	samtools view ${b}.split${s}.e2e.sam | awk -v ref=${b%.masked} '{
		sub(/^split/,"",$1);
		a=1+25*$1
		b=a+49
		print ref"\t"a"\t"b
	}' > ${b}.${s}.e2e.mask.bed

	#	Above and below NEED the complete reference (with its version number as it is in the fasta)

	samtools view ${b}.split${s}.loc.sam | awk -v ref=${b%.masked} '{
		sub(/^split/,"",$1);
		a=1+25*$1
		b=a+49
		print ref"\t"a"\t"b
	}' > ${b}.${s}.loc.mask.bed


	maskFastaFromBed -fi ${f} -fo ${b}.${s}.e2e-masked.fasta -bed ${b}.${s}.e2e.mask.bed -fullHeader

	maskFastaFromBed -fi ${f} -fo ${b}.${s}.loc-masked.fasta -bed ${b}.${s}.loc.mask.bed -fullHeader

done
done
