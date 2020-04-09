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
		#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
		unmappedid=$( qsub -N ${jobbase}.un \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/samtools.bash -F \
				"fasta -f 4 --threads $[threads-1] -N -o ${outbase}.fasta.gz ${bam}" )
		echo "${unmappedid}"
	fi
	infasta=${f}


#	Align to hg38

#	Extract unaligned

#	Align unaligned to viral selection








#	#	for ref in NC_001348 NC_001716 NC_001348.masked NC_001716.masked ; do
#
#	for ref in hg38 NC_000898.masked NC_000898 NC_001348.masked NC_001348 NC_001664.masked NC_001664 NC_001716.masked NC_001716 NC_007605.masked NC_007605 NC_009333.masked NC_009333 NC_009334.masked NC_009334 ; do
#
#		for ali in e2e loc ; do
#
#			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac
#
#			outbase="${base}.unmapped.${ref}.bowtie2-${ali}"
#			bowtie2id=""
#			f=${outbase}.bam
#			unsortedbam=${f}
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${unmappedid} ] ; then
#					depend="-W depend=afterok:${unmappedid}"
#				else
#					depend=""
#				fi
#				#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
#				bowtie2id=$( qsub ${depend} -N ${jobbase}.${ref:5:4}.b${ali} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#					-j oe -o ${outbase}.${date}.out.txt \
#					~/.local/bin/bowtie2.bash \
#					-F "-f --xeq --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} --no-unal \
#							--rg-id ${jobbase}.${ali} --rg "SM:${jobbase}" -U ${infasta} \
#							--sort -o ${outbase}.bam" )
#				echo "${bowtie2id}"
#			fi
#
#		done	#	for ali in e2e loc
#
#	done	#	for ref in NC_001348 NC_001716  ; do





#
#	outbase="${base}.unmapped"
#
#	if [ ! -z ${unmappedid} ] ; then
#		depend="-W depend=afterok:${unmappedid}"
#	else
#		depend=""
#	fi
##			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac
##	-o "${base}.unmapped.${ref}.bowtie2-${ali}.bam"
##				--rg-id ${jobbase}.${ali} --rg SM:${jobbase} \
#	qsub ${depend} -N ${jobbase}.bowtie -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#		-j oe -o ${outbase}.${date}.out.txt \
#		~/.local/bin/bowtie2many.bash \
#		-F "-f -U ${infasta} --xeq --threads ${threads} --no-unal \
#				--outbase "${outbase}" \
#				--rgbase ${jobbase} \
#				--sort \
#				--refs hg38,NC_000898.masked,NC_000898,NC_001348.masked,NC_001348,NC_001664.masked,NC_001664,NC_001716.masked,NC_001716,NC_007605.masked,NC_007605,NC_009333.masked,NC_009333,NC_009334.masked,NC_009334"
#



done	#	for bam in /francislab/data1/raw/1000genomes/unmapped/*.unmapped.*.bam ; do



#	No file to check at this level so comment out when done.
#
#for ref in hg38 NC_000898.masked NC_000898 NC_001348.masked NC_001348 NC_001664.masked NC_001664 NC_001716.masked NC_001716 NC_007605.masked NC_007605 NC_009333.masked NC_009333 NC_009334.masked NC_009334 ; do
##for ref in NC_000898.masked NC_000898 NC_001348.masked NC_001348 NC_001664.masked NC_001664 NC_001716.masked NC_001716 NC_007605.masked NC_007605 NC_009333.masked NC_009333 NC_009334.masked NC_009334 ; do
##for ref in hg38 ; do
#
#	echo $ref
#
#	qsub -N ${ref} -l nodes=1:ppn=8 -l vmem=8gb \
#		-j oe -o ${outdir}/bowtie2each.${ref}.${date}.out.txt \
#		~/.local/bin/bowtie2each.bash \
#		-F "-f --xeq --threads ${threads} --no-unal -x ${BOWTIE2}/${ref} \
#				--dir ${outdir} --suffix .unmapped --extension .fasta.gz --sort"
#
#done

#
#for ref in NC_000898.masked NC_000898 NC_001348.masked NC_001348 NC_001664.masked NC_001664 NC_001716.masked NC_001716 NC_007605.masked NC_007605 NC_009333.masked NC_009333 NC_009334.masked NC_009334 ; do
#
#	echo $ref
#
#	qsub -N ${ref} -l nodes=1:ppn=8 -l vmem=8gb \
#		-j oe -o ${outdir}/bowtie2each.${ref}.${date}.out.txt \
#		~/.local/bin/bowtie2each.bash \
#		-F "-f --xeq --threads ${threads} --no-unal -x ${BOWTIE2}/${ref} \
#				--dir ${outdir} --suffix .unmapped.hg38.unmapped --extension .fasta.gz --sort"
#
#done
#





