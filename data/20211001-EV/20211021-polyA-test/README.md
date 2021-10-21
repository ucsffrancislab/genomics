# Cutadapt polyA trimming comparisons



Multiple lengths of AAAAAAA to see how long many get trimmed with each try



```
./process.bash
```



```
for r1 in /francislab/data1/working/20211001-EV/20211003-explore/out/SFHH008?.quality.R1.fastq.gz ; do
  b=$( basename ${r1} .quality.R1.fastq.gz )
  \rm ${b}.polyA.csv
  d=$( cat ${r1}.read_count.txt )
  for i in $( seq 1 151 ); do
    n=$( zcat ${r1} | paste - - - - | cut -f2 | grep -c -e "A\{${i}\}" )
    echo -e "${i}\t${n}\t${d}" >> ${b}.polyA.csv
  done
done

for f in *polyA.csv ; do
  ./distributions.py ${f}
done
```



