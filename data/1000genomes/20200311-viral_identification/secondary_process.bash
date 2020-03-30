#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2
DIAMOND=${REFS}/diamond

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
threads=8
vmem=8

date=$( date "+%Y%m%d%H%M%S" )


outdir=/francislab/data1/working/1000genomes/20200311-viral_identification/secondary
mkdir -p ${outdir}

for bam in /francislab/data1/raw/1000genomes/unmapped/*.unmapped.*.bam ; do

	echo $bam

	jobbase=${bam%%.*}
	jobbase=$( basename $jobbase )
	echo $jobbase

	base=${outdir}/${jobbase}
	echo $base

	outbase="${base}.unmapped"
	unmappedid=''
	f=${outbase}.fasta.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		unmappedid=$( qsub -N ${jobbase}.un \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			~/.local/bin/samtools.bash -F \
				"fasta -f 4 --threads $[threads-1] -N -o ${outbase}.fasta.gz ${bam}" )
		echo "${unmappedid}"
	fi
	infasta=${f}

	for ref in NC_001348 NC_001716  ; do

		#outbase=${base}.${ref}
		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		vmem=8

		for ali in e2e loc ; do

			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac

			outbase="${base}.unmapped.${ref}.bowtie2-${ali}"
			bowtie2id=""
			f=${outbase}.bam
			unsortedbam=${f}
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${unmappedid} ] ; then
					depend="-W depend=afterok:${unmappedid}"
				else
					depend=""
				fi
				bowtie2id=$( qsub ${depend} -N ${jobbase}.${ref:5:4}.b${ali} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
					~/.local/bin/bowtie2.bash \
					-F "-f --xeq --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} --no-unal \
							--rg-id ${jobbase}.${ali} --rg "SM:${jobbase}" -U ${infasta} \
							--sort -o ${outbase}.bam" )
				echo "${bowtie2id}"
			fi

		done	#	for ali in e2e loc

	done	#	for ref in NC_001348 NC_001716  ; do

done	#	for bam in /francislab/data1/raw/1000genomes/unmapped/*.unmapped.*.bam ; do


