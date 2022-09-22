#!/usr/bin/env bash

dir=out


rawdir=/francislab/data1/raw/20220610-EV
for fastq in ${rawdir}/S*R?_001.fastq.gz ; do
	basename=$( basename $fastq .fastq.gz )
#	basename=${basename%%_*}
	basename=${basename%_001}
	r=${basename##*_}
	basename=${basename%%_*}
	ln -s ${fastq} ${dir}/${basename}_${r}.fastq.gz 2> /dev/null
	if [ -f ${fastq}.read_count.txt ] ; then
		ln -s ${fastq}.read_count.txt ${dir}/${basename}_${r}.fastq.gz.read_count.txt 2> /dev/null
	fi
done


samples=$( ls -1 /francislab/data1/raw/20220610-EV/S*_R1_*fastq.gz | awk -F/ '{print $NF}' | awk -F_ '{print $1}' | paste -s -d" " )



echo -n "|    |"
for s in ${samples} ; do
	echo -n " ${s} |"
done
echo

echo -n "| --- |"
for s in ${samples} ; do
	echo -n " --- |"
done
echo

echo -n "| meta |"
for s in ${samples} ; do
	c=$( awk -F, -v s=${s} '( $1 == s ){print $10}' metadata.csv )
	echo -n " ${c} |"
done
echo

echo -n "| Paired Raw Read Count |"
for s in ${samples} ; do
	c=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done
echo


#for q in 15 20 25 30 ; do
#for q in 15 20 25 ; do
for q in 15 ; do

	echo -n "| q${q} |"
	for s in ${samples} ; do
		echo -n " | "
	done
	echo
	
	echo -n "| q${q} Quality Read Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.R1.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} Quality % Read Count |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.R1.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}_R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo


	echo -n "| q${q} Format Read Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} Format % Read Count |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo


	echo -n "| q${q} UMI Trim Read Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} UMI Trim % Read Count |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} UMI Trim Ave R1 Read Length |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.R1.fastq.gz.average_length.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} UMI Trim Ave R2 Read Length |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.R2.fastq.gz.average_length.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	
	echo -n "| q${q} adapter Trim Read Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.R1.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} adapter Trim % Read Count |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.R1.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} adapter Trim Ave R1 Read Length |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.R1.fastq.gz.average_length.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} adapter Trim Ave R2 Read Length |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.R2.fastq.gz.average_length.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	
	
	echo -n "| q${q} poly Trim Read Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} poly Trim % Read Count |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} poly Trim Ave R1 Read Length |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.R1.fastq.gz.average_length.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} poly Trim Ave R2 Read Length |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.R2.fastq.gz.average_length.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	
	echo -n "| q${q} Not PhiX Read Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.R1.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} Not PhiX % Read Count |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.R1.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo


	echo -n "| q${q} pear assembled Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.pear.assembled.fastq.gz.read_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} pear assembled % |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.pear.assembled.fastq.gz.read_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	

	echo -n "| q${q} hg38 aligned Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.bam.aligned_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} hg38 aligned % |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.bam.aligned_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} hg38 unaligned Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.bam.unaligned_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} hg38 unaligned % |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.bam.unaligned_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.R1.fastq.gz.read_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo


	echo -n "| q${q} hg38 deduped Count |"
	for s in ${samples} ; do
		c=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.name.mated.marked.bam.F3844.aligned_count.txt 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	
	echo -n "| q${q} hg38 deduped aligned % |"
	for s in ${samples} ; do
		n=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.name.mated.marked.bam.F3844.aligned_count.txt 2> /dev/null)
		d=$(cat ${dir}/${s}.quality${q}.format.umi.t1.t2.t3.notphiX.readname.hg38.bam.aligned_count.txt 2> /dev/null)
		c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
		echo -n " ${c} |"
	done
	echo
	

done


