
#	20230628-Costello


Tumor spatial RNA-seq



Looks like this was used for all samples

This is cutadapt 1.8.1 with Python 3.6.8
Command line parameters: -e 0.1 -q 20 -O 1 -a AGATCGGAAGAGC p471SF11834-V2_S90_R1_001.fastq.gz
Trimming 1 adapter with at most 10.0% errors in single-end mode ...
Finished in 1066.74 s (20 us/read; 2.97 M reads/minute).

So only trimmed R1? Not as a pair?


Using raw data and preprocessing


P, SF, and v and not unique for this data set so need to keep even the S#
```
mkdir fastq
for f in /costellolab/data2/jocostello/rna_all/C*/*[pP]*SF*v*_S*_L*_R?_*q.gz ; do
#echo $f
if [ -f ${f} ] ; then
 base=$( basename ${f} _001.fastq.gz )
 #base=${base%_S*}
 #base=${base#*p}
 #base=${base#*P}
 #base=${base/SF*v/v}
 base=${base/_L00?_/_}
 #r=${f#*_R}
 #r=${r%_0*}
 echo ${base}
 #echo ${base}_R${r}
 #ln -s ${f} fastq/${base}_R${r}.fastq.gz
 ln -s ${f} fastq/${base}.fastq.gz
fi
done

```





