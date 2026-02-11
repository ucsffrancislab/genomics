#!/usr/bin/env python3

import pandas as pd
import numpy as np
from scipy.stats import pearsonr
import matplotlib.pyplot as plt

# Your 7 custom models
models = [
    'allGlioma',
    'gbm', 'nonGbm',
    'idhmut_1p19qcodel',
    'idhmut_1p19qnoncodel',
    'idhmut',
    'idhwt',
    # What are the other 2?
]

#for i in range(1, 23):
for i in [5,17,22]:
    print(i)

    # Load pgs-calc scores (all in one file)
    #pgscalc = pd.read_csv('pgs-calc-scores/cidr/scores.txt')
    pgscalc = pd.read_csv(f'models/num/split/chr{i}.scores.txt')
    pgscalc.columns = pgscalc.columns.str.strip('"')
    pgscalc['sample'] = pgscalc['sample'].str.strip('"')
    
    results = []
    
    for model in models:
        # Load plink scores
        plink = pd.read_csv(f'plink_scores/chr{i}.chr.pos.{model}.sscore',
                            sep='\t')
        #print(plink.head())
        plink = plink.rename(columns={"#IID": "IID"})
    
        
        # Merge
        merged = pd.merge(pgscalc[['sample', f'{model}_scoring_system']], 
                          plink[['IID', 'prs_weight_AVG']], 
                          left_on='sample', right_on='IID', 
                          how='inner')
        
                          #plink[['IID', 'PRS_raw']], 
        # Correlation
        #r, p = pearsonr(merged[f'{model}_scoring_system'], merged['PRS_raw'])
        r, p = pearsonr(merged[f'{model}_scoring_system'], merged['prs_weight_AVG'])
        
        results.append({
            'model': f'{model}_scoring_system',
            'correlation': r,
            'p_value': p,
            'n_samples': len(merged)
        })
        
        print(f"{model}: r={r:.4f}, p={p:.2e}, n={len(merged)}")
    
    # Summary
    results_df = pd.DataFrame(results)
    print("\n=== Summary ===")
    print(results_df[['model', 'correlation']])
    print(f"\nMean correlation: {results_df['correlation'].mean():.4f}")
    print(f"Range: {results_df['correlation'].min():.4f} to {results_df['correlation'].max():.4f}")


"""

./pgs-scores-check2.py 
allGlioma: r=0.9296, p=3.21e-210, n=482
gbm: r=0.8835, p=3.16e-160, n=482
nonGbm: r=0.9621, p=4.84e-273, n=482
idhmut_1p19qcodel: r=0.9945, p=0.00e+00, n=482
idhmut_1p19qnoncodel: r=0.9942, p=0.00e+00, n=482
idhmut: r=0.9971, p=0.00e+00, n=482
idhwt: r=0.9974, p=0.00e+00, n=482

=== Summary ===
                                 model  correlation
0             allGlioma_scoring_system     0.929611
1                   gbm_scoring_system     0.883530
2                nonGbm_scoring_system     0.962107
3     idhmut_1p19qcodel_scoring_system     0.994536
4  idhmut_1p19qnoncodel_scoring_system     0.994164
5                idhmut_scoring_system     0.997091
6                 idhwt_scoring_system     0.997363

Mean correlation: 0.9655
Range: 0.8835 to 0.9974


"""

