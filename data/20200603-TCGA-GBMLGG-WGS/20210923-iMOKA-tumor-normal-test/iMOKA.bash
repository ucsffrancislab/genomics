#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

subset=''
#subset='cutadapt2.lte30.'
#subset='cutadapt2.'
#subset='cutadapt2.lex.'

field=""
#field=".IDH"
#field=".Astro"
#field=".Oligo"
#field=".GBMWT"
#field=".GBMmut"
#field=".noOligo"

k=30
threads=32	#32 # 64

while [ $# -gt 0 ] ; do
	case $1 in
		-s|--subset)
			shift; subset=$1; shift;;
		-f|--field)
			shift; field=$1; shift;;
		-@|--threads)
			shift; threads=$1; shift;;
		-k)
			shift; k=$1; shift;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

mem=7		#	per thread (keep 7)
kdir=${PWD}/${subset}${k}${field}

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.6.img

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "
export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=${threads}

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
#cp ${PWD}/source.tsv ${kdir}/
#cp ${PWD}/raw${subset}.source${field}.tsv ${kdir}/source.tsv
cp ${PWD}/${subset}source${field}.tsv ${kdir}/source.tsv
cp ${PWD}/config.json ${kdir}/
cd ${kdir}	# preprocess creates a dir "preprocess" in working dir


ppid=''
if [ -d "${kdir}/preprocess" ] ; then
	echo "Preprocessing dir exists. Skipping"
else
	ppid=$( ${sbatch} --export=SINGULARITY_BINDPATH --parsable --job-name=T${k}iMOKApreprocess --time=2880 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.preprocess.${date}.txt --wrap="singularity exec ${img} preprocess.sh --input-file ${kdir}/source.tsv --kmer-length ${k} --ram $((threads*mem)) --threads ${threads} --keep-files" )
	echo $ppid
fi


crid=''
if [ -f "${kdir}/matrix.json" ] ; then
	echo "Matrix created. Skipping"
else
	if [ -z ${ppid} ] ; then
		depend=""
	else
		depend=" --dependency=afterok:${ppid} "
	fi
	#	this really only takes a minute or so. Doesn't really need much time, memory or cpu
	crid=$( ${sbatch} ${depend} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --job-name=T${k}iMOKAcreate --time=60 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.create.${date}.txt --wrap="singularity exec ${img} iMOKA_core create --input ${kdir}/create_matrix.tsv --output ${kdir}/matrix.json" )
	echo ${crid}
fi


rdid=''
if [ -f "${kdir}/reduced.matrix.json" ] ; then
	echo "Matrix reduced. Skipping"
else
	if [ -z ${crid} ] ; then
		depend=""
	else
		depend=" --dependency=afterok:${crid} "
	fi
	rdid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable ${depend} --job-name=T${k}iMOKAreduce --time=5760 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.reduce.${date}.txt --wrap="singularity exec ${img} iMOKA_core reduce --input ${kdir}/matrix.json --output ${kdir}/reduced.matrix" )
	#rdid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --job-name=T${k}iMOKAreduce --time=5760 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.reduce.${date}.txt --wrap="singularity exec ${img} iMOKA_core reduce --input ${kdir}/matrix.json --output ${kdir}/reduced.matrix" )
	echo ${rdid}
fi

agid=''
if [ -f "${kdir}/aggregated.json" ] ; then
	echo "Matrix aggregated. Skipping"
else
	if [ -z ${rdid} ] ; then
		depend=""
	else
		depend=" --dependency=afterok:${rdid} "
	fi
	agid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable ${depend} --job-name=T${k}iMOKAaggregate --time=2880 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.aggregate.${date}.txt --wrap="singularity exec ${img} iMOKA_core aggregate --input ${kdir}/reduced.matrix --count-matrix ${kdir}/matrix.json --mapper-config ${kdir}/config.json --output ${kdir}/aggregated" )
	#	--shift 4
	#agid=$( ${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --parsable --job-name=T${k}iMOKAaggregate --time=120 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.aggregate.${date}.txt --wrap="singularity exec ${img} iMOKA_core aggregate --input ${kdir}/reduced.matrix --count-matrix ${kdir}/matrix.json --mapper-config ${kdir}/config.json --output ${kdir}/aggregated" )
	echo ${agid}
fi


if [ -f "${kdir}/output.json" ] ; then
	echo "Random forest run. Skipping"
else
	if [ -z ${agid} ] ; then
		depend=""
	else
		depend=" --dependency=afterok:${agid} "
	fi
	${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --job-name=T${k}iMOKAforest ${depend} --time=2880 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.random_forest.${date}.txt --wrap="singularity exec ${img} random_forest.py --threads ${threads} -r 50 ${kdir}/aggregated.kmers.matrix ${kdir}/output"
	#	#${sbatch} --export=SINGULARITY_BINDPATH,OMP_NUM_THREADS,IMOKA_MAX_MEM_GB --job-name=T${k}iMOKAforest --time=2880 --ntasks=${threads} --mem=${sbatch_mem} --output=${kdir}/iMOKA.random_forest.${date}.txt --wrap="singularity exec ${img} random_forest.py --threads ${threads} -r 50 ${kdir}/aggregated.kmers.matrix ${kdir}/output"
fi


