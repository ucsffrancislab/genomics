#!/usr/bin/python3

import glob
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats


os.chdir('scores')
raw_files = sorted(glob.glob("*.prs.genome_raw.txt"))
z_files   = sorted(glob.glob("*.prs.genome_z.txt"))
#	⚠️ imputed-umich-i370.idhmut_1p19qcodel: 5 extreme PRS outliers
#	⚠️ imputed-umich-tcga.idhmut: 6 extreme PRS outliers
#	⚠️ imputed-umich-tcga.idhmut_1p19qcodel: 2 extreme PRS outliers
#	⚠️ imputed-umich-tcga.idhmut_1p19qnoncodel: 1 extreme PRS outliers
#raw_files = sorted(glob.glob("imputed-umich-i370.idhmut_1p19qcodel.prs.genome_raw.txt"))
#z_files   = sorted(glob.glob("imputed-umich-i370.idhmut_1p19qcodel.prs.genome_z.txt"))
#raw_files = sorted(glob.glob("imputed-umich-cidr.allGlioma.prs.genome_raw.txt"))
#z_files   = sorted(glob.glob("imputed-umich-cidr.allGlioma.prs.genome_z.txt"))

assert len(raw_files) == len(z_files), "Mismatch raw vs z files"

prs_data = []

for raw, z in zip(raw_files, z_files):
    df_raw = pd.read_csv(raw, sep="\t")
    df_z   = pd.read_csv(z, sep="\t")

    df = df_raw.merge(df_z[["IID", "PRS_z"]], on="IID")
    df["file"] = os.path.basename(raw).removesuffix('.prs.genome_raw.txt')
    prs_data.append(df)

prs = pd.concat(prs_data, ignore_index=True)



snp_summary = (
    prs.groupby("file")["SNP_CT"]
       .agg(["min", "max", "mean", "std"])
)

print(snp_summary)

# Flag suspicious variability
bad = snp_summary[snp_summary["std"] > 10]
if not bad.empty:
    print("\n⚠️ WARNING: SNP_CT variability detected")
    print(bad)




os.makedirs("qc_plots", exist_ok=True)

for fname, df in prs.groupby("file"):
    plt.figure()
    plt.hist(df["PRS_raw"], bins=50)
    plt.title(f"PRS_raw distribution\n{fname}")
    plt.xlabel("PRS_raw")
    plt.ylabel("Count")
    plt.tight_layout()
    plt.savefig(f"qc_plots/{fname}.PRS_raw.hist.png")
    plt.close()

    # Shapiro test (large N → mostly diagnostic)
    stat, p = stats.shapiro(df["PRS_raw"].sample(min(5000, len(df))))
    print(f"{fname}: Shapiro p={p:.3e}")


z_summary = (
    prs.groupby("file")["PRS_z"]
       .agg(["mean", "std", "min", "max"])
)

print(z_summary)


for fname, df in prs.groupby("file"):
    r = np.corrcoef(df["PRS_raw"], df["PRS_z"])[0,1]
    if r < 0.999999:
        print(f"⚠️ {fname}: raw vs z correlation = {r}")



for fname, df in prs.groupby("file"):
    #print( df["SNP_CT"].describe() )
    if df["SNP_CT"].std() > 0:
        r = np.corrcoef(df["SNP_CT"], df["PRS_raw"])[0,1]
        print(f"{fname}: corr(SNP_CT, PRS_raw) = {r:.4f}")
    else:
        print(f"{fname}: SNP_CT constant (no missingness bias)")





# Split dataset and model from filename if applicable
prs["dataset"] = prs["file"].str.split(".").str[0]
prs["model"]   = prs["file"].str.split(".").str[1]

for dataset, df in prs.groupby("dataset"):
    pivot = df.pivot(index="IID", columns="model", values="PRS_z")
    corr = pivot.corr()

    plt.figure(figsize=(8,6))
    plt.imshow(corr, vmin=0, vmax=1)
    plt.colorbar(label="Correlation")
    plt.title(f"Model PRS_z correlation\n{dataset}")
    plt.xticks(range(len(corr)), corr.columns, rotation=90)
    plt.yticks(range(len(corr)), corr.index)
    plt.tight_layout()
    plt.savefig(f"qc_plots/{dataset}.model_corr.png")
    plt.close()




for fname, df in prs.groupby("file"):
    outliers = df[np.abs(df["PRS_z"]) > 6]
    if not outliers.empty:
        print(f"⚠️ {fname}: {len(outliers)} extreme PRS outliers")
        print( outliers[["IID", "PRS_z", "PRS_raw"]].sort_values("PRS_z") ) 

        #print( df.loc[np.abs(df["PRS_z"]) > 6, "SNP_CT"].describe() ) # this has already been checked

        plt.figure()
        plt.hist(df["PRS_z"], bins=40)
        plt.axvline(6, color="red", linestyle="--")
        plt.axvline(-6, color="red", linestyle="--")
        plt.title("PRS_z distribution with extreme outliers")
        plt.show()
        plt.savefig(f"qc_plots/{fname}.prs_z.outliers.dist.png")
        plt.close()






