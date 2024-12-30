#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e	#	exit if any command fails	#	this can break things
set -u	#	Error on usage of unset variables
#set -o pipefail	#	can break things
#if [ -n "$( declare -F module )" ] ; then
#	echo "Loading required modules"
#	#module load CBI htslib samtools bowtie2
#fi
set -x	#	print expanded command before executing it

echo $*


#	BE CAREFUL! grep will return a fail code if none found. ERRRRR!
#~/.local/netMHCpan-4.1/netMHCpan -l 10 -f /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Modified-TCONS_00000820-9.faa -a HLA-A0217 | grep "<= SB"
#[gwendt@c4-dev3 /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM]$ echo $?
#1


l=15

status="Waiting"
start_allele=""

while [ $# -gt 0 ] ; do
	case $1 in
		-f)
			shift; fasta=$1; shift;;
		-l)
			shift; l=$1; shift;;
		--start_allele)
			shift; start_allele=$1; shift;;
		*)
			echo "Unknown param :${1}:"; exit 1;;
	esac
done


dir=$( dirname ${fasta} )/MHC
mkdir -p ${dir}
base=$( basename ${fasta} .faa )

#echo
#echo "MHC Class II"

#	grep -E "^(HLA|DR)" /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat | sort -k1,1 | awk '{if(!seen[$2]){seen[$2]=1;print}}' > /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.humanfirsts.dat
#	cut -d' ' -f1 /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.humanfirsts.dat > /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.humanfirsts.allele_names

#	wc -l /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence*
# 11048 /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat
#  1868 /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.humanfirsts.allele_names
#  1868 /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.humanfirsts.dat

#	NO DUPLICATED ALLELE NAMES
#	cut -d' ' -f1 /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat | sort | uniq -d

#	grep -E "^(HLA|DR)" /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat | cut -d' ' -f2 | sort | uniq -c | sort -k1n,1 | tail
#    106 QEFFIASGAAVDAIMESSYDYFDLQKRNYHVVFT
#    110 QEFFIASGAAVDAIMEACNIYYDLRRETYYVVFT
#    110 YNYHQRXFATVLHSLYFGGTHYDVGASRVHVAGI
#    132 YNYHERRFATVLHIVYFAYTYYDVRTETVHLETT
#    132 YNYHQRXFATVLHSLYFGLTYYAVRTETVHLETT
#    132 YNYHQRXFATVTHILYFAYTYYDVRTETVHLETT
#    143 YNYHQRXFATVLHSLYFGLTYYDVRTETVHLETT
#    176 CNYHEGGGARVAHIMYFAYTYYDVRTETVHLETT
#    176 CNYHQGGGARVAHIMYFAYTYYDVRTETVHLETT
#    484 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT

#	grep YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat | head
#	HLA-DQA10501-DQB10301 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB10309 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103108 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103109 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB10310 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103114 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103119 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103120 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103121 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT
#	HLA-DQA10501-DQB103131 YNYHQRXFATVLHSLYFAYTYYDVRTETVHLETT


# cat AGS41970_HLA.tsv | datamash transpose | grep "HLA_DRB" | sed -e 's/HLA_//' | cut -f1 | sed 's/$/ /' | sort > AGS41970_HLA.DRB.txt
#	wc -l AGS41970_HLA.DRB.txt
#	64 AGS41970_HLA.DRB.txt

#	grep -f AGS41970_HLA.DRB.txt ~/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat | cut -d' ' -f1 | sort > ~/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat.DRB
#	wc -l ~/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat.DRB
#	51 /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.dat.DRB

#	sdiff -Wsd AGS41970_HLA.DRB.txt pseudosequence.2023.all.X.dat.DRB | cut -f1 | paste -s | sed 's/ \t/, /g'
#	DRB1_01, DRB1_03, DRB1_04, DRB1_07, DRB1_08, DRB1_09, DRB1_10, DRB1_11, DRB1_12, DRB1_13, DRB1_14, DRB1_15, DRB1_16 



#	TO DO DQB and DPB



##for allele in $( grep -E '^(HLA|DRB)' /c4/home/gwendt/.local/netMHCIIpan-4.3/data/allelelist.txt | cut -d' ' -f1 ) ; do
##for allele in $( cat /c4/home/gwendt/.local/netMHCIIpan-4.3/data/pseudosequence.2023.all.X.humanfirsts.allele_names ) ; do

for allele in $( cat /francislab/data2/refs/netMHCIIpan/AGS_select ) ; do

	echo ${allele}

	#	MHC II really needs a longer length (~13) before it starts returning strong binding

	if [ "${status}" == "Running" ] || [ -z "${start_allele}" ] || [ "${start_allele}" == "${allele}" ] ; then
		status="Running"
		echo "Running"

#	 should i implement a inline length filter?

		~/.local/netMHCIIpan-4.3/netMHCIIpan -f ${fasta} \
			-length ${l} -a ${allele} \
			| grep " <= SB" \
			>> ${dir}/${base}.netMHCIIpan.AGS.txt
	else
		echo "Waiting"
	fi

#	the allele in the output file isn't the same as the allele given!!!!! this adds an asterisk

done

chmod -w ${dir}/${base}.netMHCIIpan.AGS.txt

echo "Done"

#	This script will silently fail if ANY sequence in the fasta file is < 9bp.

# ~/.local/netMHCIIpan-4.3/netMHCIIpan -f /francislab/data1/refs/PhIP-Seq/human_herpes.faa -length 15

#	# NetMHCIIpan version 4.3e
#	
#	# Input is in FASTA format
#	
#	# Peptide length 15
#	
#	# Prediction Mode: EL
#	
#	# Threshold for Strong binding peptides (%Rank)  1.00%
#	# Threshold for Weak binding peptides (%Rank)    5.00%
#	No peptides derived from protein ID 63471_Human_herpesvirus_5 len 14. Skipped
#	No peptides derived from protein ID 69377_Human_herpesvirus_3 len 11. Skipped
#	No peptides derived from protein ID 69416_Human_herpesvirus_5 len 14. Skipped
#	Error: FASTA input sequence must be of length >= 9: 96177_Human_herpesvirus_1
#	[gwendt@c4-dev3 /francislab/data1/refs/PhIP-Seq]$ 




#	 should i implement a inline filter?

