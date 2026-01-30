#!/usr/bin/env python3
"""
phipseq_qc.py

Quality control analysis for PhIP-seq z-score matrices.

Generates QC plots including:
1. Sample quality metrics (total counts, reactive peptides)
2. PCA/UMAP colored by plate, sample_type, study, group
3. Replicate correlation analysis
4. Cross-plate replicate assessment
5. Commercial control consistency across plates
6. Plate effect quantification

Usage:
    python3 phipseq_qc.py \
        --zscore-matrix zscore.csv.gz \
        --sample-metadata sample_metadata.csv \
        --output-dir qc_results

Input files:
    zscore-matrix: Peptides (rows) x Samples (columns), gzipped OK
    sample-metadata: Must have columns: sample_id, subject_id, sample_type, 
                     study, group, age, sex, plate
"""

import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from scipy import stats
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import warnings
warnings.filterwarnings('ignore')


def load_data(zscore_path: str, metadata_path: str):
    """Load z-score matrix and sample metadata."""
    print(f"Loading z-score matrix: {zscore_path}")
    zscore_df = pd.read_csv(zscore_path, index_col=0)
    print(f"  Shape: {zscore_df.shape} (peptides x samples)")
    
    print(f"Loading metadata: {metadata_path}")
    meta_df = pd.read_csv(metadata_path)
    print(f"  Shape: {meta_df.shape}")
    print(f"  Columns: {list(meta_df.columns)}")
    
    # Ensure plate is string
    if 'plate' in meta_df.columns:
        meta_df['plate'] = meta_df['plate'].astype(str)
        if not meta_df['plate'].str.contains('plate').any():
            meta_df['plate'] = 'plate_' + meta_df['plate']
    
    # Ensure sample_id is string for matching
    if 'sample_id' in meta_df.columns:
        meta_df['sample_id'] = meta_df['sample_id'].astype(str)
    
    return zscore_df, meta_df


