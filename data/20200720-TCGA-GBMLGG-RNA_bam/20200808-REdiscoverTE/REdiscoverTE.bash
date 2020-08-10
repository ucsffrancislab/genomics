#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out"
DIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200808-REdiscoverTE/out"
mkdir -p ${DIR}

date=$( date "+%Y%m%d%H%M%S" )

for r1 in ${INDIR}/02*_R1.fastq.gz ; do

	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.salmon.REdiscoverTE"
	f=${outbase}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -l vmem=62gb -N R${base}.salmon \
			-l feature=nocommunal \
			-l nodes=1:ppn=8 \
			-l gres=scratch:10 \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/salmon_scratch.bash \
			-F "quant --seqBias --gcBias --index ${SALMON}/REdiscoverTE \
				--libType A --validateMappings \
				-1 ${r1} -2 ${r2} \
				-o ${outbase} --threads 8"
			#	--unmatedReads ${f} 
	fi

done


exit



DIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200808-REdiscoverTE/out"

echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
ls -1 ${DIR}/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv


echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt


