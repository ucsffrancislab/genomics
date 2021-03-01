
```BASH
dir=/francislab/data1/raw/CCLS/bam
for f in ${dir}/GM_*bam ; do
b=${f#${dir}/GM_}
b=${b%.recaled.bam}
echo $b
ln -s ${dir}/GM_${b}.recaled.bam.bai bam/GM_${b}.100.bam.bai
ln -s ${dir}/${b}.recaled.bam.bai bam/${b}.100.bam.bai
ln -s ${dir}/GM_${b}.bam bam/GM_${b}.100.bam
ln -s ${dir}/${b}.bam bam/${b}.100.bam
done

./subsample.bash

./call.bash
```

```BASH
module load bcftools/1.10.2
for f in bam/*.*.vcf.gz; do 
echo $f
bcftools view --no-header $f | wc -l > $f.count 
bcftools isec -C ${f%%.*}.100.vcf.gz ${f} | wc -l > $f.100_isec_count
bcftools isec -C ${f} ${f%%.*}.100.vcf.gz | wc -l > $f.isec_100_count
bcftools isec -n =2 ${f} ${f%%.*}.100.vcf.gz | wc -l > $f.shared_100_isec_count
bcftools isec -n -1 ${f} ${f%%.*}.100.vcf.gz | wc -l > $f.diff_100_isec_count
done

./report.bash >> README.md
```


Upload ???
```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210301 CCLS 20210215-downsampling"
curl -netrc -X MKCOL "${BOX}/"


```





