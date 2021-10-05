#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

#threads=32	#32 # 64
#mem=7		#	per thread (keep 7)

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --parsable "

IN="/francislab/data1/raw/20211001-EV"	#/SFHH008A_S1_L001_R2_001.fastq.gz
OUT="${PWD}/out"
mkdir -p ${OUT}

for r1 in ${IN}/SFHH0*_R1_*.fastq.gz ; do

	echo $r1
	r2=${r1/_R1_/_R2_}
	echo $r2
	s=$( basename $r1 )
	s=${s%%_*}
	b1=${s}.quality.R1.fastq.gz
	b2=${s}.quality.R2.fastq.gz
	echo $b1
	echo $b2


	qid=""
	outbase="${OUT}/${s}.quality"
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qid=$( ${sbatch} --job-name=q${s} --time=60 --nodes=1 --ntasks=4 --mem=30G --output=${outbase}.${date}.out.txt \
		~/.local/bin/bbduk.bash in1=${r1} in2=${r2} out1=${outbase}.R1.fastq.gz out2=${outbase}.R2.fastq.gz minavgquality=15 )
		echo $qid
	fi


	fid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format"
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${qid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${qid} "
		fi
		fid=$( ${sbatch} ${depend} --job-name=f${s} --time=60 --nodes=1 --ntasks=4 --mem=30G --output=${oubase}.${date}.out.txt \
			${PWD}/format_filter.bash \
				${inbase}.R1.fastq.gz \
				${inbase}.R2.fastq.gz \
				${outbase}.R1.fastq.gz \
				${outbase}.R2.fastq.gz )
		echo $fid
	fi


	cid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate"
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${fid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${fid} "
		fi
		cid=$( ${sbatch} ${depend} --job-name=c${s} --time=60 --nodes=1 --ntasks=4 --mem=30G --output=${outbase}.${date}.out.txt \
			${PWD}/consolidate_umi.bash \
				9 \
				${inbase}.R1.fastq.gz \
				${inbase}.R2.fastq.gz \
				${outbase}.R1.fastq.gz \
				${outbase}.R2.fastq.gz )
		echo $cid
	fi


	tid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed"
	f=${outbase}.R1.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${cid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${cid} "
		fi
#    cutadapt -a ADAPT1 -A ADAPT2 [options] -o out1.fastq -p out2.fastq in1.fastq in2.fastq
		tid=$( ${sbatch} ${depend} --job-name=t${s} --time=60 --nodes=1 --ntasks=4 --mem=30G --output=${outbase}.${date}.out.txt \
			~/.local/bin/cutadapt.bash \
				 --match-read-wildcards -n 2 \
				-a AAAAAAAA -a TTTTTTTT \
				-m 15 --trim-n \
				-o ${outbase}.R1.fastq.gz \
				${inbase}.R1.fastq.gz )
#			~/.local/bin/cutadapt.bash \
#				 --match-read-wildcards -n 2 \
#				-a AAAAAAAA -a TTTTTTTT \
#				-A AAAAAAAA -A TTTTTTTT -U 9 \
#				-m 15 --trim-n \
#				-o ${OUT}/${s}.quality.format.consolidate.trimmed.R1.fastq.gz \
#				-p ${OUT}/${s}.quality.format.consolidate.trimmed.R2.fastq.gz \
#				${OUT}/${s}.quality.format.consolidate.R1.fastq.gz \
#				${OUT}/${s}.quality.format.consolidate.R2.fastq.gz )
		echo $tid
				#-a AAAAAAAA -G TTTTTTTT \
	fi


	phixid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed.phiX"
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${tid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${tid} "
		fi
		phixid=$( ${sbatch} ${depend} --job-name=p${s} --time=30 --ntasks=4 --mem=30G \
			--output=${outbase}.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/phiX \
			--very-sensitive-local -U ${inbase}.R1.fastq.gz -o ${f} --un ${outbase}.fastq )
	fi



	salmonid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed.phiX.salmon"
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${phixid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${phixid} "
		fi
		salmonid=$( ${sbatch} ${depend} --job-name=s${s} --time=30 --ntasks=4 --mem=30G \
			--output=${outbase}.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/salmonella \
			--very-sensitive-local -U ${inbase}.fastq -o ${f} --un ${outbase}.fastq )
	fi



	burkid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk"
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${salmonid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${salmonid} "
		fi
		burkid=$( ${sbatch} ${depend} --job-name=b${s} --time=30 --ntasks=4 --mem=30G \
			--output=${outbase}.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/burkholderia \
			--very-sensitive-local -U ${inbase}.fastq -o ${f} --un ${outbase}.fastq )
	fi



	hg38id=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk.hg38"
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${burkid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${burkid} "
		fi
		hg38id=$( ${sbatch} ${depend} --job-name=h${s} --time=30 --ntasks=8 --mem=60G \
			--output=${outbase}.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
			--very-sensitive-local -U ${inbase}.fastq -o ${f} )
	fi


done

#	minavgquality=10
#	out/SFHH008A.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	out/SFHH008B.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	out/SFHH008C.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	out/SFHH008D.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	out/SFHH008E.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	out/SFHH008F.out.txt:Total Removed:          	0 reads (0.00%) 	0 bases (0.00%)
#	
#	minavgquality=20
#	out/SFHH008A.out.txt:Total Removed:          	243854 reads (84.03%) 	36821954 bases (84.03%)
#	out/SFHH008B.out.txt:Total Removed:          	266204 reads (84.30%) 	40196804 bases (84.30%)
#	out/SFHH008C.out.txt:Total Removed:          	179040 reads (83.93%) 	27035040 bases (83.93%)
#	out/SFHH008D.out.txt:Total Removed:          	259432 reads (83.72%) 	39174232 bases (83.72%)
#	out/SFHH008E.out.txt:Total Removed:          	290410 reads (84.72%) 	43851910 bases (84.72%)
#	out/SFHH008F.out.txt:Total Removed:          	400742 reads (88.74%) 	60512042 bases (88.74%)
#	
#	minavgquality=15
#	out/SFHH008A.out.txt:Total Removed:          	3158 reads (1.09%) 	476858 bases (1.09%)
#	out/SFHH008B.out.txt:Total Removed:          	3578 reads (1.13%) 	540278 bases (1.13%)
#	out/SFHH008C.out.txt:Total Removed:          	2892 reads (1.36%) 	436692 bases (1.36%)
#	out/SFHH008D.out.txt:Total Removed:          	4174 reads (1.35%) 	630274 bases (1.35%)
#	out/SFHH008E.out.txt:Total Removed:          	4622 reads (1.35%) 	697922 bases (1.35%)
#	out/SFHH008F.out.txt:Total Removed:          	8422 reads (1.86%) 	1271722 bases (1.86%)



