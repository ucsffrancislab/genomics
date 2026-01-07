#!/usr/bin/env python3

import os
import numpy as np
import pandas as pd
import gzip


# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

# Don't use "nargs=1". It makes it an array.

#parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
parser.add_argument('-i', '--input', type=str, default='zscores.csv.gz',
  help='input csv filename to %(prog)s (default: %(default)s)')
parser.add_argument('-o', '--output', type=str, default='zscores.correlation_edges.csv.gz',
  help='output csv filename to %(prog)s (default: %(default)s)')

#parser.add_argument('-z','--zscore_threshold', type=float, default=3.5,
#  help='z-score thresholdto %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()
print(args)


#df = pd.read_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered.threshold5.csv', header=list(range(3)), index_col=[0,1])
df = pd.read_csv(args.input, header=list(range(3)), index_col=[0,1])
#df = df.astype(np.int32)
#df = df.astype(np.float32)
print(df.dtypes, flush=True)

print(df.head(), flush=True)

print(f"DataFrame shape: {df.shape}", flush=True)

#data = df.T.values.astype(np.float64)

#data = df.T.values	#.astype(np.float64)
data = df.T.values.astype(np.int8)
print(f"Data shape: {data.shape}", flush=True)

# Extract only first level of MultiIndex
df_index = df.index.get_level_values(0).astype(int)  # Convert to regular int
del df





## Filter out peptides with zero or near-zero variance
#print("Filtering peptides by variance...", flush=True)
#variances = np.var(data, axis=0)
#min_variance = 1e-10  # Very small threshold to catch constant peptides
#
#valid_mask = variances > min_variance
#valid_indices = np.where(valid_mask)[0]
#filtered_data = data[:, valid_mask]
#filtered_peptides = df.columns[valid_mask]
#
#print(f"Removed {np.sum(~valid_mask)} constant peptides", flush=True)
#print(f"Filtered data shape: {filtered_data.shape}", flush=True)





#print(data[0:5,0:5])

import gc
print("GC Collect", flush=True)
gc.collect()

print("Computing correlation matrix...", flush=True)
with np.errstate(invalid='ignore'):
    corr_matrix = np.corrcoef(data, rowvar=False)
print(f"Correlation matrix shape: {corr_matrix.shape}", flush=True)

del data

# Set threshold to reduce edges
threshold = 0.3  # Both positive and negative correlations with |r| >= 0.3
#threshold = 0  # Both positive and negative correlations with |r| >= 0.3

print("Creating edge list with streaming write...", flush=True)
rows, cols = np.triu_indices_from(corr_matrix, k=1)
weights = corr_matrix[rows, cols]

# Filter by threshold and validity
#valid_mask = np.isfinite(weights) & (np.abs(weights) >= threshold)
valid_mask = np.isfinite(weights) & (weights >= threshold)
rows = rows[valid_mask]
cols = cols[valid_mask]
weights = weights[valid_mask]

#print(f"Writing {len(rows):,} edges (filtered by |threshold|>={threshold})", flush=True)
print(f"Writing {len(rows):,} edges (filtered by threshold>={threshold})", flush=True)

# Write directly to CSV in chunks
chunk_size = 1_000_000
#with gzip.open('out.123456131415161718/counts.correlation_edges.csv.gz', 'wt') as f:
#with gzip.open('out.123456131415161718/counts.normalized.subtracted.correlation_edges.csv.gz', 'wt') as f:
#with gzip.open('out.123456131415161718/zscore.threshold5.correlation_edges.csv.gz', 'wt') as f:
#with gzip.open('out.123456131415161718/zscore.filtered.threshold5.correlation_edges.csv.gz', 'wt') as f:
with gzip.open(args.output, 'wt') as f:
    f.write('source,target,weight\n')
    
    for start in range(0, len(rows), chunk_size):
        end = min(start + chunk_size, len(rows))
        print(f"Writing chunk {start:,} to {end:,}", flush=True)
        
        for i in range(start, end):
            # Convert to Python int to avoid numpy type in output
            source = int(df_index[rows[i]])
            target = int(df_index[cols[i]])
            f.write(f"{source},{target},{weights[i]:.4f}\n")

print(f"Saved {len(rows):,} edges", flush=True)

# Clean up to avoid memory issues on exit
#import gc
print("GC Collect1", flush=True)
gc.collect()

print("del rows", flush=True)
del rows
print("del cols", flush=True)
del cols
print("del weights", flush=True)
del weights
print("del df_index", flush=True)
del df_index

print("GC Collect 2", flush=True)
gc.collect()


print(f"Data shape: {corr_matrix.shape}, dtype: {corr_matrix.dtype}", flush=True)
print(f"NaNs: {np.isnan(corr_matrix).sum()}, Infs: {np.isinf(corr_matrix).sum()}", flush=True)
#Data shape: (115293, 115293), dtype: float64
#NaNs: 5220860184, Infs: 0

# If data isn't a proper array, try:
#data = np.asarray(data)

#del df_index
#GC Collect 2
#Data shape: (115292, 115292), dtype: float64
#NaNs: 375922764, Infs: 0
#free(): invalid size

#	No matter what I do, trying to clear corr_matrix raises the "free(): invalid size" error.

#corr_matrix = np.nan_to_num(corr_matrix)
#print(f"NaNs: {np.isnan(corr_matrix).sum()}, Infs: {np.isinf(corr_matrix).sum()}", flush=True)
#print("del corr_matrix", flush=True)
#del corr_matrix


print("Done", flush=True)

# Exit immediately before Python tries to clean up huge arrays
import os
os._exit(0)  # Force exit without cleanup

