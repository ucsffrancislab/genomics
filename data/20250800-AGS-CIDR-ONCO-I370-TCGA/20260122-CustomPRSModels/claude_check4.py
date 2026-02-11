#!/usr/bin/env python3

import pandas as pd

bad_models = ['PGS000342', 'PGS000199', 'PGS000021', 'PGS000004', 'PGS000005', 'PGS000007', 'PGS000008','PGS000001',
'PGS004591',
'PGS003135']

for model in bad_models:
    print(f"\n=== {model} ===")
    total_used = 0
    total_variants = 0
    
    for chr in range(1, 23):
        try:
            info = pd.read_csv(f'pgs-calc-scores/cidr/chr{chr}.scores.csv')
            row = info[info['score'] == model]
            if not row.empty:
                used = row['variants_used'].values[0]
                total = row['variants_total'].values[0]
                total_used += used
                total_variants += total
                if used > 0:  # Only print chromosomes with matches
                    print(f"chr{chr}: {used:,} used / {total:,} total ({used/total*100:.1f}% coverage)")
        except Exception as e:
            pass
    
    print(f"TOTAL: {total_used:,} / {total_variants:,} variants ({total_used/total_variants*100:.1f}% coverage)")
