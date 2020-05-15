#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
DIR="/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200320-viral_expression/trimmed"

for f in ${DIR}/???.fastq.gz ; do

	echo $f

	base=${f%.fastq.gz}
	echo $base

#	for k in 21 31 ; do
#
#		echo "salmon quant --index ${SALMON}/RepeatDatabase_${k} --libType A --unmatedReads ${f} --validateMappings -o ${base}.salmon.RepeatDatabase_${k} --threads 8" | qsub -l vmem=16gb -N $(basename $f .fastq.gz)_${k} -l nodes=1:ppn=8 -j oe -o ${base}.salmon.RepeatDatabase_${k}.out.txt
#
#	done



#	$(SALMON_0.8.2_EXE)  quant  --seqBias  --gcBias  -i $(SALMON_INDEX_DIR)  -l 'A'  $(FASTQ_INPUT_ARGS)  -o $(SALMON_COUNTS_DIR)

	echo "~/.local/bin/salmon.bash quant --seqBias --gcBias --index ${SALMON}/REdiscoverTE --libType A --unmatedReads ${f} --validateMappings -o ${base}.salmon.REdiscoverTE --threads 8" | qsub -l vmem=64gb -N $(basename $f .fastq.gz) -l nodes=1:ppn=8 -j oe -o ${base}.salmon.REdiscoverTE.out.txt

done


exit


DIR="/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200320-viral_expression"
echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
ls -1 ${DIR}/trimmed/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv

echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=8 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt


