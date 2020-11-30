#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x

#	remember 64 cores and ~504GB mem
threads=8
vmem=62
#threads=16
#vmem=125


date=$( date "+%Y%m%d%H%M%S" )



basedir="/francislab/data1/raw/20201006-GTEx"
fastq="${basedir}/fastq"
mkdir -p ${fastq}

cd ${basedir}/data

while read -r accession ; do

	echo $accession

	outbase="${fastq}/${accession}"
	f=${outbase}_R1.fastq.gz

	#f=${fastq}/${accession}_R1.fastq.gz

	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		#	use an accession number rather that an sra file name.
		#	SRA filename will result in the fastq having the same long name.
		#	Using that accession will result in the fastq files just having the accession base
		#fastq-dump --split-e --ngc ${basedir}/prj_20942_D10852.ngc --outdir ${fastq} ${accession}
		#rename _ _R ${fastq}/${accession}_?.fastq
		##gzip ${fastq}/${accession}_R?.fastq
		##chmod a-w ${fastq}/${accession}_R?.fastq.gz
		#chmod a-w ${fastq}/${accession}_R?.fastq
		#gzip ${fastq}/${accession}_R?.fastq &

		qsub -N ${accession} \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.fastq-dump.${date}.out.txt \
			${basedir}/fastq-dump-ind.bash \
				-F "${accession}"

	fi

	#	fastq-dump is a bit like prefetch
	#	It needs the dependency data files. If they aren't in the accession dir
	#	they will download them to the current_dir/accession.
	#	By specifying the outdir, the sra file, dependencies and fastq end up together.
	
	#	Note that prefetch will put the requested sra file in the "output-directory", 
	#	it will put the dependency data in the current directory. 
	#	I found it best to be in the desired output-directory and not specify.
	#	This way both the desired data and its dependenies are together.
	#	Sadly many files have the same dependencies resulting in a lot 
	#	of redundant dependency data.

#done < ${basedir}/PairedBrainRNASRAAccessions.txt
done < <( head -n 1300 ${basedir}/PairedBrainRNASRAAccessions.txt )
#done < <( head -n 702 ${basedir}/PairedBrainRNASRAAccessions.txt | tail -n 98)
#done < <( head -n 600 ${basedir}/tmp )

