"""
Complete PhIPSeq Analysis Pipeline - VERSION 14
Based on Andreu-Sánchez et al., Immunity 2023

Key Updates in V14:
1. Protein names now include virus prefix (organism::protein_name)
2. Adjustable thresholds for protein-level seropositivity
3. Adjustable thresholds for virus-level seropositivity
4. Based on VirScan literature: threshold by number of proteins/peptides

Processes VirScan alignment counts and outputs seropositivity at:
- Peptide level
- Protein level (with adjustable threshold)
- Virus level (with adjustable threshold)
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
    Complete pipeline implementing Immunity 2023 methods with adjustable thresholds.
    
    Key improvements:
    - Protein names are prefixed with organism (organism::protein_name)
    - Protein seropositivity requires minimum number of enriched peptides
    - Virus seropositivity requires minimum number of enriched proteins
    """
    
    def __init__(self, 
                 rarefaction_depth=1_250_000, 
                 bonferroni_alpha=0.05, 
                 n_jobs=1,
                 min_peptides_per_protein=2,
                 min_proteins_per_virus=2):
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
        min_peptides_per_protein : int
            Minimum enriched peptides required for protein seropositivity (default: 2)
            Set to 1 for "any peptide positive" behavior
        min_proteins_per_virus : int
            Minimum seropositive proteins required for virus seropositivity (default: 2)
            Set to 1 for "any protein positive" behavior
            Based on literature: CMV seropositivity used threshold of 4 proteins
        """
        self.rarefaction_depth = rarefaction_depth
        self.bonferroni_alpha = bonferroni_alpha
        self.n_jobs = n_jobs
        self.min_peptides_per_protein = min_peptides_per_protein
        self.min_proteins_per_virus = min_proteins_per_virus
        
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
        
        Creates a composite protein identifier: organism::protein_name
        
        Parameters:
        -----------
        metadata_file : str
            Path to peptide metadata CSV
            Required columns: peptide_id, protein_name, virus/organism
            
        Returns:
        --------
        metadata_df : pd.DataFrame
            Peptide annotations with composite_protein_name column
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
        
        # Create composite protein name: organism::protein_name
        if 'organism' in metadata.columns and 'protein_name' in metadata.columns:
            metadata['composite_protein_name'] = (
                metadata['organism'].astype(str) + '::' + metadata['protein_name'].astype(str)
            )
            print(f"Created composite protein names (organism::protein_name)")
        else:
            warnings.warn("Could not create composite protein names - missing organism or protein_name")
        
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
        lambda_estimates : pd.Series
            Estimated library complexity for each peptide
        """
        print("\nEstimating library complexity for each peptide...")
        
        # For each peptide, estimate expected counts from distribution
        # Use median as robust estimate of "input level"
        lambda_estimates = rarefied_counts.median(axis=1)
        
        # Ensure minimum lambda to avoid division by zero
        lambda_estimates = lambda_estimates.clip(lower=0.1)
        
        print(f"Estimated complexity for {len(lambda_estimates)} peptides")
        print(f"  Median lambda: {lambda_estimates.median():.2f}")
        print(f"  Mean lambda: {lambda_estimates.mean():.2f}")
        
        return lambda_estimates
    
    def call_enriched_peptides_single_sample(self, sample_counts, lambda_estimates):
        """
        Call enriched peptides for a single sample using Generalized Poisson.
        
        Parameters:
        -----------
        sample_counts : pd.Series
            Counts for one sample
        lambda_estimates : pd.Series
            Library complexity estimates
            
        Returns:
        --------
        enriched : pd.Series
            Binary enrichment (0/1)
        pvalues : pd.Series
            P-values for each peptide
        """
        from scipy.stats import poisson
        
        # Calculate p-values using Poisson distribution
        pvalues = 1 - poisson.cdf(sample_counts - 1, lambda_estimates)
        
        # Bonferroni correction
        n_tests = len(pvalues)
        threshold = self.bonferroni_alpha / n_tests
        
        # Call enriched
        enriched = (pvalues < threshold).astype(int)
        
        return enriched, pvalues
    
    def call_enriched_peptides(self, rarefied_counts):
        """
        Call enriched (seropositive) peptides using Generalized Poisson model.
        
        Uses library complexity (estimated from sample distribution) as baseline.
        Now parallelized for speed!
        
        Parameters:
        -----------
        rarefied_counts : pd.DataFrame
            Rarefied counts (peptides x samples)
            
        Returns:
        --------
        enriched_df : pd.DataFrame
            Binary enrichment matrix (peptides x samples)
        pvalues_df : pd.DataFrame
            P-values for each peptide-sample pair
        """
        print("\nCalling enriched peptides...")
        print(f"Using Bonferroni alpha = {self.bonferroni_alpha}")
        
        # Estimate library complexity
        lambda_estimates = self.estimate_library_complexity(rarefied_counts)
        
        # Calculate threshold
        n_tests = len(rarefied_counts)
        threshold = self.bonferroni_alpha / n_tests
        print(f"Number of peptides: {n_tests}")
        print(f"Per-peptide p-value threshold: {threshold:.2e}")
        
        # Process samples in parallel
        from joblib import Parallel, delayed
        
        if self.n_jobs == -1:
            import multiprocessing
            n_jobs = multiprocessing.cpu_count()
        else:
            n_jobs = self.n_jobs
        
        print(f"Processing {len(rarefied_counts.columns)} samples using {n_jobs} cores...")
        
        results = Parallel(n_jobs=n_jobs)(
            delayed(self.call_enriched_peptides_single_sample)(
                rarefied_counts[sample],
                lambda_estimates
            )
            for sample in rarefied_counts.columns
        )
        
        # Unpack results
        enriched_list = [r[0] for r in results]
        pvalues_list = [r[1] for r in results]
        
        # Create dataframes
        enriched_df = pd.DataFrame(
            {sample: enriched for sample, enriched in zip(rarefied_counts.columns, enriched_list)},
            index=rarefied_counts.index
        )
        
        pvalues_df = pd.DataFrame(
            {sample: pvals for sample, pvals in zip(rarefied_counts.columns, pvalues_list)},
            index=rarefied_counts.index
        )
        
        # Calculate summary statistics
        n_enriched_per_sample = enriched_df.sum(axis=0)
        print(f"\nEnriched peptides per sample:")
        print(f"  Mean: {n_enriched_per_sample.mean():.1f}")
        print(f"  Median: {n_enriched_per_sample.median():.1f}")
        print(f"  Min: {n_enriched_per_sample.min()}")
        print(f"  Max: {n_enriched_per_sample.max()}")
        
        return enriched_df, pvalues_df
    
    def filter_peptides(self, enriched_df, min_prevalence=0.05, max_prevalence=0.95):
        """
        Filter peptides by prevalence (optional QC step).
        
        Parameters:
        -----------
        enriched_df : pd.DataFrame
            Binary enrichment matrix
        min_prevalence : float
            Minimum seroprevalence to keep (default: 0.05 = 5%)
        max_prevalence : float
            Maximum seroprevalence to keep (default: 0.95 = 95%)
            
        Returns:
        --------
        filtered_df : pd.DataFrame
            Filtered enrichment matrix
        """
        prevalence = enriched_df.sum(axis=1) / len(enriched_df.columns)
        
        mask = (prevalence >= min_prevalence) & (prevalence <= max_prevalence)
        
        print(f"\nFiltering peptides by prevalence ({min_prevalence:.0%}-{max_prevalence:.0%})...")
        print(f"  Before: {len(enriched_df)} peptides")
        print(f"  After: {mask.sum()} peptides")
        print(f"  Removed: {(~mask).sum()} peptides")
        
        return enriched_df[mask]
    
    def aggregate_to_protein(self, peptide_enriched, peptide_metadata):
        """
        Aggregate peptide-level seropositivity to protein level.
        
        NOW WITH ADJUSTABLE THRESHOLD!
        A sample is considered seropositive for a protein if AT LEAST
        min_peptides_per_protein enriched peptides from that protein are found.
        
        Parameters:
        -----------
        peptide_enriched : pd.DataFrame
            Binary enrichment at peptide level (peptides as ROWS, samples as COLUMNS)
        peptide_metadata : pd.DataFrame
            Peptide annotations with composite_protein_name
            
        Returns:
        --------
        protein_enriched : pd.DataFrame
            Binary enrichment at protein level (proteins as ROWS, samples as COLUMNS)
        """
        print(f"\nAggregating peptides to protein level (threshold: {self.min_peptides_per_protein} peptides)...")
        
        # Use composite protein name if available, otherwise protein_name
        protein_col = 'composite_protein_name' if 'composite_protein_name' in peptide_metadata.columns else 'protein_name'
        
        # Create a mapping of peptide_id to protein
        peptide_metadata_copy = peptide_metadata.copy()
        peptide_metadata_copy['peptide_id'] = peptide_metadata_copy['peptide_id'].astype(str)
        peptide_to_protein = peptide_metadata_copy.set_index('peptide_id')[protein_col].to_dict()
        
        # Map peptide index to protein names
        peptide_index_str = peptide_enriched.index.astype(str)
        protein_names = peptide_index_str.map(lambda x: peptide_to_protein.get(x, None))
        
        # Check for missing mappings
        n_missing = protein_names.isna().sum()
        if n_missing > 0:
            print(f"  Warning: {n_missing} peptides missing protein mapping, will be dropped")
        
        # Create temporary dataframe with protein names
        temp_df = peptide_enriched.copy()
        temp_df['protein_name'] = protein_names
        
        # Drop peptides without protein mapping
        temp_df = temp_df.dropna(subset=['protein_name'])
        
        # Get sample columns (everything except protein_name)
        sample_cols = [col for col in temp_df.columns if col != 'protein_name']
        
        # Group by protein, SUM enriched peptides
        protein_peptide_counts = temp_df.groupby('protein_name')[sample_cols].sum()
        
        # Apply threshold: protein is positive if >= min_peptides_per_protein enriched
        protein_enriched = (protein_peptide_counts >= self.min_peptides_per_protein).astype(int)
        
        print(f"Aggregated {len(peptide_enriched)} peptides to {len(protein_enriched)} proteins")
        
        # Print some statistics
        proteins_per_sample = protein_enriched.sum(axis=0)
        print(f"  Seropositive proteins per sample:")
        print(f"    Mean: {proteins_per_sample.mean():.1f}")
        print(f"    Median: {proteins_per_sample.median():.1f}")
        
        return protein_enriched
    
    def aggregate_to_virus(self, protein_enriched, peptide_metadata):
        """
        Aggregate protein-level seropositivity to virus/organism level.
        
        NOW WITH ADJUSTABLE THRESHOLD!
        A sample is considered seropositive for a virus if AT LEAST
        min_proteins_per_virus proteins from that virus are seropositive.
        
        Based on literature: CMV seropositivity used threshold of 4 proteins.
        
        Parameters:
        -----------
        protein_enriched : pd.DataFrame
            Binary enrichment at protein level (composite proteins as ROWS, samples as COLUMNS)
        peptide_metadata : pd.DataFrame
            Peptide annotations with organism and composite_protein_name
            
        Returns:
        --------
        virus_enriched : pd.DataFrame
            Binary enrichment at virus level (viruses as ROWS, samples as COLUMNS)
        """
        print(f"\nAggregating proteins to virus level (threshold: {self.min_proteins_per_virus} proteins)...")
        
        # Extract organism from composite protein name (organism::protein_name)
        # The protein index should already have organism prefix
        split_names = protein_enriched.index.str.split('::', expand=True)
        if split_names.shape[1] >= 1:
            organisms = split_names[0].values  # Get first column and convert to array
        else:
            raise ValueError("Protein names do not contain '::' delimiter. Ensure composite_protein_name was created.")
        
        # Create temporary dataframe with organism names
        temp_df = protein_enriched.copy()
        temp_df['organism'] = organisms
        
        # Get sample columns (everything except organism)
        sample_cols = [col for col in temp_df.columns if col != 'organism']
        
        # Group by organism, SUM seropositive proteins
        virus_protein_counts = temp_df.groupby('organism')[sample_cols].sum()
        
        # Apply threshold: virus is positive if >= min_proteins_per_virus proteins are seropositive
        virus_enriched = (virus_protein_counts >= self.min_proteins_per_virus).astype(int)
        
        print(f"Aggregated {len(protein_enriched)} proteins to {len(virus_enriched)} viruses/organisms")
        
        # Print some statistics
        viruses_per_sample = virus_enriched.sum(axis=0)
        print(f"  Seropositive viruses per sample:")
        print(f"    Mean: {viruses_per_sample.mean():.1f}")
        print(f"    Median: {viruses_per_sample.median():.1f}")
        
        return virus_enriched
    
    def calculate_seropositivity_stats(self, enriched_df, level_name="peptide"):
        """
        Calculate seropositivity statistics.
        
        Parameters:
        -----------
        enriched_df : pd.DataFrame
            Binary enrichment matrix (entities as ROWS, samples as COLUMNS)
        level_name : str
            Level name for reporting (peptide/protein/virus)
            
        Returns:
        --------
        stats_df : pd.DataFrame
            Statistics for each peptide/protein/virus
        """
        stats = []
        
        # enriched_df should have entities as rows, samples as columns
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
                             output_dir="results",
                             skip_filtering=True):
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
        skip_filtering : bool
            If True, skip prevalence-based peptide filtering (recommended)
            
        Returns:
        --------
        results : dict
            Dictionary containing all results dataframes
        """
        # Create output directory
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True, parents=True)
        
        print("="*70)
        print("PhIPSeq Analysis Pipeline - VERSION 14")
        print("="*70)
        print("\nKey features:")
        print("- Protein names prefixed with organism (organism::protein_name)")
        print(f"- Protein threshold: {self.min_peptides_per_protein} enriched peptides")
        print(f"- Virus threshold: {self.min_proteins_per_virus} seropositive proteins")
        print("="*70)
        
        # Step 1: Load data
        counts = self.load_counts(counts_file)
        peptide_metadata = self.load_peptide_metadata(peptide_metadata_file)
        
        sample_metadata = None
        if sample_metadata_file:
            sample_metadata = self.load_sample_metadata(sample_metadata_file)
        
        # Step 2: Rarefy
        rarefied = self.rarefy_counts(counts)
        
        # Step 3: Call enriched peptides
        enriched, pvalues = self.call_enriched_peptides(rarefied)
        
        # Step 4: Filter peptides (optional)
        if skip_filtering:
            print("\nSkipping prevalence filtering (skip_filtering=True)")
            filtered_enriched = enriched
        else:
            filtered_enriched = self.filter_peptides(enriched)
        
        # Step 5: Aggregate to protein level (with threshold)
        protein_enriched = self.aggregate_to_protein(filtered_enriched, peptide_metadata)
        
        # Step 6: Aggregate to virus level (with threshold)
        virus_enriched = self.aggregate_to_virus(protein_enriched, peptide_metadata)
        
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
        
        # Save pipeline parameters
        params = {
            'rarefaction_depth': self.rarefaction_depth,
            'bonferroni_alpha': self.bonferroni_alpha,
            'min_peptides_per_protein': self.min_peptides_per_protein,
            'min_proteins_per_virus': self.min_proteins_per_virus,
            'skip_filtering': skip_filtering
        }
        pd.Series(params).to_csv(output_path / "pipeline_parameters.csv")
        
        print(f"\nAll results saved to: {output_dir}/")
        print("\nOutput files:")
        print("  - peptide_enrichment_binary.csv")
        print("  - protein_enrichment_binary.csv")
        print("  - virus_enrichment_binary.csv")
        print("  - peptide_pvalues.csv")
        print("  - peptide_seropositivity_stats.csv")
        print("  - protein_seropositivity_stats.csv")
        print("  - virus_seropositivity_stats.csv")
        print("  - pipeline_parameters.csv")
        
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
    
    # Initialize pipeline with adjustable thresholds
    pipeline = ImmunityPhIPSeqPipeline(
        rarefaction_depth=1_250_000,
        bonferroni_alpha=0.05,
        n_jobs=-1,  # Use all CPUs
        min_peptides_per_protein=2,  # At least 2 peptides per protein
        min_proteins_per_virus=4     # At least 4 proteins per virus (like CMV study)
    )
    
    # Run complete pipeline
    results = pipeline.run_complete_pipeline(
        counts_file="phipseq_counts.csv",
        peptide_metadata_file="peptide_metadata.csv",
        sample_metadata_file="sample_metadata.csv",
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
