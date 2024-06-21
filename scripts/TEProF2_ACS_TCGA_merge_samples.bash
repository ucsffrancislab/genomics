#!/usr/bin/env bash

#	head out/allCandidateStatistics.tsv 
#	
#	File	Transcript_Name	Transcript Expression (TPM)	Fraction of Total Gene Expression	Intron Read Count
#	SRR3163500	TCONS_00000050	0.0269972980611288	1	0
#	SRR3163503	TCONS_00000050	0	0	0
#	SRR3163510	TCONS_00000050	0.276845132896947	1	0
#	SRR3163511	TCONS_00000050	0	0	0
#	SRR3163516	TCONS_00000050	4.28646182016811	1	0
#	SRR3163500	TCONS_00000056	0.758470292685066	0.189844119304379	0
#	SRR3163503	TCONS_00000056	1.16140601972494	0.230703659270909	0
#	SRR3163510	TCONS_00000056	1.09776946702687	0.216242970373199	0
#	SRR3163511	TCONS_00000056	2.65967395243595	0.277697354966442	0


head -1 $1 | sed 's/\t/,/g'

awk 'BEGIN{FS="\t";OFS=","}
(NR==1){c=1;next}
{
	split($1,a,"-")
	$1=a[1]"-"a[2]
	if(($1==subj)&&($2==tcons)){
		c+=1
		tpm+=$3
		ge+=$4
		irc+=$5
	}else{
		if(subj!=""){ print subj,tcons,tpm/c,ge/c,irc }
		c=1
		subj=$1
		tcons=$2
		tpm=$3
		ge=$4
		irc=$5
	}
}END{ 
	print subj,tcons,tpm/c,$4,irc 
}' $1

# | sort -t, -k1,2


