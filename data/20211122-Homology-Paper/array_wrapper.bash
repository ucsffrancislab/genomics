#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools/1.13 bowtie2/2.4.4 bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


dir="/francislab/data1/working/20211122-Homology-Paper/out"

mkdir -p ${dir}/raw
mkdir -p ${dir}/masks
mkdir -p ${dir}/split
mkdir -p ${dir}/split.vsl

#mkdir -p ${dir}/shredded
#mkdir -p ${dir}/bbmapped
#mkdir -p ${dir}/bbmasked


while [ $# -gt 0 ] ; do
	case $1 in
		-d|--dir)
			shift; dir=$1; shift;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done


line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

genome=$( sed -n "$line"p /francislab/data1/working/20211122-Homology-Paper/select_viruses.txt )
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
else
	echo "Local raw ${l} exists. Skipping."
fi

m=${dir}/masks/$( basename $l )
#if [ ! -f ${m}.cat ] ; then
if [ ! -f ${m}.out ] ; then
	chmod +w ${l}
	echo ~/.local/RepeatMasker/RepeatMasker -pa 8 -dir ${dir}/masks $l
	~/.local/RepeatMasker/RepeatMasker -pa 8 -dir ${dir}/masks $l
	if [ -f ${m}.masked ] ; then
		mv ${m}.masked ${m%.fasta}.masked.fasta
	fi
	chmod -w ${m%.fasta}* ${l}
else
	echo "RepeatMasker output ${m}.out found. Skipping."
fi

m=${m%.fasta}.masked.fasta

for f in ${l} ${m} ; do
	echo $f
	b=$( basename $f .fasta )

	s=25
	
	o=${dir}/split/${b}.split.${s}.fa
	echo $o

	if [ ! -f ${o} ] ; then
		if [ -f ${f} ] ; then
			mkdir ${o%.fa}
			echo faSplit -oneFile -extra=${s} size ${f} ${s} ${o%.fa}/split
			faSplit -oneFile -extra=${s} size ${f} ${s} ${o%.fa}/split
			mv ${o%.fa}/split.fa ${o}
			chmod -w $o
			rmdir ${o%.fa}
		else
			echo "${f} not found. Not splitting"
		fi
	else
		echo "Split file ${o} exists. Skipping."
	fi

	a="vsl"
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
		i="${dir}/split/${b}.split.${s}.fa"
		if [ -f "${i}" ] ; then
			x=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts
			if [ ${a} == 'vsl' ] ; then
				bowtie2 -f -U ${i} --no-unal --threads 8 \
					--very-sensitive-local \
					-x ${x} \
					-S ${o} 2> ${o%.sam}.summary.txt
			fi
			chmod -w ${o} ${o%.sam}.summary.txt
		else
			echo "${dir}/split/${b}.split.${s}.fa not found. Not aligning."
		fi
	else
		echo "Alignment ${o} exists. Skipping."
	fi

	#	Above and below NEED the complete reference (with its version number as it is in the fasta)

	#	2	chromStart	Start coordinate on the chromosome or scaffold for the sequence considered (the first base on the chromosome is numbered 0)
	#	3	chromEnd	End coordinate on the chromosome or scaffold for the sequence considered. This position is non-inclusive, unlike chromStart.
	#
	#	Bed files are 0 based, but I had been treating them as 1 based.
#				a=1+s*$1
#				b=a+(length($10)-1)

	o=${dir}/split.${a}/${b}.split.${s}.mask.bed
	if [ ! -f ${o} ] ; then
		i="${dir}/split.${a}/${b}.split.${s}.sam"
		if [ -f "${i}" ] ; then
			echo samtools sort -n -O SAM -o - ${i}
			samtools sort -n -O SAM -o - ${i} | awk -v s=${s} -v ref=${b%.masked} '(/^split/){
				sub(/^split/,"",$1);
				a=s*$1
				b=a+(length($10)-1)+1
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
		else
			echo "${i} not found. Not creating bed."
		fi
	else
		echo "Bed exists. Skipping."
	fi


#	#	not sure if i use this
#	o=${dir}/split.${a}/${b}.split.${s}.mask.masked_length.txt
#	if [ ! -f ${o} ] ; then
#		i=${dir}/split.${a}/${b}.split.${s}.mask.bed
#		if [ -f ${i} ] ; then
#			awk -F"\t" 'BEGIN{s=0}(length($0)>2){s+=($3-$2+1)}END{print s}' ${i} > ${o}
#			chmod -w ${o}
#		else
#			echo "${i} not found. Not creating masked length."
#		fi
#	else
#		echo "Masked length ${o} exists. Skipping."
#	fi

	# always the same reference here so no need to actually compare?

	o=${dir}/split.${a}/${b}.split.${s}.mask.fasta
	if [ ! -f ${o} ] ; then
		i=${dir}/split.${a}/${b}.split.${s}.mask.bed
		if [ -f ${i} ] ; then
			echo maskFastaFromBed -fi ${f} -fo ${o} -bed ${i} -fullHeader
			maskFastaFromBed -fi ${f} -fo ${o} -bed ${i} -fullHeader
			chmod -w ${o}
		else
			echo "${i} not found. Not masking."
		fi
	else
		echo "Masked fasta ${o} exists. Skipping."
	fi



