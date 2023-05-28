

```
for f in /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/*_trimmed.?.fastq.gz ; do
l=$(basename $f)
l=${l/_trimmed/}
ln -s ${f} trimmed/${l}
done



bcftool_mpileup_call_array_wrapper.bash --ref /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/genome-lib/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa /francislab/data1/working/20220804-RaleighLab-RNASeq/20230518-VCF/trimmed/*bam

```




```
bcftools view --no-header trimmed/QM101.Aligned.sortedByCoord.out.vcf.gz | awk '{print $NF}' | awk -F: '{print $1}' | sort | uniq -c

524708088 ./.
 53765241 0/0
    15165 0/1
    67700 1/1
      148 1/2
```



Change the sample name to just be the sample name.
Can't figure out how to do it during creation.
Either do this to each individually, or once after a merge

zcat trimmed/QM101.Aligned.sortedByCoord.out.vcf.gz | head -230 | sed -e '/^#CHROM/s:.Aligned.sortedByCoord.out.bam::g' -e '/^#CHROM/s:/francislab/data2/raw/20220804-RaleighLab-RNASeq/trimmed/::g' 


bcftools merge trimmed/QM101.Aligned.sortedByCoord.out.vcf.gz trimmed/QM116.Aligned.sortedByCoord.out.vcf.gz
    -o, --output FILE                 Write output to a file [standard output]
    -O, --output-type u|b|v|z[0-9]    u/b: un/compressed BCF, v/z: un/compressed VCF, 0-9: compression level [v]





The vcfs were create in 'raw' and then moved here, which is why the path in the vcf is different.

```
module load bcftools htslib

date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="bcftoolsmerge" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/bcftools_merge.${date}.out.log \
--wrap="bcftools merge -Ov /francislab/data1/working/20220804-RaleighLab-RNASeq/20230518-VCF/trimmed/*.Aligned.sortedByCoord.out.vcf.gz | sed -e '/^#CHROM/s:.Aligned.sortedByCoord.out.bam::g' -e '/^#CHROM/s:/francislab/data1/raw/20220804-RaleighLab-RNASeq/trimmed/::g' | bgzip > /francislab/data1/working/20220804-RaleighLab-RNASeq/20230518-VCF/merged.vcf.gz"


date=$( date "+%Y%m%d%H%M%S%N" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="bcftoolsmerge" \
--time=20160 --nodes=1 --ntasks=16 --mem=120G --output=${PWD}/bcftools_merge.${date}.out.log \
--wrap="bcftools merge --threads 16 -Ov /francislab/data1/working/20220804-RaleighLab-RNASeq/20230518-VCF/trimmed/*.Aligned.sortedByCoord.out.vcf.gz | sed -e '/^#CHROM/s:.Aligned.sortedByCoord.out.bam::g' -e '/^#CHROM/s:/francislab/data2/raw/20220804-RaleighLab-RNASeq/trimmed/::g' | bgzip > /francislab/data1/working/20220804-RaleighLab-RNASeq/20230518-VCF/merged.multithread.vcf.gz"

```

Took 9 days

```
-rw-r----- 1 gwendt francislab 51452831801 May 27 20:18 merged.vcf.gz
```

`bcftools merge` didn't work will with previous studies 
(20200603-TCGA-GBMLGG-WGS/20230202-bwa-MELT-2.1.5-SPLIT) 
as the VCFs and References had many mismatches.




```

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' /francislab/data1/raw/20220804-RaleighLab-RNASeq/merged.vcf.gz |\
awk 'BEGIN{FS=OFS="\t"}($4!="."){split($4,a,",");for(i=5;i<=NF;i++){gsub(/0/,$3,$i);gsub(/1/,a[1],$i);gsub(/2/,a[2],$i);gsub(/3/,a[3],$i)}print}'

```

