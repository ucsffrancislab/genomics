
#	MEGAnE

https://github.com/shohei-kojima/MEGAnE





```
usage: 0_build_kmer_set.py [-h] -fa str [-prefix str] [-outdir str] [-v]

optional arguments:
  -h, --help     show this help message and exit
  -fa str        Fasta file of the reference genome (e.g. GRCh38.fa). Please
                 make sure there is a fasta index (.fa.fai)
  -prefix str    Optional. Specify prefix of the k-mer file. If this was not
                 specified, prefix will be the file name of the input
                 reference genome. Two files, [prefix].mk and [prefix].mi,
                 will be generated.
  -outdir str    Optional. Specify output directory. Default:
                 ./megane_kmer_set
  -v, --version  show program's version number and exit
```

Really only needs about 100GB mem

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="MEGAnE" \
--time=20160 --nodes=1 --ntasks=64 --mem=490G --output=${PWD}/MEGAnE.out.log \
--wrap="singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/MEGAnE.v1.0.1.beta-20230525.sif build_kmerset -fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa -prefix reference_human_genome -outdir ${PWD}/megane_kmer_set"

```






```
usage: 1_indiv_call_genotype.py [-h] -i str -fa str -fadb str -mk str -rep str
                                -repout str -repremove str -pA_ME str -mainchr
                                str [-cov int or auto] [-readlen int or auto]
                                [-sex str] [-male_sex_chr str]
                                [-female_sex_chr str] [-sample_name str]
                                [-outdir str] [-homozygous] [-monoallelic]
                                [-skip_unmapped] [-unsorted] [-verylowdep]
                                [-lowdep] [-setting str] [-only_ins]
                                [-only_abs] [-pybedtools_tmp str] [-keep]
                                [-do_not_overwrite] [-p int] [-v]
```


```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="MEGAnE" \
--time=20160 --nodes=1 --ntasks=8 --mem=60G \
--wrap="singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/MEGAnE.v1.0.0.beta-20230525.sif call_genotype_38 \
-fa /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.fa.gz
-mk /francislab/data1/refs/MEGAnE/megane_kmer_set/reference_human_genome.mk -p 8 \

-i /path/to/input.bam \
-outdir MEGAnE_result_test \
-sample_name test_sample \

--output=${PWD}/MEGAnE.out.log

```






https://www.nature.com/articles/s41588-023-01390-2

https://zenodo.org/record/7703708


wget https://zenodo.org/record/7703708/files/1000GP.GRCh37.ME_absences.ALL.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh37.ME_absences.PASS.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh37.ME_insertions.ALL.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh37.ME_insertions.PASS.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_2504.ME_absences.ALL.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_2504.ME_absences.PASS.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_2504.ME_insertions.ALL.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_2504.ME_insertions.PASS.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_3202.ME_absences.ALL.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_3202.ME_absences.PASS.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_3202.ME_insertions.ALL.vcf.gz

wget https://zenodo.org/record/7703708/files/1000GP.GRCh38_3202.ME_insertions.PASS.vcf.gz

wget https://zenodo.org/record/7703708/files/GTEx_eQTL_mash_meta_analysis.ME.lfsr.tsv.gz

wget https://zenodo.org/record/7703708/files/GTEx_eQTL_mash_meta_analysis.ME.posterior_mean.tsv.gz

wget https://zenodo.org/record/7703708/files/GTEx_eQTL_mash_meta_analysis.ME.posterior_stdev.tsv.gz





