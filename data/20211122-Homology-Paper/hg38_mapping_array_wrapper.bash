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
	module load CBI samtools/1.16.1 bowtie2/2.5.0 bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


IN="/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/chromosomes"
OUT="/francislab/data1/working/20211122-Homology-Paper/mapping"

mkdir -p ${OUT}


#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; dir=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done


line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

chr=$( ls -1 ${IN}/*.fa.gz | sed -n "$line"p )
echo $chr

if [ -z "${chr}" ] ; then
	echo "No line at :${line}:"
	exit
fi


inbase=${OUT}/$( basename ${chr} )       #	chr1.fa.gz
outbase=${OUT}/$( basename ${chr} .gz )  #	chr1.fa
f=${outbase}
if [ -f ${f} ] ; then
	echo "Local fasta exists. Skipping step."
else
	echo "Gunzipping ${inbase}"
	zcat ${chr} > ${f}
	chmod +w ${f}
fi


inbase=${outbase}	#	chr1.fa
outbase=${inbase%.fa}.split.fa
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Split output exists. Skipping step."
else
	echo "Splitting ${inbase}"
	mkdir ${f%.fa}
	faSplit -oneFile -extra=25 size ${inbase} 25 ${f%.fa}/split
	mv ${f%.fa}/split.fa ${f}
	chmod -w ${f}
	rmdir ${f%.fa}
fi



inbase=${outbase}  #	chr1.split.fa
outbase=${inbase%.fa}.viral.bam
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Bowtie2 output exists. Skipping step."
else
	echo "Aligning ${inbase}"
	x=/francislab/data1/refs/refseq/viral-20210916/viral
	~/.local/bin/bowtie2.bash -f -U ${inbase} \
		--threads ${SLURM_NTASKS:-8} \
		--very-sensitive-local \
		-x ${x} \
		--no-unal --all --nocount --output ${f}
fi

inbase=${outbase}	#	chr1.split.viral.bam
outbase=${inbase%.bam}.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	~/.local/bin/createGFF3FromSAM.bash --input ${inbase} --size 25 --ref $( basename ${chr} .fa.gz ) #	| gzip > ${f}
	chmod -w ${f}
	#	THIS'LL BE HUGE AND KINDA USELESS
fi

inbase=${outbase}	#	chr1.split.viral.gff3.gz
outbase=${inbase%.gff3.gz}.any.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Simplified GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	#	scripts/GFF3toanyaccession.bash INPUT.gff3.gz
	zcat ${inbase} | awk 'BEGIN{FS=OFS="\t"}(!/^#/){$7="+";$9="accession=any"}{print}' | uniq | gzip > ${f}
	chmod -w ${f}
fi








inbase=${OUT}/$( basename ${chr} .fa.gz ).split.fa
outbase=${inbase%.fa}.viral.noherv.bam
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Bowtie2 output exists. Skipping step."
else
	echo "Aligning ${inbase}"
	x=/francislab/data1/refs/refseq/viral-20210916/viral.noherv
	~/.local/bin/bowtie2.bash -f -U ${inbase} \
		--threads ${SLURM_NTASKS:-8} \
		--very-sensitive-local \
		-x ${x} \
		--no-unal --all --nocount --output ${f}
fi

inbase=${outbase}	#	chr1.split.viral.noherv.bam
outbase=${inbase%.bam}.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	~/.local/bin/createGFF3FromSAM.bash --input ${inbase} --size 25 --ref $( basename ${chr} .fa.gz ) #	| gzip > ${f}
	chmod -w ${f}
	#	THIS'LL BE HUGE AND KINDA USELESS
fi

inbase=${outbase}	#	chr1.split.viral.noherv.gff3.gz
outbase=${inbase%.gff3.gz}.any.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Simplified GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	#	scripts/GFF3toanyaccession.bash INPUT.gff3.gz
	zcat ${inbase} | awk 'BEGIN{FS=OFS="\t"}(!/^#/){$7="+";$9="accession=any"}{print}' | uniq | gzip > ${f}
	chmod -w ${f}
fi







#	MUST be writable before running RepeatMasker


outbase=${OUT}/$( basename ${chr} .gz )
inbase=${outbase}
outbase=${inbase%.fa}.masked.fa
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "RepeatMasker output exists. Skipping step."
else
	echo "RepeatMasking ${inbase}"

	~/.local/RepeatMasker/RepeatMasker -species human -pa ${SLURM_NTASKS:-8} -dir $( dirname ${f} ) ${inbase}

	#	Add species? didn't make a difference

	if [ -f ${inbase}.masked ] ; then
		ln -s ${inbase}.masked ${f}
	else
		ln -s ${inbase} ${f}
	fi
	chmod -w ${inbase}.*

fi


inbase=${outbase}
outbase=${inbase%.fa}.split.fa
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Split output exists. Skipping step."
else
	echo "Splitting ${inbase}"
	mkdir ${f%.fa}
	faSplit -oneFile -extra=25 size ${inbase} 25 ${f%.fa}/split
	mv ${f%.fa}/split.fa ${f}
	chmod -w ${f}
	rmdir ${f%.fa}
fi


inbase=${outbase}
outbase=${inbase%.fa}.viral.bam
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Bowtie2 output exists. Skipping step."
else
	echo "Aligning ${inbase}"
	x=/francislab/data1/refs/refseq/viral-20210916/viral
	~/.local/bin/bowtie2.bash -f -U ${inbase} \
		--threads ${SLURM_NTASKS:-8} \
		--very-sensitive-local \
		-x ${x} \
		--no-unal --all --nocount --output ${f}
fi

#inbase=${OUT}/$( basename ${chr} .fa.gz ).masked.split.viral.bam
inbase=${outbase}
outbase=${inbase%.bam}.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	~/.local/bin/createGFF3FromSAM.bash --input ${inbase} --size 25 --ref $( basename ${chr} .fa.gz ) #	| gzip > ${f}
	chmod -w ${f}
fi

inbase=${outbase}	#	chr1.masked.split.viral.gff3.gz
outbase=${inbase%.gff3.gz}.any.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Simplified GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	#	scripts/GFF3toanyaccession.bash INPUT.gff3.gz
	zcat ${inbase} | awk 'BEGIN{FS=OFS="\t"}(!/^#/){$7="+";$9="accession=any"}{print}' | uniq | gzip > ${f}
	chmod -w ${f}
fi




#inbase=${OUT}/$( basename ${chr} .fa.gz ).masked.split.viral.bam
inbase=${OUT}/$( basename ${chr} .fa.gz ).masked.split.fa	#viral.noherv.bam
outbase=${inbase%.fa}.viral.noherv.bam
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Bowtie2 output exists. Skipping step."
else
	echo "Aligning ${inbase}"
	x=/francislab/data1/refs/refseq/viral-20210916/viral.noherv
	~/.local/bin/bowtie2.bash -f -U ${inbase} \
		--threads ${SLURM_NTASKS:-8} \
		--very-sensitive-local \
		-x ${x} \
		--no-unal --all --nocount --output ${f}
fi

#inbase=${OUT}/$( basename ${chr} .fa.gz ).masked.split.viral.noherv.bam
inbase=${outbase}
outbase=${inbase%.bam}.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	~/.local/bin/createGFF3FromSAM.bash --input ${inbase} --size 25 --ref $( basename ${chr} .fa.gz ) #	| gzip > ${f}
	chmod -w ${f}
fi

inbase=${outbase}	#	chr1.masked.split.viral.noherv.gff3.gz
outbase=${inbase%.gff3.gz}.any.gff3.gz
f=${outbase}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Simplified GFF output exists. Skipping step."
else
	echo "Creating GFF for ${inbase}"
	#	scripts/GFF3toanyaccession.bash INPUT.gff3.gz
	zcat ${inbase} | awk 'BEGIN{FS=OFS="\t"}(!/^#/){$7="+";$9="accession=any"}{print}' | uniq | gzip > ${f}
	chmod -w ${f}
fi



#	grep -h aligned mapping/chr*.masked.split.viral.bam.err.txt | grep -vs "aligned 0" | awk '{s+=$1}END{print s}'
#	11949
#	Merge regions?

#	#	Above and below NEED the complete reference (with its version number as it is in the fasta)
#
#	#	2	chromStart	Start coordinate on the chromosome or scaffold for the sequence considered (the first base on the chromosome is numbered 0)
#	#	3	chromEnd	End coordinate on the chromosome or scaffold for the sequence considered. This position is non-inclusive, unlike chromStart.
#	#
#	#	Bed files are 0 based, but I had been treating them as 1 based.
##				a=1+s*$1
##				b=a+(length($10)-1)



exit


ll /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/chromosomes/*.fa.gz | wc -l
595


mkdir -p logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-595%1 --job-name="hg38mapping" --output="${PWD}/logs/hg38_mapping_array.${date}-%A_%a.out" --time=14400 --nodes=1 --ntasks=8 --mem=60G ${PWD}/hg38_mapping_array_wrapper.bash



grep -l "No such file or directory" array.*.out  | wc -l
ll out/masks/*cat.all | wc -l


grep "Running line" array.*.out | wc -l ; date




echo '#track name="Viral Homology - HHV HM"' > hg38.split.viral.HHV.gff3
echo '##displayName=accession' >> hg38.split.viral.HHV.gff3
zcat mapping/chr*.split.viral.gff3.gz | grep -vs "^#" | grep --file HHV_accessions.txt >> hg38.split.viral.HHV.gff3
gzip hg38.split.viral.HHV.gff3

echo '#track name="Viral Homology - HHV HM (No HERVK113)"' > hg38.split.viral.noherv.HHV.gff3
echo '##displayName=accession' >> hg38.split.viral.noherv.HHV.gff3
zcat mapping/chr*.split.viral.noherv.gff3.gz | grep -vs "^#" | grep --file HHV_accessions.txt >> hg38.split.viral.noherv.HHV.gff3
gzip hg38.split.viral.noherv.HHV.gff3

echo '#track name="Viral Homology - HM"' > hg38.split.viral.any.gff3
echo '##displayName=accession' >> hg38.split.viral.any.gff3
zcat mapping/chr*.split.viral.any.gff3.gz | grep -vs "^#" >> hg38.split.viral.any.gff3
gzip hg38.split.viral.any.gff3

echo '#track name="Viral Homology - HM (No HERVK113)"' > hg38.split.viral.noherv.any.gff3
echo '##displayName=accession' >> hg38.split.viral.noherv.any.gff3
zcat mapping/chr*.split.viral.noherv.any.gff3.gz | grep -vs "^#" >> hg38.split.viral.noherv.any.gff3
gzip hg38.split.viral.noherv.any.gff3

echo '#track name="Viral Homology - HM\RM"' > hg38.masked.split.viral.gff3
echo '##displayName=accession' >> hg38.masked.split.viral.gff3
zcat mapping/chr*.masked.split.viral.gff3.gz | grep -vs "^#" >> hg38.masked.split.viral.gff3
gzip hg38.masked.split.viral.gff3

echo '#track name="Viral Homology - HM\RM (No HERVK113)"' > hg38.masked.split.viral.noherv.gff3
echo '##displayName=accession' >> hg38.masked.split.viral.noherv.gff3
zcat mapping/chr*.masked.split.viral.noherv.gff3.gz | grep -vs "^#" >> hg38.masked.split.viral.noherv.gff3
gzip hg38.masked.split.viral.noherv.gff3


echo '#track name="Viral Homology - HM\RM"' > hg38.masked.split.viral.any.gff3
echo '##displayName=accession' >> hg38.masked.split.viral.any.gff3
zcat mapping/chr*.masked.split.viral.any.gff3.gz | grep -vs "^#" >> hg38.masked.split.viral.any.gff3
gzip hg38.masked.split.viral.any.gff3

echo '#track name="Viral Homology - HM\RM (No HERVK113)"' > hg38.masked.split.viral.noherv.any.gff3
echo '##displayName=accession' >> hg38.masked.split.viral.noherv.any.gff3
zcat mapping/chr*.masked.split.viral.noherv.any.gff3.gz | grep -vs "^#" >> hg38.masked.split.viral.noherv.any.gff3
gzip hg38.masked.split.viral.noherv.any.gff3



zcat hg38.split.viral.HHV.gff3.gz | tail -n +2 | uniq | sort -k9,9 -k7,7 -k1,1 -k4n,5n | uniq | head



BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA="" #$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in hg38.*.gff3.gz ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done



