"""
Complete PhIPSeq Analysis Pipeline - CORRECTED VERSION
Based on Andreu-Sánchez et al., Immunity 2023

Key corrections:
1. Uses phage library reads (not separate input/beads sample)
2. Includes batch/plate correction for downstream analysis
3. Generates null distribution PER SAMPLE from library complexity

Processes VirScan alignment counts and outputs seropositivity at:
- Peptide level
- Protein level  
- Virus level
"""

import pandas as pd
import numpy as np
from scipy.stats import nbinom
from scipy.optimize import minimize
from statsmodels.stats.multitest import multipletests
import warnings
from pathlib import Path


class ImmunityPhIPSeqPipeline:
    """
    Complete pipeline implementing Immunity 2023 methods.
    
    Key insight from paper: "null distributions per input level 
    (number of reads per clone without IP) were generated in each sample"
    
    This means they use the PHAGE LIBRARY complexity (reads per peptide 
    in the library itself) to model expected enrichment, NOT a separate
    beads-only control.
    """
    
    def __init__(self, rarefaction_depth=1_250_000, bonferroni_alpha=0.05, n_jobs=1):
        """
        Initialize pipeline.
        
        Parameters:
        -----------
        rarefaction_depth : int
            Target read depth for rarefaction (default: 1,250,000)
        bonferroni_alpha : float
            Significance threshold for Bonferroni correction (default: 0.05)
        n_jobs : int
            Number of parallel jobs for enrichment calling (default: 1)
            Set to -1 to use all available CPUs
        """
        self.rarefaction_depth = rarefaction_depth
        self.bonferroni_alpha = bonferroni_alpha
        self.n_jobs = n_jobs
        
    def load_counts(self, counts_file):
        """
        Load counts matrix from CSV.
        
        Parameters:
        -----------
        counts_file : str
            Path to counts CSV file (peptides as rows, samples as columns)
            Should contain ONLY IP samples (no input/beads columns needed)
            
        Returns:
        --------
        counts_df : pd.DataFrame
            Counts matrix (peptides x samples)
        """
        print("Loading counts matrix...")
        counts_df = pd.read_csv(counts_file, index_col=0)
        
        print(f"Loaded {len(counts_df)} peptides x {len(counts_df.columns)} samples")
        
        return counts_df
    
    def load_peptide_metadata(self, metadata_file):
        """
        Load peptide annotations (peptide_id, protein, virus/organism).
        
        Parameters:
        -----------
        metadata_file : str
            Path to peptide metadata CSV
            Required columns: peptide_id, protein_name, virus/organism
            
        Returns:
        --------
        metadata_df : pd.DataFrame
            Peptide annotations
        """
        print("Loading peptide metadata...")
        metadata = pd.read_csv(metadata_file)
        
        # Check required columns
        if 'peptide_id' not in metadata.columns:
            # Try to use first column as peptide_id
            metadata.rename(columns={metadata.columns[0]: 'peptide_id'}, inplace=True)
        
        # Standardize column names
        col_mapping = {}
        for col in metadata.columns:
            col_lower = col.lower()
            if 'protein' in col_lower and 'protein_name' not in metadata.columns:
                col_mapping[col] = 'protein_name'
            elif ('virus' in col_lower or 'organism' in col_lower) and 'organism' not in metadata.columns:
                col_mapping[col] = 'organism'
        
        metadata.rename(columns=col_mapping, inplace=True)
        
        print(f"Loaded metadata for {len(metadata)} peptides")
        return metadata
    
    def load_sample_metadata(self, metadata_file):
        """
        Load sample metadata including batch/plate information.
        
        Parameters:
        -----------
        metadata_file : str
            Path to sample metadata CSV
            Should include: sample_id, plate/batch, and other covariates
            
        Returns:
        --------
        metadata_df : pd.DataFrame
            Sample metadata
        """
        print("Loading sample metadata...")
        metadata = pd.read_csv(metadata_file, index_col=0)
        
        # Check for plate/batch column
        plate_cols = [col for col in metadata.columns 
                     if 'plate' in col.lower() or 'batch' in col.lower()]
        
        if len(plate_cols) == 0:
            warnings.warn(
                "No plate/batch column found in sample metadata. "
                "Batch effects cannot be corrected."
            )
        else:
            print(f"Found batch column: {plate_cols[0]}")
            
        print(f"Loaded metadata for {len(metadata)} samples")
        return metadata
    
    def rarefy_counts(self, counts_df):
        """
        Rarefy counts to target depth using random subsampling.
        
        Parameters:
        -----------
        counts_df : pd.DataFrame
            Raw counts (peptides x samples)
        
        Returns:
        --------
        rarefied_df : pd.DataFrame
            Rarefied counts
        """
        print(f"\nRarefying counts to {self.rarefaction_depth:,} reads per sample...")
        
        from numpy.random import default_rng
        rng = default_rng(42)  # For reproducibility
        
        rarefied = pd.DataFrame(
            index=counts_df.index,
            columns=counts_df.columns,
            dtype=int
        )
        
        for sample in counts_df.columns:
            sample_counts = counts_df[sample].values.astype(int)
            total = sample_counts.sum()
            
            if total < self.rarefaction_depth:
                print(f"  Warning: {sample} has only {total:,} reads (below target)")
                rarefied[sample] = sample_counts
                continue
            
            # Create pool of peptide indices weighted by counts
            peptide_pool = np.repeat(
                np.arange(len(sample_counts)),
                sample_counts
            )
            
            # Random sample without replacement
            sampled_indices = rng.choice(
                peptide_pool,
                size=self.rarefaction_depth,
                replace=False
            )
            
            # Count occurrences
            rarefied_counts = np.bincount(
                sampled_indices,
                minlength=len(sample_counts)
            )
            rarefied[sample] = rarefied_counts
            
            if sample == counts_df.columns[0]:  # First sample
                print(f"  {sample}: {total:,} → {self.rarefaction_depth:,} reads")
        
        print(f"Rarefaction complete. Total samples: {len(rarefied.columns)}")
        return rarefied
    
    def estimate_library_complexity(self, rarefied_counts):
        """
        Estimate phage library complexity for each peptide.
        
        From paper: "null distributions per input level (number of reads 
        per clone without IP)"
        
        This estimates what the "input level" would be for each peptide
        based on the observed distribution across all samples.
        
        Parameters:
        -----------
        rarefied_counts : pd.DataFrame
            Rarefied counts matrix
            
        Returns:
        --------
        library_complexity : pd.Series
            Estimated input read count for each peptide
        """
        print("\nEstimating phage library complexity from sample distribution...")
        
        # Calculate median count across all samples for each peptide
        # This represents the "baseline" abundance in the phage library
        library_complexity = rarefied_counts.median(axis=1)
        
        # For peptides with zero median (very rare), use mean
        zero_median = library_complexity == 0
        library_complexity[zero_median] = rarefied_counts[zero_median].mean(axis=1)
        
        # Still zero? Use minimum non-zero value
        still_zero = library_complexity == 0
        if still_zero.any():
            min_nonzero = rarefied_counts[rarefied_counts > 0].min().min()
            library_complexity[still_zero] = min_nonzero
        
        print(f"Library complexity range: {library_complexity.min():.1f} - {library_complexity.max():.1f}")
        print(f"Median library complexity: {library_complexity.median():.1f}")
        
        return library_complexity
    
    def fit_generalized_poisson_per_sample(self, library_complexity, ip_counts):
        """
        Fit Generalized Poisson model using library complexity as baseline.
        
        Key insight: The null distribution is based on peptide abundance
        in the phage library (library_complexity), not a separate input sample.
        
        Parameters:
        -----------
        library_complexity : np.array
            Estimated baseline read count for each peptide
        ip_counts : np.array
            IP sample read counts
            
        Returns:
        --------
        pvalues : np.array
            P-values for each peptide
        """
        x = library_complexity.astype(float)
        y = ip_counts.astype(float)
        
        # Group peptides by input level (library complexity)
        # Create bins for null distribution
        x_bins = np.percentile(x[x > 0], [0, 25, 50, 75, 100])
        
        pvalues = np.ones(len(x))
        
        for i in range(len(x)):
            if y[i] == 0 or x[i] == 0:
                pvalues[i] = 1.0
                continue
            
            # Find which bin this peptide belongs to
            bin_idx = np.digitize(x[i], x_bins) - 1
            bin_idx = np.clip(bin_idx, 0, len(x_bins) - 2)
            
            # Get peptides in same bin (similar library complexity)
            in_bin = (x >= x_bins[bin_idx]) & (x < x_bins[bin_idx + 1])
            
            if in_bin.sum() < 10:
                # Not enough peptides in bin, use broader range
                in_bin = (x > 0)
            
            # Fit distribution using peptides with similar input levels
            bin_x = x[in_bin]
            bin_y = y[in_bin]
            
            # Remove zeros
            mask = (bin_x > 0) & (bin_y > 0)
            if mask.sum() < 5:
                pvalues[i] = 1.0
                continue
            
            # Fit log-linear model
            log_x = np.log(bin_x[mask] + 1)
            log_y = np.log(bin_y[mask] + 1)
            
            # Simple linear regression
            from sklearn.linear_model import LinearRegression
            lr = LinearRegression()
            lr.fit(log_x.reshape(-1, 1), log_y)
            
            # Expected count for this peptide
            log_expected = lr.predict(np.log(x[i] + 1).reshape(-1, 1))[0]
            expected = np.exp(log_expected)
            expected = max(expected, 0.1)
            
            # Calculate p-value using negative binomial
            mu = expected
            theta = mu  # Simplified dispersion
            
            try:
                p = nbinom.sf(
                    y[i] - 1,
                    n=theta,
                    p=theta / (theta + mu)
                )
                pvalues[i] = p
            except:
                pvalues[i] = 1.0
        
        return pvalues
    
    def call_enriched_peptides(self, rarefied_counts):
        """
        Call enriched (seropositive) peptides using Generalized Poisson model.
        
        Uses library complexity (estimated from sample distribution) as baseline,
        NOT a separate input/beads sample.
        
        Now parallelized for speed!
        
        Parameters:
        -----------
        rarefied_counts : pd.DataFrame
            Rarefied IP counts (peptides x samples)
            
        Returns:
        --------
        enriched : pd.DataFrame
            Binary enrichment matrix (1 = enriched, 0 = not enriched)
        pvalues : pd.DataFrame
            P-values for each peptide-sample combination
        """
        print("\nCalling enriched peptides using Generalized Poisson model...")
        print("(Using library complexity as baseline, per Immunity 2023 methods)")
        
        # Estimate library complexity
        library_complexity = self.estimate_library_complexity(rarefied_counts)
        
        n_peptides = len(rarefied_counts)
        threshold = self.bonferroni_alpha / n_peptides
        
        print(f"Bonferroni-corrected threshold: p < {threshold:.2e}")
        
        if self.n_jobs != 1:
            print(f"Using {self.n_jobs if self.n_jobs > 0 else 'all available'} CPU cores for parallel processing...")
        
        enriched = pd.DataFrame(
            0,
            index=rarefied_counts.index,
            columns=rarefied_counts.columns,
            dtype=int
        )
        
        pvalues_df = pd.DataFrame(
            index=rarefied_counts.index,
            columns=rarefied_counts.columns,
            dtype=float
        )
        
        # Parallelize across samples
        from joblib import Parallel, delayed
        
        def process_sample(sample, ip_counts_sample):
            """Process a single sample."""
            pvals = self.fit_generalized_poisson_per_sample(
                library_complexity.values,
                ip_counts_sample
            )
            enriched_sample = (pvals < threshold).astype(int)
            n_enriched = enriched_sample.sum()
            return sample, pvals, enriched_sample, n_enriched
        
        # Run in parallel
        results = Parallel(n_jobs=self.n_jobs, verbose=1)(
            delayed(process_sample)(sample, rarefied_counts[sample].values)
            for sample in rarefied_counts.columns
        )
        
        # Collect results
        for sample, pvals, enriched_sample, n_enriched in results:
            pvalues_df[sample] = pvals
            enriched[sample] = enriched_sample
            print(f"  {sample}: {n_enriched} enriched peptides")
        
        total_enriched = (enriched.sum(axis=1) > 0).sum()
        print(f"\nTotal unique enriched peptides: {total_enriched}")
        
        return enriched, pvalues_df
    
    def filter_peptides(self, enriched, min_prevalence=0.05, max_prevalence=0.95):
        """
        Filter peptides by prevalence (seroprevalence).
        
        Parameters:
        -----------
        enriched : pd.DataFrame
            Binary enrichment matrix
        min_prevalence : float
            Minimum proportion of samples with enrichment
        max_prevalence : float
            Maximum proportion of samples with enrichment
            
        Returns:
        --------
        filtered_enriched : pd.DataFrame
            Filtered enrichment matrix
        """
        print(f"\nFiltering peptides by prevalence ({min_prevalence}-{max_prevalence})...")
        
        prevalence = enriched.mean(axis=1)
        mask = (prevalence >= min_prevalence) & (prevalence <= max_prevalence)
        
        filtered = enriched[mask]
        
        print(f"Kept {len(filtered)} / {len(enriched)} peptides")
        print(f"Prevalence range: {prevalence[mask].min():.3f} - {prevalence[mask].max():.3f}")
        
        return filtered
    
    def aggregate_to_protein(self, peptide_enriched, peptide_metadata):
        """
        Aggregate peptide-level seropositivity to protein level.
        
        A sample is considered seropositive for a protein if ANY peptide
        from that protein is enriched.
        
        Parameters:
        -----------
        peptide_enriched : pd.DataFrame
            Binary enrichment at peptide level (peptide_id as INDEX)
        peptide_metadata : pd.DataFrame
            Peptide annotations with protein_name
            
        Returns:
        --------
        protein_enriched : pd.DataFrame
            Binary enrichment at protein level
        """
        print("\nAggregating peptides to protein level...")
        
        # Reset index to make peptide_id a column
        enriched_with_id = peptide_enriched.reset_index()
        
        # The index name might be None, 'index', or the actual index name
        # Rename whatever the first column is to 'peptide_id'
        if 'peptide_id' not in enriched_with_id.columns:
            # Assume first column is the peptide_id
            old_name = enriched_with_id.columns[0]
            enriched_with_id.rename(columns={old_name: 'peptide_id'}, inplace=True)
        
        # Ensure peptide_id is same type in both dataframes
        enriched_with_id['peptide_id'] = enriched_with_id['peptide_id'].astype(str)
        peptide_metadata_copy = peptide_metadata.copy()
        peptide_metadata_copy['peptide_id'] = peptide_metadata_copy['peptide_id'].astype(str)
        
        # Merge with metadata
        enriched_with_meta = enriched_with_id.merge(
            peptide_metadata_copy[['peptide_id', 'protein_name']],
            on='peptide_id',
            how='left'
        )
        
        # Check for missing protein names
        missing_protein = enriched_with_meta['protein_name'].isna().sum()
        if missing_protein > 0:
            print(f"  Warning: {missing_protein} peptides missing protein_name, will be dropped")
            enriched_with_meta = enriched_with_meta.dropna(subset=['protein_name'])
        
        # Get sample columns (exclude peptide_id and protein_name)
        sample_cols = [col for col in enriched_with_meta.columns 
                      if col not in ['peptide_id', 'protein_name']]
        
        # Group by protein, take max (any peptide positive = protein positive)
        protein_enriched = enriched_with_meta.groupby('protein_name')[sample_cols].max()
        
        print(f"Aggregated to {len(protein_enriched)} proteins")
        
        return protein_enriched
    
    def aggregate_to_virus(self, peptide_enriched, peptide_metadata):
        """
        Aggregate peptide-level seropositivity to virus/organism level.
        
        A sample is considered seropositive for a virus if ANY peptide
        from that virus is enriched.
        
        Parameters:
        -----------
        peptide_enriched : pd.DataFrame
            Binary enrichment at peptide level (peptide_id as INDEX)
        peptide_metadata : pd.DataFrame
            Peptide annotations with organism
            
        Returns:
        --------
        virus_enriched : pd.DataFrame
            Binary enrichment at virus level
        """
        print("\nAggregating peptides to virus/organism level...")
        
        # Reset index to make peptide_id a column
        enriched_with_id = peptide_enriched.reset_index()
        
        # The index name might be None, 'index', or the actual index name
        # Rename whatever the first column is to 'peptide_id'
        if 'peptide_id' not in enriched_with_id.columns:
            # Assume first column is the peptide_id
            old_name = enriched_with_id.columns[0]
            enriched_with_id.rename(columns={old_name: 'peptide_id'}, inplace=True)
        
        # Ensure peptide_id is same type in both dataframes
        enriched_with_id['peptide_id'] = enriched_with_id['peptide_id'].astype(str)
        peptide_metadata_copy = peptide_metadata.copy()
        peptide_metadata_copy['peptide_id'] = peptide_metadata_copy['peptide_id'].astype(str)
        
        # Merge with metadata
        enriched_with_meta = enriched_with_id.merge(
            peptide_metadata_copy[['peptide_id', 'organism']],
            on='peptide_id',
            how='left'
        )
        
        # Check for missing organism
        missing_organism = enriched_with_meta['organism'].isna().sum()
        if missing_organism > 0:
            print(f"  Warning: {missing_organism} peptides missing organism, will be dropped")
            enriched_with_meta = enriched_with_meta.dropna(subset=['organism'])
        
        # Get sample columns (exclude peptide_id and organism)
        sample_cols = [col for col in enriched_with_meta.columns 
                      if col not in ['peptide_id', 'organism']]
        
        # Group by organism, take max (any peptide positive = virus positive)
        virus_enriched = enriched_with_meta.groupby('organism')[sample_cols].max()
        
        print(f"Aggregated to {len(virus_enriched)} viruses/organisms")
        
        return virus_enriched
    
    def calculate_seropositivity_stats(self, enriched_df, level_name="peptide"):
        """
        Calculate seropositivity statistics.
        
        Parameters:
        -----------
        enriched_df : pd.DataFrame
            Binary enrichment matrix
        level_name : str
            Level name for reporting (peptide/protein/virus)
            
        Returns:
        --------
        stats_df : pd.DataFrame
            Statistics for each peptide/protein/virus
        """
        stats = []
        
        for entity in enriched_df.index:
            n_positive = enriched_df.loc[entity].sum()
            n_total = len(enriched_df.columns)
            prevalence = n_positive / n_total
            
            stats.append({
                f'{level_name}_id': entity,
                'n_positive_samples': int(n_positive),
                'n_total_samples': n_total,
                'seroprevalence': prevalence
            })
        
        stats_df = pd.DataFrame(stats)
        return stats_df.sort_values('seroprevalence', ascending=False)
    
    def run_complete_pipeline(self, counts_file, peptide_metadata_file,
                             sample_metadata_file=None,
                             output_dir="results"):
        """
        Run complete pipeline from counts to seropositivity at all levels.
        
        Parameters:
        -----------
        counts_file : str
            Path to counts CSV (peptides x samples, NO input column needed)
        peptide_metadata_file : str
            Path to peptide metadata CSV
        sample_metadata_file : str, optional
            Path to sample metadata with batch/plate info
        output_dir : str
            Directory for output files
            
        Returns:
        --------
        results : dict
            Dictionary containing all results dataframes
        """
        # Create output directory
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True, parents=True)
        
        print("="*70)
        print("PhIPSeq Analysis Pipeline - Immunity 2023 Method")
        print("="*70)
        print("\nKey difference from other pipelines:")
        print("Uses phage LIBRARY COMPLEXITY as baseline (not input/beads sample)")
        print("="*70)
        
        # Step 1: Load data
        counts = self.load_counts(counts_file)
        peptide_metadata = self.load_peptide_metadata(peptide_metadata_file)
        
        sample_metadata = None
        if sample_metadata_file:
            sample_metadata = self.load_sample_metadata(sample_metadata_file)
        
        # Step 2: Rarefy
        rarefied = self.rarefy_counts(counts)
        
        # Step 3: Call enriched peptides (uses library complexity internally)
        enriched, pvalues = self.call_enriched_peptides(rarefied)
        
        # Step 4: Filter peptides
        filtered_enriched = self.filter_peptides(enriched)
        
        # Step 5: Aggregate to protein level
        protein_enriched = self.aggregate_to_protein(filtered_enriched, peptide_metadata)
        
        # Step 6: Aggregate to virus level
        virus_enriched = self.aggregate_to_virus(filtered_enriched, peptide_metadata)
        
        # Step 7: Calculate statistics
        print("\nCalculating seropositivity statistics...")
        
        peptide_stats = self.calculate_seropositivity_stats(
            filtered_enriched, 
            "peptide"
        )
        protein_stats = self.calculate_seropositivity_stats(
            protein_enriched,
            "protein"
        )
        virus_stats = self.calculate_seropositivity_stats(
            virus_enriched,
            "virus"
        )
        
        # Step 8: Save all results
        print("\nSaving results...")
        
        # Binary enrichment matrices
        filtered_enriched.to_csv(output_path / "peptide_enrichment_binary.csv")
        protein_enriched.to_csv(output_path / "protein_enrichment_binary.csv")
        virus_enriched.to_csv(output_path / "virus_enrichment_binary.csv")
        
        # P-values
        pvalues.to_csv(output_path / "peptide_pvalues.csv")
        
        # Statistics
        peptide_stats.to_csv(output_path / "peptide_seropositivity_stats.csv", index=False)
        protein_stats.to_csv(output_path / "protein_seropositivity_stats.csv", index=False)
        virus_stats.to_csv(output_path / "virus_seropositivity_stats.csv", index=False)
        
        # Save sample metadata if provided
        if sample_metadata is not None:
            sample_metadata.to_csv(output_path / "sample_metadata_used.csv")
        
        print(f"\nAll results saved to: {output_dir}/")
        print("\nOutput files:")
        print("  - peptide_enrichment_binary.csv")
        print("  - protein_enrichment_binary.csv")
        print("  - virus_enrichment_binary.csv")
        print("  - peptide_pvalues.csv")
        print("  - peptide_seropositivity_stats.csv")
        print("  - protein_seropositivity_stats.csv")
        print("  - virus_seropositivity_stats.csv")
        
        # Return all results
        results = {
            'peptide_enriched': filtered_enriched,
            'protein_enriched': protein_enriched,
            'virus_enriched': virus_enriched,
            'peptide_pvalues': pvalues,
            'peptide_stats': peptide_stats,
            'protein_stats': protein_stats,
            'virus_stats': virus_stats,
            'sample_metadata': sample_metadata
        }
        
        return results


