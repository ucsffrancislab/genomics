


Pre trimmed with 20210511-trimming

Pre processed with 20210518-preprocessing


Filter out all reads that align to ...
* Burholderia - CP019668.1 Burkholderia cenocepacia strain VC7848 chromosome, complete genome
* phi-X - NC_001422.1
* Burkholder phage - NC_009235.2


Then run ...
* iMOKA
* REdiscoverTE?



for a in output/SFHH00*.*.filtered.bam.aligned_count.txt ; do

for a in output/SFHH00*.cutadapt2.filtered.bam.aligned_count.txt ; do
u=${a/align/unalign}
ac=$( cat ${a} )
uc=$( cat ${u} )
c=$( echo "scale=2; 100 * ${ac} / ( ${ac} + ${uc} )" | bc -l 2> /dev/null )
echo $( basename $a .cutadapt2.filtered.bam.aligned_count.txt ),$c
done | sort > phiX.percentage.csv

samtools view /francislab/data1/raw/20210428-EV/indexes.phiX.sam | awk '{print $1","$2}' | sort > indexes.phiX.flags.csv

