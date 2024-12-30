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



#fasta=/francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Modified-TCONS_00000820-9.faa
#fasta=/francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Original-TCONS_00000820-9.faa
#fasta=/francislab/data1/refs/PhIP-Seq/human_herpes.faa

l=10

#l1=10
#l2=15

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
#		-lI|-l1)
#			shift; l1=$1; shift;;
#		-lII|-l2)
#			shift; l2=$1; shift;;
		*)
			echo "Unknown param :${1}:"; exit 1;;
	esac
done


#fasta=$1

dir=$( dirname ${fasta} )/MHC
mkdir -p ${dir}
base=$( basename ${fasta} .faa )

#echo "MHC Class I"

#Class 1: A B and C, and Class 2:  DR DQ DP prefixes.

#	grep HLA /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.dat | sort -k1,1 | awk '{if(!seen[$2]){seen[$2]=1;print}}' > /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.humanfirsts.dat
#	cut -d' ' -f1 /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.humanfirsts.dat > /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.humanfirsts.allele_names

#	wc -l /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo*
# 13010 /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.dat
#  3594 /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.humanfirsts.allele_names
#  3594 /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.humanfirsts.dat

#	DUPLICATE ALLELE NAME
#	cut -d' ' -f1 /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.dat | sort | uniq -d
#HLA-B51:12

#	grep "HLA-B51:12 " /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.dat
#	HLA-B51:12 YYATYRNIFTNTYENALYWTYNYYTWAELAYLWH
#	HLA-B51:12 YYATYRNIFTNTYENIADWTYNYYTWAELAYLWH

#	https://www.ebi.ac.uk/ipd/imgt/hla/alleles/allele/?accession=HLA00357
#	??????
#	SHSMRYFYTAMSRPGRGEPRFIAVGYVDDTQFVRFDSDAASPRTEPRAPWIEQEGPEYWDRNTQIFKTNTQTYRENLRIALRDYNQSEAGSHTWQTMYGCDVGPDGRLLRGHNQYAYDGKDYIALNEDLSSWTAADTAAQITQRKWEAAREAEQLRAYLEGLCVEWLRRHLENGKETLQRA

#	HLA-A0101 YFAMYQENMAHTDANTLYIIYRDYTWVARVYRGY
#	MAVMAPRTLLLLLSGALALTQTWAGSHSMRYFFTSVSRPGRGEPRFIAVGYVDDTQFVRFDSDAASQKMEPRAPWIEQEGPEYWDQETRNMKAHSQTDRANLGTLRGYYNQSEDGSHTIQIMYGCDVGPDGRFLRGYRQDAYDGKDYIALNEDLRSWTAADMAAQITKRKWEAVHAAEQRRVYLEGRCVDGLRRYLENGKETLQRTDPPKTHMTHHPISDHEATLRCWALGFYPAEITLTWQRDGEDQTQDTELVETRPAGDGTFQKWAAVVVPSGEEQRYTCHVQHEGLPKPLTLRWELSSQPTIPIVGIIAGLVLLGAVITGAVVAAVMWRRKSSDRKGGSYTQAASSDSAQGSDVSLTACKV


#	grep "^HLA" /c4/home/gwendt/.local/netMHCpan-4.1/Linux_x86_64/data/MHC_pseudo.dat | cut -d' ' -f2 | sort | uniq -c | sort -k1n,1 | tail
#    181 YYSEYRNIYAQTDESNLYLSYDYYTWAERAYEWY
#    197 YFAMYQENMAHTDANTLYIIYRDYTWVARVYRGY
#    208 YYAMYQENVAQTDVDTLYIIYRDYTWAAQAYRWY
#    210 YFAMYQENVAQTDVDTLYIIYRDYTWAELAYTWY
#    225 YSAGYREKYRQADVNKLYLRFNFYTWAERAYTWY
#    226 YDSGYRENYRQADVSNLYLRYDSYTLAALAYTWY
#    249 YYAGYREKYRQTDVSNLYIRYDYYTWAELAYLWY
#    250 YDSGYREKYRQADVSNLYLRSDSYTLAALAYTWY
#    275 YSAMYEEKVAHTDENIAYLMFHYYTWAVQAYTGY
#    384 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY

