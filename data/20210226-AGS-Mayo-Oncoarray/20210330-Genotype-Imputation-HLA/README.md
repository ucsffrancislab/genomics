
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

Samples: 4365
Chromosomes: 6
SNPs: 32347
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
Alternative allele frequency > 0.5 sites: 781
Reference Overlap: 85.48 %
Match: 3,229
Allele switch: 710
Strand flip: 0
Strand flip and allele switch: 1
A/T, C/G genotypes: 18
Filtered sites:
Filter flag set: 0
Invalid alleles: 0
Multiallelic sites: 0
Duplicated sites: 0
NonSNP sites: 0
Monomorphic sites: 0
Allele mismatch: 9
SNPs call rate < 90%: 10

Excluded sites in total: 20
Remaining sites in total: 3,947
See snps-excluded.txt for details
Typed only sites: 674
See typed-only.txt for details
```


```
wget https://imputationserver.sph.umich.edu/share/results/eac16652cc07442f578c4d232c615a034096b95586f66a778beeff9ff7673961/snps-excluded.txt
wget https://imputationserver.sph.umich.edu/share/results/1e74db62c554d37eec3d652eb50f93762afd25926c904b3bd9c4d704313b61b9/typed-only.txt
wget https://imputationserver.sph.umich.edu/share/results/64e51bb1dec919c9879eeafce040971df9763cef7ff85767b5362b0e8d373fa7/chr_6.zip
wget https://imputationserver.sph.umich.edu/share/results/a7e3822ce8c06a5ba1ce0996098f9f92c827b23ef0ed7589324671ffc5ef359b/results.md5
wget https://imputationserver.sph.umich.edu/share/results/4f4bd0cd1a2e688b7a072f4d2e7c56ed1805584addc1b7982f7718411b4d829f/chr_6.log

unzip chr_6.zip
```
