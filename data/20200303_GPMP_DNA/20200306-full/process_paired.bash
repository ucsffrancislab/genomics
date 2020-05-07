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

date=$( date "+%Y%m%d%H%M%S" )


#
#	NOTE: This data is all DNA
#


for r1 in /francislab/data1/working/20200303_GPMP_DNA/20200306-full/trimmed/length/*L00?_R1.fastq.gz ; do

	r2=${r1/_R1/_R2}

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%_R1.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )
	jobbase=${jobbase%%_*}	#	SF12430-NE_S8_L001 -> SF12430-NE

	for ref in h38au  ; do

		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		vmem=8

		#for ali in e2e loc ; do
		for ali in e2e ; do

			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac

			outbase="${base}.${ref}.bowtie2-${ali}"
			bowtie2id=""
			f=${outbase}.bam
			bowtie2bam=${f}
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				bowtie2id=$( qsub -N ${jobbase}.${ref}.bt${ali} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/bowtie2.bash \
					-F "--xeq --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} \
							--rg-id ${jobbase} --rg "SM:${jobbase}" -1 ${r1} -2 ${r2} -o ${outbase}.bam" )
				echo "${bowtie2id}"
			fi

#			outbase="${base}.${ref}.bowtie2-${ali}.mapped"
#			mappedid=""
#			f=${outbase}.fasta.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${bowtie2id} ] ; then
#					depend="-W depend=afterok:${bowtie2id}"
#				else
#					depend=""
#				fi
#				mappedid=$( qsub ${depend} -N ${jobbase}.${ref}.bt${ali:0:1}m \
#					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#					-j oe -o ${outbase}.${date}.out.txt \
#					~/.local/bin/samtools.bash -F \
#						"fasta -F 4 --threads $[threads-1] -N -o ${outbase}.fasta.gz ${bowtie2bam}" )
#				echo "${mappedid}"
#			fi

			outbase="${base}.${ref}.bowtie2-${ali}.unmapped"
			unmappedid=""
			f=${outbase}.fasta.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${bowtie2id} ] ; then
					depend="-W depend=afterok:${bowtie2id}"
				else
					depend=""
				fi
				unmappedid=$( qsub ${depend} -N ${jobbase}.${ref}.bt${ali:0:1}un \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/samtools.bash -F \
						"fasta -f 4 --threads $[threads-1] -N -o ${outbase}.fasta.gz ${bowtie2bam}" )
				echo "${unmappedid}"
			fi


			infile="${base}.${ref}.bowtie2-${ali}.unmapped.fasta.gz"

	    # Count so can normalize
    	#   
    	# count_fasta_reads.bash *unmapped.fasta.gz
    	#   
			unmapped_read_count=''
    	f="${base}.${ref}.bowtie2-${ali}.unmapped.fasta.gz.read_count.txt"
    	if [ -f $f ] && [ ! -w $f ] ; then
      	unmapped_read_count=$( cat ${f} )
      	echo "Unmapped Count :${unmapped_read_count}:"
    	fi  

			if [ $ali == 'e2e' ] ; then

				outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.nr"
				f="${outbase}.daa"
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${unmappedid} ] ; then
						depend="-W depend=afterok:${unmappedid}"
					else
						depend=""
					fi
					qsub ${depend} -N ${jobbase}.${ref}.d.nr -l nodes=1:ppn=8 -l vmem=16gb \
						-j oe -o ${f}.out.txt \
						~/.local/bin/diamond.bash \
							-F "blastx --threads 8 --db ${DIAMOND}/nr \
								--query ${infile} \
								--outfmt 100 \
								--out ${f}"
				fi

				for dref in nr viral ; do

					#infile="${base}.${ref}.bowtie2-${ali}.unmapped.fasta.gz"

					diamondid=""
					outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}"
					f="${outbase}.csv.gz"
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${unmappedid} ] ; then
							depend="-W depend=afterok:${unmappedid}"
						else
							depend=""
						fi
						case $dref in
							nr) vmem=32; scratch=20;
							viral) vmem=16; scratch=10;
							*) vmem=8; scratch=5;
						esac
						# scratch about 150gb so 8gb * 20 for nr
						diamondid=$( qsub ${depend} -N ${jobbase}.${dref} -l nodes=1:ppn=8 -l vmem=${vmem}gb \
							-j oe -o ${outbase}.out.txt \
							-l gres=scratch:${scratch} \
							~/.local/bin/diamond_scratch.bash \
								-F "blastx --db ${DIAMOND}/${dref} \
									--query ${infile} --outfmt 6 --out ${f}" )
						echo $diamondid
					fi


					outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}"
					f1="${outbase}.summary.sum-species.normalized.txt.gz"
					f2="${outbase}.summary.sum-genus.normalized.txt.gz"
					if [ -f $f1 ] && [ ! -w $f1 ] && [ -f $f2 ] && [ ! -w $f2 ] ; then
						echo "Write-protected $f1 and $f2 exists. Skipping."
					else
						if [ ! -z ${diamondid} ] ; then
							depend="-W depend=afterok:${diamondid}"
						else
							depend=""
						fi
		
						#		SUMMARIZE AND NORMALIZE IN ONE SCRIPT ON SCRATCH
						#		MINIMIZE PIPING TO MINIMIZE MEMORY
		
						#	-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
		
						qsub ${depend} -N ${jobbase}.s.${dref} \
							-l feature=nocommunal \
							-l gres=scratch:50 \
							-j oe -o ${outbase}.${date}.out.txt \
							~/.local/bin/blastn_summarize_and_normalize_scratch.bash -F "\
								--db /francislab/data1/refs/taxadb/taxadb_full_nr.sqlite --accession nr \
							  --input ${outbase}.csv.gz \
								--levels species,genus \
								--unmapped_read_count '${unmapped_read_count}'"
							  #--input ${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}.csv.gz |
					fi

				done	#	for d in viral nr



				#for bref in viral.masked ; do
				#done	#	for bref in viral.masked ; do



			fi	#	if [ $ali == 'e2e' ] ; then

			#	RESET IT HERE
			#outbase="${base}.${ref}.bowtie2-${ali}.unmapped"


		done	#	for ali in e2e loc ; do

	done	#	for ref in h38au  ; do

done	#	for r1 in /francislab/data1/working/20200303_GPMP/20200306-full/trimmed/length/*_R1.fastq.gz ; do

