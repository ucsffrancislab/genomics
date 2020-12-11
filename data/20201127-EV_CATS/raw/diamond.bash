#!/usr/bin/env bash



#--masking                enable masking of low complexity regions (0/1=default)



for f in ${PWD}/output/trimmed*q.gz ; do
	base=${f%_001.fastq.gz}
	base=${base/_S?_L001/}
	basename=$(basename $base)
	echo $f
	for m in 0 1 ; do
		echo "diamond blastx --query ${f} --threads 16 --db /francislab/data1/refs/diamond/nr --outfmt 100 --out ${base}.nr.masking${m} --masking ${m}" | qsub -N ${basename}${m} -l nodes=1:ppn=16 -l vmem=125gb -l feature=nocommunal -o ${base}.nr.masking${m}.stdout -e ${base}.nr.masking${m}.stderr

done ; done

