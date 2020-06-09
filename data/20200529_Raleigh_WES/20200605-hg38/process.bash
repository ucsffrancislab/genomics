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
vmem=64

date=$( date "+%Y%m%d%H%M%S" )

INDIR="/francislab/data1/working/20200529_Raleigh_WES/20200604-prepare/trimmed/length"
OUTDIR="/francislab/data1/working/20200529_Raleigh_WES/20200605-hg38/out"
mkdir -p ${OUTDIR}

#	NEED FULL PATH HERE ON THE CLUSTER

for r1 in ${INDIR}/*_R1.fastq.gz ; do
	echo ${r1}

	r2=${r1/R1/R2}
	echo ${r2}

	base=${OUTDIR}/$( basename $r1 _R1.fastq.gz )
	echo ${base}

	jobbase=$( basename ${base} )
	echo ${jobbase}

	for ref in h38au  ; do

		outbase=${base}.${ref}
		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		#vmem=8
		#	with the --sort option, needs much more memory.

		for ali in e2e ; do

			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac

			outbase="${base}.${ref}.bowtie2-${ali}"
			bowtie2id=""
			f=${outbase}.bam
			bowtie2bam=${f}
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				#	gres=scratch should be about total needed divided by num threads
					#~/.local/bin/bowtie2_scratch.bash \
				bowtie2id=$( qsub -N ${jobbase}.${ref}.bt${ali} \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:100 \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/bowtie2_scratch.bash \
					-F "--threads ${threads} ${opt} -x ${BOWTIE2}/${ref} --sort \
							--rg-id ${jobbase} --rg "SM:${jobbase}" -1 ${r1} -2 ${r2} -o ${outbase}.bam" )
				echo "${bowtie2id}"
			fi

			outbase="${base}.${ref}.bowtie2-${ali}.PP"
			ppid=""
			f=${outbase}.bam
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${bowtie2id} ] ; then
					depend="-W depend=afterok:${bowtie2id}"
				else
					depend=""
				fi
				ppid=$( qsub ${depend} -N ${jobbase}.${ref}.PP \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:50 \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/samtools_view_scratch.bash \
					-F "-f2 --threads ${threads} -o ${f} ${bowtie2bam}" )
				echo "${ppid}"
			fi


#			outbase="${base}.${ref}.bowtie2-${ali}.PP"
#			pileupid=""
#			f=${outbase}.bcf.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${ppid} ] ; then
#					depend="-W depend=afterok:${ppid}"
#				else
#					depend=""
#				fi
#				pileupid=$( qsub ${depend} -N ${jobbase}.${ref}.pileup \
#					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:50 \
#					-j oe -o ${outbase}.pileup.${date}.out.txt \
#					~/.local/bin/bcftools_scratch.bash \
#					-F "mpileup --output-type b --output ${f} \
#						--fasta-ref /francislab/data1/refs/fasta/${ref}.fa \
#						--threads ${threads} ${outbase}.bam" )
#				echo "${pileupid}"
#			fi
#
#			outbase="${base}.${ref}.bowtie2-${ali}.PP"
#			callid=""
#			f=${outbase}.vcf.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${pileupid} ] ; then
#					depend="-W depend=afterok:${pileupid}"
#				else
#					depend=""
#				fi
#				callid=$( qsub ${depend} -N ${jobbase}.${ref}.call \
#					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb -l gres=scratch:50 \
#					-j oe -o ${outbase}.call.${date}.out.txt \
#					~/.local/bin/bcftools_scratch.bash \
#					-F "call --multiallelic-caller --variants-only --threads ${threads} \
#						--output-type z -o ${f} ${outbase}.bcf.gz" )
#				echo "${callid}"
#			fi

#	bcftools annotate -a /raid/refs/vcf/gnomad.genomes.r2.0.2.sites.liftover.b38/gnomad.genomes.r2.0.2.sites.chr${chr}.liftover.b38.vcf.gz --columns ID,GNOMAD_AC:=    AC,GNOMAD_AN:=AN,GNOMAD_AF:=AF --output-type z \
#   --output $f ${sample}.recaled.${chr}.mpileup.MQ60.call.SNP.DP200.vcf.gz


#	Not sure if needed to make own vcfs

#	strelka






		done	#	for ali in

	done	#	for ref in

done	#	for r1 in
