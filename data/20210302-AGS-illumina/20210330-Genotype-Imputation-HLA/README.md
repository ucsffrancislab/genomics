
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

Samples: 4619
Chromosomes: 6
SNPs: 19599
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
Alternative allele frequency > 0.5 sites: 283
Reference Overlap: 89.91 %
Match: 829
Allele switch: 248
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
Allele mismatch: 1
SNPs call rate < 90%: 0

Excluded sites in total: 1
Remaining sites in total: 1,077
See snps-excluded.txt for details
Typed only sites: 121
See typed-only.txt for details
```


```BASH
wget https://imputationserver.sph.umich.edu/share/results/d807b647232d0323bcc470477db06bff4e848400d8414c78105d494ab56de70e/snps-excluded.txt
wget https://imputationserver.sph.umich.edu/share/results/88a5331a715aa14c28582e211a288709ff5d5a70f69f53213d713ebec366ed0f/typed-only.txt
wget https://imputationserver.sph.umich.edu/share/results/8e13b714423b68c51a905ecbfcda67937081db3ef1357695d45dbfd3c65a713c/chr_6.zip
wget https://imputationserver.sph.umich.edu/share/results/00a1e9dd2849d4a77bd5b321e0a4f2dcb470a21e346b9047b07bb618151588f1/results.md5
wget https://imputationserver.sph.umich.edu/share/results/7a5577ceb8f5dc32265c3c26b8b771a23d94b6b7bfd2df39272482cc7f7483f6/chr_6.log

unzip chr_6.zip
```
