# PhIPSeq Analysis Pipeline Using Phippery

## Overview

This pipeline processes your existing PhIPSeq counts data (already aligned with bowtie2 and filtered for Q40) using the phippery suite from the Matsen group. Since you've already completed alignment and count extraction, we'll use the phippery Python API and CLI directly, bypassing the Nextflow phip-flow pipeline.

## Your Data Summary
- ~1,000 samples processed on 12 plates
- ~115,000 peptides (VirScan library)
- Most subjects have 2 replicate samples
- Control samples: "no-serum blanks" and "phage library" samples
- Counts matrix from Q40 bowtie2 alignments

## Pipeline Components

1. **Data Format Conversion** - Convert your existing data to phippery's required format
2. **Dataset Creation** - Build the xarray Dataset object
3. **Normalization & Enrichment** - CPM, size factors, Z-scores, fold enrichment
4. **Quality Control** - Batch/plate effect assessment, replicate correlation
5. **Statistical Analysis** - EdgeR, Z-score modeling for hit calling

## Required Input File Formats

See `01_data_format_specifications.md` for detailed format requirements.

## File Structure
```
phippery_pipeline/
├── README.md                          # This file
├── 01_data_format_specifications.md   # Detailed input format specs
├── scripts/
│   ├── 00_install_phippery.sh        # Environment setup
│   ├── 01_prepare_sample_table.py    # Convert your metadata to phippery format
│   ├── 02_prepare_peptide_table.py   # Convert peptide annotations
│   ├── 03_prepare_counts_matrix.py   # Format counts matrix
│   ├── 04_create_phippery_dataset.sh # Create xarray dataset
│   ├── 05_run_normalization.py       # Parallelized normalization
│   ├── 06_run_enrichment.py          # Enrichment calculations
│   └── run_all.sh                    # Master SLURM script
├── templates/
│   ├── sample_table_template.csv
│   └── peptide_table_template.csv
└── config/
    └── pipeline_config.yaml          # Configuration settings
```

## Quick Start

1. Prepare your environment:
   ```bash
   sbatch scripts/00_install_phippery.sh
   ```

2. Format your input files according to specifications

3. Run the pipeline:
   ```bash
   sbatch scripts/run_all.sh
   ```