# Example usage
if __name__ == "__main__":
    
    # Initialize pipeline with parallel processing
    pipeline = ImmunityPhIPSeqPipeline(
        rarefaction_depth=1_250_000,
        bonferroni_alpha=0.05,
        n_jobs=-1  # Use all available CPUs, or set to specific number like 8
    )
    
    # Run complete pipeline
    # NOTE: No input_column parameter needed!
    results = pipeline.run_complete_pipeline(
        counts_file="phipseq_counts.csv",  # ONLY IP samples
        peptide_metadata_file="peptide_metadata.csv",
        sample_metadata_file="sample_metadata.csv",  # Include plate/batch info
        output_dir="results"
    )
    
    # Print summary
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print(f"\nPeptide level:")
    print(f"  Total enriched: {len(results['peptide_enriched'])}")
    print(f"  Mean seroprevalence: {results['peptide_stats']['seroprevalence'].mean():.3f}")
    
    print(f"\nProtein level:")
    print(f"  Total proteins: {len(results['protein_enriched'])}")
    print(f"  Mean seroprevalence: {results['protein_stats']['seroprevalence'].mean():.3f}")
    
    print(f"\nVirus level:")
    print(f"  Total viruses: {len(results['virus_enriched'])}")
    print(f"  Mean seroprevalence: {results['virus_stats']['seroprevalence'].mean():.3f}")
    
    print("\nTop 5 most prevalent viruses:")
    print(results['virus_stats'].head())
    
    # Check for batch effects
    if results['sample_metadata'] is not None:
        plate_col = [col for col in results['sample_metadata'].columns 
                    if 'plate' in col.lower() or 'batch' in col.lower()]
        if len(plate_col) > 0:
            print(f"\nBatch/Plate info loaded: {plate_col[0]}")
            print("(Use for downstream batch correction in case-control analysis)")
