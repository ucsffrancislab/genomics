
import phippery
from phippery.normalize import counts_per_million, size_factors, enrichment
from phippery.modeling import zscore
import numpy as np

# Load dataset
ds = phippery.load('dataset.phip')
print('Loaded dataset:', ds.dims)

# Check control status breakdown
sample_table = ds['sample_table'].to_pandas()
print('\nControl status:')
print(sample_table['control_status'].value_counts())

# Get sample indices for each control type
library_mask = sample_table['control_status'] == 'library'
beads_mask = sample_table['control_status'] == 'beads_only'

library_indices = sample_table[library_mask].index.tolist()
beads_indices = sample_table[beads_mask].index.tolist()

print(f'\nLibrary sample indices: {len(library_indices)}')
print(f'Beads-only sample indices: {len(beads_indices)}')

# Extract library and beads-only datasets
lib_ds = ds.sel(sample_id=library_indices)
beads_ds = ds.sel(sample_id=beads_indices)

print(f'Library dataset shape: {lib_ds.dims}')
print(f'Beads dataset shape: {beads_ds.dims}')

# Run CPM normalization
print('\nRunning CPM...')
counts_per_million(ds, per_sample=True, data_table='counts', new_table_name='cpm', inplace=True)

# Also run CPM on control datasets
counts_per_million(lib_ds, per_sample=True, data_table='counts', new_table_name='cpm', inplace=True)
counts_per_million(beads_ds, per_sample=True, data_table='counts', new_table_name='cpm', inplace=True)

# Run size factors
print('Running size factors...')
size_factors(ds, data_table='counts', new_table_name='size_factors', inplace=True)

# Run fold enrichment
print('Running fold enrichment...')
enrichment(ds, lib_ds, data_table='cpm', new_table_name='enrichment', inplace=True)

# Run Z-score
print('Running Z-score...')
zscore(ds, beads_ds, data_table='cpm', new_table_name='zscore', inplace=True)

# Save
print('\nSaving normalized dataset...')
phippery.dump(ds, 'dataset_normalized.phip')

print('\nFinal dataset layers:', list(ds.data_vars))
print('Done!')

