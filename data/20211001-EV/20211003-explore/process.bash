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
#		AAAAAAAAAAAAAACTGTCTCTTATACACATCTCCGAGCCCACGAGAC
#		TTTTTTTTTTTTTTGACAGAGAATATGTGTAGAGGCTCGGGTGCTCTG
#    cutadapt -a ADAPT1 -A ADAPT2 [options] -o out1.fastq -p out2.fastq in1.fastq in2.fastq
		tid=$( ${sbatch} ${depend} --job-name=t${s} --time=60 --nodes=1 --ntasks=4 --mem=30G --output=${outbase}.${date}.out.txt \
			~/.local/bin/cutadapt.bash \
				 --match-read-wildcards -n 4 \
				-a AAAAAAAA -a TTTTTTTT \
				-a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC \
				-a GACAGAGAATATGTGTAGAGGCTCGGGTGCTCTG \
				-m 15 --trim-n \
				-o ${outbase}.R1.fastq.gz \
				${inbase}.R1.fastq.gz )
#			~/.local/bin/cutadapt.bash \
#				 --match-read-wildcards -n 2 \
#				-a AAAAAAAA -a TTTTTTTT \
#				-A AAAAAAAA -A TTTTTTTT -U 10 \
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
			--very-sensitive-local -U ${inbase}.fastq -o ${f} --un ${outbase}.fastq )
	fi

	ntid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk.hg38.nt"
	f=${outbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${hg38id} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${hg38id} "
		fi
		ntid=$( ${sbatch} ${depend} --job-name=nt${s} --time=600 --ntasks=8 --mem=60G \
			--output=${outbase}.${date}.txt \
			~/.local/bin/blastn.bash -num_threads 8 \
				-query ${inbase}.fastq \
				-db /francislab/data1/refs/blastn/nt \
				-outfmt 6 \
				-out ${f} )
	fi

	sgfid=""
	inbase=${outbase}
	outbase="${OUT}/${s}.quality.format.consolidate.trimmed.phiX.salmon.burk.hg38.nt.species_genus_family"
	f=${outbase}.txt.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ -z ${ntid} ] ; then
			depend=""
		else
			depend=" --dependency=afterok:${ntid} "
		fi

		threads=4
		db=/francislab/data1/refs/taxadb/asgf.sqlite
		input=${inbase}.txt.gz
		db_size=$( stat --dereference --format %s ${db} )

		if [ -f ${input} ] ; then
			input_size=$( stat --dereference --format %s ${input} )	#	output should be similar
		else
			#	biggest existing.
			#input_size=17000000000
			input_size=10000000000
		fi

		#	Occassionally jobs fail, apparently due to out of disk space.
		#	cp: failed to extend ‘/scratch/gwendt/105418/asgf.sqlite’: No space left on device
		#	Others aren't properly requesting scratch space, or perhaps I'm doing this wrong.
		#	Increase request size
		#
		#	I'm guessing that the number of threads is not relevant on C4?
		#	This seems to be the case. Requesting 227GB each and running 11 on n17
		#	Roughly 2.5TB and n17 has 2.6TB. Remove threads from all scratch calculations.
		#
		#index_size=$( du -sb ${index} | awk '{print $1}' )
		#scratch=$( echo $(( (((3*${input_size})+${db_size})/${threads}/1000000000*20/10)+1 )) )
		#scratch=$( echo $(( (((3*${input_size})+${db_size})/1000000000*13/10)+1 )) )
		scratch=$( echo $(( (((2*${input_size})+${db_size})/1000000000*12/10)+1 )) )
		# Add 1 in case files are small so scratch will be 1 instead of 0.
		# 11/10 adds 10% to account for the output
		# 12/10 adds 20% to account for the output

		echo "Using scratch:${scratch}"

		sgfid=$( ${sbatch} ${depend} --job-name=sgf${s} --time=600 --ntasks=4 --mem=30G \
			--output=${outbase}.${date}.txt \
			--gres=scratch:${scratch}G \
			~/.local/bin/add_species_genus_family_to_blast_output_scratch.bash \
				-input ${inbase}.txt.gz )
		echo $sgfid
	fi

#	cat out/SFHH008?.quality.format.consolidate.trimmed.phiX.salmon.burk.hg38.nt.species_genus_family.family_counts | awk '{s[$2]+=$1}END{for(k in s){print k k[s]}}'
#| sort | uniq -c | sort -rn | head -50

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


#				-m 15 --trim-n \

#	cutadapt --trim-n --match-read-wildcards -n 5 -a AAAAAA -G TTTTTT -U 10 -o SFHH008A.quality.format.consolidate.trimmed2.R1.fastq.gz -p SFHH008A.quality.format.consolidate.trimmed2.R2.fastq.gz SFHH008A.quality.format.consolidate.R1.fastq.gz SFHH008A.quality.format.consolidate.R2.fastq.gz

