#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20191008_Stanford71/20210326-preprocessing/output"
DIR="/francislab/data1/working/20191008_Stanford71/20210413-REdiscoverTE/out"

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable "
date=$( date "+%Y%m%d%H%M%S" )

mkdir -p ${DIR}

for f in ${INDIR}/??.bbduk?.unpaired.fastq.gz ; do

	echo $f
	base=$( basename $f .unpaired.fastq.gz )
	echo $base

	threads=8

	${sbatch} --mem=64G --job-name=${base} --ntasks=${threads} --time=999 \
		--output=${DIR}/${base}.salmon.REdiscoverTE.${date}.txt \
		~/.local/bin/salmon.bash quant --seqBias --gcBias --index ${SALMON}/REdiscoverTE \
			--libType A --unmatedReads ${f} --validateMappings \
			-o ${DIR}/${base}.salmon.REdiscoverTE --threads ${threads}

done


exit



DIR="/francislab/data1/working/20191008_Stanford71/20210413-REdiscoverTE/out"

echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
ls -1 ${DIR}/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv

echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt


echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup_repFamily/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup_repFamily.out.txt