#	could add bbmask.sh to the pipeline purely for its entropy feature
#	Looks like bbmask requires that I shred hg38 and align it to each virus.
#	That would take a lot longer.
#	I could use my masking style
#	i=${dir}/split.${a}/${b}.split.${s}.mask.fasta
#	o=${dir}/split.${a}/${b}.split.${s}.mask.entropy.fasta






#	To mask sequences in genome A similar to those in genome B, plus low-entropy sequences:
#	shred.sh in=B.fa out=shredded.fa length=80 minlength=70 overlap=40
#	bbmap.sh ref=A.fa in=shredded.fa outm=mapped.sam minid=0.85 maxindel=2
#	bbmask.sh in=A.fa out=masked.fa entropy=0.7 sam=mapped.sam
#	This seems different. Like you shred hg38, then align to the virus, then mask the virus based on where hg38 aligned.

#	#	shred.sh in=B.fa out=shredded.fa length=80 minlength=70 overlap=40
#	i=${f}
#	o=${dir}/shredded/${b}.${s}.fasta
#	echo $o
#	if [ ! -f ${o} ] ; then
#		if [ -f ${i} ] ; then
#			echo shred.sh in=${f} out=${o} length=50 minlength=40 overlap=25
#			/c4/home/gwendt/.local/BBMap/shred.sh in=${f} out=${o} length=50 minlength=40 overlap=25
#			chmod -w $o
#		else
#			echo "${i} not found. Not shredding."
#		fi
#	else
#		echo "Shredded file ${o} exists. Skipping."
#	fi
#
#	#	bbmap.sh ref=A.fa in=shredded.fa outm=mapped.sam minid=0.85 maxindel=2
#	i=${o}
#	o=${dir}/bbmapped/${b}.${s}.sam
#	x=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa
#	echo $o
#	if [ ! -f ${o} ] ; then
#		if [ -f ${i} ] ; then
#			echo bbmap.sh ref=${x} in=${i} outm=${o} minid=0.85 maxindel=2
#			/c4/home/gwendt/.local/BBMap/bbmap.sh -Xmx50g ref=${x} in=${i} outm=${o} minid=0.85 maxindel=2
#			chmod -w $o
#		else
#			echo "${i} not found. Not mapping"
#		fi
#	else
#		echo "Mapped file ${o} exists. Skipping."
#	fi
#
#	#	bbmask.sh in=A.fa out=masked.fa entropy=0.7 sam=mapped.sam
#	sam=${dir}/bbmapped/${b}.${s}.sam
#	i=${f}
#	o=${dir}/bbmasked/${b}.${s}.fasta
#	echo $o
#	if [ ! -f ${o} ] ; then
#		if [ -f ${i} ] ; then
#			echo bbmask.sh in=${i} out=${o} entropy=0.7 sam=mapped.sam
#			/c4/home/gwendt/.local/BBMap/bbmask.sh -Xmx50g in=${i} out=${o} entropy=0.7 sam=${sam}
#			chmod -w $o
#		else
#			echo "${i} not found. Not masking"
#		fi
#	else
#		echo "Masked file ${o} exists. Skipping."
#	fi





	#for fa in ${f} ${dir}/split.${a}/${b}.split.${s}.mask.fasta ${dir}/bbmasked/${b}.${s}.fasta ; do
	for fa in ${f} ${dir}/split.${a}/${b}.split.${s}.mask.fasta ; do
		o=${fa}.base_count.txt
		if [ ! -f ${o} ] ; then
			if [ -f ${fa} ] ; then
				tail -n +2 ${fa} | tr -d "\n" | sed 's/\(.\)/\1\n/g' | sort | uniq -c > ${o}
				chmod -w ${o}
			else
				echo "${fa} not found. Not counting bases."
			fi
		else
			echo "Base counts ${o} exist. Skipping."
		fi
	done


	

done	#	for f in ${l} ${m} ; do


exit


wc -l /francislab/data1/working/20211122-Homology-Paper/select_viruses.txt 
27



date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-27%8 --job-name="homology" --output="${PWD}/array.${date}-%A_%a.out" --time=900 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20211122-Homology-Paper/array_wrapper.bash



grep -l "No such file or directory" array.*.out  | wc -l
ll out/masks/*cat.all | wc -l


grep "Running line" array.*.out | wc -l ; date





