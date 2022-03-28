#!/usr/bin/env bash

SALMON="/francislab/data1/refs/salmon"
INDIR="/francislab/data1/working/20191008_Stanford71/20210326-preprocessing/output"
DIR="/francislab/data1/working/20191008_Stanford71/20210413-REdiscoverTE/out"

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --parsable "
date=$( date "+%Y%m%d%H%M%S" )

mkdir -p ${DIR}

for raw in ${INDIR}/??.bbduk?.unpaired.fastq.gz ; do

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


	#	OUT OF MEMORY FAILURE - upped from 8/60 to 16/110
	#	19.bbduk1k15, 20.bbduk1k15, 23.bbduk1k15, 73.bbduk1k15, 68.bbduk1k15, 66.bbduk1k15, ...

	#	TIMEOUT - upped from 99 to 999
	#	70.bbduk2k31, 62.bbduk2k15, 61.bbduk2k31, 61.bbduk3k15, 59.bbduk3k15, 52.bbduk3k31, ...

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

		threads=16
		mem=110

		#	infile won't exist immediately so reference raw file
		infile_size=$( stat --dereference --format %s ${raw} )
		index=${SALMON}/REdiscoverTE.k15
		index_size=$( du -sb ${index} | awk '{print $1}' )
	
		#scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
		scratch=$( echo $(( (((3*${infile_size})+${index_size})/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output
	
		echo "Using scratch:${scratch}"
	
		${sbatch} ${depend} --mem=${mem}G --job-name=${basename}k15 --ntasks=${threads} --time=999 \
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

		threads=16
		mem=110

		#	infile won't exist immediately so reference raw file
		infile_size=$( stat --dereference --format %s ${raw} )
		index=${SALMON}/REdiscoverTE.k31
		index_size=$( du -sb ${index} | awk '{print $1}' )

		#scratch=$( echo $(( (((3*${infile_size})+${index_size})/${threads}/1000000000*12/10)+1 )) )
		scratch=$( echo $(( (((3*${infile_size})+${index_size})/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output
	
		echo "Using scratch:${scratch}"
	
		${sbatch} ${depend} --mem=${mem}G --job-name=${basename}k31 --ntasks=${threads} --time=999 \
			--gres=scratch:${scratch}G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/salmon_scratch.bash quant --seqBias --gcBias --index ${index} \
				--libType A --unmatedReads ${infile} --validateMappings \
				-o ${out_base} --threads ${threads}
	fi



done


exit


INDIR="${PWD}/out"
sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "
date=$( date "+%Y%m%d%H%M%S" )
for k in 15 31 ; do for bbduk in 1 2 3 ; do
echo "bbduk${bbduk}.k${k}"
OUTDIR="${PWD}/rollup.bbduk${bbduk}.k${k}"
mkdir ${OUTDIR}
echo -e "sample\tquant_sf_path" > ${OUTDIR}/REdiscoverTE.tsv
ls -1 ${INDIR}/??.bbduk${bbduk}.salmon.REdiscoverTE.k${k}/quant.sf | awk -F/ '{split($8,a,".");print a[1]"\t"$0}' >> ${OUTDIR}/REdiscoverTE.tsv

echo ${sbatch} --job-name=bbduk${bbduk}.k${k}.rollup --time=999 --ntasks=64 --mem=495G \
	--output=${OUTDIR}/rollup.${date}.txt \
	--wrap "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${OUTDIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${OUTDIR}/rollup/"
done ; done

		
#		echo "/francislab/data1/refs/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/francislab/data1/refs/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup.out.txt
#		
#		
#		echo "~/github/ucsffrancislab/REdiscoverTE/rollup.R --metadata=${DIR}/REdiscoverTE.tsv --datadir=/home/gwendt/github/ucsffrancislab/REdiscoverTE/original/REdiscoverTE/rollup_annotation/ --nozero --threads=64 --assembly=hg38 --outdir=${DIR}/REdiscoverTE_rollup_repFamily/" | qsub -l vmem=500gb -N rollup -l nodes=1:ppn=64 -j oe -o ${DIR}/REdiscoverTE_rollup_repFamily.out.txt
#		
#		
