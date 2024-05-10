
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



##	20240422


```
ln -s /francislab/data1/raw/20240328-Illumina-PhIP/fastq2

./EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out2 --extension .merged.fastq.gz \
  ${PWD}/fastq2/*.merged.fastq.gz

```

```
for baseind in HAPLib.1 HAPLib.2 LExPELib.1 LExPELib.2 vir3 VIR3_clean ; do 
echo $baseind; 
INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}; 
for fq in ${PWD}/out2/*fastq.gz ; do 
echo $fq; 
s=$(basename $fq .fastq.gz)_bt2alle2e; 
bam=${PWD}/out2/${s}.${baseind}.bam; 
echo ~/.local/bin/bowtie2.bash --threads 8 -x ${INDEX} --all --very-sensitive -U $fq --sort --output ${bam} >> commands; 
done; done 

commands_array_wrapper.bash --array_file commands --time 720 --threads 8 --mem 60G 
```




##	20240506

Where did the reads align?


```
samtools view -F20 out/S2_bt2alle2e.VIR3_clean.bam | cut -f4 | sort -n | uniq -c
  14632 1
   1183 2
    490 3
    168 4
     46 5
     20 6
     13 7
      7 8
```


Sample | n aligned direction | n aligned position | position | 


```
echo -e "sample,total,unaligned,aligned,forward,reverse,% unaligned,% aligned,% forward,% reverse,% aligned 0/1,% aligned 85/86,% aligned other" > align_analysis_1.csv
for s in S0 S1 S2 S3 S4 ; do
total=$( samtools view -c out/${s}_bt2alle2e.VIR3_clean.bam )
aligned=$( samtools view -c -F4 out/${s}_bt2alle2e.VIR3_clean.bam )
unaligned=$( samtools view -c -f4 out/${s}_bt2alle2e.VIR3_clean.bam )
forward=$( samtools view -c -F20 out/${s}_bt2alle2e.VIR3_clean.bam )
reverse=$( samtools view -c -F4 -f16 out/${s}_bt2alle2e.VIR3_clean.bam )
ap=$( echo "scale=2; 100 * ${aligned} / ${total}" | bc -l 2> /dev/null )
up=$( echo "scale=2; 100 * ${unaligned} / ${total}" | bc -l 2> /dev/null )
fp=$( echo "scale=2; 100 * ${forward} / ${aligned}" | bc -l 2> /dev/null )
rp=$( echo "scale=2; 100 * ${reverse} / ${aligned}" | bc -l 2> /dev/null )
astart=$( samtools view -F20 out/${s}_bt2alle2e.VIR3_clean.bam | cut -f4 | awk '(/^(1|2)$/)' | wc -l )
amiddle=$( samtools view -F20 out/${s}_bt2alle2e.VIR3_clean.bam | cut -f4 | awk '(/^(85|86)$/)' | wc -l )
aother=$( samtools view -F20 out/${s}_bt2alle2e.VIR3_clean.bam | cut -f4 | awk '(!/^(1|2|85|86)$/)' | wc -l )
asp=$( echo "scale=2; 100 * ${astart} / ${forward}" | bc -l 2> /dev/null )
amp=$( echo "scale=2; 100 * ${amiddle} / ${forward}" | bc -l 2> /dev/null )
aop=$( echo "scale=2; 100 * ${aother} / ${forward}" | bc -l 2> /dev/null )
echo -e "${s},${total},${unaligned},${aligned},${forward},${reverse},${up},${ap},${fp},${rp},${asp},${amp},${aop}"
done >> align_analysis_1.csv
```




```
sample	total	unaligned	aligned	forward	reverse	% unaligned	% aligned	% forward	% reverse
S0	349400	273478	75922	75866	56	78.27	21.72	99.92	.07
S1	76081	37980	38101	38101	0	49.92	50.07	100.00	0
S2	61745	35375	26370	26365	5	57.29	42.70	99.98	.01
S3	5095996	119724	4976272	4976067	205	2.34	97.65	99.99	0
S4	5339393	99504	5239889	5239593	296	1.86	98.13	99.99	0
```






```
\rm commands
for baseind in VIR3_clean.1-75 VIR3_clean.1-84 ; do 
echo $baseind; 
INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}; 
for fq in ${PWD}/out2/*fastq.gz ; do 
echo $fq; 
s=$(basename $fq .fastq.gz)_bt2alle2e; 
bam=${PWD}/out2/${s}.${baseind}.bam; 
echo ~/.local/bin/bowtie2.bash --threads 8 -x ${INDEX} --very-sensitive -U $fq --sort --output ${bam} >> commands; 
done; done 

commands_array_wrapper.bash --array_file commands --time 720 --threads 8 --mem 60G 
```



