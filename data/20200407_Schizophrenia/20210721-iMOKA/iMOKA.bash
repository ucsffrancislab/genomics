#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

#subset='.cutadapt2.lte30'
#subset='.cutadapt2'
subset=''

field=""
#field=".IDH"

k=81
threads=64
mem=7		#	per thread (keep 7)
kdir=${PWD}/${k}${subset}${field}

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.3.img

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "
export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=${threads}

#export IMOKA_MAX_MEM_GB=$((threads*(mem-4)))
#export IMOKA_MAX_MEM_GB=$((threads*(mem-3)))
#export IMOKA_MAX_MEM_GB=$((threads*(mem-2)))
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))
echo "IMOKA_MAX_MEM_GB=${IMOKA_MAX_MEM_GB}"
export sbatch_mem=$((threads*mem))G
echo "sbatch_mem=${sbatch_mem}"

#IMOKA_MAX_MEM_GB=192
#IMOKA_MAX_MEM_GB=256
#IMOKA_MAX_MEM_GB=320
#sbatch_mem=452G


#The aggregate step always says that it can't find the matrix, but works.
#	setting SINGULARITY_BINDPATH instead of passing --bind seems to remedy?


mkdir ${kdir}; 
cp ${PWD}/source.tsv ${kdir}/
#cp ${PWD}/raw${subset}.source${field}.tsv ${kdir}/source.tsv
cp ${PWD}/config.json ${kdir}/
cd ${kdir}	# preprocess creates a dir "preprocess" in working dir

ppid=$( ${sbatch} --export=SINGULARITY_BINDPATH --parsable --job-name=S${k}iMOKApreprocess --time=120 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.preprocess.${date}.txt --wrap="singularity exec ${img} preprocess.sh --input-file ${kdir}/source.tsv --kmer-length ${k} --ram $((threads*mem)) --threads ${threads}" )

crid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --dependency=afterok:${ppid} --job-name=S${k}iMOKAcreate --time=120 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.create.${date}.txt --wrap="singularity exec ${img} iMOKA_core create --input ${kdir}/create_matrix.tsv --output ${kdir}/matrix.json" )

rdid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --dependency=afterok:${crid} --job-name=S${k}iMOKAreduce --time=5760 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.reduce.${date}.txt --wrap="singularity exec ${img} iMOKA_core reduce --input ${kdir}/matrix.json --output ${kdir}/reduced.matrix" )
#rdid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --job-name=S${k}iMOKAreduce --time=5760 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.reduce.${date}.txt --wrap="singularity exec ${img} iMOKA_core reduce --input ${kdir}/matrix.json --output ${kdir}/reduced.matrix" )

agid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --dependency=afterok:${rdid} --job-name=S${k}iMOKAaggregate --time=120 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.aggregate.${date}.txt --wrap="singularity exec ${img} iMOKA_core aggregate --input ${kdir}/reduced.matrix --count-matrix ${kdir}/matrix.json --mapper-config ${kdir}/config.json --output ${kdir}/aggregated" )
#agid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --job-name=S${k}iMOKAaggregate --time=120 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.aggregate.${date}.txt --wrap="singularity exec ${img} iMOKA_core aggregate --input ${kdir}/reduced.matrix --count-matrix ${kdir}/matrix.json --mapper-config ${kdir}/config.json --output ${kdir}/aggregated" )

${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --job-name=S${k}iMOKAforest --dependency=afterok:${agid} --time=2880 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.random_forest.${date}.txt --wrap="singularity exec ${img} random_forest.py --threads ${threads} -r 50 ${kdir}/aggregated.kmers.matrix ${kdir}/output"
#${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --job-name=S${k}iMOKAforest --time=2880 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.random_forest.${date}.txt --wrap="singularity exec ${img} random_forest.py --threads ${threads} -r 50 ${kdir}/aggregated.kmers.matrix ${kdir}/output"


