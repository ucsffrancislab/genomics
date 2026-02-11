#!/usr/bin/env python3
import pandas as pd

# Load your pgs-calc model
pgscalc_model = pd.read_csv('pgs-calc_models_without_chr_prefix/allGlioma_scoring_system.txt.gz', 
                             sep='\t')

print(f"pgs-calc model variants: {len(pgscalc_model):,}")
print("\nFirst few variants:")
print(pgscalc_model.head(10))

# Load plink model
plink_model = pd.read_csv('plink_models_with_chr_prefix/allGlioma_scoring_system.txt.gz',
                          sep='\s+')

print(f"\nplink model variants: {len(plink_model):,}")
print("\nFirst few variants:")
print(plink_model.head(10))

# Check if positions match for the same variants
# Extract chr:pos from plink IDs
plink_model['chr'] = plink_model['ID'].str.split(':').str[0].str.replace('chr', '')
plink_model['pos'] = plink_model['ID'].str.split(':').str[1].astype(int)

# Convert both to string for matching
pgscalc_model['hm_chr'] = pgscalc_model['hm_chr'].astype(str)
plink_model['chr'] = plink_model['chr'].astype(str)

# See if any match
merged = pd.merge(pgscalc_model, plink_model, 
                  left_on=['hm_chr', 'hm_pos'], 
                  right_on=['chr', 'pos'],
                  how='inner')

print(f"\nVariants matching by chr:pos: {len(merged):,}")
print(f"Matching rate: {len(merged)/len(pgscalc_model)*100:.2f}%")
