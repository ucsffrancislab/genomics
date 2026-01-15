# Phippery Data Format Specifications

## Overview

Phippery requires three CSV files to create its xarray Dataset:
1. **Sample Table** - Sample metadata with required and optional columns
2. **Peptide Table** - Peptide/oligo annotations 
3. **Counts Matrix** - Wide-format matrix of raw counts

---

## 1. Sample Table (sample_table.csv)

### Required Columns

| Column Name | Type | Description | Example Values |
|-------------|------|-------------|----------------|
| `sample_id` | Integer | **AUTO-GENERATED** - Do NOT include; phippery adds this | (leave out) |
| `sample_name` | String | Your unique sample identifier | "S001_rep1", "BLANK_plate3_A1" |

### Recommended Columns for Your Study

| Column Name | Type | Description | Example Values |
|-------------|------|-------------|----------------|
| `subject_id` | String | Subject/participant identifier | "SUBJ_001", "SUBJ_002" |
| `replicate` | Integer | Replicate number (1, 2, etc.) | 1, 2 |
| `control_status` | String | **CRITICAL for enrichment** | "empirical", "beads_only", "library" |
| `plate` | String | Processing plate identifier | "plate_01", "plate_02", ..., "plate_12" |
| `group` | String | Case/control or disease group | "case", "control", "healthy" |
| `sex` | String | Subject sex | "M", "F", "unknown" |
| `age` | Integer/Float | Subject age | 45, 32.5 |
| `batch` | String | Processing batch (if different from plate) | "batch_1", "batch_2" |

### Control Status Values

**CRITICAL**: The `control_status` column is required for many phippery functions:

| Value | Description | Use |
|-------|-------------|-----|
| `empirical` | Actual serum/experimental samples | Test samples |
| `beads_only` | No-serum blank controls | Z-score normalization background |
| `library` | Phage library input samples | CPM fold-enrichment calculation |

### Example Sample Table

```csv
sample_name,subject_id,replicate,control_status,plate,group,sex,age,batch
S001_rep1,SUBJ_001,1,empirical,plate_01,case,M,45,batch_A
S001_rep2,SUBJ_001,2,empirical,plate_01,case,M,45,batch_A
S002_rep1,SUBJ_002,1,empirical,plate_01,control,F,52,batch_A
S002_rep2,SUBJ_002,2,empirical,plate_01,control,F,52,batch_A
BLANK_P01_A1,NA,1,beads_only,plate_01,NA,NA,NA,batch_A
BLANK_P01_A2,NA,2,beads_only,plate_01,NA,NA,NA,batch_A
LIB_P01_A1,NA,1,library,plate_01,NA,NA,NA,batch_A
```

---

## 2. Peptide Table (peptide_table.csv)

### Required Columns

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `peptide_id` | Integer | **AUTO-GENERATED** - Do NOT include | (leave out) |
| `oligo` | String | Oligonucleotide sequence (uppercase = coding, lowercase = adapter) | "atcgATGCGTAGCTAGCatcg" |

### Recommended Columns for VirScan

| Column Name | Type | Description | Example Values |
|-------------|------|-------------|----------------|
| `peptide_name` | String | Unique peptide identifier | "VirScan_00001" |
| `peptide_seq` | String | Amino acid sequence | "MVLSPADKTNVKAAWG" |
| `virus` | String | Virus name/species | "Human herpesvirus 4" |
| `virus_species_id` | Integer | Taxonomy ID | 10376 |
| `protein` | String | Protein name | "EBNA-1" |
| `protein_accession` | String | Protein accession | "NP_001229.1" |
| `start_pos` | Integer | Start position in protein | 1, 57, 113 |
| `end_pos` | Integer | End position in protein | 56, 112, 168 |
| `library` | String | Library source | "VirScan_v3" |

### Example Peptide Table

