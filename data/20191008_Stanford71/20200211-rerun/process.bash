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
#	NOTE: This data is a mix of RNA and DNA
#


for r1 in /francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed/length/unpaired/??.fastq.gz ; do

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )

#	for k in 9 11 13 ; do
#
#		infile="${r1}"
#
#		qoutbase="${base}.${k}mers.jellyfish2"
#		f="${qoutbase}.csv.gz"
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			unset size vmem threads
#			case $k in 
#				9 | 11 | 13 | 15 ) size=5;vmem=8;threads=8;;
#				17) size=10;vmem=32;threads=8;;
#				21) size=10;vmem=32;threads=16;;
#			esac  # seems to work
#			qsub -N ${jobbase}.rjf.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#				-j oe -o ${qoutbase}.${date}.out.txt \
#				~/.local/bin/jellyfish_count_and_dump.bash \
#					-F "--threads ${threads} -c --mer-len ${k} --input ${infile} --size ${size}"
#		fi
#
#	done


	for ref in h38au  ; do

		outbase=${base}.${ref}
		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		vmem=8

		#for ali in e2e loc ; do
		for ali in e2e ; do

			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac

			qoutbase="${outbase}.bowtie2-${ali}"
			bowtie2id=""
			f=${qoutbase}.bam
			bowtie2bam=${f}
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				bowtie2id=$( qsub -N ${jobbase}.${ref}.bt${ali} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${qoutbase}.${date}.out.txt \
					~/.local/bin/bowtie2.bash \
					-F "--xeq --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} \
							--rg-id ${jobbase} --rg "SM:${jobbase}" -U ${r1} -o ${qoutbase}.bam" )
				echo "${bowtie2id}"
			fi

			qoutbase="${outbase}.bowtie2-${ali}.mapped"
			mappedid=""
			f=${qoutbase}.fasta.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${bowtie2id} ] ; then
					depend="-W depend=afterok:${bowtie2id}"
				else
					depend=""
				fi
				mappedid=$( qsub ${depend} -N ${jobbase}.${ref}.bt${ali:0:1}m \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${qoutbase}.${date}.out.txt \
					~/.local/bin/samtools.bash -F \
						"fasta -F 4 --threads $[threads-1] -N -o ${qoutbase}.fasta.gz ${bowtie2bam}" )
				echo "${mappedid}"
			fi


			qoutbase="${outbase}.bowtie2-${ali}.unmapped"
			unmappedid=""
			f=${qoutbase}.fasta.gz
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
					-j oe -o ${qoutbase}.${date}.out.txt \
					~/.local/bin/samtools.bash -F \
						"fasta -f 4 --threads $[threads-1] -N -o ${qoutbase}.fasta.gz ${bowtie2bam}" )
				echo "${unmappedid}"
			fi


			if [ $ali == 'e2e' ] ; then
				#	base=${r1%.fastq.gz}
				#	outbase=${base}.${ref}
				#	qoutbase="${outbase}.bowtie2-${ali}.unmapped"
				infile=${qoutbase}.fasta.gz

				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${unmappedid} ] ; then
						depend="-W depend=afterok:${unmappedid}"
					else
						depend=""
					fi
					qsub ${depend} -N ${jobbase}.${ref}.d.nr -l nodes=1:ppn=8 -l vmem=16gb \
						-j oe -o ${qoutbase}.diamond.nr.daa.out.txt \
						~/.local/bin/diamond.bash \
							-F "blastx -p 8 -d ${DIAMOND}/nr \
								-q ${infile} \
								-f 100 \
								-o ${qoutbase}.diamond.nr.daa"
				fi









				#	convert .diamond.nr.daa to blast.txt
				#	summarize blast.txt
				#	sum summary to species, genus, subfamily 
















