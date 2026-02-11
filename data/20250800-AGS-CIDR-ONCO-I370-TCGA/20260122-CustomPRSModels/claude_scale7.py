#!/usr/bin/env python3

import pandas as pd

# Load scores
scores = pd.read_csv('pgs-calc-scores/cidr/scores.txt')
scores.columns = scores.columns.str.strip('"')
scores['sample'] = scores['sample'].str.strip('"')

# Standardize all PRS columns (exclude sample ID)
prs_cols = [col for col in scores.columns if col != 'sample']

scores_standardized = scores.copy()
for col in prs_cols:
    scores_standardized[col] = (scores[col] - scores[col].mean()) / scores[col].std()

# Save standardized scores
scores_standardized.to_csv('pgs-calc-scores/cidr/scores_standardized.txt', index=False)

print("Standardized scores saved!")

# Verify
print("\nSample after standardization:")
for model in ['allGlioma_scoring_system', 'PGS001584']:
    print(f"{model}: mean={scores_standardized[model].mean():.3e}, std={scores_standardized[model].std():.3f}")