```csv
peptide_name,oligo,peptide_seq,virus,protein,start_pos,end_pos
VirScan_00001,atcgATGGTGCTGTCTCCTGCTGATAAGACCAACGTGAAGGCCGCCTGGGGTatcg,MVLSPADKTNVKAAWG,Human cytomegalovirus,UL55,1,56
VirScan_00002,atcgGGTGCCGTGGCTGAAGGTGAAGGTGATGCCGTTGAAGCCCTGGGCatcg,GAVAEGEADVEAVLG,Human cytomegalovirus,UL55,29,84
VirScan_00003,atcgATGGCTAAGCTGGTGAAGAGCGTGGCTGACATGCTGGTGGGTatcg,MAKLVKSVADMLVG,Epstein-Barr virus,EBNA-1,1,56
```

**Note on oligo column**: 
- Lowercase nucleotides = adapter sequences (trimmed during alignment)
- Uppercase nucleotides = coding sequence that aligns to reads
- If you don't have adapter info, use all uppercase

---

## 3. Counts Matrix (counts_matrix.csv)

### Format

- **Rows**: Peptides (must match order of peptide_table)
- **Columns**: Samples (must match order of sample_table)
- **First row**: Header with sample names matching `sample_name` in sample_table
- **First column**: Peptide identifier (optional index column) OR no index
- **Values**: Integer raw counts

### Option A: With Row Index

```csv
,S001_rep1,S001_rep2,S002_rep1,S002_rep2,BLANK_P01_A1,LIB_P01_A1
VirScan_00001,523,612,389,445,12,8943
VirScan_00002,1245,1189,892,956,23,7621
VirScan_00003,89,102,2341,2567,8,6543
```

### Option B: Without Row Index (recommended)

```csv
S001_rep1,S001_rep2,S002_rep1,S002_rep2,BLANK_P01_A1,LIB_P01_A1
523,612,389,445,12,8943
1245,1189,892,956,23,7621
89,102,2341,2567,8,6543
```

### Critical Requirements

1. **Column order in counts_matrix must match row order in sample_table**
2. **Row order in counts_matrix must match row order in peptide_table**
3. **All values must be numeric (integers)**
4. **No missing values allowed** (use 0 for zero counts)
5. **Shape**: (num_peptides, num_samples) = (~115,000, ~1,000)

---

## 4. Converting Your Existing Data

### Your Current Format (Likely)

If you have a counts matrix from bowtie2, it's probably in one of these formats:

**Format 1: Wide matrix with peptide IDs as index**
```
peptide_id    sample1    sample2    sample3
peptide_0001  523        612        389
peptide_0002  1245       1189       892
```

**Format 2: Tall/long format**
```
peptide_id    sample_id    count
peptide_0001  sample1      523
peptide_0001  sample2      612
```

### Conversion Scripts

The scripts in `scripts/` directory will help convert your format:
- `01_prepare_sample_table.py` - Create sample_table.csv from your metadata
- `02_prepare_peptide_table.py` - Create peptide_table.csv from VirScan library
- `03_prepare_counts_matrix.py` - Reformat counts to required orientation

---

## 5. Validation Checklist

Before running the pipeline, verify:

- [ ] sample_table.csv has `sample_name` column
- [ ] sample_table.csv has `control_status` column with valid values
- [ ] sample_table.csv does NOT have `sample_id` column
- [ ] peptide_table.csv has `oligo` column
- [ ] peptide_table.csv does NOT have `peptide_id` column
- [ ] counts_matrix.csv has same number of columns as rows in sample_table
- [ ] counts_matrix.csv has same number of rows as rows in peptide_table
- [ ] counts_matrix column names match sample_table `sample_name` values
- [ ] All counts are non-negative integers
- [ ] No missing/NA values in counts matrix

---

## 6. Data Size Considerations

For your dataset (~115,000 peptides × ~1,000 samples):

- **Raw counts matrix**: ~115 million values
- **Memory estimate**: ~1-2 GB for counts alone
- **With normalizations**: 5-10 GB for full dataset
- **Recommended**: Use gzipped CSVs for storage

Your HPC node (64 cores, 500GB memory) is well-suited for this dataset.
