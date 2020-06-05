#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20200529_Raleigh_WES/20200604-prepare/trimmed/length"
DIR="/francislab/data1/working/20200529_Raleigh_WES/20200604-REdiscoverTE/out"

for r1 in ${INDIR}/*_R1.fastq.gz ; do

	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	qsub -l vmem=64gb -N ${base} \
		-l nodes=1:ppn=8 \
		-j oe -o ${DIR}/${base}.salmon.REdiscoverTE.out.txt \
		~/.local/bin/salmon.bash \
		-F "quant --seqBias --gcBias --index ${SALMON}/REdiscoverTE \
			--libType A --validateMappings \
			-1 ${r1} -2 ${r2} \
			-o ${DIR}/${base}.salmon.REdiscoverTE --threads 8"
		#	--unmatedReads ${f} 

done


exit



DIR="/francislab/data1/working/20200529_Raleigh_WES/20200604-REdiscoverTE/out"

echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
ls -1 ${DIR}/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv


echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=450gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt



echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup_repFamily/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup_repFamily.out.txt

