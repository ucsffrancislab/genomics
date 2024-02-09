#!/usr/bin/env bash

#	module load WitteLab python3/3.9.1 

set -u

k=$1

mkdir tf/${k}

join -1 2 -2 1 <( sort -k2,2 ${PWD}/out/${k}/create_matrix.tsv)  <( sort -k1,1 ${PWD}/train_ids.tsv ${PWD}/test_ids.tsv )| awk 'BEGIN{OFS="\t"}{print $2,$1,$4}' > tf/${k}/create_matrix.tsv


img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

export SINGULARITY_BINDPATH=/francislab
export APPTAINER_BINDPATH=/francislab
export OMP_NUM_THREADS=64
export IMOKA_MAX_MEM_GB=440


#	prep to dump
singularity exec ${img} iMOKA_core create -i ${PWD}/tf/${k}/create_matrix.tsv -o ${PWD}/tf/${k}/create_matrix.json

#	dump rescaled kmers to be used in the zscore algorithm
singularity exec ${img} iMOKA_core dump -i ${PWD}/tf/${k}/create_matrix.json -o ${PWD}/tf/${k}/kmers.rescaled.tsv

gzip ${PWD}/tf/${k}/kmers.rescaled.tsv



#	./tf.py
