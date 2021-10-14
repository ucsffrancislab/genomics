#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools/1.13 bowtie2/2.4.4 bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it



dir="/francislab/data1/working/20211012-hg38-complete-homology/out"
page=1

mkdir -p ${dir}/raw
mkdir -p ${dir}/masks
mkdir -p ${dir}/split

#splits="c20 c19 c18 c17 c16 c15 c14 c13 c12 c11 c10 c9 c8 c7 c6 c5 c4 c3 c2 c1 vsl"
splits="vsl"

for a in ${splits}; do
	mkdir -p ${dir}/split.${a}
done


while [ $# -gt 0 ] ; do
	case $1 in
		-p|--page)
			shift; page=$1; shift;;
		-d|--dir)
			shift; dir=$1; shift;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

offset=$(((page-1)*1000 ))
line=$((${SLURM_ARRAY_TASK_ID:-1}+${offset}))

#	Use a 1 based index since there is no line 0.

genome=$( sed -n "$line"p /francislab/data1/refs/refseq/complete-20210920/complete_genomes.txt )
echo $genome

if [ -z "${genome}" ] ; then
	echo "No line at :${line}:"
	exit
fi

accession=$( head -1 $genome | sed -e 's/_/ /g' -e 's/ /_/' -e 's/^>//' | awk '{print $1}' )
echo $accession

l=${dir}/raw/${accession}.fasta

if [ ! -f ${l} ] ; then
	cat ${genome} | sed -e '1s/_/ /g' -e '1s/ /_/' > ${l}
	chmod +w ${l}
fi

m=${dir}/masks/$( basename $l )
if [ ! -f ${m}.cat ] ; then
	echo ~/.local/RepeatMasker/RepeatMasker -pa 8 -dir ${dir}/masks $l
	~/.local/RepeatMasker/RepeatMasker -pa 8 -dir ${dir}/masks $l
	if [ -f ${m}.masked ] ; then
		mv ${m}.masked ${m%.fasta}.masked.fasta
	fi
	chmod -w ${m%.fasta}* ${l}
fi

m=${m%.fasta}.masked.fasta