#	grep YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY /c4/home/gwendt/.local/netMHCpan-4.1/Linux_x86_64/data/MHC_pseudo.dat | head
#	HLA-A0201 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0209 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0224 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0225 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0230 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0231 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0240 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0243 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0259 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	HLA-A0266 YFAMYGEKVAHTHVDTLYVRYHYYTWAVLAYTWY
#	Are these results identical?




#	Select even fewer alleles based on whats in AGS. May include duplicates but so few, don't really care.

#	cat AGS41970_HLA.tsv | datamash transpose | grep "HLA_[ABC]" | sed -e 's/_/-/' -e 's/_//' | cut -f1 | sed 's/$/ /' | sort > AGS41970_HLA.ABC.txt
#	wc -lAGS41970_HLA.ABC.txt
#	246 AGS41970_HLA.ABC.txt

#	grep -f AGS41970_HLA.ABC.txt ~/.local/netMHCpan-4.1/data/MHC_pseudo.dat | cut -d' ' -f1 | sort > ~/.local/netMHCpan-4.1/data/MHC_pseudo.dat.ABC
#	wc -l ~/.local/netMHCpan-4.1/data/MHC_pseudo.dat.ABC
#	178 /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.dat.ABC


#	sdiff -Wsd AGS41970_HLA.ABC.txt MHC_pseudo.dat.ABC | cut -f1 | paste -s | sed 's/ \t/, /g'
#	HLA-A01, HLA-A02, HLA-A03, HLA-A11, HLA-A23, HLA-A24, HLA-A2401, HLA-A25, HLA-A26, HLA-A29, HLA-A30, HLA-A31, HLA-A32, HLA-A33, HLA-A34, HLA-A36, HLA-A66, HLA-A68, HLA-A69, HLA-A74, HLA-A80, HLA-B07, HLA-B08, HLA-B13, HLA-B14, HLA-B15, HLA-B1526, HLA-B18, HLA-B27, HLA-B35, HLA-B37, HLA-B38, HLA-B39, HLA-B40, HLA-B41, HLA-B42, HLA-B44, HLA-B45, HLA-B46, HLA-B47, HLA-B48, HLA-B49, HLA-B50, HLA-B51, HLA-B52, HLA-B53, HLA-B54, HLA-B55, HLA-B56, HLA-B57, HLA-B58, HLA-B73, HLA-B78, HLA-B81, HLA-C01, HLA-C02, HLA-C03, HLA-C04, HLA-C05, HLA-C06, HLA-C07, HLA-C08, HLA-C12, HLA-C14, HLA-C15, HLA-C16, HLA-C17, HLA-C18 

#	sdiff -Wsd AGS41970_HLA.ABC.txt MHC_pseudo.dat.ABC | cut -f1 | wc -l
#	68



##for allele in $( grep -E '^HLA' /c4/home/gwendt/.local/netMHCpan-4.1/data/allelenames | cut -d' ' -f1 ) ; do
##for allele in $( cat /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.humanfirsts.allele_names ) ; do
##for allele in $( cat /c4/home/gwendt/.local/netMHCpan-4.1/data/MHC_pseudo.dat.ABC ) ; do


for allele in $( cat /francislab/data2/refs/netMHCpan/AGS_select ) ; do

	echo ${allele}

	if [ "${status}" == "Running" ] || [ -z "${start_allele}" ] || [ "${start_allele}" == "${allele}" ] ; then
		status="Running"
		echo "Running"
		~/.local/netMHCpan-4.1/netMHCpan -f ${fasta} \
			-l ${l} -a ${allele} \
			| grep " <= SB" \
			>> ${dir}/${base}.netMHCpan.AGS.txt
	else
		echo "Waiting"
	fi



#	exists=$( awk -v allele=${allele} '($2==allele){print;exit}' ${dir}/${base}.netMHCpan.AGS.txt | wc -l )
#
##	the allele in the output file isn't the same as the allele given!!!!!
#
#	if [ $exists == 0 ] ; then
#		echo "Running"
#		~/.local/netMHCpan-4.1/netMHCpan -f ${fasta} \
#			-l ${l} -a ${allele} \
#			| grep " <= SB" \
#			>> ${dir}/${base}.netMHCpan.AGS.txt
#	else
#		echo "Exists. Skipping."
#	fi

done
chmod -w ${dir}/${base}.netMHCpan.AGS.txt

echo "Done"

