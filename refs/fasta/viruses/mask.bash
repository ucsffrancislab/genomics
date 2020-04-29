#!/usr/bin/env bash

for f in NC_00????.?.masked.fasta ; do
for s in 50 25 ; do

	echo $f

	b=$( basename $f .fasta )

	faSplit -oneFile -extra=${s} size ${f} ${s} split

	mv split.fa ${b}.split.${s}.fa

#	bowtie2 -x hg38-noEBV -f -U ${b}.split.fa --very-sensitive --no-unal -S ${b}.split.e2e.sam

#	bowtie2 -x hg38-noEBV -f -U ${b}.split.${s}.fa --very-sensitive-local --no-unal -S ${b}.split.${s}.loc.sam
	bowtie2 -x hg38-noEBV -f -U ${b}.split.${s}.fa --no-unal \
		--local -D 25 -R 3 -N 0 -L 18 -i S,1,0.30 --score-min G,15,8 \
		-S ${b}.split.${s}.loc.sam
#		--very-sensitive-local \
#   -D 20 -R 3 -N 0 -L 20 -i S,1,0.50

#		-D 25 -R 3 -N 0 -L 18 -i S,1,0.40 --score-min G,20,8 \
# cat /francislab/data1/refs/fasta/viruses/testing/NC_001664.4.masked.50.D25.R3.N0.L18.S,1,0.40.G,20,8.loc.mask.bed
#	cat /francislab/data1/refs/fasta/viruses/testing/NC_001664.4.masked.50.D25.R3.N1.L20.S,1,0.40.G,20,8.loc.mask.bed


#	samtools view ${b}.split.e2e.sam | awk -v ref=${b%.masked} '{
#		sub(/^split/,"",$1);
#		a=1+25*$1
#		b=a+49
#		print ref"\t"a"\t"b
#	}' > ${b}.e2e.mask.bed

	#	Above and below NEED the complete reference (with its version number as it is in the fasta)

	echo make bed

	samtools view ${b}.split.${s}.loc.sam | awk -v s=${s} -v ref=${b%.masked} '{
		sub(/^split/,"",$1);
		a=1+s*$1
		b=a+(2*s-1)
		print ref"\t"a"\t"b
	}' | awk 'BEGIN{FS=OFS="\t"}(NR==1){r=$1;if($2>50){s=$2-50}else{s=1};e=$3+50} (NR!=1){ if( $2 <= (e+50+1) ){ e=$3+50 }else{ print $1,s,e; s=$2-50; e=$3+50 } }END{print r,s,e}' > ${b}.${s}.loc.mask.bed
#	}' | awk 'BEGIN{FS=OFS="\t"}(NR==1){r=$1;s=$2;e=$3} (NR!=1){ if( $2 <= (e+1) ){ e=$3 }else{ print $1,s,e; s=$2; e=$3 } }END{print r,s,e}' > ${b}.${s}.loc.mask.bed
#	}' > ${b}.${s}.loc.mask.bed

#	maskFastaFromBed -fi ${f} -fo ${b}.e2e-masked.fasta -bed ${b}.e2e.mask.bed -fullHeader

	echo maskFastaFromBed

	maskFastaFromBed -fi ${f} -fo ${b}.${s}.loc-masked.fa -bed ${b}.${s}.loc.mask.bed -fullHeader

done
done

