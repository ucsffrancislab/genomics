#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20191008_Stanford71/20210326-preprocessing/output"
DIR="/francislab/data1/working/20191008_Stanford71/20210413-REdiscoverTE/out"

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable "
date=$( date "+%Y%m%d%H%M%S" )

mkdir -p ${DIR}

for raw in ${INDIR}/0?.bbduk?.unpaired.fastq.gz ; do

	echo $raw
	basename=$( basename $raw .unpaired.fastq.gz )
	echo $basename

	in_base=${INDIR}/${basename}
	out_base=${DIR}/${basename}
	separate_id=""
	#f=${out_base}.gt31.fastq.gz
	f=${out_base}.lte31.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		separate_id=$( ${sbatch} --job-name=${basename}-sep --time=99 --ntasks=4 --mem=30G \
			--output=${out_base}.separate.${date}.txt \
			${PWD}/fastq_separate_by_length.bash ${raw} )
		echo ${separate_id}
	fi


	in_base=${DIR}/${basename}


	infile=${in_base}.lte31.fastq.gz
	out_base=${in_base}.salmon.REdiscoverTE.k15
	f=${out_base}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${separate_id} ] ; then
			depend="--dependency=afterok:${separate_id}"
		else
			depend=""
		fi

		threads=8

		#	infile won't exist immediately so reference raw file
		infile_size=$( stat --dereference --format %s ${raw} )
		index=${SALMON}/REdiscoverTE.k15
		index_size=$( du -sb ${index} | awk '{print $1}' )
	
		scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output
	
		echo "Using scratch:${scratch}"
	
		${sbatch} ${depend} --mem=64G --job-name=${basename}k15 --ntasks=${threads} --time=99 \
			--gres=scratch:${scratch}G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
				--libType A --unmatedReads ${infile} --validateMappings \
				-o ${out_base} --threads ${threads}
	fi



	infile=${in_base}.gt31.fastq.gz
	out_base=${in_base}.salmon.REdiscoverTE.k31
	f=${out_base}
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${separate_id} ] ; then
			depend="--dependency=afterok:${separate_id}"
		else
			depend=""
		fi

		threads=8

		#	infile won't exist immediately so reference raw file
		infile_size=$( stat --dereference --format %s ${raw} )
		index=${SALMON}/REdiscoverTE.k31
		index_size=$( du -sb ${index} | awk '{print $1}' )
	
		scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output
	
		echo "Using scratch:${scratch}"
	
		${sbatch} ${depend} --mem=64G --job-name=${basename}k31 --ntasks=${threads} --time=99 \
			--gres=scratch:${scratch}G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
				--libType A --unmatedReads ${infile} --validateMappings \
				-o ${out_base} --threads ${threads}
	fi



done


exit



#		DIR="/francislab/data1/working/20191008_Stanford71/20210413-REdiscoverTE/out"
#		
#		echo -e "sample\tquant_sf_path" > ${DIR}/REdiscoverTE.tsv
#		ls -1 ${DIR}/*REdiscoverTE/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${DIR}/REdiscoverTE.tsv
#		
#		echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt
#		
#		
#		echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup_repFamily/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup_repFamily.out.txt
#		
#		
