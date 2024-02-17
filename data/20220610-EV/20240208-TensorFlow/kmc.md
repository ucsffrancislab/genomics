

Try to count and dump counts using kmc (or other) without iMOKA

https://github.com/refresh-bio/KMC


```
wget https://github.com/refresh-bio/KMC/releases/download/v3.2.3/KMC3.2.3.linux.x64.tar.gz
```


```
input_file="NONE"
outputDir=$(realpath ./preprocess/)
library_type="NULL"
keepFiles="F"
minCounts="5"
kmer_len="31"
threads="1"
use_fastqc="F"
maxRam="12"
kmcCounterVal="4294967295"
samflag="NONE"
matrix_file=$(realpath ./create_matrix.tsv)

echo ${s_files} | awk '{for (i=1; i<= NF; i++) { print $i } }' > ./tmp_dir/kmc_input

kmc -k${kmer_len} -t${threads} -m${maxRam} -cs${kmcCounterVal} -ci${minCounts} -b -${file_type} @./tmp_dir/kmc_input ./tmp_dir/tmp.kmc ./working_dir/ 2>> ${logdir}/kmc.err >> ${logdir}/kmc.out  || count_success=$(( count_success + 1)) ;
kmc_tools transform ./tmp_dir/tmp.kmc dump -s ./tmp_dir/tmp.txt 2>> ${logdir}/kmc_tools.err >> ${logdir}/kmc_tools.out
```



First step creates a "database"

Second step converts to readable tsv file

Third step create binary tsv?


How to "rescale" or "normalize"?
iMOKA/iMOKA_core/src/Matrix/BinaryMatrix.cpp
	total counts is the total number of kmers in the sample.
  rescale factor is usually 1000000000
		normalization_factors[i] = (double) (total_counts[i] / rescale_factor);

	rescaled count = raw count * 1,000,000,000 / total counts ( not sure how the noted formula above worked? )

Still no idea what total_prefix or total_suffix is


how to dump all together


```

./bin/kmc -k10 -t8 -m32 -cs4294967295 -ci0 in/SFHH005z_S0.fastq.gz kmcout kmcdir

./bin/kmc_tools transform kmcout dump 10mers.txt


iMOKA_core create -i ./tmp_dir/kma.input -o "./${s_name}.json" -r 1 2>> ${logdir}/imoka_create.err >> ${logdir}/imoka_create.out

```

There is a "kmc filter" and "kmc transform reduce" that could be used.

There is also a "kmc complex" that may be usable to normalize / rescale the counts.





##	20240212

```
K-Mer Counter (KMC) ver. 3.2.3 (2023-12-08)
Usage:
 kmc [options] <input_file_name> <output_file_name> <working_directory>
 kmc [options] <@input_file_names> <output_file_name> <working_directory>
Parameters:
  input_file_name - single file in specified (-f switch) format (gziped or not)
  @input_file_names - file name with list of input files in specified (-f switch) format (gziped or not)
Options:
  -v - verbose mode (shows all parameter settings); default: false
  -k<len> - k-mer length (k from 1 to 256; default: 25)
  -m<size> - max amount of RAM in GB (from 1 to 1024); default: 12
  -sm - use strict memory mode (memory limit from -m<n> switch will not be exceeded)
  -hc - count homopolymer compressed k-mers (approximate and experimental)
  -p<par> - signature length (5, 6, 7, 8, 9, 10, 11); default: 9
  -f<a/q/m/bam/kmc> - input in FASTA format (-fa), FASTQ format (-fq), multi FASTA (-fm) or BAM (-fbam) or KMC(-fkmc); default: FASTQ
  -ci<value> - exclude k-mers occurring less than <value> times (default: 2)
  -cs<value> - maximal value of a counter (default: 255)
  -cx<value> - exclude k-mers occurring more of than <value> times (default: 1e9)
  -b - turn off transformation of k-mers into canonical form
  -r - turn on RAM-only mode 
  -n<value> - number of bins 
  -t<value> - total number of threads (default: no. of CPU cores)
  -sf<value> - number of FASTQ reading threads
  -sp<value> - number of splitting threads
  -sr<value> - number of threads for 2nd stage
  -j<file_name> - file name with execution summary in JSON format
  -w - without output
  -o<kmc/kff> - output in KMC of KFF format; default: KMC
  -hp - hide percentage progress (default: false)
  -e - only estimate histogram of k-mers occurrences instead of exact k-mer counting
  --opt-out-size - optimize output database size (may increase running time)
Example:
kmc -k27 -m24 NA19238.fastq NA.res /data/kmc_tmp_dir/
kmc -k27 -m24 @files.lst NA.res /data/kmc_tmp_dir/
```


