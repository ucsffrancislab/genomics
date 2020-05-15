#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
DIR="/francislab/data1/working/20200430_Raleigh_RNASeq/20200515_REdiscoverTE"



for f in ${DIR}/trimmed/*.fastq.gz ; do

	echo $f

	base=${f%.fastq.gz}
	echo $base

	echo "~/.local/bin/salmon.bash quant --seqBias --gcBias --index ${SALMON}/REdiscoverTE --libType A --unmatedReads ${f} --validateMappings -o ${base}.salmon.REdiscoverTE --threads 8" | qsub -l vmem=64gb -N $(basename $f .fastq.gz) -l nodes=1:ppn=8 -j oe -o ${base}.salmon.REdiscoverTE.out.txt

done


exit


DIR="/francislab/data1/working/20200430_Raleigh_RNASeq/20200515_REdiscoverTE"

echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
ls -1 ${DIR}/trimmed/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv

echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=8 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt


