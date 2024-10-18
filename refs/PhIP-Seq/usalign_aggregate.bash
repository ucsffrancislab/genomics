#!/usr/bin/env bash

#	~/.local/USalign/USalign -outfmt 2 fold_np_040188_model_0.cif fold_tcons_00000820_9_model_0.cif
#	#PDBchain1                     PDBchain2                            TM1     TM2   RMSD   ID1   ID2  IDali L1  L2  Lali
#	fold_np_040188_model_0.cif:A	fold_tcons_00000820_9_model_0.cif:A	0.5543	0.3861	3.28	0.137	0.093	0.217	393	581	249

infile=/francislab/data1/refs/PhIP-Seq/human_herpes_usalign.tsv
pdbs=$( cut -f1 human_herpes_usalign_TEST.tsv | cut -f1 -d: | uniq )


#pdbs=/francislab/data1/refs/PhIP-Seq/human_herpes/*/ranked_0.pdb
#outdir=/francislab/data1/refs/PhIP-Seq/human_herpes_usalign
##mkdir ${outdir}


for b in $pdbs ; do
	bi=${b##*/ranked_}
	bi=${bi%.pdb}
	bj=${b##*human_herpes/}
	bj=${bj%/ranked_?.pdb}
echo -n ",${bj}_${bi}"
done
echo

for a in $pdbs ; do

	ai=${a##*/ranked_}
	ai=${ai%.pdb}

	aj=${a##*human_herpes/}
	aj=${aj%/ranked_?.pdb}

	echo -n "${aj}_${ai}"

#	for b in $pdbs ; do
#
#		bi=${b##*/ranked_}
#		bi=${bi%.pdb}
#
#		bj=${b##*human_herpes/}
#		bj=${bj%/ranked_?.pdb}
#
#		#echo "Compare ${a} ${b}"
#		#echo "${aj}_${ai}-${bj}_${bi}"
#
#		#~/.local/USalign/USalign -a T ${a} ${b} > ${outdir}/${aj}_${ai}-${bj}_${bi}.usalign.log
#
#		#TM-score= 0.48931 (if normalized by average length of two structures: L=56.0, d0=2.48)
#
#		#log=${outdir}/${aj}_${ai}-${bj}_${bi}.usalign.log
#
#		log=${outdir}/${aj}/${bj}/${aj}_${ai}-${bj}_${bi}.usalign.log
#
#		if [ -f ${log} ] ; then
#			tmscore=$( grep "if normalized by average length of two structures:" ${log} | cut -d' ' -f2 )
#		else
#			tmscore=''
#		fi
#
#		echo -n ",${tmscore}"
#	
#	done

echo ; done


exit;




sbatch --export=NONE --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="usalign_aggregate" --output="${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out" --time=14-0 --nodes=1 --ntasks-per-node=4 --ntasks=4 --mem=30G /francislab/data1/refs/PhIP-Seq/usalign_aggregate.bash




