#!/usr/bin/env python3

import pandas as pd

# Load the scores.info to see total matching stats
info = pd.read_csv('pgs-calc-scores/cidr/scores.info', sep='\t')

# Find allGlioma model
allglioma = info[info['score'].str.contains('allGlioma', case=False, na=False)]
print(allglioma[['score', 'variants_used', 'variants_total', 'coverage']])

# Or if the score column has a different name/format:
print("\nAll scores info:")
print(info.head(20))

