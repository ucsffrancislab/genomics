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

				#for dref in nr viral ; do
				for dref in viral ; do

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
						diamondid=$( qsub ${depend} -N ${jobbase}.${dref} -l nodes=1:ppn=8 -l vmem=16gb \
							-j oe -o ${outbase}.out.txt \
							~/.local/bin/diamond.bash \
								-F "blastx --threads 8 --db ${DIAMOND}/${dref} \
									--query ${infile} --outfmt 6 --out ${f}" )
						echo $diamondid
					fi
					input=${f}

					summaryid=""
					outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}.summary"
					f=${outbase}.txt.gz
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${diamondid} ] ; then
							depend="-W depend=afterok:${diamondid}"
						else
							depend=""
						fi
#						if [ -f $input ] ; then
#							#	On first run, this wouldn't work
#							size=$( stat -c %s $input )
#							if [ $size -gt 10000000 ] ; then
#								echo "Size $size gt 10000000"
#								vmem=8
#							elif [ $size -gt 8000000 ] ; then
#								echo "Size $size gt 8000000"
#								vmem=6
#							else
#								echo "Size $size NOT gt 8000000"
#								vmem=4
#							fi
#						else
#							vmem=4
#						fi
#						summaryid=$( qsub ${depend} -N ${jobbase}.s.${dref} -l nodes=1:ppn=2 -l vmem=${vmem}gb \
						summaryid=$( qsub ${depend} -N ${jobbase}.s.${dref} -l nodes=1:ppn=8 -l vmem=${vmem}gb \
							-j oe -o ${outbase}.${date}.out.txt \
							~/.local/bin/blastn_summary.bash -F "-input ${input}" )
						echo $summaryid
					fi
		
					summary=$f

					#					normalize

		      if [ -n "${unmapped_read_count}" ] ; then
        		echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
						outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}.summary.normalized"
						f=${outbase}.txt.gz
						if [ -f $f ] && [ ! -w $f ] ; then
							echo "Write-protected $f exists. Skipping."
						else
							if [ ! -z ${summaryid} ] ; then
								depend="-W depend=afterok:${summaryid}"
							else
								depend=""
							fi
							#-l nodes=1:ppn=2 -l vmem=4gb \
							qsub ${depend} -N ${jobbase}.norm.${dref} \
								-j oe -o ${outbase}.${date}.out.txt \
								~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
						fi
					fi
		
					#					sum summaries

					for level in species genus ; do
						suffix=${level%%,*}	#	in case a list of level's provided
		
						sumsummaryid=""
						outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}.summary.sum-${suffix}"
						f=${outbase}.txt.gz
						if [ -f $f ] && [ ! -w $f ] ; then
							echo "Write-protected $f exists. Skipping."
						else
							if [ ! -z ${summaryid} ] ; then
								depend="-W depend=afterok:${summaryid}"
							else
								depend=""
							fi
							#sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2}.${dref} -l nodes=1:ppn=2 -l vmem=4gb \
							sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2}.${dref} -l nodes=1:ppn=8 -l vmem=${vmem}gb \
								-j oe -o ${outbase}.${date}.out.txt \
								~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )
							echo $sumsummaryid
						fi
						sumsummary=${f}
			
						#					normalize

		      	if [ -n "${unmapped_read_count}" ] ; then
        			echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
							outbase="${base}.${ref}.bowtie2-${ali}.unmapped.diamond.${dref}.summary.sum-${suffix}.normalized"
							f=${outbase}.txt.gz
							if [ -f $f ] && [ ! -w $f ] ; then
								echo "Write-protected $f exists. Skipping."
							else
								if [ ! -z ${sumsummaryid} ] ; then
									depend="-W depend=afterok:${sumsummaryid}"
								else
									depend=""
								fi
								#-l nodes=1:ppn=2 -l vmem=4gb \
								qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
									-l nodes=1:ppn=8 -l vmem=8gb \
									-j oe -o ${outbase}.${date}.out.txt \
									~/.local/bin/normalize_summary.bash \
										-F "-input ${sumsummary} -d ${unmapped_read_count}"
							fi
						fi

					done	#	for level in species genus subfamily ; do
			
				done	#	for d in viral nr







				#for bref in viral.masked ; do
				#done	#	for bref in viral.masked ; do







			fi	#	if [ $ali == 'e2e' ] ; then

			#	RESET IT HERE
			#outbase="${base}.${ref}.bowtie2-${ali}.unmapped"


		done	#	for ali in e2e loc ; do

	done	#	for ref in h38au  ; do

done	#	for r1 in /francislab/data1/working/20200303_GPMP/20200306-full/trimmed/length/*_R1.fastq.gz ; do

