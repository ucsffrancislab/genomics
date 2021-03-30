
# Genotype Imputation HLA

Same vcf files fromo TOPMed imputation.

https://imputationserver.sph.umich.edu

##	Input

Using Multi-ethnic reference panel

Array build:
* **hg19**
* hg38

Phasing:
* **Eagle v2.4 (phased output)**
* No phasing

Mode:
* **Quality Control & Imputation**
* Quality Control & Phasing Only
* Quality Control Only

##	Output

```
Input Validation
1 valid VCF file(s) found.

Samples: 6716
Chromosomes: 6
SNPs: 44625
Chunks: 1
Datatype: unphased
Build: hg19
Reference Panel: apps@multiethnic-hla-panel-Ggroup@1.0.0 (hg19)
Population: mixed
Phasing: eagle
Mode: imputation


Quality Control
Skip allele frequency check.

Calculating QC Statistics

Statistics:
Ref. Panel Range: 6:27967817-33966082
Alternative allele frequency > 0.5 sites: 0
Reference Overlap: 86.15 %
Match: 1,534
Allele switch: 46
Strand flip: 0
Strand flip and allele switch: 0
A/T, C/G genotypes: 0
Filtered sites:
Filter flag set: 0
Invalid alleles: 0
Multiallelic sites: 0
Duplicated sites: 0
NonSNP sites: 0
Monomorphic sites: 0
Allele mismatch: 0
SNPs call rate < 90%: 46

Excluded sites in total: 46
Remaining sites in total: 1,534
See snps-excluded.txt for details
Typed only sites: 254
See typed-only.txt for details
```


```BASH
wget https://imputationserver.sph.umich.edu/share/results/2e614e0e7e55cd52805a67deb304c817ba21e0d138cdcc5974cd865029eda79a/snps-excluded.txt
wget https://imputationserver.sph.umich.edu/share/results/4e16d3ff01b246cfefdc90ec88f396a822c7db0ac6dd60fa30bc9fd8383bea9f/typed-only.txt
wget https://imputationserver.sph.umich.edu/share/results/7a6818656fe211211b8d0d27072374e2a27d35d26d8014585f192b00fccbe077/chr_6.zip
wget https://imputationserver.sph.umich.edu/share/results/5ba01240defb516627cdba334b38bcaac36fb9793ed72c4ed1523c9e345bf201/results.md5
wget https://imputationserver.sph.umich.edu/share/results/cb88d7724365781532a899c50a7311e5fa32d16b886f5a3f5695e8222d12300b/chr_6.log

unzip chr_6.zip
```

