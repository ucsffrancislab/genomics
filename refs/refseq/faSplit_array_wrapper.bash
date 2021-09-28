#!/usr/bin/env bash

dir="/francislab/data1/refs/refseq/complete-20210920"
page=1

while [ $# -gt 0 ] ; do
	case $1 in
		-p|--page)
			shift; page=$1; shift;;
		-d|--dir)
			shift; dir=$1; shift;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

offset=$(((page-1)*1000 ))
line=$((SLURM_ARRAY_TASK_ID+offset))

#	Use a 1 based index since there is no line 0.

f=$( sed -n "$line"p ${dir}/complete.genomic.fna.filelist.txt )

touch ${dir}/${f}.faSplit.txt

echo faSplit byname ${dir}/${f} ${dir}/split/

faSplit byname ${dir}/${f} ${dir}/split/


