
import phippery
import pandas as pd
from pathlib import Path

# Load normalized dataset
ds = phippery.load('dataset_normalized.phip')
print('Dataset layers:', list(ds.data_vars))

# Create output directory
outdir = Path('exported_data')
outdir.mkdir(exist_ok=True)

# Export sample table
sample_df = ds['sample_table'].to_pandas()
sample_df.to_csv(outdir / 'sample_table.csv')
print(f'Saved sample_table.csv ({sample_df.shape})')

# Export peptide table
peptide_df = ds['peptide_table'].to_pandas()
peptide_df.to_csv(outdir / 'peptide_table.csv')
print(f'Saved peptide_table.csv ({peptide_df.shape})')

# Export each data layer
for layer in ['counts', 'cpm', 'size_factors', 'enrichment', 'zscore']:
    if layer in ds.data_vars:
        df = ds[layer].to_pandas()
        outfile = outdir / f'{layer}.csv.gz'
        df.to_csv(outfile, compression='gzip')
        print(f'Saved {layer}.csv.gz ({df.shape})')

print('\nDone! Files in:', outdir)