def match_samples(zscore_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Match z-score columns to metadata rows."""
    zscore_samples = set(zscore_df.columns.astype(str))
    
    # Try to match on sample_id or sample_name
    if 'sample_id' in meta_df.columns:
        meta_samples = set(meta_df['sample_id'].astype(str))
        match_col = 'sample_id'
    elif 'sample_name' in meta_df.columns:
        meta_samples = set(meta_df['sample_name'].astype(str))
        match_col = 'sample_name'
    else:
        raise ValueError("Metadata must have 'sample_id' or 'sample_name' column")
    
    common = zscore_samples & meta_samples
    print(f"\nSample matching on '{match_col}':")
    print(f"  Z-score matrix samples: {len(zscore_samples)}")
    print(f"  Metadata samples: {len(meta_samples)}")
    print(f"  Common samples: {len(common)}")
    
    if len(common) == 0:
        # Try matching column names directly
        print("\n  No match on IDs, checking column names vs sample_name...")
        if 'sample_name' in meta_df.columns:
            meta_samples = set(meta_df['sample_name'].astype(str))
            common = zscore_samples & meta_samples
            match_col = 'sample_name'
            print(f"  Common samples after name match: {len(common)}")
    
    if len(common) == 0:
        print("\n  WARNING: No matching samples found!")
        print(f"  Z-score columns (first 5): {list(zscore_df.columns[:5])}")
        print(f"  Metadata {match_col} (first 5): {list(meta_df[match_col][:5])}")
        raise ValueError("Cannot match samples between z-score matrix and metadata")
    
    # Filter to common samples
    zscore_df = zscore_df[[c for c in zscore_df.columns if str(c) in common]]
    meta_df = meta_df[meta_df[match_col].astype(str).isin(common)].copy()
    meta_df = meta_df.set_index(match_col)
    
    # Reorder metadata to match z-score column order
    meta_df = meta_df.loc[zscore_df.columns.astype(str)]
    
    return zscore_df, meta_df


def compute_sample_metrics(zscore_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Compute per-sample quality metrics."""
    metrics = pd.DataFrame(index=zscore_df.columns)
    
    # Handle inf values
    zscore_clean = zscore_df.replace([np.inf, -np.inf], np.nan)
    
    metrics['n_reactive_z3'] = (zscore_clean > 3).sum()
    metrics['n_reactive_z5'] = (zscore_clean > 5).sum()
    metrics['n_reactive_z10'] = (zscore_clean > 10).sum()
    metrics['median_zscore'] = zscore_clean.median()
    metrics['mean_zscore'] = zscore_clean.mean()
    metrics['max_zscore'] = zscore_clean.max()
    metrics['n_missing'] = zscore_clean.isna().sum()
    metrics['pct_missing'] = 100 * metrics['n_missing'] / len(zscore_df)
    
    # Add metadata
    for col in meta_df.columns:
        metrics[col] = meta_df[col].values
    
    return metrics


def plot_sample_metrics(metrics: pd.DataFrame, output_dir: Path):
    """Plot sample-level QC metrics."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    
    # 1. Reactive peptides histogram
    ax = axes[0, 0]
    ax.hist(metrics['n_reactive_z3'], bins=50, edgecolor='black', alpha=0.7)
    ax.set_xlabel('Number of reactive peptides (Z > 3)')
    ax.set_ylabel('Number of samples')
    ax.set_title('Reactive Peptides per Sample')
    ax.axvline(metrics['n_reactive_z3'].median(), color='red', linestyle='--', 
               label=f'Median: {metrics["n_reactive_z3"].median():.0f}')
    ax.legend()
    
    # 2. Reactive peptides by plate
    ax = axes[0, 1]
    if 'plate' in metrics.columns:
        plate_order = sorted(metrics['plate'].unique())
        sns.boxplot(data=metrics, x='plate', y='n_reactive_z3', ax=ax, order=plate_order)
        ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')
        ax.set_xlabel('Plate')
        ax.set_ylabel('Reactive peptides (Z > 3)')
        ax.set_title('Reactive Peptides by Plate')
    
    # 3. Reactive peptides by sample_type
    ax = axes[0, 2]
    if 'sample_type' in metrics.columns:
        type_order = metrics.groupby('sample_type')['n_reactive_z3'].median().sort_values().index
        sns.boxplot(data=metrics, x='sample_type', y='n_reactive_z3', ax=ax, order=type_order)
        ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')
        ax.set_xlabel('Sample Type')
        ax.set_ylabel('Reactive peptides (Z > 3)')
        ax.set_title('Reactive Peptides by Sample Type')
    
    # 4. Missing data by plate
    ax = axes[1, 0]
    if 'plate' in metrics.columns:
        plate_order = sorted(metrics['plate'].unique())
        sns.boxplot(data=metrics, x='plate', y='pct_missing', ax=ax, order=plate_order)
        ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')
        ax.set_xlabel('Plate')
        ax.set_ylabel('% Missing/Inf values')
        ax.set_title('Missing Data by Plate')
    
    # 5. Median z-score distribution
    ax = axes[1, 1]
    ax.hist(metrics['median_zscore'], bins=50, edgecolor='black', alpha=0.7)
    ax.set_xlabel('Median Z-score')
    ax.set_ylabel('Number of samples')
    ax.set_title('Median Z-score Distribution')
    ax.axvline(0, color='red', linestyle='--')
    
    # 6. Z>3 vs Z>10 scatter
    ax = axes[1, 2]
    ax.scatter(metrics['n_reactive_z3'], metrics['n_reactive_z10'], alpha=0.5, s=20)
    ax.set_xlabel('Reactive peptides (Z > 3)')
    ax.set_ylabel('Reactive peptides (Z > 10)')
    ax.set_title('Low vs High Confidence Hits')
    
    plt.tight_layout()
    plt.savefig(output_dir / 'sample_metrics.png', dpi=150)
    plt.close()
    print(f"  Saved: sample_metrics.png")


def plot_pca(zscore_df: pd.DataFrame, meta_df: pd.DataFrame, output_dir: Path):
    """PCA analysis colored by various metadata."""
    print("\nRunning PCA...")
    
    # Prepare data - transpose so samples are rows
    X = zscore_df.T.copy()
    
    # Handle missing/inf values
    X = X.replace([np.inf, -np.inf], np.nan)
    X = X.fillna(0)
    
    # Standardize
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # PCA
    pca = PCA(n_components=min(10, X.shape[0], X.shape[1]))
    pcs = pca.fit_transform(X_scaled)
    
    var_explained = pca.explained_variance_ratio_ * 100
    print(f"  PC1: {var_explained[0]:.1f}% variance")
    print(f"  PC2: {var_explained[1]:.1f}% variance")
    
    # Create PC dataframe
    pc_df = pd.DataFrame(pcs[:, :4], columns=['PC1', 'PC2', 'PC3', 'PC4'], 
                         index=zscore_df.columns)
    for col in meta_df.columns:
        pc_df[col] = meta_df[col].values
    
    # Plot colored by different variables
    color_vars = ['plate', 'sample_type', 'study', 'group']
    color_vars = [v for v in color_vars if v in pc_df.columns and pc_df[v].nunique() > 1]
    
    n_plots = len(color_vars)
    if n_plots == 0:
        print("  No categorical variables for coloring PCA")
        return pc_df
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    axes = axes.flatten()
    
    for i, var in enumerate(color_vars[:4]):
        ax = axes[i]
        
        # Get unique values and assign colors
        unique_vals = pc_df[var].dropna().unique()
        n_colors = len(unique_vals)
        
        if n_colors <= 10:
            palette = sns.color_palette("tab10", n_colors)
        else:
            palette = sns.color_palette("husl", n_colors)
        
        color_map = dict(zip(unique_vals, palette))
        colors = [color_map.get(v, 'gray') for v in pc_df[var]]
        
        scatter = ax.scatter(pc_df['PC1'], pc_df['PC2'], c=colors, alpha=0.6, s=30)
        ax.set_xlabel(f'PC1 ({var_explained[0]:.1f}%)')
        ax.set_ylabel(f'PC2 ({var_explained[1]:.1f}%)')
        ax.set_title(f'PCA colored by {var}')
        
        # Legend
        handles = [plt.Line2D([0], [0], marker='o', color='w', 
                              markerfacecolor=color_map[v], markersize=8, label=str(v))
                   for v in unique_vals]
        ax.legend(handles=handles, loc='best', fontsize=8, ncol=max(1, n_colors // 10))
    
    # Clear unused axes
    for i in range(len(color_vars), 4):
        axes[i].axis('off')
    
    plt.tight_layout()
    plt.savefig(output_dir / 'pca_by_metadata.png', dpi=150)
    plt.close()
    print(f"  Saved: pca_by_metadata.png")
    
    # Also save PC1 vs PC3 and PC2 vs PC3
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    if 'plate' in pc_df.columns:
        unique_vals = pc_df['plate'].dropna().unique()
        palette = sns.color_palette("husl", len(unique_vals))
        color_map = dict(zip(unique_vals, palette))
        colors = [color_map.get(v, 'gray') for v in pc_df['plate']]
        
        axes[0].scatter(pc_df['PC1'], pc_df['PC3'], c=colors, alpha=0.6, s=30)
        axes[0].set_xlabel(f'PC1 ({var_explained[0]:.1f}%)')
        axes[0].set_ylabel(f'PC3 ({var_explained[2]:.1f}%)')
        axes[0].set_title('PC1 vs PC3 (colored by plate)')
        
        axes[1].scatter(pc_df['PC2'], pc_df['PC3'], c=colors, alpha=0.6, s=30)
        axes[1].set_xlabel(f'PC2 ({var_explained[1]:.1f}%)')
        axes[1].set_ylabel(f'PC3 ({var_explained[2]:.1f}%)')
        axes[1].set_title('PC2 vs PC3 (colored by plate)')
    
    plt.tight_layout()
    plt.savefig(output_dir / 'pca_additional.png', dpi=150)
    plt.close()
    print(f"  Saved: pca_additional.png")
    
    return pc_df


def analyze_replicates(zscore_df: pd.DataFrame, meta_df: pd.DataFrame, output_dir: Path):
    """Analyze replicate correlation within subjects."""
    print("\nAnalyzing replicate correlations...")
    
    if 'subject_id' not in meta_df.columns:
        print("  No subject_id column - skipping replicate analysis")
        return None
    
    # Find subjects with multiple samples
    subject_counts = meta_df['subject_id'].value_counts()
    multi_sample_subjects = subject_counts[subject_counts > 1].index.tolist()
    
    print(f"  Subjects with replicates: {len(multi_sample_subjects)}")
    
    if len(multi_sample_subjects) == 0:
        print("  No replicates found")
        return None
    
    # Calculate correlations
    correlations = []
    for subj in multi_sample_subjects:
        samples = meta_df[meta_df['subject_id'] == subj].index.tolist()
        
        # Get plate info
        plates = meta_df.loc[samples, 'plate'].unique() if 'plate' in meta_df.columns else ['unknown']
        same_plate = len(plates) == 1
        
        # Calculate pairwise correlations
        for i, s1 in enumerate(samples):
            for s2 in samples[i+1:]:
                z1 = zscore_df[s1].replace([np.inf, -np.inf], np.nan)
                z2 = zscore_df[s2].replace([np.inf, -np.inf], np.nan)
                
                # Remove NaN
                mask = ~(z1.isna() | z2.isna())
                if mask.sum() > 100:
                    r, p = stats.pearsonr(z1[mask], z2[mask])
                    rho, _ = stats.spearmanr(z1[mask], z2[mask])
                    
                    correlations.append({
                        'subject_id': subj,
                        'sample1': s1,
                        'sample2': s2,
                        'pearson_r': r,
                        'spearman_rho': rho,
                        'same_plate': same_plate,
                        'plates': ','.join(map(str, plates)),
                        'n_peptides': mask.sum()
                    })
    
    if len(correlations) == 0:
        print("  No valid correlations computed")
        return None
    
    corr_df = pd.DataFrame(correlations)
    
    # Summary stats
    print(f"\n  Replicate correlations summary:")
    print(f"    Median Pearson r: {corr_df['pearson_r'].median():.3f}")
    print(f"    Median Spearman rho: {corr_df['spearman_rho'].median():.3f}")
    print(f"    Range: {corr_df['pearson_r'].min():.3f} - {corr_df['pearson_r'].max():.3f}")
    
    # Same plate vs different plate
    if corr_df['same_plate'].nunique() > 1:
        same = corr_df[corr_df['same_plate']]['pearson_r']
        diff = corr_df[~corr_df['same_plate']]['pearson_r']
        print(f"\n    Same plate (n={len(same)}): median r = {same.median():.3f}")
        print(f"    Different plate (n={len(diff)}): median r = {diff.median():.3f}")
    
    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # 1. Histogram of correlations
    ax = axes[0]
    ax.hist(corr_df['pearson_r'], bins=30, edgecolor='black', alpha=0.7)
    ax.axvline(corr_df['pearson_r'].median(), color='red', linestyle='--',
               label=f'Median: {corr_df["pearson_r"].median():.3f}')
    ax.set_xlabel('Pearson correlation')
    ax.set_ylabel('Number of replicate pairs')
    ax.set_title('Replicate Correlations')
    ax.legend()
    
    # 2. Same plate vs different plate
    ax = axes[1]
    if corr_df['same_plate'].nunique() > 1:
        corr_df['plate_status'] = corr_df['same_plate'].map({True: 'Same plate', False: 'Different plates'})
        sns.boxplot(data=corr_df, x='plate_status', y='pearson_r', ax=ax)
        ax.set_xlabel('')
        ax.set_ylabel('Pearson correlation')
        ax.set_title('Replicate Correlation by Plate Status')
    else:
        ax.text(0.5, 0.5, 'All replicates on same plate', ha='center', va='center', transform=ax.transAxes)
        ax.set_title('Replicate Correlation by Plate Status')
    
    # 3. Scatter of example replicate pair
    ax = axes[2]
    # Pick the median correlation pair
    median_idx = (corr_df['pearson_r'] - corr_df['pearson_r'].median()).abs().idxmin()
    row = corr_df.loc[median_idx]
    s1, s2 = row['sample1'], row['sample2']
    
    z1 = zscore_df[s1].replace([np.inf, -np.inf], np.nan)
    z2 = zscore_df[s2].replace([np.inf, -np.inf], np.nan)
    mask = ~(z1.isna() | z2.isna())
    
    ax.scatter(z1[mask], z2[mask], alpha=0.1, s=5)
    ax.plot([-5, 20], [-5, 20], 'r--', alpha=0.5)
    ax.set_xlabel(f'{s1} Z-score')
    ax.set_ylabel(f'{s2} Z-score')
    ax.set_title(f'Example replicate pair (r={row["pearson_r"]:.3f})')
    ax.set_xlim(-5, 20)
    ax.set_ylim(-5, 20)
    
    plt.tight_layout()
    plt.savefig(output_dir / 'replicate_correlations.png', dpi=150)
    plt.close()
    print(f"  Saved: replicate_correlations.png")
    
    # Save correlations table
    corr_df.to_csv(output_dir / 'replicate_correlations.csv', index=False)
    print(f"  Saved: replicate_correlations.csv")
    
    return corr_df


def analyze_commercial_control(zscore_df: pd.DataFrame, meta_df: pd.DataFrame, output_dir: Path):
    """Analyze commercial control consistency across plates."""
    print("\nAnalyzing commercial control consistency...")
    
    if 'sample_type' not in meta_df.columns:
        print("  No sample_type column - skipping")
        return
    
    # Find commercial control samples
    commercial_mask = meta_df['sample_type'].str.lower().str.contains('commercial', na=False)
    if commercial_mask.sum() == 0:
        print("  No commercial control samples found")
        return
    
    commercial_samples = meta_df[commercial_mask].index.tolist()
    print(f"  Found {len(commercial_samples)} commercial control samples")
    
    if 'plate' in meta_df.columns:
        plates = meta_df.loc[commercial_samples, 'plate'].unique()
        print(f"  Across {len(plates)} plates: {list(plates)}")
    
    if len(commercial_samples) < 2:
        print("  Need at least 2 commercial controls for comparison")
        return
    
    # Calculate pairwise correlations
    commercial_z = zscore_df[commercial_samples].replace([np.inf, -np.inf], np.nan)
    corr_matrix = commercial_z.corr()
    
    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Correlation heatmap
    ax = axes[0]
    mask = np.triu(np.ones_like(corr_matrix, dtype=bool), k=1)
    #sns.heatmap(corr_matrix, mask=mask, annot=True, fmt='.3f', cmap='RdYlBu_r',
    sns.heatmap(corr_matrix, mask=mask, annot=False, fmt='.3f', cmap='RdYlBu_r',
                center=1, vmin=0.8, vmax=1, ax=ax, square=True)
    ax.set_title('Commercial Control Correlations')
    
    # 2. Z-score profiles
    ax = axes[1]
    # Subsample peptides for visualization
    n_peptides = min(1000, len(commercial_z))
    peptide_idx = np.random.choice(len(commercial_z), n_peptides, replace=False)
    
    for i, col in enumerate(commercial_z.columns):
        ax.plot(commercial_z.iloc[peptide_idx, i].values, alpha=0.5, label=col, linewidth=0.5)
    
    ax.set_xlabel('Peptide (subset)')
    ax.set_ylabel('Z-score')
    ax.set_title('Commercial Control Z-score Profiles')
    ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig(output_dir / 'commercial_control_qc.png', dpi=150)
    plt.close()
    print(f"  Saved: commercial_control_qc.png")


def analyze_plate_effects(zscore_df: pd.DataFrame, meta_df: pd.DataFrame, output_dir: Path):
    """Quantify plate effects."""
    print("\nAnalyzing plate effects...")
    
    if 'plate' not in meta_df.columns:
        print("  No plate column - skipping")
        return
    
    plates = meta_df['plate'].unique()
    print(f"  Plates: {len(plates)}")
    
    # Calculate median z-score per plate
    plate_medians = {}
    for plate in plates:
        samples = meta_df[meta_df['plate'] == plate].index.tolist()
        plate_z = zscore_df[samples].replace([np.inf, -np.inf], np.nan)
        plate_medians[plate] = plate_z.median(axis=1)
    
    plate_median_df = pd.DataFrame(plate_medians)
    
    # Plate-plate correlations
    plate_corr = plate_median_df.corr()
    
    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Plate correlation heatmap
    ax = axes[0]
    sns.heatmap(plate_corr, annot=True, fmt='.2f', cmap='RdYlBu_r', 
                center=1, ax=ax, square=True)
    ax.set_title('Plate Median Z-score Correlations')
    
    # 2. Distribution of median z-scores by plate
    ax = axes[1]
    for plate in plates:
        vals = plate_median_df[plate].dropna()
        ax.hist(vals, bins=50, alpha=0.5, label=plate, density=True)
    ax.set_xlabel('Median Z-score across samples')
    ax.set_ylabel('Density')
    ax.set_title('Plate-level Z-score Distributions')
    ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig(output_dir / 'plate_effects.png', dpi=150)
    plt.close()
    print(f"  Saved: plate_effects.png")
    
    # Save plate correlation
    plate_corr.to_csv(output_dir / 'plate_correlations.csv')
    print(f"  Saved: plate_correlations.csv")


def summarize_metadata(meta_df: pd.DataFrame, output_dir: Path):
    """Generate metadata summary tables."""
    print("\nMetadata summary:")
    
    summaries = []
    
    for col in ['sample_type', 'study', 'group', 'plate', 'sex']:
        if col in meta_df.columns:
            counts = meta_df[col].value_counts(dropna=False)
            print(f"\n  {col}:")
            for val, count in counts.items():
                print(f"    {val}: {count}")
            summaries.append(counts.to_frame(name='count').reset_index().rename(columns={'index': col}))
    
    # Cross-tabulation: sample_type x study
    if 'sample_type' in meta_df.columns and 'study' in meta_df.columns:
        crosstab = pd.crosstab(meta_df['sample_type'], meta_df['study'], margins=True)
        crosstab.to_csv(output_dir / 'crosstab_sampletype_study.csv')
        print(f"\n  Saved: crosstab_sampletype_study.csv")
    
    # Cross-tabulation: group x study
    if 'group' in meta_df.columns and 'study' in meta_df.columns:
        crosstab = pd.crosstab(meta_df['group'], meta_df['study'], margins=True)
        crosstab.to_csv(output_dir / 'crosstab_group_study.csv')
        print(f"\n  Saved: crosstab_group_study.csv")
    
    # Cross-tabulation: plate x sample_type
    if 'plate' in meta_df.columns and 'sample_type' in meta_df.columns:
        crosstab = pd.crosstab(meta_df['plate'], meta_df['sample_type'], margins=True)
        crosstab.to_csv(output_dir / 'crosstab_plate_sampletype.csv')
        print(f"\n  Saved: crosstab_plate_sampletype.csv")


def identify_outliers(metrics: pd.DataFrame, output_dir: Path):
    """Identify potential outlier samples."""
    print("\nIdentifying potential outliers...")
    
    outliers = []
    
    # Low reactive peptides (potential failed samples)
    q1 = metrics['n_reactive_z3'].quantile(0.25)
    iqr = metrics['n_reactive_z3'].quantile(0.75) - q1
    low_threshold = q1 - 1.5 * iqr
    low_reactive = metrics[metrics['n_reactive_z3'] < max(0, low_threshold)]
    if len(low_reactive) > 0:
        print(f"  Low reactive peptides (n={len(low_reactive)}): potential failed samples")
        for idx in low_reactive.index[:5]:
            print(f"    {idx}: {low_reactive.loc[idx, 'n_reactive_z3']:.0f} peptides")
        outliers.extend([(idx, 'low_reactive') for idx in low_reactive.index])
    
    # High missing data
    high_missing = metrics[metrics['pct_missing'] > 10]
    if len(high_missing) > 0:
        print(f"  High missing data (n={len(high_missing)}): >10% missing")
        outliers.extend([(idx, 'high_missing') for idx in high_missing.index])
    
    # Extreme median z-score
    extreme_median = metrics[(metrics['median_zscore'] < -2) | (metrics['median_zscore'] > 2)]
    if len(extreme_median) > 0:
        print(f"  Extreme median z-score (n={len(extreme_median)})")
        outliers.extend([(idx, 'extreme_median') for idx in extreme_median.index])
    
    if outliers:
        outlier_df = pd.DataFrame(outliers, columns=['sample', 'reason'])
        outlier_df.to_csv(output_dir / 'potential_outliers.csv', index=False)
        print(f"  Saved: potential_outliers.csv")
    else:
        print("  No outliers identified")


def main():
    parser = argparse.ArgumentParser(description='QC analysis for PhIP-seq z-score data')
    parser.add_argument('--zscore-matrix', required=True, help='Z-score matrix CSV (peptides x samples)')
    parser.add_argument('--sample-metadata', required=True, help='Sample metadata CSV')
    parser.add_argument('--output-dir', default='qc_results', help='Output directory')
    args = parser.parse_args()
    
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {output_dir}")
    
    # Load data
    zscore_df, meta_df = load_data(args.zscore_matrix, args.sample_metadata)
    
    # Match samples
    zscore_df, meta_df = match_samples(zscore_df, meta_df)
    
    # Metadata summary
    summarize_metadata(meta_df, output_dir)
    
    # Compute sample metrics
    print("\nComputing sample metrics...")
    metrics = compute_sample_metrics(zscore_df, meta_df)
    metrics.to_csv(output_dir / 'sample_metrics.csv')
    print(f"  Saved: sample_metrics.csv")
    
    # Plot sample metrics
    print("\nPlotting sample metrics...")
    plot_sample_metrics(metrics, output_dir)
    
    # PCA
    pc_df = plot_pca(zscore_df, meta_df, output_dir)
    pc_df.to_csv(output_dir / 'pca_coordinates.csv')
    print(f"  Saved: pca_coordinates.csv")
    
    # Replicate analysis
    analyze_replicates(zscore_df, meta_df, output_dir)
    
    # Commercial control analysis
    analyze_commercial_control(zscore_df, meta_df, output_dir)
    
    # Plate effects
    analyze_plate_effects(zscore_df, meta_df, output_dir)
    
    # Identify outliers
    identify_outliers(metrics, output_dir)
    
    print(f"\n{'='*60}")
    print("QC analysis complete!")
    print(f"Results in: {output_dir}")
    print('='*60)


if __name__ == '__main__':
    main()
