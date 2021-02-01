

```BASH
nohup ./subsample.bash &



for bam in bam/122*bam ; do
echo $bam
samtools idxstats $bam | awk -vreadlen=150 '{len+=$2;nreads+=$3}END{print nreads * readlen / len }' > $bam.coverage
done

nohup ./call.bash &
```

for some reason seed 13 creates a problematic bam file for 120207.60a.bam that fails when calling for vcf
and 50a. Trying seed 17.
this is odd since the full file does not have a problem

```
cat 120207.60a.mpileup.out.txt
Note: none of --samples-file, --ploidy or --ploidy-file given, assuming all sites are diploid
  pileup] 1 samples in 1 input files
[mpileup] maximum number of reads per input file set to -d 250
bcftools: sam.c:3948: resolve_cigar2: Assertion `k < c->n_cigar' failed.
Error: could not parse the input VCF
index: the input is probably truncated, use -f to index anyway: /francislab/data1/working/CCLS/20210121-downsampling_test/vcf/120207.60a.vcf.gz

cat vcf/corrupt/120207.50a.mpileup.out.txt 
Note: none of --samples-file, --ploidy or --ploidy-file given, assuming all sites are diploid
[mpileup] 1 samples in 1 input files
[mpileup] maximum number of reads per input file set to -d 250
bcftools: sam.c:3948: resolve_cigar2: Assertion `k < c->n_cigar' failed.
Error: could not parse the input VCF
index: the input is probably truncated, use -f to index anyway: /francislab/data1/working/CCLS/20210121-downsampling_test/vcf/120207.50a.vcf.gz
```

recreated bam file with same result. Could try different seed


Mismatch of chrM and MT so not included in output


```BASH
mkdir newvcf
for f in vcf/122*vcf.gz ; do
echo $f
new=$( basename $f .vcf.gz )
old=${new%.*}
echo "Sub ${old} with ${new}"
zcat $f | sed "/^#CHROM/s/${old}/${new}/" | bgzip > newvcf/${new}.vcf.gz
bcftools index newvcf/${new}.vcf.gz
done
```



They can be merged into 1 giant vcf file or compared with something like ...
`bedtools intersect ...`
 or
`bcftools isec ...`


#	put in decreasing order
```
nohup bcftools merge -o 120207.vcf.gz -Oz newvcf/120207.100.vcf.gz newvcf/120207.80?.vcf.gz newvcf/120207.60?.vcf.gz newvcf/120207.50?.vcf.gz &
nohup bcftools merge -o 122997.vcf.gz -Oz newvcf/122997.100.vcf.gz newvcf/122997.80?.vcf.gz newvcf/122997.60?.vcf.gz newvcf/122997.50?.vcf.gz &
nohup bcftools merge -o 186069.vcf.gz -Oz newvcf/186069.100.vcf.gz newvcf/186069.80?.vcf.gz newvcf/186069.60?.vcf.gz newvcf/186069.50?.vcf.gz &
```


```BASH
for f in newvcf/*.*.vcf.gz; do echo $f ; bcftools view --no-header $f | wc -l > $f.count ; done

for f in newvcf/*.*.vcf.gz; do echo $f ; bcftools isec -C ${f%%.*}.100.vcf.gz ${f} | wc -l > $f.100_isec_count ; done
for f in newvcf/*.*.vcf.gz; do echo $f ; bcftools isec -C ${f} ${f%%.*}.100.vcf.gz | wc -l > $f.isec_100_count ; done



for f in newvcf/*.*.vcf.gz; do echo $f ; bcftools isec -n =2 ${f} ${f%%.*}.100.vcf.gz | wc -l > $f.shared_100_isec_count ; done
for f in newvcf/*.*.vcf.gz; do echo $f ; bcftools isec -n -1 ${f} ${f%%.*}.100.vcf.gz | wc -l > $f.diff_100_isec_count ; done


```



Upload ...
```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210127 CCLS 20210121-downsampling_test"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T 122997.vcf.gz "${BOX}/"
curl -netrc -T 122997.vcf.gz.csi "${BOX}/"

```


