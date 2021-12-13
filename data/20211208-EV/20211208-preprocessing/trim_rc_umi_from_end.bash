#!/usr/bin/env bash

#cp $1 $2


#	trim rc umi from near end of read (AND QUALITY STRING)

zcat $1 | paste - - - - | awk -F"\t" '{
	split($1,a,"_")
	umi=substr(a[1],2,9)
	cmd="echo "umi"|rev|tr \"[ACTG]\" \"[TGAC]\""
	cmd | getline rcumi
	close(cmd)
	#print rcumi
	#print $2
	i=index($2,"C"rcumi)
	if(i>0){
		$2=substr($2,1,i-1)
		$4=substr($4,1,i-1)
	}
	print $1
	print $2
	print $3
	print $4
}' | gzip > $2


chmod -w $2


count_fasta_reads.bash $2

average_fasta_read_length.bash $2


