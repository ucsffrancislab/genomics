#!/usr/bin/env python3

import pandas as pd
from scipy.stats import pearsonr

# Load full pgs-calc scores
pgscalc = pd.read_csv('pgs-calc-scores/cidr/scores.txt')
pgscalc.columns = pgscalc.columns.str.strip('"')
pgscalc['sample'] = pgscalc['sample'].str.strip('"')

# Test allGlioma and gbm (the ones that improved most)
test_models = ['allGlioma_scoring_system', 'gbm_scoring_system']

for model in test_models:
    print(f"\n=== {model} ===")
    
    chr_corrs = []
    for chr in range(1, 23):
        # Load plink chr-specific scores
        plink = pd.read_csv(f'plink-scores/imputed-umich-cidr/chr{chr}.dose.{model.replace("_scoring_system", "")}.sscore', 
                           sep='\t')
        
        # Merge
        merged = pd.merge(pgscalc[['sample', model]], 
                         plink.rename(columns={'#IID': 'sample'})[['sample', 'NAMED_ALLELE_DOSAGE_SUM']],
                         on='sample')
        
        r, _ = pearsonr(merged[model], merged['NAMED_ALLELE_DOSAGE_SUM'])
        chr_corrs.append({'chr': chr, 'correlation': r})
        
    chr_df = pd.DataFrame(chr_corrs).sort_values('correlation')
    print("\nWorst 5 chromosomes:")
    print(chr_df.head())
    print(f"\nBest chromosome: chr{chr_df.iloc[-1]['chr']} (r={chr_df.iloc[-1]['correlation']:.4f})")
    print(f"Worst chromosome: chr{chr_df.iloc[0]['chr']} (r={chr_df.iloc[0]['correlation']:.4f})")