```
file_type=$($read_files ${s_files} | head -n 1 | awk 'NR==1 { if ($0 ~ /^>/) { print "fm" } else { print "fq" } }')
echo ${s_files} | awk '{for (i=1; i<= NF; i++) { print $i } }' > ./tmp_dir/kmc_input

I don't understand what the @ symbol mean in the "@./tmp_dir/kmc_input" ???

 kmc [options] <input_file_name> <output_file_name> <working_directory>
 kmc [options] <@input_file_names> <output_file_name> <working_directory>
Parameters:
  input_file_name - single file in specified (-f switch) format (gziped or not)
  @input_file_names - file name with list of input files in specified (-f switch) format (gziped or not)
Options:


```




```
kmer_len=9
threads=8
maxRam=32
logdir="log_dir"
minCounts="0"
file_type="fq"
kmcCounterVal="4294967295"

mkdir tmp_dir
mkdir working_dir
mkdir ${logdir}


for f in in/SFHH005a[abcde]_S0.fastq.gz ; do
b=$( basename $f .fastq.gz )
echo $f > ./tmp_dir/kmc_input
./bin/kmc -k${kmer_len} -t${threads} -m${maxRam} -cs${kmcCounterVal} -ci${minCounts} -b -${file_type} @./tmp_dir/kmc_input ./tmp_dir/${b} ./working_dir/ 2>> ${logdir}/kmc.err >> ${logdir}/kmc.out

done

```



```
for f in in/SFHH005a[abcde]_S0.fastq.gz ; do
b=$( basename $f .fastq.gz )
./bin/kmc_tools transform tmp_dir/${b} dump -s tmp_dir/${b}.raw.tsv
cat tmp_dir/${b}.raw.tsv | datamash sum 2 > tmp_dir/${b}.total_kmer_count
total_kmer_count=$( cat tmp_dir/${b}.total_kmer_count )
awk -v sample=${b} -v total_kmer_count=${total_kmer_count} 'BEGIN{FS=OFS="\t";print "kmer",sample}{$2=$2*1000000000/total_kmer_count;print}' tmp_dir/${b}.raw.tsv > tmp_dir/${b}.normalized.tsv
done
```



```
join -t, -a1 -a2 -e0 -o0,1.2,2.2 <( sed 's/\t/,/' tmp_dir/SFHH005aa_S0.normalized.tsv ) <( sed 's/\t/,/' tmp_dir/SFHH005ab_S0.normalized.tsv ) | head

join -t, -a1 -a2 -e0 -oauto <( sed 's/\t/,/' tmp_dir/SFHH005aa_S0.normalized.tsv ) <( sed 's/\t/,/' tmp_dir/SFHH005ab_S0.normalized.tsv ) | head
```


```
i=0
for tsv in tmp_dir/*.normalized.tsv ; do
if [ $i -eq 0 ] ; then
a=${tsv}
else
join --header -t, -a1 -a2 -e0 -oauto <( sed 's/\t/,/' ${a} ) <( sed 's/\t/,/' ${tsv} ) > tmp_dir/joined.normalized.tmp.${i}.csv
a=tmp_dir/joined.normalized.tmp.${i}.csv
fi
i=$[i+1]
done

```











##	20240216

Note that iMOKA defaults to a minCount of 5 for kmc. I did not. My matrix is gonna be much bigger

iMOKA
 24929959

kmc-0 (roughly)
989949357