for f in ${l} ${m} ; do
	echo $f
	b=$( basename $f .fasta )

	#for s in 100 75 50 25 ; do
	for s in 25 ; do
	
		o=${dir}/split/${b}.split.${s}.fa
		echo $o

		if [ ! -f ${o} ] ; then
			mkdir ${o%.fa}
			echo faSplit -oneFile -extra=${s} size ${f} ${s} ${o%.fa}/split
			faSplit -oneFile -extra=${s} size ${f} ${s} ${o%.fa}/split
			mv ${o%.fa}/split.fa ${o}
			chmod -w $o
			rmdir ${o%.fa}
		fi

		for a in ${splits}; do
			echo ${a}
	
			#	I can't remember the details, but I believe the custom settings
			#	were meant to inspire more alignments.

			#	--very-sensitive-local = -D 20 -R 3 -N 0 -L 20 -i S,1,0.50
			#	--score-min <func> min acceptable alignment score w/r/t read length
			#                     (G,20,8 for local, L,-0.6,-0.6 for end-to-end)
			# G,20,8 for 50 = 20 + 8*ln(50) = 20 + 8 * 3.91 = 51.29
			#   -D 40 -R 5 -N 1 -L 20 -i C,1,0 

			o=${dir}/split.${a}/${b}.split.${s}.sam
			if [ ! -f ${o} ] ; then
				if [ ${a} == 'c20' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 1 -L 18 -i C,1,0 --score-min C,50,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c19' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 1 -L 18 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c18' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 1 -L 18 -i C,1,0 --score-min C,44,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c17' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 1 -L 16 -i C,1,0 --score-min C,44,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c16' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 1 -L 18 -i C,1,0 --score-min C,42,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c15' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 16 -i C,1,0 --score-min C,42,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c14' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 16 -i C,1,0 --score-min C,40,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c13' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 18 -i C,1,0 --score-min C,40,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c12' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 12 -i C,1,0 --score-min C,40,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c11' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 22 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c10' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 20 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c9' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 30 -R 4 -N 0 -L 10 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c8' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 18 -i C,1,0 --score-min G,15,8 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c7' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 12 -i C,1,0 --score-min G,15,8 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c6' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 12 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c5' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 18 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c4' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 15 -i C,1,0 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c3' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 15 -i C,1,0 --score-min G,15,8 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c2' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 15 -i S,1,0.25 --score-min G,15,8 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'c1' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--local -D 25 -R 3 -N 0 -L 18 -i S,1,0.30 --score-min G,15,8 \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				elif [ ${a} == 'vsl' ] ; then
					bowtie2 -f -U ${dir}/split/${b}.split.${s}.fa --no-unal --threads 8 \
						--very-sensitive-local \
						-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
						-S ${o} 2> ${o%.sam}.summary.txt
				fi
				chmod -w ${o} ${o%.sam}.summary.txt
			fi

			#	Above and below NEED the complete reference (with its version number as it is in the fasta)

			o=${dir}/split.${a}/${b}.split.${s}.mask.bed
			if [ ! -f ${o} ] ; then
				#samtools view split.${a}/${b}.split.${s}.sam | awk -v s=${s} -v ref=${b%.masked} '{
				echo samtools sort -n -O SAM -o - ${dir}/split.${a}/${b}.split.${s}.sam
				samtools sort -n -O SAM -o - ${dir}/split.${a}/${b}.split.${s}.sam | awk -v s=${s} -v ref=${b%.masked} '{
					sub(/^split/,"",$1);
					a=1+s*$1
					b=a+(2*s-1)
					print ref"\t"a"\t"b
				}' | awk -v ext=0 'BEGIN{FS=OFS="\t"}{
					if( r == "" ){
						#	first record
						r=$1
						s=(($2>ext)?$2:(ext+1))-ext
						e=$3+ext
					} else {
						if( $2 <= (e+ext+1) ){
							e=$3+ext
						}else{
							print $1,s,e
							s=$2-ext
							e=$3+ext
						} 
					}
				}END{ if( r != "" ) print r,s,e }' > ${o}
				chmod -w ${o}
			fi
	
			o=${dir}/split.${a}/${b}.split.${s}.mask.masked_length.txt
			if [ ! -f ${o} ] ; then
				awk -F"\t" 'BEGIN{s=0}(length($0)>2){s+=($3-$2+1)}END{print s}' ${dir}/split.${a}/${b}.split.${s}.mask.bed > ${o}
				chmod -w ${o}
			fi
	
			# always the same reference here so no need to actually compare?
	
			o=${dir}/split.${a}/${b}.split.${s}.fasta
			if [ ! -f ${o} ] ; then
				echo maskFastaFromBed -fi ${f} -fo ${o} -bed ${dir}/split.${a}/${b}.split.${s}.mask.bed -fullHeader
				maskFastaFromBed -fi ${f} -fo ${o} -bed ${dir}/split.${a}/${b}.split.${s}.mask.bed -fullHeader
				chmod -w ${o}
			fi


			for fa in ${f} ${dir}/split.${a}/${b}.split.${s}.fasta ; do
				o=${fa}.base_count.txt
				if [ ! -f ${o} ] ; then
					tail -n +2 ${fa} | tr -d "\n" | sed 's/\(.\)/\1\n/g' | sort | uniq -c > ${o}
					chmod -w ${o}
				fi
			done


		done	#	for a in c1 vsl ; do
		
	done	#	for s in 100 50 25 ; do
	
done	#	for f in ${l} ${m} ; do






exit

wc -l /francislab/data1/refs/refseq/complete-20210920/complete_genomes.txt
46123 /francislab/data1/refs/refseq/complete-20210920/complete_genomes.txt

47 pages

date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-1000%10 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=300 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211012-hg38-complete-homology/array_wrapper.bash --page 15



grep -l "No such file or directory" array.*.out  | wc -l
ll out/masks/*cat.all | wc -l




