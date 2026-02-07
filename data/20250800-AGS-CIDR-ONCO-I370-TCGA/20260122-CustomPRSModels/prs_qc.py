#!/usr/bin/python3

import glob
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats


os.chdir('scores')
#raw_files = sorted(glob.glob("*.prs.genome_raw.select.txt"))
#z_files   = sorted(glob.glob("*.prs.genome_z.select.txt"))
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
    #df["file"] = os.path.basename(raw).removesuffix('.prs.genome_raw.select.txt')
    df["file"] = os.path.basename(raw).removesuffix('.prs.genome_raw.txt')
    prs_data.append(df)

prs = pd.concat(prs_data, ignore_index=True)

# Split dataset and model from filename if applicable
prs["dataset"] = prs["file"].str.split(".").str[0].str.split("-").str[2]
prs["model"]   = prs["file"].str.split(".").str[1]

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




#os.makedirs("qc_plots_select", exist_ok=True)
os.makedirs("qc_plots_new", exist_ok=True)

for fname, df in prs.groupby("file"):
    plt.figure()
    plt.hist(df["PRS_raw"], bins=50)
    plt.title(f"PRS_raw distribution\n{fname}")
    plt.xlabel("PRS_raw")
    plt.ylabel("Count")
    plt.tight_layout()
    #plt.savefig(f"qc_plots_select/{fname}.PRS_raw.hist.png")
    plt.savefig(f"qc_plots_new/{fname}.PRS_raw.hist.png")
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
    #plt.savefig(f"qc_plots_select/{dataset}.model_corr.png")
    plt.savefig(f"qc_plots_new/{dataset}.model_corr.png")
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
        #plt.savefig(f"qc_plots_select/{fname}.prs_z.outliers.dist.png")
        plt.savefig(f"qc_plots_new/{fname}.prs_z.outliers.dist.png")
        plt.close()





#prs.to_csv('testing.prs.csv')
#
#,IID,PRS_raw,SNP_CT,PRS_z,file,dataset,model
#0,147_G146-1-0427562915,20.9992,1648348,0.646634036499858,imputed-umich-cidr.allGlioma,cidr,allGlioma
#1,136_G135-1-0427562904,20.955,1648348,0.3237928454686345,imputed-umich-cidr.allGlioma,cidr,allGlioma
#2,369_G369-1-0427563047,21.0402,1648348,0.9461021096283708,imputed-umich-cidr.allGlioma,cidr,allGlioma
#3,27_G025-1-0427562792,20.959,1648348,0.3530092428470355,imputed-umich-cidr.allGlioma,cidr,allGlioma
#
#
#/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250724-pgs/pgs-onco-hg19/estimated-population.txt
#	
pcs = pd.read_csv('IID_PCs.tsv', sep="\t")
print(pcs.dtypes)
print(pcs.head())
print(prs.dtypes)
print(prs.head())

print(pcs.shape)
print(prs.shape)
prs = pd.merge(prs,pcs, left_on='IID', right_on='IID', how='inner')
print(prs.shape)

corr_rows = []
pcs = ["PC1", "PC2", "PC3", "PC4", "PC5"]

for (dataset, model), g in prs.groupby(["dataset", "model"]):

    for pc in pcs:
        if pc not in g.columns:
            continue

        gg = g.dropna(subset=["PRS_raw", pc])
        if len(gg) < 10:
            continue

        r = np.corrcoef(gg["PRS_raw"], gg[pc])[0, 1]

        corr_rows.append({
            "dataset": dataset,
            "model": model,
            "pc": pc,
            "n": len(gg),
            "pearson_r": r,
            "abs_r": abs(r)
        })

corr_df = (
    pd.DataFrame(corr_rows)
      .sort_values("abs_r", ascending=False)
)

corr_df.to_csv(
    "prs_pc1_pc5_correlations.tsv",
    sep="\t",
    index=False
)




#	What you should do next (if you get more time)
#	
#	If you only do one more thing, do this:
#	
#	Plot PRS by known categorical variables
#	
#	For idhwt only:
#	
#	IDH mutation status
#	
#	1p/19q status
#	
#	GBM vs nonGBM
#	
#	sequencing center / batch / array (if available)
#	
#	A single boxplot will likely explain the modes.
#	
#	#sns.boxplot(x="IDH_status", y="PRS_raw", data=idhwt_df)
#	
#	If the modes align → mystery solved.



#	convert the sample's IID column ...
#	TCGA-02-0003-10A_TCGA-02-0003-10A,
#	to just the subject ...
#	TCGA-02-0003

#	awk 'BEGIN{FS=OFS="\t"}{print $1,$4,$5,$6,$8,$9}' /francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv | head
#	case_submitter_id	race	ethnicity	gender	IDH	x1p19q
#	TCGA-02-0001	white	not hispanic or latino	female	WT	non-codel
#	TCGA-02-0003	white	not hispanic or latino	male	WT	non-codel
#	TCGA-02-0004	white	not hispanic or latino	male	WT	NA
#	TCGA-02-0006	white	not hispanic or latino	female	WT	non-codel
#	TCGA-02-0007	white	not hispanic or latino	female	WT	non-codel
#	TCGA-02-0009	white	not hispanic or latino	female	WT	non-codel
#	TCGA-02-0010	white	not hispanic or latino	female	Mutant	non-codel

#	
#	prs_tcga = prs[prs['IID'].str.startswith('TCGA')].copy() # make a copy to avoid the CopyWarning
#	
#	prs_tcga['subject'] = prs_tcga['IID'].str[0:12]
#	#prs_tcga.loc[:, 'subject'] = prs_tcga['IID'].str[:12]
#	print(prs_tcga.shape)
#	
#	
#	#	there are only 873 TCGA samples in the TCGA dataset
#	
#	tcga = pd.read_csv('/francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv', sep="\t")
#	print(tcga.shape)
#	#	Not sure where 1114 is coming from
#	prs_tcga = pd.merge(prs_tcga, tcga, left_on='subject', right_on='case_submitter_id', how='inner')
#	print(prs_tcga.shape)
#	
#	#	cut -d$'\t' -f1 scores/prs_tcga.tsv | sort | uniq | wc -l
#	#	870
#	
#	prs_tcga.to_csv(
#		    "prs_tcga.tsv",
#		    sep="\t",
#		    index=False
#		)
#	


