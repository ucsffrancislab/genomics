
```BASH
dir=/francislab/data1/working/CCLS/20210216-cigar_correction/bam
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




Change chrM to MT???




Mismatch of chrM and MT so not included in output


```BASH
mkdir newvcf
for f in vcf/*vcf.gz ; do
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
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210127 CCLS 20210215-downsampling_test"
curl -netrc -X MKCOL "${BOX}/"

curl -netrc -T 122997.vcf.gz "${BOX}/"
curl -netrc -T 122997.vcf.gz.csi "${BOX}/"
```



