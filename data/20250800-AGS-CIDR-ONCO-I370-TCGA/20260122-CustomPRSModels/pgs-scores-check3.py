#!/usr/bin/env python3

import pandas as pd
import numpy as np
from scipy.stats import pearsonr
import matplotlib.pyplot as plt

# Load scores
server_scores = pd.read_csv('/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/pgs-cidr-hg19/scores.txt')
local_scores = pd.read_csv('pgs-calc-scores/cidr/scores.txt')

# Clean up column names and sample IDs
for df in [server_scores, local_scores]:
    df.columns = df.columns.str.strip('"')
    df['sample'] = df['sample'].str.strip('"')

print(f"Server scores: {server_scores.shape[0]} samples, {server_scores.shape[1]-1} models")
print(f"Local scores: {local_scores.shape[0]} samples, {local_scores.shape[1]-1} models")

# Find overlapping models
server_models = set(server_scores.columns) - {'sample'}
local_models = set(local_scores.columns) - {'sample'}
overlapping_models = sorted(server_models & local_models)

print(f"\nOverlapping PGS models: {len(overlapping_models)}")
print(f"Server only: {len(server_models - local_models)}")
print(f"Local only: {len(local_models - server_models)}")

# Merge on sample
merged = pd.merge(server_scores, local_scores, on='sample', 
                  how='inner', suffixes=('_server', '_local'))

print(f"\nMerged samples: {len(merged)}")

# Calculate correlations for all overlapping models
results = []

for model in overlapping_models:
    server_col = f'{model}_server' if f'{model}_server' in merged.columns else model
    local_col = f'{model}_local' if f'{model}_local' in merged.columns else model
    
    # Handle cases where model name didn't get suffix (no collision)
    if server_col not in merged.columns:
        server_col = model
        local_col = model
        # This means the model only exists in one, skip
        continue
    
    r, p = pearsonr(merged[server_col], merged[local_col])
    
    results.append({
        'model': model,
        'correlation': r,
        'p_value': p
    })

results_df = pd.DataFrame(results).sort_values('correlation')

print("\n=== Correlation Summary ===")
print(f"Mean: {results_df['correlation'].mean():.4f}")
print(f"Median: {results_df['correlation'].median():.4f}")
print(f"Range: {results_df['correlation'].min():.4f} to {results_df['correlation'].max():.4f}")

print("\n=== Worst 20 correlations ===")
print(results_df.head(20)[['model', 'correlation']])

print("\n=== Best 20 correlations ===")
print(results_df.tail(20)[['model', 'correlation']])

# Save full results
results_df.to_csv('server_vs_local_correlations.csv', index=False)
print("\nFull results saved to server_vs_local_correlations.csv")

# Plot distribution
plt.figure(figsize=(10, 6))
plt.hist(results_df['correlation'], bins=50, edgecolor='black')
plt.xlabel('Correlation (Server vs Local)')
plt.ylabel('Number of PGS Models')
plt.title(f'Distribution of Correlations ({len(results_df)} models)')
plt.axvline(results_df['correlation'].mean(), color='red', linestyle='--', label=f'Mean = {results_df["correlation"].mean():.3f}')
plt.legend()
plt.tight_layout()
plt.savefig('server_vs_local_correlation_distribution.png', dpi=150)
print("Plot saved to server_vs_local_correlation_distribution.png")


