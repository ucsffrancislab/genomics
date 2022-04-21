#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
#export OMP_NUM_THREADS=16
#export IMOKA_MAX_MEM_GB=96
export OMP_NUM_THREADS=64
#export IMOKA_MAX_MEM_GB=490
#export IMOKA_MAX_MEM_GB=420
export IMOKA_MAX_MEM_GB=390

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
basedir=/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA

for k in 11 21 31 ; do
	for subset in 80a 80b 80c ; do
#
#cat IDH.11.80a/matrix.json | jq '.names| length'
#97
#cat IDH.11.80b/matrix.json | jq '.names| length'
#97
#cat IDH.11.80c/matrix.json | jq '.names| length'
#97
#
#cat IDH.11.80a/matrix.json | jq '{count_files: .count_files[0:48], groups: .groups[0:48], k_len: .k_len, names: .names[0:48], prefix_size: .prefix_size[0:48], rescale_factor: .rescale_factor, total_counts: .total_counts[0:48], total_prefix: .total_prefix[0:48], total_suffix: .total_suffix[0:48] }' | jq '.names| length'
#cat IDH.11.80a/matrix.json | jq '{count_files: .count_files[48:97], groups: .groups[48:97], k_len: .k_len, names: .names[48:97], prefix_size: .prefix_size[48:97], rescale_factor: .rescale_factor, total_counts: .total_counts[48:97], total_prefix: .total_prefix[48:97], total_suffix: .total_suffix[48:97] }' | jq '.names| length'
#
		dir=${basedir}/IDH.${k}.${subset}
		echo $k $subset
		#sed -i "s'/[^,]*preprocess'${dir}/preprocess'g" ${dir}/matrix.json 

#	97
		#	The array returned by .[10:15] will be of length 5, containing the elements from index 10 (inclusive) to index 15 (exclusive). 

		cat IDH.${k}.${subset}/matrix.json | jq '{count_files: .count_files[0:25], groups: .groups[0:25], k_len: .k_len, names: .names[0:25], prefix_size: .prefix_size[0:25], rescale_factor: .rescale_factor, total_counts: .total_counts[0:25], total_prefix: .total_prefix[0:25], total_suffix: .total_suffix[0:25] }' > IDH.${k}.${subset}/matrix.a.json

		cat IDH.${k}.${subset}/matrix.json | jq '{count_files: .count_files[25:50], groups: .groups[25:50], k_len: .k_len, names: .names[25:50], prefix_size: .prefix_size[25:50], rescale_factor: .rescale_factor, total_counts: .total_counts[25:50], total_prefix: .total_prefix[25:50], total_suffix: .total_suffix[25:50] }' > IDH.${k}.${subset}/matrix.b.json

		cat IDH.${k}.${subset}/matrix.json | jq '{count_files: .count_files[50:75], groups: .groups[50:75], k_len: .k_len, names: .names[50:75], prefix_size: .prefix_size[50:75], rescale_factor: .rescale_factor, total_counts: .total_counts[50:75], total_prefix: .total_prefix[50:75], total_suffix: .total_suffix[50:75] }' > IDH.${k}.${subset}/matrix.c.json

		cat IDH.${k}.${subset}/matrix.json | jq '{count_files: .count_files[75:97], groups: .groups[75:97], k_len: .k_len, names: .names[75:97], prefix_size: .prefix_size[75:97], rescale_factor: .rescale_factor, total_counts: .total_counts[75:97], total_prefix: .total_prefix[75:97], total_suffix: .total_suffix[75:97] }' > IDH.${k}.${subset}/matrix.d.json

		singularity exec ${img} iMOKA_core extract -s ${dir}/matrix.a.json -i ${dir}/select_kmers.txt -o ${dir}/matrix.a.tsv

		singularity exec ${img} iMOKA_core extract -s ${dir}/matrix.b.json -i ${dir}/select_kmers.txt -o ${dir}/matrix.b.tsv

		singularity exec ${img} iMOKA_core extract -s ${dir}/matrix.c.json -i ${dir}/select_kmers.txt -o ${dir}/matrix.c.tsv

		singularity exec ${img} iMOKA_core extract -s ${dir}/matrix.d.json -i ${dir}/select_kmers.txt -o ${dir}/matrix.d.tsv

done ; done

