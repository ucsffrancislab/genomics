#!/usr/bin/env python3

import pandas as pd
from scipy.stats import pearsonr

# Focus on allGlioma and gbm (the problematic ones)
test_models = ['allGlioma_scoring_system', 'gbm_scoring_system']

for model in test_models:
    print(f"\n=== {model} ===")
    
    chr_corrs = []
    for chr in range(1, 23):
        # Load pgs-calc scores for this chromosome (all models)
        pgscalc_chr = pd.read_csv(f'pgs-calc-scores/cidr/chr{chr}.scores.txt')
        pgscalc_chr.columns = pgscalc_chr.columns.str.strip('"')
        pgscalc_chr['sample'] = pgscalc_chr['sample'].str.strip('"')
        
        # Load plink scores for this chromosome, this model
        plink_chr = pd.read_csv(f'plink-scores/imputed-umich-cidr/chr{chr}.dose.{model.replace("_scoring_system", "")}.sscore',
                                sep='\t')
        plink_chr.rename(columns={'#IID': 'sample'}, inplace=True)
        
        # Merge on sample
        merged = pd.merge(pgscalc_chr[['sample', model]], 
                         plink_chr[['sample', 'NAMED_ALLELE_DOSAGE_SUM']],
                         on='sample')
        
        r, _ = pearsonr(merged[model], merged['NAMED_ALLELE_DOSAGE_SUM'])
        chr_corrs.append({'chr': chr, 'correlation': r})
        
    chr_df = pd.DataFrame(chr_corrs).sort_values('correlation')
    print("\nWorst 5 chromosomes:")
    print(chr_df.head())
    print(f"\nWorst: chr{chr_df.iloc[0]['chr']} (r={chr_df.iloc[0]['correlation']:.4f})")

