#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
#INDIR="/francislab/data1/raw/20200822-TARGET-RNA_fastq/fastq"
INDIR="/francislab/data1/working/20200822-TARGET-RNA_fastq/20200827-preprocess/trimmed/length"
DIR="/francislab/data1/working/20200822-TARGET-RNA_fastq/20200824-REdiscoverTE/out"
mkdir -p ${DIR}

#	remember 64 cores and ~504GB mem
threads=8
vmem=62

date=$( date "+%Y%m%d%H%M%S" )

for r1 in ${INDIR}/*_R1.fastq.gz ; do

	base=${r1%_R1.fastq.gz}
	r2=${r1/_R1/_R2}

	base=$( basename $r1 _R1.fastq.gz )
	echo $base

	outbase="${DIR}/${base}.salmon.REdiscoverTE"
	f=${outbase}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		index=${SALMON}/REdiscoverTE

		r1_size=$( stat --dereference --format %s ${r1} )
		r2_size=$( stat --dereference --format %s ${r2} )
		index_size=$( du -sb ${index} | awk '{print $1}' )
		scratch=$( echo $(( ((${r1_size}+${r2_size}+${index_size})/${threads}/1000000000*11/10)+1 )) )
		#	Add 1 in case files are small so scratch will be 1 instead of 0.
		#	11/10 adds 10% to account for the output

		echo "Using scratch:${scratch}"

		qsub -l vmem=${vmem}gb -N ${base}.salmon \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} \
			-l gres=scratch:${scratch} \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/salmon_scratch.bash \
			-F "quant --seqBias --gcBias --index ${index} \
				--libType A --validateMappings \
				-1 ${r1} -2 ${r2} \
				-o ${outbase} --threads ${threads}"
			#	--unmatedReads ${f} 
	fi

done


exit



DIR="/francislab/data1/working/20200822-TARGET-RNA_fastq/20200824-REdiscoverTE/out"

echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
ls -1 ${DIR}/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv


echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt


