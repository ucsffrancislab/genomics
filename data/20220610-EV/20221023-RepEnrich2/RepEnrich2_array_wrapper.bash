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
	#module load CBI samtools/1.13 bowtie2/2.4.4 
	#bedtools2/2.30.0
fi
set -x  #       print expanded command before executing it

#SALMON="/francislab/data1/refs/salmon"
#index=${SALMON}/REdiscoverTE.k15
#cp -r ${index} ${TMPDIR}/
#scratch_index=${TMPDIR}/$( basename ${index} )

SUFFIX="format.umi.quality15.t2.t3.hg38.name.marked.deduped.hg38.bam"
IN="/francislab/data1/working/20220610-EV/20221019-preprocess-trim-R1only-bowtie2correction/out"
OUT="/francislab/data1/working/20220610-EV/20221023-RepEnrich2/out"

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-d|--dir)
#			shift; OUT=$1; shift;;
#		*)
#			echo "Unknown params :${1}:"; exit ;;
#	esac
#done

mkdir -p ${OUT}

line=${SLURM_ARRAY_TASK_ID:-1}
echo "Running line :${line}:"

#	Use a 1 based index since there is no line 0.

#fasta=$( ls -tr1d ${IN}/*fa.gz | sed -n "$line"p )
#fasta=$( ls -1 ${IN}/*fa.gz | sed -n "$line"p )
bam=$( ls -1 ${IN}/*.${SUFFIX} | sed -n "$line"p )
echo $bam

if [ -z "${bam}" ] ; then
	echo "No line at :${line}:"
	exit
fi

date=$( date "+%Y%m%d%H%M%S%N" )

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

base=$( basename ${bam} .${SUFFIX} )




out_base=${OUT}/${base}

f=${out_base}_multimap.fastq

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
#if [ -d $f ] ; then
#	echo "$f exists. Skipping."
#
#	if [ -f ${f}/quant.sf ] ; then
#		echo "Gzipping"
#		chmod -R +w ${f}
#		gzip ${f}/quant.sf
#		chmod -R -w ${f}
#	fi
#
else



#		singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img python /RepEnrich2/RepEnrich2_subset.py -h
#	usage: RepEnrich2_subset.py [-h] [--version] [--pairedend PAIREDEND]
#	                            alignment_file MAPQ sample_name
#	
#	Prepartion for downstream running of RepEnrich2 by subsetting reads to
#	uniquely mapped and multi-mapped. For this script to run properly samtools and
#	bedtools must be loaded. You will need 1) An alignment file. 2) A defined MAPQ
#	threshold (30 by default) command-line usage EXAMPLE: python
#	RepEnrich_subset.py /example/path/data/alignment.sam 30
#	
#	positional arguments:
#	  alignment_file        bam file of aligned reads. Example
#	                        /example/path/alignment.bam
#	  MAPQ                  MAPQ threshold for subsetting uniquely mapping and
#	                        multi-mapping reads. This will be aligner-dependent as
#	                        many aligners treat the MAPQ field differently
#	                        (Default = 30)
#	  sample_name           The name of your sample (used to generate the name of
#	                        the output files)
#	
#	optional arguments:
#	  -h, --help            show this help message and exit
#	  --version             show program's version number and exit
#	  --pairedend PAIREDEND
#	                        Designate this option for paired-end data. Default
#	                        FALSE change to TRUE


	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img \
		python /RepEnrich2/RepEnrich2_subset.py ${bam} 20 ${out_base} --pairedend FALSE

	chmod -w ${out_base}_unique.bam
	chmod -w ${out_base}_multimap_filtered.bam
	chmod -w ${out_base}_multimap.fastq


fi



f=${out_base}/${base}_fraction_counts.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."

# base=$( basename $bam _unique.bam )
# sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=r${base} --time=2880 --nodes=1 --ntasks=16 --mem=120G \
#  --output=${PWD}/out/${base}.repenrich2.txt \
#  --wrap "


#	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img python /RepEnrich2/RepEnrich2.py -h
#	usage: RepEnrich2.py [-h] [--version] [--pairedend PAIREDEND]
#	                     [--collapserepeat collapserepeat]
#	                     [--fastqfile2 fastqfile2] [--cpus cpus]
#	                     [--allcountmethod allcountmethod] [--is_bed is_bed]
#	                     annotation_file outputfolder outputprefix setup_folder
#	                     fastqfile alignment_bam
#	
#	Part II: Conducting the alignments to the psuedogenomes. Before doing this
#	step you will require 1) a bamfile of the unique alignments with index 2) a
#	fastq file of the reads mapping to more than one location. These files can be
#	obtained using the following bowtie options [EXAMPLE: bowtie -S -m 1 --max
#	multimap.fastq mm9 mate1_reads.fastq] Once you have the unique alignment
#	bamfile and the reads mapping to more than one location in a fastq file you
#	can run this step. EXAMPLE: python master_output.py
#	/users/nneretti/data/annotation/hg19/hg19_repeatmasker.txt
#	/users/nneretti/datasets/repeatmapping/POL3/Pol3_human/HeLa_InputChIPseq_Rep1
#	HeLa_InputChIPseq_Rep1 /users/nneretti/data/annotation/hg19/setup_folder
#	HeLa_InputChIPseq_Rep1_multimap.fastq HeLa_InputChIPseq_Rep1.bam
#	
#	positional arguments:
#	  annotation_file       List RepeatMasker.org annotation file for your
#	                        organism. The file may be downloaded from the
#	                        RepeatMasker.org website. Example:
#	                        /data/annotation/hg19/hg19_repeatmasker.txt
#	  outputfolder          List folder to contain results. Example: /outputfolder
#	  outputprefix          Enter prefix name for data. Example:
#	                        HeLa_InputChIPseq_Rep1
#	  setup_folder          List folder that contains the repeat element
#	                        psuedogenomes. Example
#	                        /data/annotation/hg19/setup_folder
#	  fastqfile             Enter file for the fastq reads that map to multiple
#	                        locations. Example /data/multimap.fastq
#	  alignment_bam         Enter bamfile output for reads that map uniquely.
#	                        Example /bamfiles/old.bam
#	
#	optional arguments:
#	  -h, --help            show this help message and exit
#	  --version             show program's version number and exit
#	  --pairedend PAIREDEND
#	                        Designate this option for paired-end sequencing.
#	                        Default FALSE change to TRUE
#	  --collapserepeat collapserepeat
#	                        Designate this option to generate a collapsed repeat
#	                        type. Uncollapsed output is generated in addition to
#	                        collapsed repeat type. Simple_repeat is default to
#	                        simplify downstream analysis. You can change the
#	                        default to another repeat name to collapse a seperate
#	                        specific repeat instead or if the name of
#	                        Simple_repeat is different for your organism. Default
#	                        Simple_repeat
#	  --fastqfile2 fastqfile2
#	                        Enter fastqfile2 when using paired-end option. Default
#	                        none
#	  --cpus cpus           Enter available cpus per node. The more cpus the
#	                        faster RepEnrich performs. RepEnrich is designed to
#	                        only work on one node. Default: "1"
#	  --allcountmethod allcountmethod
#	                        By default the pipeline only outputs the fraction
#	                        count method. Consdidered to be the best way to count
#	                        multimapped reads. Changing this option will include
#	                        the unique count method, a conservative count, and the
#	                        total count method, a liberal counting strategy. Our
#	                        evaluation of simulated data indicated fraction
#	                        counting is best. Default = FALSE, change to TRUE
#	  --is_bed is_bed       Is the annotation file a bed file. This is also a
#	                        compatible format. The file needs to be a tab
#	                        seperated bed with optional fields. Ex. format chr
#	                        start end Name_element class family. The class and
#	                        family should identical to name_element if not
#	                        applicable. Default FALSE change to TRUE

else
	echo "Step 4) Run RepEnrich2 on the data"

	#	This creates folders pair1_ and sorted_ so it must be isolate from other runs in its own dir

	singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/RepEnrich2.img \
		python /RepEnrich2/RepEnrich2.py /francislab/data1/refs/RepEnrich2/hg38_repeatmasker_clean.txt \
			${out_base} ${base} \
			/francislab/data1/refs/RepEnrich2/setup_folder_hg38 \
			${out_base}_multimap.fastq \
			${out_base}_unique.bam \
			--cpus ${SLURM_NTASKS:-8} --pairedend FALSE

	chmod -w ${out_base}/${base}_class_fraction_counts.txt
	chmod -w ${out_base}/${base}_fraction_counts.txt
	chmod -w ${out_base}/${base}_family_fraction_counts.txt



#	cp ${fasta} ${TMPDIR}/
#	scratch_fasta=${TMPDIR}/$( basename ${fasta} )
#	scratch_out=${TMPDIR}/$( basename ${out_base} )
#
#	~/.local/bin/salmon.bash quant --seqBias --gcBias --index ${scratch_index} \
#		--no-version-check \
#		--libType A --validateMappings \
#		--unmatedReads ${scratch_fasta} \
#		-o ${scratch_out} --threads ${SLURM_NTASKS}
#
#	#	GOTTA move an existing dir or we'll move this INTO it.
#	if [ -d ${f} ] ; then
#		date=$( date "+%Y%m%d%H%M%S" --date="$( stat --printf '%z' ${f} )" )
#		mv ${f} ${f}.${date}
#	fi
#
#	chmod -R +w ${scratch_out}	#	so script can move and delete the contents (not crucial but stops error messages)
#	gzip ${scratch_out}/quant.sf
#
#	mv ${scratch_out} $( dirname ${f} )
#	chmod -R a-w ${f}
#
#	/bin/rm -rf ${scratch_fasta}

fi




echo "Done"
date

exit



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="RepEnrich2" --output="${PWD}/logs/RepEnrich2.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/RepEnrich2_array_wrapper.bash



scontrol update ArrayTaskThrottle=6 JobId=352083

