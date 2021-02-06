

```BASH
./preprocess.bash








samtools flags UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY


for f in output/*fastq.gz ; do
zcat $f | paste - - - - | wc -l > $f.read_count
zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
done


for f in ${PWD}/output/*.trimmed.fastq.gz ; do

	basename=$( basename $f .fastq.gz )

	sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
		--output=${PWD}/output/${basename}.bowtie2phiX.output.txt \
		~/.local/bin/bowtie2.bash --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -U $f -o ${PWD}/output/${basename}.bowtie2phiX.bam

done


for f in output/*.bam ; do
samtools view -c -F 3844 $f > $f.aligned_count
done



for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
done

for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' > ${f}.transcript_ids
awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv ${f}.transcript_ids | sort | uniq -c | sort -rn > ${f}.gene_count
done

awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv output/*.toTranscriptome.out.bam.transcript_ids | sort | uniq -c | sort -rn > gene_count




for f in ${PWD}/output/*unmapped.fasta.gz ; do
  base=${f%.fasta.gz}
  basename=$(basename $base)
  echo $f
  for m in 0 1 ; do

    sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
      --output=${base}.sbatch.diamond.nr.masking${m}.output.txt \
      ~/.local/bin/diamond.bash blastx --query ${f} --threads 8 --db /francislab/data1/refs/diamond/nr \
        --outfmt 100 --out ${base}.nr.masking${m}.daa --masking ${m}

done ; done



./report.bash 
```









|    | SFHH001A_R1 | SFHH001B_R1 | Undetermined_R1 |
| --- | --- | --- | --- |
| Raw Read Count | 366663 | 382619 | 141627 |
| Raw Read Length | 301 | 301 | 301 |
| Trimmed Read Count | 240007 | 262535 | 139825 |
| Trimmed Ave Read Length | 55.5678 | 51.5464 | 274.402 |
| STAR Aligned to Transcriptome | 20045 | 23712 | 253 |
| STAR Aligned to Transcriptome % | 8.35 | 9.03 | .18 |
| STAR Aligned to Genome | 112578 | 119483 | 1566 |
| STAR Aligned to Genome % | 46.90 | 45.51 | 1.11 |
| Bowtie Aligned to phiX | 17384 | 18145 | 135927 |
| Bowtie Aligned to phiX % | 7.24 | 6.91 | 97.21 |
| MECP2 | 4720 | 8090 | 40 |
| P2RX6 | 4557 | 4116 | 63 |
| NAALADL2 | 4300 | 3380 |  |
| FGD2 | 2836 | 2797 |  |
| PACS2 | 2643 | 2070 | 30 |
| ESRRB | 1210 | 2248 | 30 |
| FOXO3 | 1368 | 1422 |  |
| L1CAM | 1164 | 1596 | 16 |
| ILDR2 | 1361 | 1288 |  |
| RNA45SN2 | 1258 | 1255 | 14 |
| RNA45SN4 | 1246 | 1252 | 14 |
| RNA45SN3 | 1244 | 1248 | 14 |
| RNA45SN1 | 1242 | 1242 | 14 |
| RNA45SN5 | 1235 | 1242 | 14 |
| AK9 | 720 | 1659 | 18 |
| LOC105374102 | 1048 | 1288 | 4 |
| EDEM3 | 1245 | 1050 | 12 |
| SIK3 | 971 | 1152 | 27 |
| GRB10 | 1222 | 894 |  |
| SLC22A1 | 1032 | 1032 | 24 |


```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210205 20210205-EV_CATS 20210205-preprocessing"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*daa ;do curl -netrc -T $f "${BOX}/" ; done
```


locally on my laptop
```BASH
for f in *daa ; do echo $f ;/Applications/MEGAN/tools/daa-meganizer --in ${f} --mapDB ~/megan/megan-map-Jul2020-2.db --threads 8; done
```

