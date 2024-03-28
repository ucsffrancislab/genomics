
#	20240328-Illumina-PhIP/20240328-PhIP-Seq


```
ln -s /francislab/data1/raw/20240328-Illumina-PhIP/fastq
```


#	
#	
#	```
#	module load samtools
#	mkdir bam
#	
#	for baseind in HAPLib.1 HAPLib.2 LExPELib.1 LExPELib.2 our_vir3 vir3 VIR3_clean ; do
#	echo $baseind
#	INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}
#	for fq in fastq/*fastq.gz ; do
#	echo $fq
#	s=$(basename $fq .fastq.gz)_bt2allloc
#	bam=bam/${s}.${baseind}.bam
#	bowtie2.bash -x ${INDEX} --all --very-sensitive-local -U $fq --sort --output ${bam}
#	samtools idxstats $bam | cut -f 1,3 | sed -e '/^\*\t/d' -e "1 i id\t${s}" | tr "\\t" "," > ${bam%.bam}.count.csv
#	done
#	done
#	```
#	
#	
#	
#	baseind=VIR3_clean
#	INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}
#	fq=fastq/S3.fastq.gz 
#	s=$(basename $fq .fastq.gz)_bt2allloc2
#	bam=bam/${s}.${baseind}.bam
#	bowtie2.bash --threads 8 -x ${INDEX} --all --very-sensitive-local -U $fq --sort --output ${bam}
#	fq=fastq/S4.fastq.gz 
#	s=$(basename $fq .fastq.gz)_bt2allloc2
#	bam=bam/${s}.${baseind}.bam
#	bowtie2.bash --threads 8 -x ${INDEX} --all --very-sensitive-local -U $fq --sort --output ${bam}
#	
#	
#	
#	```
#	
#	echo ",S0,S1,S2,S3,S4"
#	for baseind in HAPLib.1 HAPLib.2 LExPELib.1 LExPELib.2 vir3 VIR3_clean ; do
#	out="${baseind}"
#	for s in S0 S1 S2 S3 S4 ; do
#	c=$( cat bam/${s}_bt2allloc.${baseind}.bam.aligned_count.txt )
#	out="${out},${c}"
#	done
#	echo $out
#	done
#	
#	
#	```
#	
#	vir3 is 115753 50bp sequences
#	VIR3_clean is 115753 168bp sequences
#	
#	
#	
#	
#	


##	20240328

```
./EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out --extension .fastq.gz \
  ${PWD}/fastq/*.fastq.gz

```

```
for baseind in HAPLib.1 HAPLib.2 LExPELib.1 LExPELib.2 vir3 VIR3_clean ; do 
echo $baseind; 
INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}; 
for fq in ${PWD}/out/*fastq.gz ; do 
echo $fq; 
s=$(basename $fq .fastq.gz)_bt2alle2e; 
bam=${PWD}/out/${s}.${baseind}.bam; 
echo ~/.local/bin/bowtie2.bash --threads 8 -x ${INDEX} --all --very-sensitive -U $fq --sort --output ${bam} >> commands; 
done; done 

commands_array_wrapper.bash --array_file commands --time 720 --threads 8 --mem 60G 
```


```

echo ",S0,S1,S2,S3,S4" > counts.csv

#out="Total Reads"
#for s in S0 S1 S2 S3 S4 ; do
#c=$( cat fastq/${s}.fastq.gz.read_count.txt )
#out="${out},${c}"
#done
#echo $out >> counts.csv
#
#for baseind in HAPLib.1 HAPLib.2 LExPELib.1 LExPELib.2 vir3 VIR3_clean ; do
#out="${baseind}"
#for s in S0 S1 S2 S3 S4 ; do
#c=$( cat bam/${s}_bt2allloc.${baseind}.bam.aligned_count.txt )
#out="${out},${c}"
#done
#echo $out >> counts.csv
#done

out="Trimmed Reads"
for s in S0 S1 S2 S3 S4 ; do
c=$( cat out/${s}.fastq.gz.read_count.txt )
out="${out},${c}"
done
echo $out >> counts.csv

for baseind in HAPLib.1 HAPLib.2 LExPELib.1 LExPELib.2 vir3 VIR3_clean ; do
out="${baseind}"
for s in S0 S1 S2 S3 S4 ; do
c=$( cat out/${s}_bt2alle2e.${baseind}.bam.aligned_count.txt )
out="${out},${c}"
done
echo $out >> counts.csv
done

```


