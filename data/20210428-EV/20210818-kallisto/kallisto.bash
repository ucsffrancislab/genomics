#!/usr/bin/env bash

#	zcat /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005*.cutadapt2.fastq.gz | paste - - - - | cut -f 2 | awk '{l=length;sum+=l;sumsq+=(l)^2;print "Avg:",sum/NR,"\tStddev:\t"sqrt((sumsq-sum^2/NR)/NR)}' > avg_length.ssstdev.txt

#	tail -n 1 avg_length.ssstdev.txt
#	Avg: 56.6817 	Stddev:	50.6513

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "

OUT=${PWD}/kallisto
mkdir -p ${OUT}

threads=4
mem=30G
date=$( date "+%Y%m%d%H%M%S" )

for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH005*.cutadapt2.fastq.gz ; do
	#base=${f%cutadapt2.fastq.gz}
	#base=${base/_S?_L001/}
	#base=${base/trimmed_/}
	#basename=$(basename $base)

	basename=$( basename $f .cutadapt2.fastq.gz )
	echo $f
	echo $basename


	# untested skipping k, v, ag and ar

	if [[ "${basename}" =~ ^(SFHH005k|SFHH005v|SFHH005ag|SFHH005ar)$ ]]; then
		echo "Skipping ${basename}"
	else

		${sbatch} --job-name=${basename} --time=60 --ntasks=${threads} --mem=${mem} --output=${OUT}/${basename}.kallisto.${date}.txt \
			~/.local/bin/kallisto.bash quant -b $((10*threads)) --threads ${threads} --single-overhang --single -l 56.6817 -s 50.6513 \
				--index /francislab/data1/refs/kallisto/hrna_15.idx \
				--output-dir ${OUT}/${basename}.hrna_15 ${f}
		#--wrap="singularity exec ${img} random_forest.py --threads ${threads} -r 50 ${kdir}/aggregated.kmers.matrix ${kdir}/output"
	fi

done


#	Sleuth ....


