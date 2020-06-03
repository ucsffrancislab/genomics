#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD

erv_path="/home/jake/.github/jakewendt/ERVcaller"

rm -f sample_list

for r1 in /raid/data/raw/MS-20190422/SF*_R1.fastq.gz ; do
	echo $r1
	r2=${r1/_R1./_R2.}
	echo $r2
	core=$( basename $r1 _R1.fastq.gz )

	if [ ${core} == "SF1A07_S7" ] ; then
		echo "Skipping SF1A07_S7"
		continue
	fi

	echo ${core} >> sample_list

	f=${wd}/${core}
	mkdir -p $f
	if [ -d $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		# MUST BE (-i)_1(-f) and (-i)_2(-f)
		ln -s ${r1} ${core}_1.fastq.gz
		ln -s ${r2} ${core}_2.fastq.gz

		${erv_path}/ERVcaller_v1.4.pl \
			-i ${core} \
			-f .fastq.gz \
			-O ${f} \
			-H /raid/refs/fasta/hg38.chr6.fa \
			-T /raid/refs/fasta/SVAs.fasta \
			-t 40 -S 20 -BWA_MEM

		rm ${core}_1.fastq.gz
		rm ${core}_2.fastq.gz

#		ln -s ${f}/${core}.vcf

		chmod a-w ${f}
	fi


	f=${core}.vcf

	if [ -f $f ] ; then
		echo "Link $f exists. Skipping."
	else
		echo "Creating $f"

		ln -s ${wd}/${core}/${core}.vcf
	fi




#	bwa seems to require its indexes in the same directory as the source fasta?
#	or maybe that's just these perl scripts?
#	regardless, the Human and TE files need to be indexed in the same dir.

#	Seems that the human reference MUST NOT BE COMPRESSED

#			-T /home/jake/.github/jakewendt/ERVcaller/Database/HERVK.fa \
#			-T /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta \
#			-T /raid/refs/fasta/HERVK113.fasta \
#			-T /raid/refs/fasta/SVAs.fasta \


#/raid/data/raw/CCLS_983899/983899_1.fastq.gz
# MUST BE _1 and _2
#	
#	output_dir=/raid/data/working/CCLS/20190405-983899-ERVCaller/HERVK113-fastq/
#	mkdir -p $output_dir
#	/home/jake/.github/jakewendt/ERVcaller/ERVcaller_v1.4.pl \
#		-I /raid/data/raw/CCLS_983899/ \
#		-i 983899 \
#		-f .fastq.gz \
#		-O ${output_dir} \
#		-H /raid/refs/fasta/hg38.num.fa \
#		-T /raid/refs/fasta/HERVK113.fasta \
#		-t 40 -S 20 -BWA_MEM &
#	
#	
#	Step 2 seems to be finding (-f 4 -F 264)
#	unmapped and mate mapped and not secondary
#	and putting them in 983899.recaled_su.bam

#	-f 8 -F 260 
#	Mapped and mate unmapped and not secondary
#	-> 983899.recaled_sm.bam

#	included SE_MEI not installed. Fails, but doesn't stop.

#~~~~ paired-end reads in bam format were loaded
#sh: 1: extractSoftclipped: not found
#[bam_sort_core] merging from 0 files and 39 in-memory blocks...
#[M::bam2fq_mainloop] discarded 0 singletons
#[M::bam2fq_mainloop] processed 6550378 reads
#
#gzip: 983899.recaled_soft.fastq.gz: unexpected end of file
#
#Chimeric and split reads...
#=====================================
#[E::bwa_idx_load] fail to locate the index files
#[E::bwa_idx_load] fail to locate the index files
#
#Improper reads...
#=====================================



#       -i|input_sampleID <STR>			Sample ID (required)
#       -f|file_suffix <STR>			The suffix of the input data, including: zipped FASTQ file (i.e., .fq.gz, and fastq.gz),
#						unzipped FASTQ file (i.e., .fq, and fastq),
#						BAM file (.bam), and a bam file list (.list; with "-multiple_BAM") (required). Default: .bam
#       -H|Human_reference_genome <STR>		The FASTA file of the human reference genome (required)
#       -T|TE_reference_genomes <STR>		The TE library (FASTA) used for screening (required)
#       -I|Input_directory <STR>			The directory of input data. Default: Not specified (current working directory)
#       -O|Output_directory <STR>		The directory for output data. Default: Not specified (current working directory)
#       -n|number_of_reads <INT>			The minimum number of reads support a TE insertion. Default: 3
#       -d|data_type <STR>			Data type, including: WGS, RNA-seq. Default: WGS
#       -s|sequencing_type <STR>			Type of sequencing data, including: paired-end, single-end. Default: paired-end
#       -l|length_insertsize <FLOAT>		Insert size length (bp). It will be estimated if it is not specified
#       -L|L_std_insertsize <FLOAT>		Standard deviation of insert size length (bp). It will be estimated if it is not specified
#       -r|read_len <INT>			Read length (bp), including: 100, 150, and 250 bp. Default: 100
#       -t|threads <INT>				The number of threads will be used. Default: 1
#       -S|Split <INT>				The minimum length for split reads. A longer length is recommended with longer read length. Default: 20
#       -m|multiple_BAM				If multiple BAM files are used as the input (input bam file need to be indexed). Default: not specified
#       -B|BWA_MEM				If the bam file is generated using aligner BWA_MEM. Default: Not specified
#       -G|Genotype				Genotyping function (input bam file need to be indexed). Default: not specified
#       -h|help					Print this help

done


f=all_samples_merged.vcf
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	##	Combine multiple samples with providing a list of consensus TE loci
	##	${erv_path}/Scripts/Combine_VCF_files.pl -l sample_list -c 1KGP.TE.sites.vcf >Output_merged.vcf  

	#	Combine multiple samples without providing a list of consensus TE loci
	#${erv_path}/Scripts/Combine_VCF_files.pl -l sample_list > ${f}

	#	The README example command is wrong.
	${erv_path}/Scripts/Combine_VCF_files.pl -l sample_list -o ${f}

	chmod a-w ${f}
fi




#	Calculate the number of reads support non-insertions at the consensus TE loci per sample
#	(It is recommended to filter out low-quality TE loci from the combined VCF file first before running this script)
#	${erv_path}/Scripts/Calculate_reads_among_nonTE_locations.pl -i Output_merged.vcf -S sampleID -o output.nonTE -b bamFile.bam -s paired-end -l length_insertsize -L std_insertsize -r read_length -t threads

#	Distinguish missing genotypes and non-insertion genotypes at the consensus TE loci to get the final genotypes for all samples
#	cat *.nonTE >nonTE_allsamples
#	${erv_path}/Scripts/Distinguish_nonTE_from_missing_genotype.pl -n nonTE_allsamples -v Output_merged.vcf -o Output_merged-final.vcf


