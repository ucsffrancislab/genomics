#!/usr/bin/env python3
import pandas as pd
import sys

base = sys.argv[1]

# Read the .map file for SNP names
map_df = pd.read_csv(base + ".map", sep=r"\s+", header=None,
                     names=["chr", "snp", "cm", "bp"], engine="python")

# Read the .ped file (PLINK mixes tabs and spaces)
ped = pd.read_csv(base + ".ped", sep=r"\s+", header=None, engine="python")

# Sanity check
expected_cols = 6 + 2 * len(map_df)
assert ped.shape[1] == expected_cols, (
    f"Expected {expected_cols} columns but got {ped.shape[1]}. "
    f"Check delimiter or that .map and .ped match."
)

# Columns 0-5: FID, IID, Father, Mother, Sex, Phenotype
sample_info = ped.iloc[:, :2]
sample_info.columns = ["FID", "IID"]

genotypes = ped.iloc[:, 6:]

# Combine allele pairs into "A/G" format
geno_matrix = pd.DataFrame()
for i, snp in enumerate(map_df["snp"]):
    a1 = genotypes.iloc[:, 2 * i].astype(str)
    a2 = genotypes.iloc[:, 2 * i + 1].astype(str)
    geno_matrix[snp] = a1 + "/" + a2

# Combine and save
result = pd.concat([sample_info.reset_index(drop=True), geno_matrix], axis=1)
result.to_csv(base + ".csv", index=False)
