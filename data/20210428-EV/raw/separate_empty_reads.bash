#!/usr/bin/env bash


#	Why are these "empty"?
#	These reads start with the adapter.
#	Not entirely certain this is necessary as the trimmers do it.
#	It doesn't look like I use the "nonempty" directory anyway.


mkdir empty nonempty

for f in Hansen/SFHH005*.fastq.gz ; do
	echo $f
	b=$( basename $f .gz )
	o=${b}.gz
	if [ -f empty/$o ] && [ ! -w empty/$o ] ; then
		echo "Write-protected $o exists. Skipping."
	else
		echo "Creating $o"
		zcat $f | paste - - - - | awk -v b=$b -F"\t" '($2~/^(GGAAGAGCACAC|GAAGAGCACACG|AGATCGGAAGAG)/){ print $1"\n"$2"\n"$3"\n"$4 > "empty/"b;next}{ print $1"\n"$2"\n"$3"\n"$4 > "nonempty/"b;}'
		gzip {empty,nonempty}/$b
		chmod -w {empty,nonempty}/${o}
	fi
done


for f in Hansen/SFHH006*.fastq.gz ; do
	echo $f
	b=$( basename $f .gz )
	o=${b}.gz
	if [ -f empty/$o ] && [ ! -w empty/$o ] ; then
		echo "Write-protected $o exists. Skipping."
	else
		echo "Creating $o"
		zcat $f | paste - - - - | awk -v b=$b -F"\t" '($2~/^TGGAATTCTCGG/){ print $1"\n"$2"\n"$3"\n"$4 > "empty/"b;next}{ print $1"\n"$2"\n"$3"\n"$4 > "nonempty/"b;}'
		gzip {empty,nonempty}/$b
		chmod -w {empty,nonempty}/${o}
	fi
done

count_fasta_reads.bash empty/*fastq.gz nonempty/*fastq.gz
average_fasta_read_length.bash empty/*fastq.gz nonempty/*fastq.gz

cp Hansen/*.{subject,diagnosis,labkit} empty/
cp Hansen/*.{subject,diagnosis,labkit} nonempty/

