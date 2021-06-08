!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x


# -m, --mer-len=uint32                    *Length of mer
# -s, --size=uint64                       *Hash size
# -t, --threads=uint32                     Number of threads (1)
# -o, --output=string                      Output prefix (mer_counts)
# -C, --both-strands                       Count both strand, canonical representation (false)

threads=8
kmersize=13
size=5

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--i*)
			shift; file=$1; shift;;
		-t|--t*)
			shift; threads=$1; shift ;;
		-c|--c*|-C|--b*)
			#shift; canonical='--both-strands';;		#	in jellyfish 2, this is --canonical
			shift; canonical='--canonical';;		#	in jellyfish 2, this is --canonical
		-k|--k*|-m|--m*)
			shift; kmersize=$1; shift ;;
		-s|--s*)
			shift; size=$1; shift ;;
		*)
			shift;;
	esac
done


#unique_extension=".fast?.gz"

INDIR=$( dirname $file )
#OUTPREFIX=$( basename $file	${unique_extension} )
OUTPREFIX=$( basename $file	)
OUTPREFIX=${OUTPREFIX%.fast?.gz}
OUTBASE="${INDIR}/${OUTPREFIX}.${kmersize}mers"


#f1=${OUTBASE}.sorted.txt.gz

f=${OUTBASE}.jellyfish2.csv.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else


	f1=${OUTBASE}.jellyfish2
	if [ -f $f1 ] && [ ! -w $f1 ] ; then
		echo "Write-protected $f1 exists. Skipping."
	else
		echo "Creating $f1"
	
		mkdir -p ${OUTBASE}
	
	
		#	I think that perhaps this samtools fastq should have some flags added to filter out only high quality, proper pair aligned reads?
		#	Sadly "samtools fastq" does not have a -q quality filter as does "samtools view". Why not?
		#	I suppose that I could pipe one to the other like ...
		#		<( samtools view -h -q 40 -f 2 ${file} | samtools fastq - )
	
		#	I think that when extracting reads from a bam, we probably shouldn't use the -C(canonical) flag,
		#		particularly when select high quality mappings
	
		date
		#	--matrix ${f}.Matrix 
		jellyfish count ${canonical} --output ${OUTBASE}/tmp \
			--mer-len ${kmersize} --threads ${threads} --size ${size}G \
			--timing ${f1}.Timing \
			<( zcat ${file} )
	#--stats ${f}.Stats \
		date
	
		COUNT=$(ls ${OUTBASE}/tmp* |wc -l)
	
		if [ $COUNT -eq 1 ]
		then
			#mv ${OUTBASE}/tmp_0 ${f}	#	jellyfish 1
			mv ${OUTBASE}/tmp ${f1}	#	jellyfish 2
		else
			jellyfish merge -o ${f1} ${OUTBASE}/tmp*
		fi
		rm -rf ${OUTBASE}
	
		chmod a-w $f1
	fi




#	f=${OUTBASE}.hist.csv
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#
#		f2=${OUTBASE}.jellyfish.hist.csv
#		if [ -f $f2 ] && [ ! -w $f2 ] ; then
#			echo "Write-protected $f2 exists. Skipping."
#		else
#			echo "Creating $f2"
#			jellyfish histo --full --output ${f2} --threads ${threads} ${OUTBASE}.jellyfish
#			chmod a-w $f2
#		fi
#
#		# swap, for some reason?
#		awk '{print $2"\t"$1}' ${f2} > ${f}
#		chmod a-w $f
#
#		rm -f $f2
#	fi
#
#	f=${OUTBASE}.total_counts.txt
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#		awk '{if(NR!=1) sum+=$1*$2} END {print sum}' ${OUTBASE}.hist.csv > ${f}
#		chmod a-w $f
#	fi







#	f2=${OUTBASE}.sorted.txt
	f2=${OUTBASE}.jellyfish2.csv
	if [ -f $f2 ] && [ ! -w $f2 ] ; then
		echo "Write-protected $f2 exists. Skipping."
	else
		echo "Creating $f2"
		#	Original HAWK version does this with CUTOFF. I have no idea why.
		#	Set it to 1, output it to a file, then add 1 and use as the lower limit.
		#	Everytime? Why not just fixed as 2?
		#	CUTOFF=1
		#	echo $CUTOFF > ${OUTPREFIX}_cutoff.csv
		#	${jellyfishDir}/jellyfish dump -c -L `expr $CUTOFF + 1` \
		#		${OUTPREFIX}_kmers_jellyfish > ${OUTPREFIX}_kmers.txt

#		f3=${OUTBASE}.txt
#		if [ -f $f3 ] && [ ! -w $f3 ] ; then
#			echo "Write-protected $f3 exists. Skipping."
#		else
#			echo "Creating $f3"
#			#jellyfish dump --column --lower-count 2 ${OUTBASE}.jellyfish > ${f3}
#			jellyfish dump --column --lower-count 2 ${f1} > ${f2}
			jellyfish dump --column ${f1} > ${f2}
			chmod a-w $f2
#		fi

#		echo "Creating $f2"
#		#sort --parallel=${threads} -n -k 1 ${f3} > ${f2}
#		sort --parallel=${threads} --numeric-sort --key 1 ${f3} > ${f2}
#		#sort -n -k 1 ${f3} > ${f2}
#		chmod a-w $f2
#
#		rm -f $f3
	fi



	gzip --best $f2
	#	should be "a-w" already as gzip preserves
	#	it also removes the source so no rm necessary

	rm -f ${f1}	#${OUTBASE}.jellyfish2

fi