#				for k in 13 ; do
#
#					infile="${outbase}.bowtie2-${ali}.unmapped.fasta.gz"
#
#					qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped.${k}mers.sorted"
#					f="${qoutbase}.txt.gz"
#					if [ -f $f ] && [ ! -w $f ] ; then
#						echo "Write-protected $f exists. Skipping."
#					else
#						if [ ! -z ${unmappedid} ] ; then
#							depend="-W depend=afterok:${unmappedid}"
#						else
#							depend=""
#						fi
#						unset size vmem threads
#						case $k in
#							13) size=5;vmem=8;threads=8;;
#							21) size=10;vmem=64;threads=16;;
#						esac
#						qsub ${depend} -N ${jobbase}.hjf.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#							-j oe -o ${qoutbase}.${date}.out.txt \
#							~/.local/bin/hawk_jellyfish_count_and_dump.bash \
#								-F "--threads ${threads} -c --mer-len ${k} --input ${infile} --size ${size}"
#						#	-l feature=nocommunal \
#					fi
#
#				done
#
#				for k in 9 11 13 15 ; do
#
#					infile="${outbase}.bowtie2-${ali}.mapped.fasta.gz"
#
#					qoutbase="${base}.${ref}.bowtie2-${ali}.mapped.${k}mers.jellyfish2"
#					f="${qoutbase}.csv.gz"
#					if [ -f $f ] && [ ! -w $f ] ; then
#						echo "Write-protected $f exists. Skipping."
#					else
#						if [ ! -z ${mappedid} ] ; then
#							depend="-W depend=afterok:${mappedid}"
#						else
#							depend=""
#						fi
#						unset size vmem threads
#						case $k in 
#							9 | 11 | 13 | 15 ) size=5;vmem=8;threads=8;;
#							17 | 19 ) size=10;vmem=32;threads=8;;
#							21) size=10;vmem=32;threads=16;;
#						esac 
#						mappedjfid=$( qsub ${depend} -N ${jobbase}.mjf.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#							-j oe -o ${qoutbase}.${date}.out.txt \
#							~/.local/bin/jellyfish_count_and_dump.bash \
#								-F "--threads ${threads} -c --mer-len ${k} --input ${infile} --size ${size}" )
#						echo $mappedjfid
#						#	-l feature=nocommunal \
#					fi
#
#				done
#
#				for k in 9 11 13 15 ; do
#
#					infile="${outbase}.bowtie2-${ali}.unmapped.fasta.gz"
#
#					qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped.${k}mers.jellyfish2"
#					f="${qoutbase}.csv.gz"
#					if [ -f $f ] && [ ! -w $f ] ; then
#						echo "Write-protected $f exists. Skipping."
#					else
#						if [ ! -z ${unmappedid} ] ; then
#							depend="-W depend=afterok:${unmappedid}"
#						else
#							depend=""
#						fi
#						unset size vmem threads
#						case $k in 
#							9 | 11 | 13 | 15) size=5;vmem=8;threads=8;;
#							17 | 19 ) size=5;vmem=32;threads=8;;
#							21) size=10;vmem=32;threads=16;;
#						esac 
#						unmappedjfid=$( qsub ${depend} -N ${jobbase}.ujf.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#							-j oe -o ${qoutbase}.${date}.out.txt \
#							~/.local/bin/jellyfish_count_and_dump.bash \
#								-F "--threads ${threads} -c --mer-len ${k} --input ${infile} --size ${size}" )
#						#	-l feature=nocommunal \
#						echo $unmappedjfid
#					fi
#
#				done





				for k in 11 21 ; do

					infile="${outbase}.bowtie2-${ali}.unmapped.fasta.gz"

					unmappeddskid=''
					qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped.${k}mers.dsk"
					f="${qoutbase}.h5"
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${unmappedid} ] ; then
							depend="-W depend=afterok:${unmappedid}"
						else
							depend=""
						fi
						#vmem=8;threads=8;
						vmem=16;threads=8;
						#unset size vmem threads
						#case $k in 
						#	9 | 11 | 13 | 15) size=5;vmem=8;threads=8;;
						#	17 | 19 ) size=5;vmem=32;threads=8;;
						#	21 | 31 ) vmem=16;threads=8;;
						#esac 
						unmappeddskid=$( qsub ${depend} -N ${jobbase}.udsk.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
							-j oe -o ${qoutbase}.${date}.out.txt \
							~/.local/bin/dsk.bash \
								-F "-nb-cores ${threads} -kmer-size ${k} -abundance-min 0 \
									-max-memory $[vmem/2]000 -file ${infile} -out ${f}" )
						echo $unmappeddskid
					fi

					infile="${f}"
					dsk2asciiid=""
					f="${qoutbase}.txt.gz"
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${unmappeddskid} ] ; then
							depend="-W depend=afterok:${unmappeddskid}"
						else
							depend=""
						fi
						vmem=8;threads=8;
						dsk2asciiid=$( qsub ${depend} -N ${jobbase}.ud2a.${k} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
							-j oe -o ${qoutbase}2ascii.${date}.out.txt \
							~/.local/bin/dsk2ascii.bash \
								-F "-nb-cores ${threads} -file ${infile} -out ${f}" )
						echo $dsk2asciiid
					fi

					f="${qoutbase}"	#	DIRECTORY
					if [ -d $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${dsk2asciiid} ] ; then
							depend="-W depend=afterok:${dsk2asciiid}"
						else
							depend=""
						fi
						#vmem=8;threads=8;
