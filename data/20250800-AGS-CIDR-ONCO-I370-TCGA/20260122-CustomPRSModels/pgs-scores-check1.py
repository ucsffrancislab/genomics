#!/usr/bin/env python3

import pandas as pd
import numpy as np
from scipy.stats import pearsonr
import matplotlib.pyplot as plt

# Load pgs-calc scores
pgscalc = pd.read_csv('pgs-calc-scores/cidr/scores.txt')
pgscalc.columns = pgscalc.columns.str.strip('"')
pgscalc['sample'] = pgscalc['sample'].str.strip('"')

# Load plink scores for one model (let's start with allGlioma)
plink = pd.read_csv('plink-scores/imputed-umich-cidr.allGlioma.prs.genome_raw.txt', 
                    sep='\t')

# Merge on sample ID
# May need to adjust this depending on ID format differences
merged = pd.merge(pgscalc[['sample', 'allGlioma_scoring_system']], 
                  plink[['IID', 'PRS_raw']], 
                  left_on='sample', right_on='IID', 
                  how='inner')

print(f"Merged {len(merged)} samples")
print(f"\npgs-calc range: {merged['allGlioma_scoring_system'].min():.3f} to {merged['allGlioma_scoring_system'].max():.3f}")
print(f"plink range: {merged['PRS_raw'].min():.3f} to {merged['PRS_raw'].max():.3f}")

# Correlation
r, p = pearsonr(merged['allGlioma_scoring_system'], merged['PRS_raw'])
print(f"\nPearson correlation: {r:.6f} (p={p:.2e})")

# Scatter plot
plt.figure(figsize=(10, 6))
plt.scatter(merged['PRS_raw'], merged['allGlioma_scoring_system'], alpha=0.5)
plt.xlabel('plink2 raw score')
plt.ylabel('pgs-calc score')
plt.title(f'allGlioma scoring: plink2 vs pgs-calc (r={r:.4f})')
plt.tight_layout()
plt.savefig('plink_vs_pgscalc_allGlioma.png', dpi=150)
print("\nPlot saved to plink_vs_pgscalc_allGlioma.png")

# Check if pgs-calc is just standardized plink
plink_standardized = (merged['PRS_raw'] - merged['PRS_raw'].mean()) / merged['PRS_raw'].std()
r_std, _ = pearsonr(merged['allGlioma_scoring_system'], plink_standardized)
print(f"\nCorrelation with standardized plink: {r_std:.6f}")


print(f"\nplink SNP count: {plink['SNP_CT'].iloc[0]:,}")

