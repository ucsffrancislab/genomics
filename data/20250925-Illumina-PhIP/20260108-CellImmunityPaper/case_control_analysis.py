"""
Case-Control Analysis for PhIPSeq Data
Performs statistical testing at peptide, protein, and virus levels
"""

import pandas as pd
import numpy as np
from scipy.stats import fisher_exact, chi2_contingency
from statsmodels.stats.multitest import multipletests
import matplotlib.pyplot as plt
import seaborn as sns


class CaseControlAnalyzer:
    """
    Case-control analysis for PhIPSeq seropositivity data.
    """
    
    def __init__(self, n_jobs=1):
        """
        Initialize analyzer.
        
        Parameters:
        -----------
        n_jobs : int
            Number of parallel jobs (default: 1)
            Set to -1 to use all CPU cores
        """
        self.n_jobs = n_jobs
    
    def load_sample_metadata(self, metadata_file):
        """
        Load sample metadata with case/control labels.
        
        Parameters:
        -----------
        metadata_file : str
            Path to sample metadata CSV
            Expected columns: sample_id, status (or similar)
            
        Returns:
        --------
        metadata : pd.DataFrame
            Sample metadata
        """
        metadata = pd.read_csv(metadata_file, index_col=0)
        return metadata
    
    def _test_single_entity_worker(self, args):
        """
        Worker function for parallel testing of a single entity.
        
        Parameters:
        -----------
        args : tuple
            (entity_id, entity_data, cases, controls, has_batch, batch_data, skip_failed_batch)
            
        Returns:
        --------
        result : dict
            Test results for this entity
        """
        entity, entity_data, cases, controls, has_batch, batch_data, skip_failed_batch = args
        
        # Create 2x2 contingency table
        case_pos = entity_data[cases].sum()
        case_neg = len(cases) - case_pos
        control_pos = entity_data[controls].sum()
        control_neg = len(controls) - control_pos
        
        table = [[case_pos, case_neg], [control_pos, control_neg]]
        
        # Fisher's exact test
        odds_ratio, fisher_p = fisher_exact(table, alternative='two-sided')
        
        # Chi-square test (if sufficient counts)
        if all(x >= 5 for row in table for x in row):
            chi2_stat, chi2_p, _, _ = chi2_contingency(table)
        else:
            chi2_stat, chi2_p = np.nan, np.nan
        
        # Calculate prevalences
        case_prev = case_pos / len(cases) if len(cases) > 0 else 0
        control_prev = control_pos / len(controls) if len(controls) > 0 else 0
        
        # Risk ratio
        risk_ratio = case_prev / (control_prev + 1e-10)
        
        # Batch-adjusted analysis using logistic regression
        batch_adjusted_or = np.nan
        batch_adjusted_p = np.nan
        batch_failed = False
        
        if has_batch:
            try:
                import statsmodels.api as sm
                from pandas import get_dummies
                
                # Prepare data for logistic regression
                all_samples, y, X_peptide, batch_labels = batch_data
                
                # This entity's data
                X_peptide_entity = entity_data[all_samples].values
                
                # Create dummy variables for batches
                batch_dummies = get_dummies(batch_labels, drop_first=True)
                
                # Combine peptide status with batch dummies
                X = pd.DataFrame({'peptide': X_peptide_entity})
                X = pd.concat([X, batch_dummies], axis=1)
                X = sm.add_constant(X)
                
                # Fit logistic regression
                model = sm.Logit(y, X).fit(disp=0, maxiter=100)
                
                # Extract peptide coefficient
                batch_adjusted_or = np.exp(model.params['peptide'])
                batch_adjusted_p = model.pvalues['peptide']
                
            except Exception as e:
                # If regression fails, use Fisher's p-value as fallback
                batch_failed = True
                if skip_failed_batch:
                    batch_adjusted_or = odds_ratio
                    batch_adjusted_p = fisher_p
                else:
                    batch_adjusted_or = np.nan
                    batch_adjusted_p = np.nan
        
        return {
            'entity_id': entity,
            'case_positive': int(case_pos),
            'case_total': len(cases),
            'control_positive': int(control_pos),
            'control_total': len(controls),
            'case_prevalence': case_prev,
            'control_prevalence': control_prev,
            'prevalence_diff': case_prev - control_prev,
            'odds_ratio': odds_ratio,
            'risk_ratio': risk_ratio,
            'fisher_pvalue': fisher_p,
            'chi2_pvalue': chi2_p,
            'batch_adjusted_OR': batch_adjusted_or,
            'batch_adjusted_pvalue': batch_adjusted_p,
            'batch_failed': batch_failed
        }
    
    def load_sample_metadata(self, metadata_file):
        """
        Load sample metadata with case/control labels.
        
        Parameters:
        -----------
        metadata_file : str
            Path to sample metadata CSV
            Expected columns: sample_id, status (or similar)
            
        Returns:
        --------
        metadata : pd.DataFrame
            Sample metadata
        """
        metadata = pd.read_csv(metadata_file, index_col=0)
        return metadata
    
    def test_single_entity(self, enriched_matrix, metadata, 
                          case_col='status',
                          case_value='case', 
                          control_value='control',
                          adjust_for_batch=True,
                          batch_col='plate',
                          skip_failed_batch=True):
        """
        Test each peptide/protein/virus for case-control enrichment.
        
        Implements batch correction per Immunity 2023: "adjusted for age, 
        sex and sequencing plate"
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix (entities x samples)
        metadata : pd.DataFrame
            Sample metadata with case/control labels
        case_col : str
            Column name for case/control status
        case_value : str
            Value indicating cases
        control_value : str
            Value indicating controls
        adjust_for_batch : bool
            Whether to adjust for batch effects using logistic regression
        batch_col : str
            Column name for batch/plate
        skip_failed_batch : bool
            If True, use Fisher's p-value when batch adjustment fails (recommended)
            If False, keep NaN for failed batch adjustments
            
        Returns:
        --------
        results_df : pd.DataFrame
            Statistical test results for each entity
        """
        # Get case and control sample IDs
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Filter to samples present in enrichment matrix
        cases = [s for s in cases if s in enriched_matrix.columns]
        controls = [s for s in controls if s in enriched_matrix.columns]
        
        # Check for batch column
        has_batch = batch_col in metadata.columns if adjust_for_batch else False
        
        print(f"\nTesting {len(enriched_matrix)} entities")
        print(f"Cases: {len(cases)}, Controls: {len(controls)}")
        if has_batch:
            print(f"Adjusting for batch effects using column: {batch_col}")
            n_batches = metadata[batch_col].nunique()
            print(f"Number of batches: {n_batches}")
            
            # Warn if sample size is small relative to batches
            if len(cases) + len(controls) < n_batches * 5:
                print(f"WARNING: Small sample size ({len(cases) + len(controls)}) relative to batches ({n_batches})")
                print(f"         Logistic regression may fail frequently.")
                print(f"         Will use Fisher's exact test as fallback when this happens.")
        
        # Determine number of jobs
        if self.n_jobs == -1:
            import multiprocessing
            n_jobs = multiprocessing.cpu_count()
        else:
            n_jobs = self.n_jobs
        
        if n_jobs > 1:
            print(f"Using {n_jobs} parallel workers...")
        
        # Prepare batch data for all entities
        batch_data = None
        if has_batch:
            all_samples = list(cases) + list(controls)
            y = np.array([1] * len(cases) + [0] * len(controls))
            batch_labels = metadata.loc[all_samples, batch_col].values
            batch_data = (all_samples, y, None, batch_labels)
        
        # Prepare arguments for parallel processing
        args_list = [
            (
                entity,
                enriched_matrix.loc[entity],
                cases,
                controls,
                has_batch,
                batch_data,
                skip_failed_batch
            )
            for entity in enriched_matrix.index
        ]
        
        # Process in parallel
        if n_jobs > 1:
            from joblib import Parallel, delayed
            results = Parallel(n_jobs=n_jobs)(
                delayed(self._test_single_entity_worker)(args)
                for args in args_list
            )
        else:
            # Sequential processing
            results = [self._test_single_entity_worker(args) for args in args_list]
        
        # Count batch failures
        failed_batch_count = sum(1 for r in results if r.get('batch_failed', False))
        
        # Remove batch_failed flag (not needed in output)
        for r in results:
            r.pop('batch_failed', None)
        
        results_df = pd.DataFrame(results)
        
        # Report on batch adjustment failures
        if has_batch and failed_batch_count > 0:
            print(f"\nBatch adjustment failed for {failed_batch_count}/{len(enriched_matrix)} entities")
            if skip_failed_batch:
                print(f"  → Used Fisher's exact test as fallback for these entities")
            else:
                print(f"  → These entities have NaN batch-adjusted p-values")
        
        # FDR correction for Fisher's test
        _, fisher_qvals, _, _ = multipletests(
            results_df['fisher_pvalue'],
            method='fdr_bh'
        )
        results_df['fisher_qvalue'] = fisher_qvals
        
        # FDR correction for batch-adjusted test (if available)
        if has_batch and not results_df['batch_adjusted_pvalue'].isna().all():
            _, batch_qvals, _, _ = multipletests(
                results_df['batch_adjusted_pvalue'].fillna(1.0),
                method='fdr_bh'
            )
            results_df['batch_adjusted_qvalue'] = batch_qvals
        
        # Bonferroni correction
        _, fisher_bonf, _, _ = multipletests(
            results_df['fisher_pvalue'],
            method='bonferroni'
        )
        results_df['fisher_bonferroni'] = fisher_bonf
        
        # Sort by p-value (use batch-adjusted if available, else Fisher)
        if has_batch and not results_df['batch_adjusted_pvalue'].isna().all():
            results_df = results_df.sort_values('batch_adjusted_pvalue')
        else:
            results_df = results_df.sort_values('fisher_pvalue')
        
        return results_df
    
    def apply_fdr_correction(self, results_df, fdr_threshold=0.05):
        """
        Apply FDR correction to p-values.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Results from test_single_entity
        fdr_threshold : float
            FDR threshold for significance (default: 0.05)
            Common values: 0.05 (standard), 0.01 (stringent), 0.10 (exploratory)
            
        Returns:
        --------
        results_df : pd.DataFrame
            Results with FDR column added
        """
        from statsmodels.stats.multitest import multipletests
        
        # Determine which p-value column to use
        if 'batch_adjusted_pvalue' in results_df.columns:
            pval_col = 'batch_adjusted_pvalue'
        elif 'pvalue' in results_df.columns:
            pval_col = 'pvalue'
        elif 'fisher_pvalue' in results_df.columns:
            pval_col = 'fisher_pvalue'
        else:
            raise ValueError("No p-value column found in results")
        
        print(f"Applying FDR correction to {pval_col} with threshold {fdr_threshold}...")
        
        # Apply Benjamini-Hochberg FDR correction
        reject, pvals_corrected, alphacSidak, alphacBonf = multipletests(
            results_df[pval_col], 
            alpha=fdr_threshold, 
            method='fdr_bh'
        )
        
        results_df['fdr'] = pvals_corrected
        results_df['significant_fdr'] = reject
        
        print(f"  Significant at FDR < {fdr_threshold}: {reject.sum()}")
        
        return results_df
    
    def analyze_all_levels(self, peptide_enriched, protein_enriched, 
                          virus_enriched, metadata,
                          case_col='status',
                          case_value='case',
                          control_value='control',
                          adjust_for_batch=True,
                          batch_col='plate',
                          output_dir='results'):
        """
        Run case-control analysis at all levels with batch correction.
        
        Parameters:
        -----------
        peptide_enriched : pd.DataFrame
            Peptide-level enrichment
        protein_enriched : pd.DataFrame
            Protein-level enrichment
        virus_enriched : pd.DataFrame
            Virus-level enrichment
        metadata : pd.DataFrame
            Sample metadata (must include batch/plate info if adjust_for_batch=True)
        adjust_for_batch : bool
            Whether to adjust for batch effects (recommended)
        batch_col : str
            Column name for batch/plate info
        output_dir : str
            Output directory
            
        Returns:
        --------
        all_results : dict
            Results at all levels
        """
        print("="*70)
        print("Case-Control Analysis (Immunity 2023 Method)")
        print("="*70)
        
        if adjust_for_batch:
            if batch_col not in metadata.columns:
                print(f"\nWarning: Batch column '{batch_col}' not found in metadata")
                print("Proceeding without batch correction")
                adjust_for_batch = False
        
        results = {}
        
        # Peptide level
        print("\n1. Peptide-level analysis...")
        peptide_results = self.test_single_entity(
            peptide_enriched, metadata,
            case_col, case_value, control_value,
            adjust_for_batch, batch_col
        )
        results['peptide'] = peptide_results
        
        # Use batch-adjusted if available
        if 'batch_adjusted_qvalue' in peptide_results.columns:
            n_sig_peptides = (peptide_results['batch_adjusted_qvalue'] < 0.05).sum()
            print(f"   Significant peptides (batch-adjusted q < 0.05): {n_sig_peptides}")
        else:
            n_sig_peptides = (peptide_results['fisher_qvalue'] < 0.05).sum()
            print(f"   Significant peptides (q < 0.05): {n_sig_peptides}")
        
        # Protein level
        print("\n2. Protein-level analysis...")
        protein_results = self.test_single_entity(
            protein_enriched, metadata,
            case_col, case_value, control_value,
            adjust_for_batch, batch_col
        )
        results['protein'] = protein_results
        
        if 'batch_adjusted_qvalue' in protein_results.columns:
            n_sig_proteins = (protein_results['batch_adjusted_qvalue'] < 0.05).sum()
            print(f"   Significant proteins (batch-adjusted q < 0.05): {n_sig_proteins}")
        else:
            n_sig_proteins = (protein_results['fisher_qvalue'] < 0.05).sum()
            print(f"   Significant proteins (q < 0.05): {n_sig_proteins}")
        
        # Virus level
        print("\n3. Virus-level analysis...")
        virus_results = self.test_single_entity(
            virus_enriched, metadata,
            case_col, case_value, control_value,
            adjust_for_batch, batch_col
        )
        results['virus'] = virus_results
        
        if 'batch_adjusted_qvalue' in virus_results.columns:
            n_sig_viruses = (virus_results['batch_adjusted_qvalue'] < 0.05).sum()
            print(f"   Significant viruses (batch-adjusted q < 0.05): {n_sig_viruses}")
        else:
            n_sig_viruses = (virus_results['fisher_qvalue'] < 0.05).sum()
            print(f"   Significant viruses (q < 0.05): {n_sig_viruses}")
        
        # Save results
        from pathlib import Path
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True, parents=True)
        
        peptide_results.to_csv(output_path / "case_control_peptide.csv", index=False)
        protein_results.to_csv(output_path / "case_control_protein.csv", index=False)
        virus_results.to_csv(output_path / "case_control_virus.csv", index=False)
        
        print(f"\nResults saved to {output_dir}/")
        
        return results
    
    def create_volcano_plot(self, results_df, level_name="peptide",
                           qvalue_threshold=0.05, output_file=None):
        """
        Create volcano plot of case-control results.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Case-control results
        level_name : str
            Level name for title
        qvalue_threshold : float
            Significance threshold for coloring
        output_file : str, optional
            Path to save plot
        """
        fig, ax = plt.subplots(figsize=(10, 8))
        
        # Calculate -log10(p) and log2(OR)
        results_df['-log10_p'] = -np.log10(results_df['fisher_pvalue'] + 1e-300)
        results_df['log2_OR'] = np.log2(results_df['odds_ratio'] + 1e-10)
        
        # Color by significance
        colors = np.where(
            results_df['fisher_qvalue'] < qvalue_threshold,
            'red',
            'gray'
        )
        
        # Plot
        scatter = ax.scatter(
            results_df['log2_OR'],
            results_df['-log10_p'],
            c=colors,
            alpha=0.6,
            s=30,
            edgecolors='black',
            linewidths=0.5
        )
        
        # Add significance lines
        ax.axhline(-np.log10(0.05), color='black', linestyle='--', 
                  alpha=0.3, label='p = 0.05')
        ax.axvline(0, color='black', linestyle='-', alpha=0.3)
        
        # Labels
        ax.set_xlabel('Log2(Odds Ratio)', fontsize=14, fontweight='bold')
        ax.set_ylabel('-Log10(P-value)', fontsize=14, fontweight='bold')
        ax.set_title(f'Case vs Control: {level_name.capitalize()} Level',
                    fontsize=16, fontweight='bold')
        
        # Add counts
        n_sig = (results_df['fisher_qvalue'] < qvalue_threshold).sum()
        ax.text(0.02, 0.98, f'Significant: {n_sig}',
               transform=ax.transAxes,
               fontsize=12,
               verticalalignment='top',
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        plt.tight_layout()
        
        if output_file:
            plt.savefig(output_file, dpi=300, bbox_inches='tight')
            print(f"Saved volcano plot: {output_file}")
        
        return fig
    
    def create_heatmap(self, enriched_matrix, metadata, results_df,
                      top_n=50, case_col='status',
                      case_value='case', control_value='control',
                      output_file=None):
        """
        Create heatmap of top discriminating entities.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        metadata : pd.DataFrame
            Sample metadata
        results_df : pd.DataFrame
            Case-control results
        top_n : int
            Number of top entities to plot
        output_file : str, optional
            Path to save plot
        """
        # Get top entities
        top_entities = results_df.nsmallest(top_n, 'fisher_pvalue')['entity_id']
        plot_data = enriched_matrix.loc[top_entities]
        
        # Sort samples by case/control
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Filter to available samples
        cases = [s for s in cases if s in plot_data.columns]
        controls = [s for s in controls if s in plot_data.columns]
        
        sample_order = list(cases) + list(controls)
        plot_data = plot_data[sample_order]
        
        # Create annotation colors
        col_colors = [
            'red' if s in cases else 'blue'
            for s in sample_order
        ]
        
        # Create clustermap
        g = sns.clustermap(
            plot_data,
            cmap='RdBu_r',
            col_cluster=False,
            row_cluster=True,
            col_colors=col_colors,
            figsize=(14, 10),
            cbar_kws={'label': 'Seropositive'},
            yticklabels=True,
            xticklabels=False
        )
        
        g.fig.suptitle(f'Top {top_n} Discriminating Entities', 
                      y=1.01, fontsize=16, fontweight='bold')
        
        # Add legend
        from matplotlib.patches import Patch
        legend_elements = [
            Patch(facecolor='red', label='Case'),
            Patch(facecolor='blue', label='Control')
        ]
        g.ax_heatmap.legend(
            handles=legend_elements,
            loc='upper left',
            bbox_to_anchor=(1.15, 1),
            frameon=True
        )
        
        plt.tight_layout()
        
        if output_file:
            plt.savefig(output_file, dpi=300, bbox_inches='tight')
            print(f"Saved heatmap: {output_file}")
        
        return g
    
    def create_enrichment_distribution(self, enriched_matrix, metadata,
                                       case_col='status', case_value='case',
                                       control_value='control',
                                       output_file='enrichment_distribution.png'):
        """
        Create distribution plot showing number of enriched peptides per subject.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        metadata : pd.DataFrame
            Sample metadata
        case_col : str
            Column for case/control status
        case_value, control_value : str
            Values for cases and controls
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        import seaborn as sns
        
        # Get case and control samples
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Convert to strings to match enriched_matrix columns
        cases = [str(s) for s in cases if str(s) in enriched_matrix.columns]
        controls = [str(s) for s in controls if str(s) in enriched_matrix.columns]
        
        # Calculate number of enriched peptides per sample
        case_counts = enriched_matrix[cases].sum(axis=0)
        control_counts = enriched_matrix[controls].sum(axis=0)
        
        # Create figure
        fig, ax = plt.subplots(figsize=(10, 6))
        
        # Plot histograms
        bins = np.linspace(0, max(case_counts.max(), control_counts.max()), 30)
        
        ax.hist(control_counts, bins=bins, alpha=0.5, label='Controls', color='blue', edgecolor='black')
        ax.hist(case_counts, bins=bins, alpha=0.5, label='Cases', color='red', edgecolor='black')
        
        # Add mean lines
        ax.axvline(control_counts.mean(), color='blue', linestyle='--', linewidth=2, 
                   label=f'Control mean: {control_counts.mean():.1f}')
        ax.axvline(case_counts.mean(), color='red', linestyle='--', linewidth=2,
                   label=f'Case mean: {case_counts.mean():.1f}')
        
        ax.set_xlabel('Number of Enriched Peptides', fontsize=12)
        ax.set_ylabel('Number of Subjects', fontsize=12)
        ax.set_title('Distribution of Enriched Peptides per Subject', fontsize=14, fontweight='bold')
        ax.legend()
        ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved enrichment distribution plot to {output_file}")
        
        return fig
    
    def create_roc_curve(self, results_df, enriched_matrix, metadata,
                        case_col='status', case_value='case', control_value='control',
                        top_n=10, output_file='roc_curve.png'):
        """
        Create ROC curves for top discriminatory peptides.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Results with p-values
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        metadata : pd.DataFrame
            Sample metadata
        top_n : int
            Number of top peptides to plot
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        from sklearn.metrics import roc_curve, auc
        
        # Get case/control labels
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Convert to strings to match enriched_matrix columns
        cases = [str(s) for s in cases]
        controls = [str(s) for s in controls]
        
        # Filter to samples in enriched_matrix
        cases = [s for s in cases if s in enriched_matrix.columns]
        controls = [s for s in controls if s in enriched_matrix.columns]
        
        all_samples = list(cases) + list(controls)
        y_true = np.array([1] * len(cases) + [0] * len(controls))
        
        # Get top N peptides
        top_peptides = results_df.nsmallest(top_n, 'fisher_pvalue')['entity_id'].values
        
        # Create figure
        fig, ax = plt.subplots(figsize=(10, 8))
        
        colors = plt.cm.tab10(np.linspace(0, 1, top_n))
        
        for i, peptide in enumerate(top_peptides):
            if peptide in enriched_matrix.index:
                y_score = enriched_matrix.loc[peptide, all_samples].values
                fpr, tpr, _ = roc_curve(y_true, y_score)
                roc_auc = auc(fpr, tpr)
                
                ax.plot(fpr, tpr, color=colors[i], lw=2, 
                       label=f'{peptide} (AUC = {roc_auc:.3f})')
        
        # Diagonal line
        ax.plot([0, 1], [0, 1], 'k--', lw=2, label='Random (AUC = 0.500)')
        
        ax.set_xlabel('False Positive Rate', fontsize=12)
        ax.set_ylabel('True Positive Rate', fontsize=12)
        ax.set_title(f'ROC Curves - Top {top_n} Discriminatory Peptides', fontsize=14, fontweight='bold')
        ax.legend(loc='lower right', fontsize=9)
        ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved ROC curve plot to {output_file}")
        
        return fig
    
    def create_venn_diagram(self, enriched_matrix, metadata,
                           case_col='status', case_value='case', control_value='control',
                           output_file='venn_diagram.png'):
        """
        Create Venn diagram showing peptide overlap between cases and controls.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        metadata : pd.DataFrame
            Sample metadata
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        from matplotlib_venn import venn2
        
        # Get case and control samples
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Convert to strings to match enriched_matrix columns
        cases = [str(s) for s in cases if str(s) in enriched_matrix.columns]
        controls = [str(s) for s in controls if str(s) in enriched_matrix.columns]
        
        # Get peptides enriched in at least one sample per group
        case_peptides = set(enriched_matrix.index[enriched_matrix[cases].sum(axis=1) > 0])
        control_peptides = set(enriched_matrix.index[enriched_matrix[controls].sum(axis=1) > 0])
        
        # Create figure
        fig, ax = plt.subplots(figsize=(10, 8))
        
        venn = venn2([case_peptides, control_peptides], 
                     set_labels=(f'Cases\n(n={len(cases)})', f'Controls\n(n={len(controls)})'),
                     set_colors=('red', 'blue'),
                     alpha=0.5,
                     ax=ax)
        
        # Add title
        ax.set_title('Peptide Enrichment Overlap', fontsize=14, fontweight='bold')
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved Venn diagram to {output_file}")
        
        return fig
    
    def create_effect_size_plot(self, results_df, top_n=30, 
                                output_file='effect_sizes.png'):
        """
        Create forest plot showing odds ratios with confidence intervals.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Results with odds ratios
        top_n : int
            Number of top peptides to plot
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        
        # Get top N significant peptides
        top = results_df.nsmallest(top_n, 'fisher_pvalue').copy()
        
        # Check if we have any peptides to plot
        if len(top) == 0:
            print(f"Warning: No peptides available for effect size plot. Skipping.")
            return None
        
        # Calculate 95% CI for odds ratio (approximate)
        # Using log scale: log(OR) ± 1.96 * SE
        # SE ≈ sqrt(1/a + 1/b + 1/c + 1/d) for 2x2 table
        
        # Handle infinite and zero odds ratios
        top['odds_ratio_clean'] = top['odds_ratio'].replace([np.inf, -np.inf], np.nan)
        top['odds_ratio_clean'] = top['odds_ratio_clean'].fillna(top['odds_ratio_clean'].max() * 10)
        top['log_or'] = np.log(top['odds_ratio_clean'].clip(lower=0.01))
        
        # Approximate SE from contingency table
        top['se'] = np.sqrt(
            1/top['case_positive'].clip(lower=1) + 
            1/(top['case_total'] - top['case_positive']).clip(lower=1) +
            1/top['control_positive'].clip(lower=1) +
            1/(top['control_total'] - top['control_positive']).clip(lower=1)
        )
        
        # Calculate confidence intervals
        top['ci_lower'] = np.exp(top['log_or'] - 1.96 * top['se'])
        top['ci_upper'] = np.exp(top['log_or'] + 1.96 * top['se'])
        
        # Ensure lower CI is not negative and error bars are valid
        top['ci_lower'] = top['ci_lower'].clip(lower=0.01)
        top['error_lower'] = (top['odds_ratio_clean'] - top['ci_lower']).clip(lower=0)
        top['error_upper'] = (top['ci_upper'] - top['odds_ratio_clean']).clip(lower=0)
        
        # Remove any rows with invalid data
        top = top.dropna(subset=['odds_ratio_clean', 'error_lower', 'error_upper'])
        
        if len(top) == 0:
            print(f"Warning: No valid peptides for effect size plot after filtering. Skipping.")
            return None
        
        # Create figure
        fig, ax = plt.subplots(figsize=(10, max(8, len(top) * 0.3)))
        
        # Plot
        y_pos = np.arange(len(top))
        
        # Error bars
        ax.errorbar(top['odds_ratio_clean'], y_pos, 
                   xerr=[top['error_lower'], top['error_upper']],
                   fmt='o', markersize=6, capsize=4, color='darkblue')
        
        # Reference line at OR=1
        ax.axvline(1, color='red', linestyle='--', linewidth=2, alpha=0.7, label='OR = 1 (no effect)')
        
        # Labels
        ax.set_yticks(y_pos)
        ax.set_yticklabels(top['entity_id'], fontsize=9)
        ax.set_xlabel('Odds Ratio (95% CI)', fontsize=12)
        ax.set_ylabel('Peptide ID', fontsize=12)
        ax.set_title(f'Effect Sizes - Top {len(top)} Peptides', fontsize=14, fontweight='bold')
        ax.set_xscale('log')
        ax.grid(True, alpha=0.3, axis='x')
        ax.legend()
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved effect size plot to {output_file}")
        
        return fig
    
    def create_cumulative_prevalence(self, enriched_matrix, metadata, results_df,
                                    case_col='status', case_value='case', control_value='control',
                                    output_file='cumulative_prevalence.png'):
        """
        Create cumulative prevalence plot showing coverage by top peptides.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        metadata : pd.DataFrame
            Sample metadata
        results_df : pd.DataFrame
            Results sorted by significance
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        
        # Get case and control samples
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Convert to strings to match enriched_matrix columns
        cases = [str(s) for s in cases if str(s) in enriched_matrix.columns]
        controls = [str(s) for s in controls if str(s) in enriched_matrix.columns]
        
        # Sort peptides by significance
        sorted_peptides = results_df.sort_values('fisher_pvalue')['entity_id'].values
        
        # Calculate cumulative positive subjects
        case_cumulative = []
        control_cumulative = []
        
        case_positive_set = set()
        control_positive_set = set()
        
        for peptide in sorted_peptides:
            if peptide in enriched_matrix.index:
                # Add subjects positive for this peptide
                case_pos = set([s for s in cases if enriched_matrix.loc[peptide, s] == 1])
                control_pos = set([s for s in controls if enriched_matrix.loc[peptide, s] == 1])
                
                case_positive_set.update(case_pos)
                control_positive_set.update(control_pos)
                
                case_cumulative.append(len(case_positive_set) / len(cases) * 100)
                control_cumulative.append(len(control_positive_set) / len(controls) * 100)
        
        # Create figure
        fig, ax = plt.subplots(figsize=(12, 6))
        
        x = np.arange(1, len(case_cumulative) + 1)
        ax.plot(x, case_cumulative, 'r-', linewidth=2, label='Cases')
        ax.plot(x, control_cumulative, 'b-', linewidth=2, label='Controls')
        
        ax.set_xlabel('Number of Top Peptides (ranked by p-value)', fontsize=12)
        ax.set_ylabel('Cumulative % Subjects Seropositive', fontsize=12)
        ax.set_title('Cumulative Coverage by Top Peptides', fontsize=14, fontweight='bold')
        ax.legend(fontsize=11)
        ax.grid(True, alpha=0.3)
        ax.set_xlim(0, min(500, len(x)))  # Show first 500 peptides
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved cumulative prevalence plot to {output_file}")
        
        return fig
    
    def create_violin_plot(self, enriched_matrix, metadata,
                          case_col='status', case_value='case', control_value='control',
                          output_file='violin_plot.png'):
        """
        Create violin plot comparing peptide counts between cases and controls.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        metadata : pd.DataFrame
            Sample metadata
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        import seaborn as sns
        
        # Get case and control samples
        cases = metadata[metadata[case_col] == case_value].index
        controls = metadata[metadata[case_col] == control_value].index
        
        # Convert to strings to match enriched_matrix columns
        cases = [str(s) for s in cases if str(s) in enriched_matrix.columns]
        controls = [str(s) for s in controls if str(s) in enriched_matrix.columns]
        
        # Get counts
        case_counts = enriched_matrix[cases].sum(axis=0)
        control_counts = enriched_matrix[controls].sum(axis=0)
        
        # Prepare data for seaborn
        plot_data = pd.DataFrame({
            'Peptide Count': list(case_counts) + list(control_counts),
            'Group': ['Case'] * len(case_counts) + ['Control'] * len(control_counts)
        })
        
        # Create figure
        fig, ax = plt.subplots(figsize=(8, 6))
        
        # Violin plot
        sns.violinplot(data=plot_data, x='Group', y='Peptide Count', 
                      palette={'Case': 'red', 'Control': 'blue'},
                      ax=ax, inner='box')
        
        # Add individual points
        sns.swarmplot(data=plot_data, x='Group', y='Peptide Count',
                     color='black', alpha=0.3, size=3, ax=ax)
        
        ax.set_ylabel('Number of Enriched Peptides', fontsize=12)
        ax.set_xlabel('Group', fontsize=12)
        ax.set_title('Peptide Enrichment Distribution', fontsize=14, fontweight='bold')
        ax.grid(True, alpha=0.3, axis='y')
        
        # Add statistics
        from scipy import stats
        t_stat, p_val = stats.ttest_ind(case_counts, control_counts)
        ax.text(0.5, 0.98, f'T-test p-value: {p_val:.2e}',
               transform=ax.transAxes, ha='center', va='top',
               bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved violin plot to {output_file}")
        
        return fig
    
    def create_peptide_correlation_heatmap(self, enriched_matrix, results_df,
                                          top_n=50, output_file='peptide_correlations.png'):
        """
        Create correlation heatmap for top peptides.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        results_df : pd.DataFrame
            Results with p-values
        top_n : int
            Number of top peptides
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        import seaborn as sns
        
        # Get top peptides
        top_peptides = results_df.nsmallest(top_n, 'fisher_pvalue')['entity_id'].values
        top_peptides = [p for p in top_peptides if p in enriched_matrix.index]
        
        # Calculate correlation matrix
        corr_matrix = enriched_matrix.loc[top_peptides].T.corr()
        
        # Create figure
        fig, ax = plt.subplots(figsize=(12, 10))
        
        # Heatmap
        sns.heatmap(corr_matrix, cmap='RdBu_r', center=0, vmin=-1, vmax=1,
                   square=True, linewidths=0.5, cbar_kws={'label': 'Correlation'},
                   ax=ax, xticklabels=True, yticklabels=True)
        
        ax.set_title(f'Peptide Co-occurrence Correlation - Top {len(top_peptides)} Peptides',
                    fontsize=14, fontweight='bold')
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved correlation heatmap to {output_file}")
        
        return fig
    
    def create_manhattan_plot(self, results_df, output_file='manhattan_plot.png'):
        """
        Create Manhattan-style plot showing -log10(p-value) for all peptides.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Results with p-values
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        
        # Calculate -log10(p-value)
        results_plot = results_df.copy()
        results_plot['-log10(p)'] = -np.log10(results_plot['fisher_pvalue'].clip(lower=1e-300))
        
        # Create figure
        fig, ax = plt.subplots(figsize=(14, 6))
        
        # Scatter plot
        x = np.arange(len(results_plot))
        colors = ['#1f77b4' if i % 2 == 0 else '#ff7f0e' for i in range(len(results_plot))]
        
        ax.scatter(x, results_plot['-log10(p)'], c=colors, alpha=0.6, s=10)
        
        # Significance threshold lines
        bonf_threshold = -np.log10(0.05 / len(results_plot))
        fdr_threshold = -np.log10(0.05)
        
        ax.axhline(bonf_threshold, color='red', linestyle='--', linewidth=2, 
                  label=f'Bonferroni (p={0.05/len(results_plot):.2e})')
        ax.axhline(fdr_threshold, color='green', linestyle='--', linewidth=2,
                  label=f'FDR threshold (p=0.05)')
        
        ax.set_xlabel('Peptide Index', fontsize=12)
        ax.set_ylabel('-log10(p-value)', fontsize=12)
        ax.set_title('Manhattan Plot - All Peptides', fontsize=14, fontweight='bold')
        ax.legend()
        ax.grid(True, alpha=0.3, axis='y')
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved Manhattan plot to {output_file}")
        
        return fig
    
    def create_prevalence_comparison_plot(self, results_df, top_n=30,
                                         output_file='prevalence_comparison.png'):
        """
        Create side-by-side bar plot comparing case vs control prevalence.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Results with prevalence data
        top_n : int
            Number of top peptides
        output_file : str
            Output file path
        """
        import matplotlib.pyplot as plt
        
        # Get top peptides
        top = results_df.nsmallest(top_n, 'fisher_pvalue')
        
        # Create figure
        fig, ax = plt.subplots(figsize=(12, max(8, top_n * 0.3)))
        
        y_pos = np.arange(len(top))
        width = 0.35
        
        # Bars
        ax.barh(y_pos - width/2, top['case_prevalence'] * 100, width, 
               label='Cases', color='red', alpha=0.7)
        ax.barh(y_pos + width/2, top['control_prevalence'] * 100, width,
               label='Controls', color='blue', alpha=0.7)
        
        ax.set_yticks(y_pos)
        ax.set_yticklabels(top['entity_id'], fontsize=9)
        ax.set_xlabel('Prevalence (%)', fontsize=12)
        ax.set_ylabel('Peptide ID', fontsize=12)
        ax.set_title(f'Prevalence Comparison - Top {top_n} Peptides', 
                    fontsize=14, fontweight='bold')
        ax.legend()
        ax.grid(True, alpha=0.3, axis='x')
        
        plt.tight_layout()
        plt.savefig(output_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved prevalence comparison plot to {output_file}")
        
        return fig
    
    def create_upset_plot(self, enriched_matrix, results_df, metadata,
                         case_col='status', case_value='case',
                         top_n=20, output_file='upset_plot.png'):
        """
        Create UpSet plot showing combinations of top peptides.
        
        Parameters:
        -----------
        enriched_matrix : pd.DataFrame
            Binary enrichment matrix
        results_df : pd.DataFrame
            Results with p-values
        metadata : pd.DataFrame
            Sample metadata
        top_n : int
            Number of top peptides
        output_file : str
            Output file path
        """
        try:
            from upsetplot import plot as upset_plot_func
            from upsetplot import from_memberships
            import matplotlib.pyplot as plt
            
            # Get cases only
            cases = metadata[metadata[case_col] == case_value].index
            # Convert to strings to match enriched_matrix columns
            cases = [str(s) for s in cases if str(s) in enriched_matrix.columns]
            
            # Get top peptides
            top_peptides = results_df.nsmallest(top_n, 'fisher_pvalue')['entity_id'].values
            top_peptides = [p for p in top_peptides if p in enriched_matrix.index]
            
            # Get enrichment data for top peptides in cases
            case_data = enriched_matrix.loc[top_peptides, cases]
            
            # Convert to UpSet format - ensure peptide IDs are strings
            memberships = []
            for col in case_data.columns:
                # Convert peptide IDs to strings for UpSet
                positive_peptides = [str(p) for p in case_data.index[case_data[col] == 1]]
                if positive_peptides:
                    memberships.append(positive_peptides)
            
            if len(memberships) == 0:
                print("Warning: No peptide combinations found for UpSet plot. Skipping.")
                return None
            
            # Create upset plot
            fig = plt.figure(figsize=(14, 8))
            upset_data = from_memberships(memberships)
            upset_plot_func(upset_data, fig=fig, show_counts=True)
            
            plt.suptitle(f'Peptide Combinations in Cases - Top {top_n} Peptides',
                        fontsize=14, fontweight='bold', y=0.98)
            
            plt.tight_layout()
            plt.savefig(output_file, dpi=300, bbox_inches='tight')
            plt.close()
            
            print(f"Saved UpSet plot to {output_file}")
            
        except ImportError:
            print("Warning: upsetplot package not installed. Skipping UpSet plot.")
            print("Install with: pip install upsetplot")
            fig = None
        except Exception as e:
            print(f"Warning: UpSet plot failed with error: {e}")
            print("Skipping UpSet plot.")
            fig = None
        
        return fig
    
    def create_prevalence_barplot(self, results_df, top_n=20, 
                                 level_name='peptide', output_file=None):
        """
        Create barplot comparing prevalences.
        
        Parameters:
        -----------
        results_df : pd.DataFrame
            Case-control results
        top_n : int
            Number of top entities to plot
        level_name : str
            Level name for labels
        output_file : str, optional
            Path to save plot
        """
        # Get top significant entities
        top_results = results_df[
            results_df['fisher_qvalue'] < 0.05
        ].nsmallest(top_n, 'fisher_pvalue')
        
        if len(top_results) == 0:
            print("No significant entities to plot")
            return None
        
        # Prepare data for plotting
        x = np.arange(len(top_results))
        width = 0.35
        
        fig, ax = plt.subplots(figsize=(12, 8))
        
        # Create bars
        bars1 = ax.barh(
            x - width/2,
            top_results['case_prevalence'],
            width,
            label='Case',
            color='red',
            alpha=0.7
        )
        bars2 = ax.barh(
            x + width/2,
            top_results['control_prevalence'],
            width,
            label='Control',
            color='blue',
            alpha=0.7
        )
        
        # Labels
        ax.set_yticks(x)
        ax.set_yticklabels(top_results['entity_id'], fontsize=8)
        ax.set_xlabel('Seroprevalence', fontsize=14, fontweight='bold')
        ax.set_title(
            f'Top {len(top_results)} {level_name.capitalize()}s: Case vs Control',
            fontsize=16,
            fontweight='bold'
        )
        ax.legend(fontsize=12)
        ax.invert_yaxis()
        
        # Add grid
        ax.grid(axis='x', alpha=0.3)
        
        plt.tight_layout()
        
        if output_file:
            plt.savefig(output_file, dpi=300, bbox_inches='tight')
            print(f"Saved prevalence plot: {output_file}")
        
        return fig


# Example usage
if __name__ == "__main__":
    
    # Initialize analyzer
    analyzer = CaseControlAnalyzer()
    
    # Load data
    peptide_enriched = pd.read_csv("results/peptide_enrichment_binary.csv", index_col=0)
    protein_enriched = pd.read_csv("results/protein_enrichment_binary.csv", index_col=0)
    virus_enriched = pd.read_csv("results/virus_enrichment_binary.csv", index_col=0)
    metadata = pd.read_csv("sample_metadata.csv", index_col=0)
    
    # Run analysis at all levels
    results = analyzer.analyze_all_levels(
        peptide_enriched,
        protein_enriched,
        virus_enriched,
        metadata,
        case_col='status',
        case_value='case',
        control_value='control',
        output_dir='results/case_control'
    )
    
    # Create visualizations
    print("\nCreating visualizations...")
    
    # Volcano plots
    analyzer.create_volcano_plot(
        results['peptide'],
        level_name='peptide',
        output_file='results/case_control/volcano_peptide.png'
    )
    
    analyzer.create_volcano_plot(
        results['virus'],
        level_name='virus',
        output_file='results/case_control/volcano_virus.png'
    )
    
    # Heatmaps
    analyzer.create_heatmap(
        peptide_enriched,
        metadata,
        results['peptide'],
        top_n=50,
        output_file='results/case_control/heatmap_peptides.png'
    )
    
    # Prevalence plots
    analyzer.create_prevalence_barplot(
        results['virus'],
        top_n=20,
        level_name='virus',
        output_file='results/case_control/prevalence_viruses.png'
    )
    
    print("\nAnalysis complete!")