```

for v in VIR3_clean VIR3_clean.1-75 VIR3_clean.1-84 ; do
echo -e "sample,total,unaligned,aligned,forward,reverse,% unaligned,% aligned,% forward,% reverse,% aligned 0/1,% aligned 85/86,% aligned other" > align_analysis.${v}.csv
for s in S0 S1 S2 S3 S4 ; do
total=$( samtools view -c -F3840 out2/${s}_bt2alle2e.${v}.bam )
aligned=$( samtools view -c -F3844 out2/${s}_bt2alle2e.${v}.bam )
unaligned=$( samtools view -c -f4 -F3840 out2/${s}_bt2alle2e.${v}.bam )
forward=$( samtools view -c -F3860 out2/${s}_bt2alle2e.${v}.bam )
reverse=$( samtools view -c -F3844 -f16 out2/${s}_bt2alle2e.${v}.bam )
ap=$( echo "scale=2; 100 * ${aligned} / ${total}" | bc -l 2> /dev/null )
up=$( echo "scale=2; 100 * ${unaligned} / ${total}" | bc -l 2> /dev/null )
fp=$( echo "scale=2; 100 * ${forward} / ${aligned}" | bc -l 2> /dev/null )
rp=$( echo "scale=2; 100 * ${reverse} / ${aligned}" | bc -l 2> /dev/null )
astart=$( samtools view -F3860 out2/${s}_bt2alle2e.${v}.bam | cut -f4 | awk '(/^(1|2)$/)' | wc -l )
amiddle=$( samtools view -F3860 out2/${s}_bt2alle2e.${v}.bam | cut -f4 | awk '(/^(85|86)$/)' | wc -l )
aother=$( samtools view -F3860 out2/${s}_bt2alle2e.${v}.bam | cut -f4 | awk '(!/^(1|2|85|86)$/)' | wc -l )
asp=$( echo "scale=2; 100 * ${astart} / ${forward}" | bc -l 2> /dev/null )
amp=$( echo "scale=2; 100 * ${amiddle} / ${forward}" | bc -l 2> /dev/null )
aop=$( echo "scale=2; 100 * ${aother} / ${forward}" | bc -l 2> /dev/null )
echo -e "${s},${total},${unaligned},${aligned},${forward},${reverse},${up},${ap},${fp},${rp},${asp},${amp},${aop}"
done >> align_analysis.${v}.csv
done

```



```
echo -n -e "sample,total" > align_analysis.all.csv
for s in aligned forward "% aligned" "% forward" "% aligned 0/1" ; do
for v in 1-168 1-84 1-75 ; do
echo -n -e ",${s} ${v}"
done
done >> align_analysis.all.csv
echo >> align_analysis.all.csv

for s in S0 S1 S2 S3 S4 ; do
total=$( samtools view -c -F3840 out2/${s}_bt2alle2e.VIR3_clean.bam )
echo -n -e "${s},${total}"

for v in . .1-84. .1-75. ; do
aligned=$( samtools view -c -F3844 out2/${s}_bt2alle2e.VIR3_clean${v}bam )
echo -n -e ",${aligned}"
done

for v in . .1-84. .1-75. ; do
forward=$( samtools view -c -F3860 out2/${s}_bt2alle2e.VIR3_clean${v}bam )
echo -n -e ",${forward}"
done

for v in . .1-84. .1-75. ; do
aligned=$( samtools view -c -F3844 out2/${s}_bt2alle2e.VIR3_clean${v}bam )
ap=$( echo "scale=2; 100 * ${aligned} / ${total}" | bc -l 2> /dev/null )
echo -n -e ",${ap}"
done

for v in . .1-84. .1-75. ; do
aligned=$( samtools view -c -F3844 out2/${s}_bt2alle2e.VIR3_clean${v}bam )
forward=$( samtools view -c -F3860 out2/${s}_bt2alle2e.VIR3_clean${v}bam )
fp=$( echo "scale=2; 100 * ${forward} / ${aligned}" | bc -l 2> /dev/null )
echo -n -e ",${fp}"
done

for v in . .1-84. .1-75. ; do
forward=$( samtools view -c -F3860 out2/${s}_bt2alle2e.VIR3_clean${v}bam )
astart=$( samtools view -F3860 out2/${s}_bt2alle2e.VIR3_clean${v}bam | cut -f4 | awk '(/^(1|2)$/)' | wc -l )
asp=$( echo "scale=2; 100 * ${astart} / ${forward}" | bc -l 2> /dev/null )
echo -n -e ",${asp}"
done
echo

done >> align_analysis.all.csv

```



```
zcat /francislab/data1/refs/PhIP-Seq/VIR3_clean.uniq.fna.gz | paste - - | awk '{print $1"-a";print substr($2,1,70); print $1"-b";print substr($2,49,70);print $1"-c";print substr($2,99)}' | gzip > VIR3_clean.uniq.70.fna.gz
```

```
\rm commands
for baseind in VIR3_clean VIR3_clean.1-75 VIR3_clean.1-84 ; do 
echo $baseind; 
INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}; 
for fa in VIR3_clean.70.fna.gz ; do 
echo $fa; 
s=$(basename $fa .fna.gz)_bt2alle2e; 
bam=${PWD}/out2/${s}.${baseind}.bam; 
echo ~/.local/bin/bowtie2.bash --threads 8 -x ${INDEX} --very-sensitive -U $fa -f --sort --output ${bam} >> commands; 
done; done 

commands_array_wrapper.bash --array_file commands --time 720 --threads 8 --mem 60G 
```



