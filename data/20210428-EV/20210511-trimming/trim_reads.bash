#!/usr/bin/env bash

mkdir trimmed
cp /francislab/data1/raw/20210428-EV/Hansen/*.{subject,diagnosis,labkit} trimmed/


sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --parsable "

date=$( date "+%Y%m%d%H%M%S" )


for fastq in /francislab/data1/raw/20210428-EV/Hansen/SFHH00*.fastq.gz ; do
	echo $fastq

	basename=$( basename $fastq .fastq.gz )
	basename=${basename%%_*}
	echo $basename
	labkit=$( cat /francislab/data1/raw/20210428-EV/Hansen/${basename}.labkit )

	out_base=trimmed/${basename}
	f=${out_base}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"

		if [ ${labkit} == "D-plex" ] ; then
			#trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTG"
			#AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
			#trim_options="-a AGATCGGAAGAGCACACGTCTG"
			trim_options="-a AGATCGGAAGAGCACACGTC -a GATCGGAAGAGCACACGTCT -a ATCGGAAGAGCACACGTCTG -a TCGGAAGAGCACACGTCTGA -a CGGAAGAGCACACGTCTGAA -a GGAAGAGCACACGTCTGAAC -a GAAGAGCACACGTCTGAACT -a AAGAGCACACGTCTGAACTC -a AGAGCACACGTCTGAACTCC -a GAGCACACGTCTGAACTCCA -a AGCACACGTCTGAACTCCAG -a GCACACGTCTGAACTCCAGT -a CACACGTCTGAACTCCAGTC -a ACACGTCTGAACTCCAGTCA"
		elif [ ${labkit} == "Lexogen" ] ; then
			#TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC
			#trim_options="-a TGGAATTCTCGGGTGCCAAGGA"
			trim_options="-a TGGAATTCTCGGGTGCCAAG -a GGAATTCTCGGGTGCCAAGG -a GAATTCTCGGGTGCCAAGGA -a AATTCTCGGGTGCCAAGGAA -a ATTCTCGGGTGCCAAGGAAC -a TTCTCGGGTGCCAAGGAACT -a TCTCGGGTGCCAAGGAACTC -a CTCGGGTGCCAAGGAACTCC -a TCGGGTGCCAAGGAACTCCA -a CGGGTGCCAAGGAACTCCAG -a GGGTGCCAAGGAACTCCAGT -a GGTGCCAAGGAACTCCAGTC -a GTGCCAAGGAACTCCAGTCA -a TGCCAAGGAACTCCAGTCAC"
		else
			trim_options=""
		fi
#  -e RATE, --error-rate RATE

		${sbatch} --parsable --job-name=${basename} \
			--time=180 --ntasks=2 --mem=15G \
			--output=${out_base}.${date}.txt \
			~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
				${trim_options} -a AAAAAAAA -m 15 \
				-o ${f} ${fastq}
	fi

done

#count_fasta_reads.bash trimmed/*fastq.gz
#average_fasta_read_length.bash trimmed/*fastq.gz


