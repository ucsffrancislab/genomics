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
	#module load CBI samtools/1.13 bowtie2/2.4.4 bedtools2/2.30.0
fi
#set -x  #       print expanded command before executing it


OUT="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/out"
mkdir -p ${OUT}

#date=$( date "+%Y%m%d%H%M%S" )
threads=8


#	Use a 1 based index since there is no line 0.
offset=0
line=$((${SLURM_ARRAY_TASK_ID:-1}+${offset}))
sample=$( sed -n "$line"p /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/sample_ids.txt )
echo $sample


#	sadly there are a couple duplicates which complicate things, so take just the first

r1=$( ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/${sample}-*1_R1*z | head -1 )
echo $r1

r2=${r1/_R1./_R2.}
b=$( basename $r1 +1_R1.fastq.gz )
b=${b%-*}
b=${b%-*}
b=${b%-*}
echo $b

outbase=${OUT}/${b}

f=${outbase}.vdjca
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	\rm -f ${f}
	~/.local/mixcr-3.0.13/mixcr align --threads ${threads} --species human ${r1} ${r2} ${f}
	chmod -w ${f}
fi

assemble=""
f=${outbase}.clns
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	\rm -f ${f}
	~/.local/mixcr-3.0.13/mixcr assemble --threads ${threads} ${outbase}.vdjca ${f}
	chmod -w ${f}
fi

exportClones=""
f=${outbase}.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	\rm -f ${f}
	~/.local/mixcr-3.0.13/mixcr exportClones ${outbase}.clns ${f}
	chmod -w ${f}
fi



exit


ls /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/??-????-01?-*1_R1*z | xargs -I% basename % | cut -d- -f1,2,3 | uniq > sample_ids.txt


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-689%10 --job-name="MiXCR" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/array_wrapper.bash


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=589-689%3 --job-name="MiXCR" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/array_wrapper.bash


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=600-689%4 --job-name="MiXCR" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/array_wrapper.bash


date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=670-689%10 --job-name="MiXCR" --output="${PWD}/array.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/array_wrapper.bash