```
zcat /francislab/data1/refs/PhIP-Seq/VIR3_clean.fna.gz | paste - - | wc -l
128257

```

In a perfect world, there should be 128257 at 1, 49 and 99, but that's not what happens.

```
samtools view -F20 out2/VIR3_clean.70_bt2alle2e.VIR3_clean.bam | cut -f4 | sort -n | uniq -c
  92069 1
  36087 15
      1 18
      3 30
      4 33
      1 36
      2 39
      4 42
      2 45
      7 48
 128228 49
      5 51
      7 54
     12 57
     15 60
     11 63
     14 66
     24 69
     27 72
      3 73
     24 75
     23 78
     38 81
     80 84
  36192 85
    125 87
      3 88
    233 90
      4 91
    285 93
      6 94
    388 96
      9 97
  90835 99


samtools view -F20 out2/VIR3_clean.70_bt2alle2e.VIR3_clean.1-75.bam | cut -f4 | sort -n | uniq -c
 128294 1
      1 2
     44 3
     25 4
      9 5
     28 6
     11 7
     30 8
     26 9
     20 10
     17 11
     23 12
     30 13
     20 14
   9625 15
     11 16


samtools view -F20 out2/VIR3_clean.70_bt2alle2e.VIR3_clean.1-84.bam | cut -f4 | sort -n | uniq -c
 128291 1
      1 2
     26 3
     25 4
     10 5
     17 6
     32 7
     47 8
     73 9
     84 10
     69 11
    140 12
    159 13
    136 14
  73257 15
     97 16
     33 17
    244 18
     37 19
      4 20
    289 21
      5 22
      3 23
      1 24
      1 25
      1 27


```



```
/c4/home/gwendt/.local/bin/bowtie2.bash --threads 8 -x /francislab/data1/refs/PhIP-Seq/VIR3_clean --very-sensitive -U /francislab/data1/refs/PhIP-Seq/VIR3_clean.fna.gz -f --sort --output /francislab/data1/working/20240328-Illumina-PhIP/20240328-PhIP-Seq/out2/VIR3_clean.bt2alle2e.VIR3_clean.bam

samtools view -F20 out2/VIR3_clean.bt2alle2e.VIR3_clean.bam | cut -f4 | sort -n | uniq -c
 128257 1

samtools view -f4 out2/VIR3_clean.bt2alle2e.VIR3_clean.bam 

```





##	20240508 - investigating homology and database size


```
\rm commands
for l in 70 80 90 100 110 120 130 140 150 160 168 ; do
baseind="VIR3_clean.1-${l}"
echo $baseind; 
INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}; 
for fq in ${PWD}/out2/*fastq.gz ; do 
echo $fq; 
s=$(basename $fq .fastq.gz)_bt2e2e; 
bam=${PWD}/out2/${s}.${baseind}.bam; 
echo ~/.local/bin/bowtie2.bash --threads 8 -x ${INDEX} --very-sensitive -U $fq --sort --output ${bam} >> commands; 
done; done 

commands_array_wrapper.bash --array_file commands --time 720 --threads 8 --mem 60G 
```




```
module load samtools

for s in S0 S1 S2 S3 S4 ; do
for l in 70 80 90 100 110 120 130 140 150 160 168 ; do
baseind="VIR3_clean.1-${l}"
a=$( samtools view -c -F3840 ${PWD}/out2/${s}_bt2e2e.${baseind}.bam )
b=$( samtools view -F3860 ${PWD}/out2/${s}_bt2e2e.${baseind}.bam | cut -f4 | awk '($1<5)' | wc -l )
c=$( echo "scale=2; 100 * ${b} / ${a}" | bc -l 2> /dev/null )
echo "${l} - ${s} - ${c}"
done
done
```






```
samtools view -h -F3860 out2/VIR3_clean.70_bt2alle2e.VIR3_clean.1-75.bam | samtools depth - | awk '($3>5)'
```





```
\rm commands
for l in 70 80 90 100 110 120 130 140 150 160 168 ; do
baseind="VIR3_clean.1-${l}"
INDEX=/francislab/data1/refs/PhIP-Seq/${baseind}; 
for fa in VIR3_clean.uniq.70.fna.gz ; do 
echo $fa; 
s=$(basename $fa .fna.gz)_bt2e2e; 
bam=${PWD}/out2/${s}.${baseind}.bam; 
echo ~/.local/bin/bowtie2.bash --threads 8 -x ${INDEX} --very-sensitive -U $fa -f --sort --output ${bam} >> commands; 
done; done 

commands_array_wrapper.bash --array_file commands --time 720 --threads 8 --mem 60G 
```



```
for l in 70 80 90 100 110 120 130 140 150 160 168 ; do
echo $l
samtools view -F20 out2/VIR3_clean.70_bt2e2e.VIR3_clean.1-${l}.bam | cut -f4 | sort -n | uniq -c | awk '$1>1000'
done
```








These initial VIR3 sequences are supposed to be overlapping by 84 bp which is why they also align at position 85 as well!




