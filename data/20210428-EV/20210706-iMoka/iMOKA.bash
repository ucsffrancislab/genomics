#!/usr/bin/env bash


date=$( date "+%Y%m%d%H%M%S" )


# k=35 
#==> 31/iMOKA.reduce.20210709083723.txt <==
#Memory occupied: 3.387Mb.
#Memory occupied: 3.559Mb.
#Reducing with 16 threads, each analysing a maximum total of 288230376151711744 k-mers.
#
#==> 33/iMOKA.reduce.20210709083650.txt <==
#Memory occupied: 3.391Mb.
#Memory occupied: 3.559Mb.
#Reducing with 16 threads, each analysing a maximum total of 4611686018427387904 k-mers.
#
#==> 35/iMOKA.reduce.20210709085051.txt <==
#Memory occupied: 3.387Mb.
#Memory occupied: 3.555Mb.
#Reducing with 16 threads, each analysing a maximum total of 0 k-mers.
#
#	Perhaps 35 caused an overflow?
#
k=33


#	31 288230376151711744
#	*4*4
#	33 4611686018427387904
#	*4*4
#	35 73786976294838206464



threads=32
mem=7		#	per thread (keep 7)
kdir=${PWD}/${k}

img=/francislab/data2/refs/singularity/iMOKA-1.0.img
#1.1 versions fail to create any tsv.sorted.bin files in preprocessing
#It also says "stdtr domain error" a lot???

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=${threads}

#	Still not clear on the memory settings. Too high and it uses swap for some reason. Too low and it takes longer.
#	Singularity takes space
#	threads*mem is too high.
#	perhaps threads*(mem-1)
#export IMOKA_MAX_MEM_GB=${mem}
#export IMOKA_MAX_MEM_GB=$((4*mem))
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))
export sbatch_mem=$((threads*mem+4))G


#The aggregate step always says that it can't find the matrix, but works.
#	setting SINGULARITY_BINDPATH instead of passing --bind seems to remedy?


#mkdir ${kdir}; cd ${kdir}
#
#ppid=$( ${sbatch} --export=SINGULARITY_BINDPATH --parsable --job-name=${k}iMOKApreprocess --time=60 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.preprocess.${date}.txt --wrap="singularity exec ${img} preprocess.sh --keep-files --input-file /francislab/data1/working/20210428-EV/20210706-iMoka/source.tsv --kmer-length ${k} --ram $((threads*mem)) --threads ${threads}" )
#
#crid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --dependency=afterok:${ppid} --job-name=${k}iMOKAcreate --time=60 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.create.${date}.txt --wrap="singularity exec ${img} iMOKA_core create --input ${kdir}/create_matrix.tsv --output ${kdir}/matrix.json" )
#
#rdid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --dependency=afterok:${crid} --job-name=${k}iMOKAreduce --time=5760 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.reduce.${date}.txt --wrap="singularity exec ${img} iMOKA_core reduce --input ${kdir}/matrix.json --output ${kdir}/reduced.matrix" )
##rdid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --job-name=${k}iMOKAreduce --time=5760 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.reduce.${date}.txt --wrap="singularity exec ${img} iMOKA_core reduce --input ${kdir}/matrix.json --output ${kdir}/reduced.matrix" )
#
#agid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --dependency=afterok:${rdid} --job-name=${k}iMOKAaggregate --time=60 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.aggregate.${date}.txt --wrap="singularity exec ${img} iMOKA_core aggregate --input ${kdir}/reduced.matrix --count-matrix ${kdir}/matrix.json --output ${kdir}/aggregated" )
#
#${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --job-name=${k}iMOKAforest --dependency=afterok:${agid} --time=1440 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.random_forest.${date}.txt --wrap="singularity exec ${img} random_forest.py --threads ${threads} ${kdir}/aggregated.kmers.matrix ${kdir}/output"
${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --job-name=${k}iMOKAforest --time=1440 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.random_forest.${date}.txt --wrap="singularity exec ${img} random_forest.py --threads ${threads} ${kdir}/aggregated.kmers.matrix ${kdir}/output"