#-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						qsub ${depend} -N ${jobbase}.uslt.${k} \
							-j oe -o ${qoutbase}.${date}.out.txt \
							~/.local/bin/dsk_ascii_split_scratch.bash \
								-F "-k ${k} -outbase ${qoutbase}"
#								-F "-infile ${infile} -k ${k} -threads ${threads} -mem $[vmem/2]000 -outbase ${qoutbase}"
					fi

				done

			fi
			#	RESET IT HERE
			qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped"

		done	#	for ali in e2e loc ; do

	done	#	for ref in h38au  ; do


	for kref in ${KALLISTO}/{mi_13,mt_13,hp_31}.idx ; do

		basekref=$( basename $kref .idx )

		case $basekref in
			rsg_13)
				vmem=128;;
			rsg_*|vm_13)
				vmem=64;;
			hrna_11|rsrna_13)
				vmem=32;;
			mi_*|mt_*|hp_*|ami_*|amt_*|ahp_*)
				vmem=8;;
			*)
				vmem=16;;
		esac

		qoutbase=${base}.kallisto.single.${basekref}
		f=${qoutbase}
		#	NOTE THAT THIS IS A DIRECTORY AND NOT A FILE
		if [ -d $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else

			#	Not sure if we actually need the bam file
			#-F "quant -b ${threads}0 --threads ${threads} --pseudobam \

			qsub -N ${jobbase}.${basekref}.ks -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-j oe -o ${qoutbase}.${date}.out.txt \
				~/.local/bin/kallisto.bash \
				-F "quant -b ${threads}0 --threads ${threads} \
					--single-overhang --single -l 145.11 -s 20.175 --index ${kref} \
					--output-dir ${qoutbase} ${r1}"
		fi

		#	zcat /francislab/data1/working/20191008_Stanford71/20200211/trimmed/length/unpaired/*fastq.gz \
		#		| paste - - - - | cut -f 2 |
		#		awk '{l=length;sum+=l;sumsq+=(l)^2;print "Avg:",sum/NR,"\tStddev:\t"sqrt((sumsq-sum^2/NR)/NR)}' \
		#		> trimmed.avg_length.ssstdev.txt
		#	cat trimmed.avg_length.ssstdev.txt
		#	Avg: 144.9 Stddev:20.6282
		#	Avg: 144.924 	Stddev:	20.6833
		#	Avg: 145.11 	Stddev:	20.175
		#
		#	Should these numbers be sample specific???


	done


#	#	In light of previous nr alignments, explicitly align to the following ...
#
#	for ref in CP031704.1 CP048030.1 NC_000926.1 NC_001638.1 NC_023091.1 NC_027859.1 NC_028331.1 NC_033969.1 NC_039754.1 NC_039755.1 NC_041490.1 NC_042478.1 ; do
#
#		outbase=${base}.${ref}
#		#	bowtie2 really only uses a bit more memory than the reference.
#		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
#		#	Ran well with 8gb.
#		vmem=8
#
#		for ali in e2e ; do
#			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac
#			qoutbase="${outbase}.bowtie2-${ali}"
#			f=${qoutbase}.bam
#			bowtie2bam=${f}
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				qsub -N ${jobbase}.${ref}.bt${ali} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#					-j oe -o ${qoutbase}.${date}.out.txt \
#					~/.local/bin/bowtie2.bash \
#					-F "--xeq --no-unal --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} \
#							--rg-id ${jobbase} --rg "SM:${jobbase}" -U ${r1} -o ${qoutbase}.bam"
#			fi
#		done
#	done

done	#	for r1 in /francislab/data1/working/20191008_Stanford71/20200211/trimmed/changed/unpaired/*.fastq.gz ; do

