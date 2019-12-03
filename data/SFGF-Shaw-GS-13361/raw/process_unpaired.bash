#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


KALLISTO=/data/shared/francislab/refs/kallisto
SUBREAD=/data/shared/francislab/refs/subread
BOWTIE2=/data/shared/francislab/refs/bowtie2
BLASTDB=/data/shared/francislab/refs/blastn

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/data/shared/francislab/refs/bowtie2
#export BLASTDB=/data/shared/francislab/refs/blastn
threads=8

date=$( date "+%Y%m%d%H%M%S" )


#
#	NOTE: This data is a mix of RNA and DNA
#


for r1 in /data/shared/francislab/data/raw/SFGF-Shaw-GS-13361/trimmed/unpaired/01*.fastq.gz ; do

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )

#
#	WAITING UNTIL HAVE THE SPACE
#
#	#	subread references
#	#for ref in h38au h38am h_rna rsg h38_cdna h38_ncrna h38_rna mirna mature hairpin ; do
#	for ref in h38_cdna h38_ncrna h38_rna mirna mature hairpin ; do
#
#	#for ref_path in ${SUBREAD}/*.files ; do
#	#	ref=$( basename $ref_path .files )
#
#		sref=${SUBREAD}/${ref}
#		outbase=${base}.${ref}
#
#		#	subread
#		#  -t <int>          Type of input sequencing data. Its values include
#		#                      0: RNA-seq data
#		#                      1: genomic DNA-seq data.
#
#		vmem=16
#
#		qsub -N ${jobbase}.${ref}.srr -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#			-o ${outbase}.subread.rna.${date}.out.txt -e ${outbase}.subread.rna.${date}.err.txt \
#			~/.local/bin/subread-align.bash \
#			-F "-t 0 -T ${threads} -i ${sref} -r ${r1} -o ${outbase}.subread.rna.bam"
#
#		qsub -N ${jobbase}.${ref}.srd -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#			-o ${outbase}.subread.dna.${date}.out.txt -e ${outbase}.subread.dna.${date}.err.txt \
#			~/.local/bin/subread-align.bash \
#			-F "-t 1 -T ${threads} -i ${sref} -r ${r1} -o ${outbase}.subread.dna.bam"
#
#	done


	#for ref in hg38am hg38au  ; do
	for ref in h38au  ; do

		outbase=${base}.${ref}
		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		vmem=8	

		qoutbase="${outbase}.bowtie2.e2e"
#	dark
		bowtie2id=$( qsub -N ${jobbase}.${ref}.bt -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
			~/.local/bin/bowtie2.bash \
			-F "--xeq --threads ${threads} --very-sensitive -x ${BOWTIE2}/${ref} \
					-U ${r1} -o ${qoutbase}.bam" )
		echo "${bowtie2id}"

		infile="${qoutbase}.bam"
		qoutbase="${qoutbase}.unmapped"
#	dark
		unmappedid=$( qsub -W depend=afterok:${bowtie2id} -N ${jobbase}.${ref}.btun -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
			~/.local/bin/samtools.bash -F "fasta -f 4 --threads $[threads-1] -N -o ${qoutbase}.fasta.gz ${infile}" )
		echo "${unmappedid}"

		#infile=${qoutbase}.fasta
		infile=${qoutbase}.fasta.gz
		qoutbase="${qoutbase}.blastn.nt"	#.txt.gz"

		#	blastn needs fasta NOT fastq or fasta.gz

#	01...fasta has about 2.7 million reads
#	after about 4 hours, only 27,000 had been processed and it was 5GB.
#	it will take about 400 hours to process this whole file and it will be about 2TB!
#	TMI
#	Need to filter and speed up and use less memory
#	add evalue, num_hits or num_descriptions or ...
#	split file into 100 read files

		#	blastn nt NEEDED about 100GB for 01
		qsub -W depend=afterok:${unmappedid} -N ${jobbase}.${ref}.btunnt -l nodes=1:ppn=${threads} -l vmem=128gb \
			-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
			~/.local/bin/blastn.bash -F "-query ${infile} -outfmt 6 -db ${BLASTDB}/nt -num_threads ${threads}"




#		qsub -N ${jobbase}.${ref}.bt -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#			-o ${outbase}.bowtie2.loc.${date}.out.txt -e ${outbase}.bowtie2.loc.${date}.err.txt \
#			~/.local/bin/bowtie2.bash \
#			-F "--xeq --threads ${threads} --very-sensitive-local -x ${BOWTIE2}/${ref} -1 ${r1} -2 ${r2} --no-unal -o ${outbase}.bowtie2.loc.bam"

	done

#
#	WAITING UNTIL HAVE THE SPACE
#
#	for kref in ${KALLISTO}/*idx ; do
#
#		basekref=$( basename $kref .idx )
#
#		case $basekref in
#			rsg)
#				vmem=64;;
#				#vmem=32;;	#	SOME rsg runs fail with bad_alloc so upping to 64GB
#			mi_*|mt_*|hp_*)
#				vmem=8;;
#			*)
#				vmem=16;;
#		esac
#
#		outbase=${base}.${basekref}.kallisto.single
#		qsub -N ${jobbase}.${basekref}.ks -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#			-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
#			~/.local/bin/kallisto.bash \
#			-F "quant -b ${threads}0 --threads ${threads} --pseudobam \
#				--single-overhang --single -l 144.924 -s 20.6833 --index ${kref} \
#				--output-dir ${outbase} ${r1}"
#
#		#	Avg: 144.924 	Stddev:	20.6833
#
#	done












