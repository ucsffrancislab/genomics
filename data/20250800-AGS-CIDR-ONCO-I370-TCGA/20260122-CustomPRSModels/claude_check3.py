#!/usr/bin/env python3

import pandas as pd

# Load imputation server scores
server_scores = pd.read_csv('/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/pgs-cidr-hg19/scores.txt', 
                            sep='\t', nrows=5)

print("Server scores shape:", server_scores.shape)
print("\nFirst few columns:")
print(server_scores.columns[:10].tolist())
print("\nFirst few rows, first few columns:")
print(server_scores.iloc[:5, :5])

# Check sample ID column name
sample_col = [col for col in server_scores.columns if 'sample' in col.lower() or 'iid' in col.lower() or 'id' in col.lower()]
print(f"\nPotential sample ID columns: {sample_col}")