|    | 268325 | 439338 | 63185 | 634370 | 983899 |
| --- | --- | --- | --- | --- | --- |
| Calls 100 | 4910829 | 4938766 | 4959885 | 4964703 | 5045782 |
| Calls 80a | 4874159 | 4899928 | 4923570 | 4929517 | 5007265 |
| Calls 80b | 4873710 | 4899258 | 4923811 | 4928664 | 5008099 |
| Calls 80c | 4874261 | 4899853 | 4924128 | 4929219 | 5007724 |
| Calls 60a | 4823487 | 4845578 | 4875579 | 4881266 | 4954914 |
| Calls 60b | 4823760 | 4845585 | 4875929 | 4881220 | 4955326 |
| Calls 60c | 4823473 | 4845707 | 4876404 | 4881656 | 4955033 |
| Calls 50a | 4789281 | 4808740 | 4844417 | 4848930 | 4918745 |
| Calls 50b | 4789572 | 4808457 | 4843122 | 4849110 | 4919426 |
| Calls 50c | 4789244 | 4807983 | 4843943 | 4849166 | 4919525 |
| % Calls 100/100 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |
| % Calls 80a/100 | 99.25 | 99.21 | 99.26 | 99.29 | 99.23 |
| % Calls 80b/100 | 99.24 | 99.20 | 99.27 | 99.27 | 99.25 |
| % Calls 80c/100 | 99.25 | 99.21 | 99.27 | 99.28 | 99.24 |
| % Calls 60a/100 | 98.22 | 98.11 | 98.30 | 98.31 | 98.19 |
| % Calls 60b/100 | 98.22 | 98.11 | 98.30 | 98.31 | 98.20 |
| % Calls 60c/100 | 98.22 | 98.11 | 98.31 | 98.32 | 98.20 |
| % Calls 50a/100 | 97.52 | 97.36 | 97.67 | 97.66 | 97.48 |
| % Calls 50b/100 | 97.53 | 97.36 | 97.64 | 97.67 | 97.49 |
| % Calls 50c/100 | 97.52 | 97.35 | 97.66 | 97.67 | 97.49 |
| isec Diff Calls 100 100 | 0 | 0 | 0 | 0 | 0 |
| isec Diff Calls 100 80a | 157302 | 154114 | 162753 | 152730 | 165871 |
| isec Diff Calls 100 80b | 157239 | 153744 | 162468 | 153735 | 166499 |
| isec Diff Calls 100 80c | 157752 | 154137 | 162343 | 152952 | 166620 |
| isec Diff Calls 100 60a | 276426 | 270228 | 286058 | 271107 | 289800 |
| isec Diff Calls 100 60b | 275035 | 269913 | 285854 | 271139 | 290974 |
| isec Diff Calls 100 60c | 275988 | 271021 | 285301 | 270281 | 290501 |
| isec Diff Calls 100 50a | 340348 | 332832 | 351452 | 333065 | 357117 |
| isec Diff Calls 100 50b | 338867 | 332771 | 351071 | 333553 | 358264 |
| isec Diff Calls 100 50c | 339711 | 333929 | 351040 | 333683 | 357337 |
| % isec Diff Calls 100/100 | 0 | 0 | 0 | 0 | 0 |
| % isec Diff Calls 80a/100 | 3.20 | 3.12 | 3.28 | 3.07 | 3.28 |
| % isec Diff Calls 80b/100 | 3.20 | 3.11 | 3.27 | 3.09 | 3.29 |
| % isec Diff Calls 80c/100 | 3.21 | 3.12 | 3.27 | 3.08 | 3.30 |
| % isec Diff Calls 60a/100 | 5.62 | 5.47 | 5.76 | 5.46 | 5.74 |
| % isec Diff Calls 60b/100 | 5.60 | 5.46 | 5.76 | 5.46 | 5.76 |
| % isec Diff Calls 60c/100 | 5.61 | 5.48 | 5.75 | 5.44 | 5.75 |
| % isec Diff Calls 50a/100 | 6.93 | 6.73 | 7.08 | 6.70 | 7.07 |
| % isec Diff Calls 50b/100 | 6.90 | 6.73 | 7.07 | 6.71 | 7.10 |
| % isec Diff Calls 50c/100 | 6.91 | 6.76 | 7.07 | 6.72 | 7.08 |
| isec Shared Calls 100 100 | 4910829 | 4938766 | 4959885 | 4964703 | 5045782 |
| isec Shared Calls 100 80a | 4813843 | 4842290 | 4860351 | 4870745 | 4943588 |
| isec Shared Calls 100 80b | 4813650 | 4842140 | 4860614 | 4869816 | 4943691 |
| isec Shared Calls 100 80c | 4813669 | 4842241 | 4860835 | 4870485 | 4943443 |
| isec Shared Calls 100 60a | 4728945 | 4757058 | 4774703 | 4787431 | 4855448 |
| isec Shared Calls 100 60b | 4729777 | 4757219 | 4774980 | 4787392 | 4855067 |
| isec Shared Calls 100 60c | 4729157 | 4756726 | 4775494 | 4788039 | 4855157 |
| isec Shared Calls 100 50a | 4679881 | 4707337 | 4726425 | 4740284 | 4803705 |
| isec Shared Calls 100 50b | 4680767 | 4707226 | 4725968 | 4740130 | 4803472 |
| isec Shared Calls 100 50c | 4680181 | 4706410 | 4726394 | 4740093 | 4803985 |
| % isec Shared Calls 100/100 | 100.00 | 100.00 | 100.00 | 100.00 | 100.00 |
| % isec Shared Calls 80a/100 | 98.02 | 98.04 | 97.99 | 98.10 | 97.97 |
| % isec Shared Calls 80b/100 | 98.02 | 98.04 | 97.99 | 98.08 | 97.97 |
| % isec Shared Calls 80c/100 | 98.02 | 98.04 | 98.00 | 98.10 | 97.97 |
| % isec Shared Calls 60a/100 | 96.29 | 96.32 | 96.26 | 96.42 | 96.22 |
| % isec Shared Calls 60b/100 | 96.31 | 96.32 | 96.27 | 96.42 | 96.22 |
| % isec Shared Calls 60c/100 | 96.30 | 96.31 | 96.28 | 96.44 | 96.22 |
| % isec Shared Calls 50a/100 | 95.29 | 95.31 | 95.29 | 95.47 | 95.20 |
| % isec Shared Calls 50b/100 | 95.31 | 95.31 | 95.28 | 95.47 | 95.19 |
| % isec Shared Calls 50c/100 | 95.30 | 95.29 | 95.29 | 95.47 | 95.20 |