#	#	ftp://mirbase.org/pub/mirbase/CURRENT/hairpin.fa.gz
#	#	ftp://mirbase.org/pub/mirbase/CURRENT/mature.fa.gz
#
#	#for ref in viral.masked hairpin ; do
#	for ref in hairpin ; do
#
#		f=${base}.${ref}.loc.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			#bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -U ${fastq} \
#			bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -1 ${r1} -2 ${r2} \
#				--score-min G,1,7 \
#				--no-unal 2> ${f}.bowtie2.err \
#				| samtools view -o ${f} - #> ${f}.samtools.log 2> ${f}.samtools.err
#			chmod a-w $f

#	done
#
#	for ref in mature mirna ; do
#
#		#	G,20,8 = 20 + 8 * ln(x) where x is ~150 ~> 60
#		#	G,1,8 = 1 + 8 * ln(x) where x is ~150  ~> 40
#		#	G,1,6 = 1 + 6 * ln(x) where x is ~150  ~> 30
#
#		f=${base}.${ref}.loc.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			#bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -U ${fastq} \
#			bowtie2 --xeq --threads 40 --very-sensitive-local -x ${ref} -1 ${r1} -2 ${r2} \
#				--score-min G,1,6 \
#				--no-unal 2> ${f}.bowtie2.err \
#				| samtools view -o ${f} - #> ${f}.samtools.log 2> ${f}.samtools.err
#			chmod a-w $f
#		fi
#
#	done
#
#	f=${base}.fa
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#		#cat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' -e 's/ (.)/\/\1 /'  -e 's/ .*$//' > ${f}
#		cat $r1 $r2 | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' > ${f}
#		#cat $fastq | paste - - - - | cut -f 1,2 | tr '\t' '\n' | sed -E -e 's/^@/>/' > ${f}
#		chmod a-w $f
#	fi
#
#	#for ref in viral.masked hairpin mature ; do
#	for ref in hairpin mature mirna ; do
#
#		f="${base}.${ref}"
#		if [ -e "${f}" ] && [ ! -w "${f}" ] ; then
#			echo "Write protected ${f} exists. Skipping"
#		else
#			echo "Running kallisto"
#
#			kallisto quant -b 40 --threads 40 \
#				--pseudobam \
#				--single-overhang --single -l 146.0 -s 17.6 \
#				--index /raid/refs/kallisto/${ref}.idx \
#				--output-dir ./${f} \
#				${r1} ${r2}
#
#			chmod a-w ${f}
#
#	This was probably wrong, as kallisto status would be from chmod, NOT kallisto
#	Assignment should've been before chmod
#
#			kallistostatus=$?
#
#			if [ $kallistostatus -ne 0 ] ; then
#				echo "Kallisto failed."
#				mv ${f} ${f}.FAILED
#			fi
#		fi
#
#		f=${base}.${ref}.e2e.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			echo "Creating $f"
#			#bowtie2 --xeq --threads 40 --very-sensitive -x ${ref} -U ${fastq} \
#			bowtie2 --xeq --threads 40 --very-sensitive -x ${ref} -1 ${r1} -2 ${r2} \
#				--no-unal 2> ${f}.bowtie2.err \
#				| samtools view -o ${f} - #> ${f}.samtools.log 2> ${f}.samtools.err
#			chmod a-w $f
#		fi
#
#		for x in loc e2e ; do
#
#			f=${base}.${ref}.${x}.bam.counts
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				echo "Creating $f"
#				#samtools view -f  64 -F 4 ${base}.${ref}.${x}.bam | awk '{print $1"/1",$3}' >  ${f}.tmp
#				#samtools view -f 128 -F 4 ${base}.${ref}.${x}.bam | awk '{print $1"/2",$3}' >> ${f}.tmp
#				#sort ${f}.tmp | uniq | awk '{print $2}' | sort | uniq -c > ${f}
#
#				#	first awk/sort/uniq is to ensure that a read doesn't get counted for aligning
#				#	to the same ref multiple times (really only needed for blast output)
#				#samtools view -F 4 ${base}.${ref}.${x}.bam | awk '{print $1,$3}' | sort | uniq | awk '{print $2}' | sort | uniq -c > ${f}
#
#				echo "ref ${base}" > ${f}
#				samtools view -F 4 ${base}.${ref}.${x}.bam | awk '{print $3}' | sort | uniq -c | awk '{print $2,$1}' >> ${f}
#				c=$( grep -c "^>" ${base}.fa )
#				echo "total_reads ${c}" >> ${f}
#
#				a=$( samtools view -c -F 4 ${base}.${ref}.${x}.bam )
#				echo "unaligned $[${c}-${a}]" >> ${f}
#
#				chmod a-w $f
#			fi
#
#		done
#
#	done
#
#
done