|    | 120207 | 122997 | 186069 |
| --- | --- | --- | --- |
| Calls 100 | 4928327 | 4860894 | 5572749 |
| Calls 80a | 4890812 | 4826081 | 5534195 |
| Calls 80b | 4890148 | 4826205 | 5533788 |
| Calls 80c | 4890206 | 4826311 | 5534199 |
| Calls 60a | 4841176 | 4777832 | 5480342 |
| Calls 60b | 4840584 | 4777717 | 5479350 |
| Calls 60c | 4840677 | 4777998 | 5479872 |
| Calls 50a | 4807865 | 4743739 | 5442461 |
| Calls 50b | 4808378 | 4743381 | 5441249 |
| Calls 50c | 4807947 | 4744365 | 5442610 |
| % Calls 100/100 | 100.00 | 100.00 | 100.00 |
| % Calls 80a/100 | 99.23 | 99.28 | 99.30 |
| % Calls 80b/100 | 99.22 | 99.28 | 99.30 |
| % Calls 80c/100 | 99.22 | 99.28 | 99.30 |
| % Calls 60a/100 | 98.23 | 98.29 | 98.34 |
| % Calls 60b/100 | 98.21 | 98.28 | 98.32 |
| % Calls 60c/100 | 98.22 | 98.29 | 98.33 |
| % Calls 50a/100 | 97.55 | 97.58 | 97.66 |
| % Calls 50b/100 | 97.56 | 97.58 | 97.64 |
| % Calls 50c/100 | 97.55 | 97.60 | 97.66 |
| isec Diff Calls 100 100 | 0 | 0 | 0 |
| isec Diff Calls 100 80a | 163311 | 155771 | 163286 |
| isec Diff Calls 100 80b | 164301 | 155701 | 163321 |
| isec Diff Calls 100 80c | 164139 | 156165 | 164094 |
| isec Diff Calls 100 60a | 287485 | 272262 | 286467 |
| isec Diff Calls 100 60b | 287749 | 271023 | 286057 |
| isec Diff Calls 100 60c | 287122 | 272074 | 286001 |
| isec Diff Calls 100 50a | 354066 | 335957 | 352748 |
| isec Diff Calls 100 50b | 353597 | 334725 | 352008 |
| isec Diff Calls 100 50c | 353060 | 335113 | 352239 |
| isec Shared Calls 100 100 | 4928327 | 4860894 | 5572749 |
| isec Shared Calls 100 80a | 4827914 | 4765602 | 5471829 |
| isec Shared Calls 100 80b | 4827087 | 4765699 | 5471608 |
| isec Shared Calls 100 80c | 4827197 | 4765520 | 5471427 |
| isec Shared Calls 100 60a | 4741009 | 4683232 | 5383312 |
| isec Shared Calls 100 60b | 4740581 | 4683794 | 5383021 |
| isec Shared Calls 100 60c | 4740941 | 4683409 | 5383310 |
| isec Shared Calls 100 50a | 4691063 | 4634338 | 5331231 |
| isec Shared Calls 100 50b | 4691554 | 4634775 | 5330995 |
| isec Shared Calls 100 50c | 4691607 | 4635073 | 5331560 |
| % isec Shared Calls 100/100 | 100.00 | 100.00 | 100.00 |
| % isec Shared Calls 80a/100 | 97.96 | 98.03 | 98.18 |
| % isec Shared Calls 80b/100 | 97.94 | 98.04 | 98.18 |
| % isec Shared Calls 80c/100 | 97.94 | 98.03 | 98.18 |
| % isec Shared Calls 60a/100 | 96.19 | 96.34 | 96.60 |
| % isec Shared Calls 60b/100 | 96.19 | 96.35 | 96.59 |
| % isec Shared Calls 60c/100 | 96.19 | 96.34 | 96.60 |
| % isec Shared Calls 50a/100 | 95.18 | 95.33 | 95.66 |
| % isec Shared Calls 50b/100 | 95.19 | 95.34 | 95.66 |
| % isec Shared Calls 50c/100 | 95.19 | 95.35 | 95.67 |



