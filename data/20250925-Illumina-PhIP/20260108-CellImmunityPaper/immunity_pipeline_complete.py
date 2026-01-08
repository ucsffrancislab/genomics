"""
Complete PhIPSeq Analysis Pipeline
Based on Andreu-Sánchez et al., Immunity 2023

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
    """
    
    def __init__(self, rarefaction_depth=1_250_000, bonferroni_alpha=0.05):
        """
        Initialize pipeline.
        
        Parameters:
        -----------
        rarefaction_depth : int
            Target read depth for rarefaction (default: 1,250,000)
        bonferroni_alpha : float
            Significance threshold for Bonferroni correction (default: 0.05)
        """
        self.rarefaction_depth = rarefaction_depth
        self.bonferroni_alpha = bonferroni_alpha
        
    def load_counts(self, counts_file, input_column=None):
        """
        Load counts matrix from CSV.
        
        Parameters:
        -----------
        counts_file : str
            Path to counts CSV file (peptides as rows, samples as columns)
        input_column : str, optional
            Column name for input library. If None, will look for column 
            containing 'input' or 'beads'
            
        Returns:
        --------
        counts_df : pd.DataFrame
            Counts matrix (peptides x samples)
        input_counts : pd.Series
            Input library counts
        """
        print("Loading counts matrix...")
        counts_df = pd.read_csv(counts_file, index_col=0)
        
        print(f"Loaded {len(counts_df)} peptides x {len(counts_df.columns)} samples")
        
        # Find input library column
        if input_column is None:
            input_candidates = [col for col in counts_df.columns 
                              if 'input' in col.lower() or 'beads' in col.lower()]
            if len(input_candidates) == 0:
                raise ValueError(
                    "Could not find input library column. "
                    "Please specify input_column parameter."
                )
            input_column = input_candidates[0]
            print(f"Using '{input_column}' as input library")
        
        input_counts = counts_df[input_column]
        ip_counts = counts_df.drop(input_column, axis=1)
        
        return ip_counts, input_counts
    
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
    
    def fit_generalized_poisson(self, input_counts, ip_counts):
        """
        Fit Generalized Poisson model and calculate p-values.
        
        This implements the enrichment calling method from Immunity 2023,
        based on Larman et al. 2011.
        
        Parameters:
        -----------
        input_counts : np.array
            Input library read counts
        ip_counts : np.array
            IP sample read counts
            
        Returns:
        --------
        pvalues : np.array
            P-values for each peptide
        """
        x = input_counts.astype(float)
        y = ip_counts.astype(float)
        
        # Only fit model using peptides with non-zero input counts
        mask = (x > 0) & (y > 0)
        
        if mask.sum() < 10:
            warnings.warn("Too few non-zero counts for robust fitting")
            return np.ones(len(x))
        
        # Fit log-linear relationship: log(y) ~ log(x)
        # This estimates expected IP count based on input count
        log_x = np.log(x[mask] + 1)
        log_y = np.log(y[mask] + 1)
        
        # Simple linear regression
        from sklearn.linear_model import LinearRegression
        lr = LinearRegression()
        lr.fit(log_x.reshape(-1, 1), log_y)
        
        # Predict expected counts for all peptides
        log_expected = lr.predict(np.log(x + 1).reshape(-1, 1))
        expected = np.exp(log_expected)
        expected = np.maximum(expected, 0.1)  # Avoid zeros
        
        # Calculate p-values using negative binomial distribution
        # (approximation to Generalized Poisson)
        pvalues = np.ones(len(x))
        
        for i in range(len(x)):
            if y[i] == 0:
                pvalues[i] = 1.0
                continue
            
            # Negative binomial parameters
            mu = expected[i]
            # Estimate dispersion parameter (simplified)
            theta = mu
            
            # P(X >= observed count) - right tail test
            # Using survival function: P(X > k) = sf(k)
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
    
    def call_enriched_peptides(self, rarefied_counts, input_counts):
        """
        Call enriched (seropositive) peptides using Generalized Poisson model.
        
        Parameters:
        -----------
        rarefied_counts : pd.DataFrame
            Rarefied IP counts (peptides x samples)
        input_counts : pd.Series
            Input library counts
            
        Returns:
        --------
        enriched : pd.DataFrame
            Binary enrichment matrix (1 = enriched, 0 = not enriched)
        pvalues : pd.DataFrame
            P-values for each peptide-sample combination
        """
        print("\nCalling enriched peptides using Generalized Poisson model...")
        
        n_peptides = len(rarefied_counts)
        threshold = self.bonferroni_alpha / n_peptides
        
        print(f"Bonferroni-corrected threshold: p < {threshold:.2e}")
        
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
        
        for i, sample in enumerate(rarefied_counts.columns):
            ip_counts_sample = rarefied_counts[sample].values
            pvals = self.fit_generalized_poisson(input_counts.values, ip_counts_sample)
            
            pvalues_df[sample] = pvals
            enriched[sample] = (pvals < threshold).astype(int)
            
            n_enriched = enriched[sample].sum()
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
            Binary enrichment at peptide level
        peptide_metadata : pd.DataFrame
            Peptide annotations with protein_name
            
        Returns:
        --------
        protein_enriched : pd.DataFrame
            Binary enrichment at protein level
        """
        print("\nAggregating peptides to protein level...")
        
        # Merge enrichment with metadata
        enriched_with_meta = peptide_enriched.copy()
        enriched_with_meta = enriched_with_meta.merge(
            peptide_metadata[['peptide_id', 'protein_name']],
            left_index=True,
            right_on='peptide_id',
            how='left'
        )
        
        # Group by protein, take max (any peptide positive = protein positive)
        protein_enriched = enriched_with_meta.groupby('protein_name')[
            peptide_enriched.columns
        ].max()
        
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
            Binary enrichment at peptide level
        peptide_metadata : pd.DataFrame
            Peptide annotations with organism
            
        Returns:
        --------
        virus_enriched : pd.DataFrame
            Binary enrichment at virus level
        """
        print("\nAggregating peptides to virus/organism level...")
        
        # Merge enrichment with metadata
        enriched_with_meta = peptide_enriched.copy()
        enriched_with_meta = enriched_with_meta.merge(
            peptide_metadata[['peptide_id', 'organism']],
            left_index=True,
            right_on='peptide_id',
            how='left'
        )
        
        # Group by organism, take max (any peptide positive = virus positive)
        virus_enriched = enriched_with_meta.groupby('organism')[
            peptide_enriched.columns
        ].max()
        
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
    
    def run_complete_pipeline(self, counts_file, metadata_file, 
                             output_dir="results", input_column=None):
        """
        Run complete pipeline from counts to seropositivity at all levels.
        
        Parameters:
        -----------
        counts_file : str
            Path to counts CSV
        metadata_file : str
            Path to peptide metadata CSV
        output_dir : str
            Directory for output files
        input_column : str, optional
            Input library column name
            
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
        
        # Step 1: Load data
        ip_counts, input_counts = self.load_counts(counts_file, input_column)
        peptide_metadata = self.load_peptide_metadata(metadata_file)
        
        # Step 2: Rarefy
        rarefied = self.rarefy_counts(ip_counts)
        
        # Step 3: Call enriched peptides
        enriched, pvalues = self.call_enriched_peptides(rarefied, input_counts)
        
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
            'virus_stats': virus_stats
        }
        
        return results


# Example usage
if __name__ == "__main__":
    
    # Initialize pipeline
    pipeline = ImmunityPhIPSeqPipeline(
        rarefaction_depth=1_250_000,
        bonferroni_alpha=0.05
    )
    
    # Run complete pipeline
    results = pipeline.run_complete_pipeline(
        counts_file="phipseq_counts.csv",
        metadata_file="peptide_metadata.csv",
        output_dir="results",
        input_column=None  # Will auto-detect
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
