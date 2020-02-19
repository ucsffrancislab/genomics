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


for r1 in /francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed/length/unpaired/*.fastq.gz ; do

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )

	#	for k in 13 ; do
	#		qoutbase="${base}.${k}mers.sorted"
	#		f="${qoutbase}.txt.gz"
	#		if [ -f $f ] && [ ! -w $f ] ; then
	#			echo "Write-protected $f exists. Skipping."
	#		else
	#			qsub -N ${jobbase}.hjd.${k} -l nodes=1:ppn=32 -l vmem=16gb \
	#				-o ${qoutbase}.${date}.out.txt \
	#				-e ${qoutbase}.${date}.err.txt \
	#				~/.local/bin/hawk_jellyfish_count_and_dump.bash \
	#					-F "--threads 32 -c --mer-len ${k} --input ${r1}"
	#		fi
	#	done


#	#	subread references
#	#for ref in h38au h38am h_rna rsg h38_cdna h38_ncrna h38_rna mirna mature hairpin ; do
#	#for ref in h38_cdna h38_ncrna h38_rna mirna mature hairpin ; do
#	for ref in h38au ; do
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
#		qoutbase="${outbase}.subread-rna"
#		f=${qoutbase}.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			qsub -N ${jobbase}.${ref}.srr -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#				-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
#				~/.local/bin/subread-align.bash \
#				-F "-t 0 -T ${threads} -i ${sref} -r ${r1} -o ${qoutbase}.bam"
#		fi
#
#		qoutbase="${outbase}.subread-dna"
#		f=${qoutbase}.bam
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			qsub -N ${jobbase}.${ref}.srd -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#				-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
#				~/.local/bin/subread-align.bash \
#				-F "-t 1 -T ${threads} -i ${sref} -r ${r1} -o ${qoutbase}.bam"
#		fi
#
#		#for s in subread-rna subread-dna ; do
#		#	j=${s/na}
#		#	j=${j/ubread-/r}
#		#	case $j in 'srd') opt="-t 1";; 'srr') opt="-t 0";; esac
#		#	qoutbase="${outbase}.${s}"
#		#	f=${qoutbase}.bam
#		#	if [ -f $f ] && [ ! -w $f ] ; then
#		#		echo "Write-protected $f exists. Skipping."
#		#	else
#		#		qsub -N ${jobbase}.${ref}.${s} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#		#			-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
#		#			~/.local/bin/subread-align.bash \
#		#			-F "${opt} -T ${threads} -i ${sref} -r ${r1} -o ${qoutbase}.bam"
#		#	fi
#		#done
#
#	done




	#for ref in hg38am hg38au  ; do
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
					-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
					~/.local/bin/bowtie2.bash \
					-F "--xeq --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} \
							--rg-id ${jobbase} --rg "SM:${jobbase}" -U ${r1} -o ${qoutbase}.bam" )
				echo "${bowtie2id}"
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
					-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
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
						-o ${qoutbase}.diamond.nr.daa.out.txt \
						-e ${qoutbase}.diamond.nr.daa.err.txt \
						~/.local/bin/diamond.bash \
							-F "blastx -p 8 -d ${DIAMOND}/nr \
								-q ${infile} \
								-f 100 \
								-o ${qoutbase}.diamond.nr.daa"
				fi

#				for k in 13 ; do
#					qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped.${k}mers.sorted"
#					f="${qoutbase}.txt.gz"
#					if [ -f $f ] && [ ! -w $f ] ; then
#						echo "Write-protected $f exists. Skipping."
#					else
#						if [ ! -z ${bowtie2id} ] ; then
#							depend="-W depend=afterok:${bowtie2id}"
#						else
#							depend=""
#						fi
#						qsub ${depend} -N ${jobbase}.hjd.${k} -l nodes=1:ppn=8 -l vmem=8gb \
#							-o ${qoutbase}.${date}.out.txt \
#							-e ${qoutbase}.${date}.err.txt \
#							~/.local/bin/hawk_jellyfish_count_and_dump.bash \
#								-F "--threads 8 -c --mer-len ${k} --input ${infile}"
#					fi
#				done
			fi
			#	RESET IT HERE
			qoutbase="${base}.${ref}.bowtie2-${ali}.unmapped"



#			infile=${qoutbase}.fasta.gz
#			qoutbase="${qoutbase}.blastn"	#.nt.txt.gz"
#
#			#	blastn needs fasta NOT fastq or fasta.gz
#
#			#	01...fasta has about 2.7 million reads
#			#	after about 4 hours, only 27,000 had been processed and it was 5GB.
#			#	it will take about 400 hours to process this whole file and it will be about 2TB!
#			#	TMI
#			#	Need to filter and speed up and use less memory
#			#	add evalue, num_hits or num_descriptions or ...
#			#	split file into 100 read files
#			#
#			#		#	blastn nt NEEDED about 100GB for 01
#			#		qsub -W depend=afterok:${unmappedid} -N ${jobbase}.${ref}.btunnt -l nodes=1:ppn=${threads} -l vmem=128gb \
#			#			-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
#			#			~/.local/bin/blastn.bash -F "-query ${infile} -outfmt 6 -db ${BLASTDB}/nt -num_threads ${threads}"
#			#
#
#			for vref in viral viral.raw viral.masked ; do
#				abbrev=$( echo ${vref} | awk '{split($0,a,".");for(s in a){print substr(a[s],1,1)}}' | paste -sd '' )
#
#				vblastnid=""
#				f=${qoutbase}.${vref}.txt.gz
#				if [ -f $f ] && [ ! -w $f ] ; then
#					echo "Write-protected $f exists. Skipping."
#				else
#					if [ ! -z ${unmappedid} ] ; then
#						depend="-W depend=afterok:${unmappedid}"
#					else
#						depend=""
#					fi
#					vblastnid=$( qsub ${depend} -N ${jobbase}.${ref}.b${ali:0:1}u${abbrev} \
#						-l nodes=1:ppn=${threads} -l vmem=8gb \
#						-o ${qoutbase}.${vref}.${date}.out.txt -e ${qoutbase}.${vref}.${date}.err.txt \
#						~/.local/bin/blastn.bash -F "-query ${infile} -outfmt 6 \
#							-db ${BLASTDB}/${vref} -num_threads ${threads}" )
#					echo ${vblastnid}
#				fi
#
#
#				for max in 10 1e-10 1e-20 1e-30 ; do
#
#					core=${qoutbase}.${vref}.${max}.summary
#					f=${core}.txt.gz
#					if [ -f $f ] && [ ! -w $f ] ; then
#						echo "Write-protected $f exists. Skipping."
#					else
#						if [ ! -z ${vblastnid} ] ; then
#							depend="-W depend=afterok:${vblastnid}"
#						else
#							depend=""
#						fi
#						#	-l nodes=1:ppn=${threads} -l vmem=8gb \
#						qsub ${depend} -N ${jobbase}.${ref}.b${ali:0:1}u${abbrev}s${max:(-2):2} \
#							-l nodes=1:ppn=4 -l vmem=4gb \
#							-o ${core}.${date}.out.txt -e ${core}.${date}.err.txt \
#							~/.local/bin/blastn_summary.bash \
#								-F "-input ${qoutbase}.${vref}.txt.gz -db ${BLASTDB}/${vref} -max ${max}"
#					fi
#
#				done
#
#			done	#	for vref in viral viral.raw viral.masked ; do
#
#
#			qoutbase="${outbase}.bowtie2-${ali}.unmapped"
#			infile=${qoutbase}.fasta.gz
#
#			kraken2id=""
#			qoutbase="${qoutbase}.kraken2.standard"
#			f=${qoutbase}.txt.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${unmappedid} ] ; then
#					depend="-W depend=afterok:${unmappedid}"
#				else
#					depend=""
#				fi
#				#	  --memory-mapping        Avoids loading database into RAM
#				#	  --paired                The filenames provided have paired-end reads
#				#	  --use-names             Print scientific names instead of just taxids
#				#	  --gzip-compressed       Input files are compressed with gzip
#				#	  --bzip2-compressed      Input files are compressed with bzip2
#				#	  --help                  Print this message
#				#	  --version               Print version information
#				kraken2id=$( qsub ${depend} -N ${jobbase}.${ref}.bt${ali:0:1}unk \
#					-l nodes=1:ppn=${threads} -l vmem=64gb \
#					-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
#					~/.local/bin/kraken2.bash -F \
#						"--db ${KRAKEN2}/standard --threads ${threads} --output ${f} --use-names ${infile}" )
#			fi
#
#			#qoutbase="${qoutbase}.kraken2.standard"
#			f=${qoutbase}.summary.txt.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${kraken2id} ] ; then
#					depend="-W depend=afterok:${kraken2id}"
#				else
#					depend=""
#				fi
#				#-l nodes=1:ppn=${threads} -l vmem=8gb \
#				qsub ${depend} -N ${jobbase}.${ref}.bt${ali:0:1}unks \
#					-o ${qoutbase}.summary.${date}.out.txt -e ${qoutbase}.summary.${date}.err.txt \
#					~/.local/bin/kraken2_summary.bash -F "-input ${qoutbase}.txt.gz"
#			fi

		done	#	for ali in e2e loc ; do

		#		qsub -N ${jobbase}.${ref}.bt -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
		#			-o ${outbase}.bowtie2.loc.${date}.out.txt -e ${outbase}.bowtie2.loc.${date}.err.txt \
		#			~/.local/bin/bowtie2.bash \
		#			-F "--xeq --threads ${threads} --very-sensitive-local -x ${BOWTIE2}/${ref} \
		#			-1 ${r1} -2 ${r2} --no-unal -o ${outbase}.bowtie2.loc.bam"

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
				-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
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


	#	In light of previous nr alignments, explicitly align to the following ...

	for ref in CP031704.1 CP048030.1 NC_000926.1 NC_001638.1 NC_023091.1 NC_027859.1 NC_028331.1 NC_033969.1 NC_039754.1 NC_039755.1 NC_041490.1 NC_042478.1 ; do

		outbase=${base}.${ref}
		#	bowtie2 really only uses a bit more memory than the reference.
		#	4gb would probably be enough for hg38. Nope. Needs more than 4.
		#	Ran well with 8gb.
		vmem=8

		for ali in e2e ; do
			case $ali in 'loc') opt="--very-sensitive-local";; 'e2e') opt="--very-sensitive";; esac
			qoutbase="${outbase}.bowtie2-${ali}"
			f=${qoutbase}.bam
			bowtie2bam=${f}
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				qsub -N ${jobbase}.${ref}.bt${ali} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-o ${qoutbase}.${date}.out.txt -e ${qoutbase}.${date}.err.txt \
					~/.local/bin/bowtie2.bash \
					-F "--xeq --no-unal --threads ${threads} ${opt} -x ${BOWTIE2}/${ref} \
							--rg-id ${jobbase} --rg "SM:${jobbase}" -U ${r1} -o ${qoutbase}.bam"
			fi
		done
	done

done	#	for r1 in /francislab/data1/working/20191008_Stanford71/20200211/trimmed/changed/unpaired/*.fastq.gz ; do

