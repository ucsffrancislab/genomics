

```
tail -n +2 /francislab/data1/raw/20191008_Stanford71/metadata.csv | awk -F"," '{print $1"\t"$2"\t/francislab/data1/working/20191008_Stanford71/20210326-preprocessing/output/"$1".bbduk2.unpaired.fastq.gz"}' > source.tsv

```


```
export SINGULARITY_BINDPATH=/francislab
singularity exec /francislab/data2/refs/singularity/iMOKA_extended-1.1.1.img iMOKA_core config -o config.json
```



```
./iMOKA.bash
```



```
module load samtools bowtie2
tail -n +2 51/output_fi.tsv | awk '{print ">"$1;print $1}' > 51/output_fi.fasta
bowtie2 -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts --very-sensitive -f -U 51/output_fi.fasta > 51/output_fi.sam

samtools view 51/output_fi.sam | awk '{print $1, $3, $4}'
GCCGAAGCCTCAAGGAAGGGATGCTTTTGTAAAACAAGACTTGTGGAATAT chr1 264478
TACATTGGATTACATTCGTTGATGATTTCATTCGGTTCCATTCAATGATGA chr16 34582282
TGTAAATGTTCTGTAGACGTTGACAGAAATAGCTATTTGGAGCTGCGCTTT chr22 12891377
AGAATTAGATATAATGACAGTTATTATATTTTTAAACCTTTCAAATAAGAA chr4 189899197
CACTCCACTACATTCTATTACATCCAATTCCATTCCACTCAATTCCACTCC chr16 34062261
ACTCATCTCACAGAGTTGAAGTTTTCTTTTGAATGAGCAGTTTGGAAACAC chr22 12335389
TTTTCTTTGAAGACATTACCGTTTCCAACGAAATCCTCACAGCTATCCAAA chr8 45684339
CTCCCAAAGGGCTGGAATTACAGACAAGAGCCGCTGCACACAGCCACATGT chr22 12193396
GTGGGCTTCATCCCTGGGATGCAAGGCTGGTTCAAAATACACAAATCAATA chr6 69257006
AATCTGAACCATCTATCGATTAAGCTCTCAAAAACTAAATAGACTGCTGCC chr9 65898848
CAAATGACCCTAAATCCCTCACTAACCTACCCCTGCCCTCACTAAACTTAA chr4 99232256
AAGTTAGGTTATCAGTCTTTCTACCTATTAAGTTAGGTTGCAGTTTGTCCA chr3_GL000221v1_random 62070
TTTAAACTTCTGAGTTTTCATCGAGATTAACATGCATTTGTTGAAAGAGAA chr14 19032261

while read -r chr pos ; do
echo $chr $pos
awk -v chr=$chr -v pos=$pos '( ($1==chr) && ( $4 < pos+1000 ) && ( $5 > pos-1000 ) )' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf
done < <( samtools view 51/output_fi.sam | awk '{print $3, $4}' )


while read -r chr pos ; do
echo $chr $pos
awk -v chr=$chr -v pos=$pos '( ($1==chr) && ( $4 < pos+1000 ) && ( $5 > pos-1000 ) )' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf
done < <( samtools view 51/output_fi.all.sam | grep TACATTGGATTACATTCGTTGATGATTTCATTCGGTTCCATTCAATGATGA  | awk '{print $3, $4}' )


bowtie2 --all -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts --very-sensitive -f -U 51/output_fi.fasta > 51/output_fi.all.sam
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA/31"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 31/aggregated.json "${BOX}/"
curl -netrc -T 31/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA/41"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 41/aggregated.json "${BOX}/"
curl -netrc -T 41/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA/51"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 51/aggregated.json "${BOX}/"
curl -netrc -T 51/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA/61"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 61/aggregated.json "${BOX}/"
curl -netrc -T 61/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA/71"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 71/aggregated.json "${BOX}/"
curl -netrc -T 71/output.json "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20191008_Stanford71/20210714-iMOKA/81"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T 81/aggregated.json "${BOX}/"
curl -netrc -T 81/output.json "${BOX}/"
```



