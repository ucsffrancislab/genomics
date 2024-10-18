#!/usr/bin/env bash

pdbs=/francislab/data1/refs/PhIP-Seq/human_herpes/*/ranked_?.pdb
#outdir=/francislab/data1/refs/PhIP-Seq/human_herpes_usalign
#mkdir ${outdir}

out=/francislab/data1/refs/PhIP-Seq/human_herpes_usalign.tsv

for a in $pdbs ; do
	for b in $pdbs ; do
	
		echo "Compare ${a} ${b}"
		~/.local/USalign/USalign -outfmt 2 ${a} ${b} | tail -n +2 >> ${out}

#		ai=${a##*/ranked_}
#		ai=${ai%.pdb}
#		
#		aj=${a##*human_herpes/}
#		aj=${aj%/ranked_?.pdb}
#		
#		bi=${b##*/ranked_}
#		bi=${bi%.pdb}
#		
#		bj=${b##*human_herpes/}
#		bj=${bj%/ranked_?.pdb}

#		echo "${aj}_${ai}-${bj}_${bi}"
#		
#		#log=${outdir}/${aj}_${ai}-${bj}_${bi}.usalign.log
#
#		#	Just too many files ending up in the same directory.
#
#		mkdir -p ${outdir}/${aj}/${bj}
#		log=${outdir}/${aj}/${bj}/${aj}_${ai}-${bj}_${bi}.usalign.log
#
#		if [ -f ${log} ] ; then
#			echo "${log} exists"
#			echo "Skipping"
#		else
#			~/.local/USalign/USalign -a T ${a} ${b} > ${log}
#		fi

done ; done


exit;



sbatch --export=NONE --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="usalign" --output="${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out" --time=14-0 --nodes=1 --ntasks-per-node=2 --ntasks=2 --mem=15G /francislab/data1/refs/PhIP-Seq/usalign.bash


