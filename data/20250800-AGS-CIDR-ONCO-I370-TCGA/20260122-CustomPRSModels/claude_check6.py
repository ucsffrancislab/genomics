#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

# Load pgs-calc scores
pgscalc = pd.read_csv('pgs-calc-scores/cidr/scores.txt')
pgscalc.columns = pgscalc.columns.str.strip('"')
pgscalc['sample'] = pgscalc['sample'].str.strip('"')

# Exclude sample ID column
score_columns = [col for col in pgscalc.columns if col != 'sample']

# Test a sample of models
sample_models = np.random.choice(score_columns, min(20, len(score_columns)), replace=False)

print("=== Testing normality of pgs-calc scores ===\n")

results = []
for model in sample_models:
    scores = pgscalc[model].dropna()
    
    # Basic stats
    mean = scores.mean()
    std = scores.std()
    
    # Shapiro-Wilk test for normality
    shapiro_stat, shapiro_p = stats.shapiro(scores)
    
    # Check if approximately standardized (mean≈0, std≈1)
    is_standardized = abs(mean) < 0.5 and abs(std - 1.0) < 0.5
    
    results.append({
        'model': model,
        'mean': mean,
        'std': std,
        'min': scores.min(),
        'max': scores.max(),
        'shapiro_p': shapiro_p,
        'appears_standardized': is_standardized
    })
    
results_df = pd.DataFrame(results)

print("Summary statistics:")
print(f"Mean of means: {results_df['mean'].mean():.3f} (expect ~0 if standardized)")
print(f"Mean of stds: {results_df['std'].mean():.3f} (expect ~1 if standardized)")
print(f"Models that appear standardized: {results_df['appears_standardized'].sum()}/{len(results_df)}")

print("\nDetailed sample:")
print(results_df[['model', 'mean', 'std', 'min', 'max']].to_string())

# Plot distribution of one model
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 4 example models
for idx, model in enumerate(sample_models[:4]):
    ax = axes[idx // 2, idx % 2]
    scores = pgscalc[model].dropna()
    
    ax.hist(scores, bins=30, edgecolor='black', alpha=0.7, density=True)
    
    # Overlay normal distribution
    mu, sigma = scores.mean(), scores.std()
    x = np.linspace(scores.min(), scores.max(), 100)
    ax.plot(x, stats.norm.pdf(x, mu, sigma), 'r-', linewidth=2, label='Normal fit')
    
    ax.set_title(f'{model}\nμ={mu:.2f}, σ={sigma:.2f}')
    ax.set_xlabel('PRS Score')
    ax.set_ylabel('Density')
    ax.legend()

plt.tight_layout()
plt.savefig('pgs_score_distributions.png', dpi=150)
print("\nDistribution plots saved to pgs_score_distributions.png")

# Check your custom models specifically
print("\n=== Your custom models ===")
custom_models = [col for col in score_columns if 'glioma' in col.lower() or 'idh' in col.lower() or 'gbm' in col.lower()]
for model in custom_models:
    scores = pgscalc[model].dropna()
    print(f"{model}: mean={scores.mean():.3f}, std={scores.std():.3f}, range=[{scores.min():.2f}, {scores.max():.2f}]")


