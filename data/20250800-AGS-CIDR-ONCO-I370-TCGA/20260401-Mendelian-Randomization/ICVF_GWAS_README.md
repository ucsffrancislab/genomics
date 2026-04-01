# ICVF GWAS Summary Statistics for Mendelian Randomization
## Mapping from PGS Catalog → BIG40 → MR-Ready Format

### Overview

This package provides everything needed to obtain ICVF (intracellular volume 
fraction) GWAS summary statistics for use as **exposure data** in a bidirectional
two-sample Mendelian Randomization analysis with glioma.

### Source Data

| Attribute        | Value |
|-----------------|-------|
| **GWAS**        | Smith et al. (2021) *Nature Neuroscience* |
| **Title**       | An expanded set of genome-wide association studies of brain imaging phenotypes in UK Biobank |
| **DOI**         | 10.1038/s41593-021-00826-4 |
| **Server**      | Oxford Brain Imaging Genetics (BIG40): https://open.win.ox.ac.uk/ukbiobank/big40/ |
| **Sample**      | UK Biobank, European ancestry, N = 33,224 (combined discovery + replication) |
| **Variants**    | 17,103,079 SNPs on chromosomes 1-22 and X |
| **Genome build**| GRCh37 / hg19 |
| **Effect allele**| a2 (alternative allele) |

### PGS Source

The 18 ICVF polygenic scores used in the glioma PGS association analysis were from:
- **Tanigawa et al. (2022)** *PLoS Genetics* — "Significant sparse polygenic risk scores across 813 traits in UK Biobank"
- **DOI**: 10.1371/journal.pgen.1010105
- **Method**: snpnet (L1-penalized regression)
- **Training N**: 21,080 (UK Biobank, white British ancestry)

These PGS were trained on the **same underlying UK Biobank imaging GWAS data** that 
is served by BIG40. The BIG40 summary statistics provide the full genome-wide 
association results needed for instrument selection in MR.

### Mapping Table

| PGS ID | UKB Field | BIG40 IDP# | Tract | Method |
|--------|-----------|------------|-------|--------|
| PGS001454 | 25347 | 1905 | Body of corpus callosum | TBSS |
| PGS001456 | 25358 | 1916 | Cerebral peduncle (R) | TBSS |
| PGS001457 | 25379 | 1937 | Cingulum cingulate gyrus (L) | TBSS |
| PGS001458 | 25378 | 1936 | Cingulum cingulate gyrus (R) | TBSS |
| PGS001459 | 25381 | 1939 | Cingulum hippocampus (L) | TBSS |
| PGS001460 | 25380 | 1938 | Cingulum hippocampus (R) | TBSS |
| PGS001466 | 25346 | 1904 | Genu of corpus callosum | TBSS |
| PGS001471 | 25344 | 1902 | Middle cerebellar peduncle | TBSS |
| PGS001474 | 25363 | 1921 | Posterior limb int. capsule (L) | TBSS |
| PGS001478 | 25365 | 1923 | Retrolenticular int. capsule (L) | TBSS |
| PGS001479 | 25364 | 1922 | Retrolenticular int. capsule (R) | TBSS |
| PGS001480 | 25375 | 1933 | Sagittal stratum (L) | TBSS |
| PGS001481 | 25374 | 1932 | Sagittal stratum (R) | TBSS |
| PGS001484 | 25369 | 1927 | Superior corona radiata (L) | TBSS |
| PGS001485 | 25368 | 1926 | Superior corona radiata (R) | TBSS |
| PGS001662 | 25651 | 1951 | Acoustic radiation (R) | ProbtrackX |
| PGS001669 | 25660 | 1960 | Forceps major | ProbtrackX |
| PGS001679 | 25657 | 1957 | Parahippocampal cingulum (R) | ProbtrackX |

### Download URLs

Each summary statistics file is ~344 MB compressed (17.1M SNPs):

```
https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats33k/{IDP_NUMBER}.txt.gz
```

Example for sagittal stratum (R), IDP 1932:
```bash
curl -O -L -C - https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats33k/1932.txt.gz
```

Use `download_icvf_sumstats.sh` to download all 18 files automatically.

### File Format

The stats33k files are **space-delimited, gzipped**, with header:

```
chr rsid pos a1 a2 beta se pval(-log10)
```

| Column | Description |
|--------|-------------|
| chr | Chromosome (01-22, 0X) |
| rsid | rs ID or chr:pos:ref:alt identifier |
| pos | Base pair position (GRCh37) |
| a1 | Reference allele |
| a2 | Alternative allele (**effect allele**) |
| beta | Effect size (per copy of a2; phenotype scaled to unit variance) |
| se | Standard error |
| pval(-log10) | -log10(p-value) — **convert with: p = 10^(-value)** |

**Note on allele frequency:** EAF (effect allele frequency) is NOT in the per-IDP 
stats files. It is available in the separate variant annotation file:
```
https://open.win.ox.ac.uk/ukbiobank/big40/release2/variants.txt.gz
```
Format: `chr rsid pos a1 a2 af info` (270 MB compressed, same row order as stats files).

### IEU OpenGWAS Availability

The BIG40 data IS indexed in IEU OpenGWAS as batch **`ubm-b`** (3,935 IDPs from 
Elliott et al. 2021). However, since May 2024 the OpenGWAS API requires JWT 
authentication.

To use via TwoSampleMR in R:
1. Register at https://api.opengwas.io/ 
2. Set token: `ieugwasr::opengwas_jwt_set("<your_token>")`
3. Access datasets as `ubm-b-{IDP_number}` (e.g., `ubm-b-1932` for sagittal stratum R)

The older batch **`ubm-a`** contains Elliott et al. 2018 data (N≈8,428) — use 
**`ubm-b`** for the larger 33k sample.

### Recommended MR Strategy

For the ICVF → Glioma analysis, we recommend starting with the **sagittal stratum (R)**
(IDP 1932 / PGS001481) as the primary exposure:
- Highest glioma SNP overlap (4 glioma risk SNPs in PGS)
- High absolute weight contribution from glioma SNPs (0.83%)
- ICVF has among the highest heritability of all brain imaging phenotypes

Then expand to additional tracts as sensitivity analyses.

### Files in This Package

| File | Description |
|------|-------------|
| `icvf_pgs_to_big40_mapping.csv` | Complete mapping table (PGS → UKB → BIG40 → URL) |
| `download_icvf_sumstats.sh` | Bash script to download all 18 summary stats files |
| `format_icvf_for_mr.R` | R script to format downloads for TwoSampleMR |
