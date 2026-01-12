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
    
    def __init__(self):
        pass
    
    def load_sample_metadata(self, metadata_file):
        """
        Load sample metadata with case/control labels.
        
        Parameters:
        -----------
        metadata_file : str
            Path to sample metadata CSV
            Expected columns: sample_id, disease_status (or similar)
            
        Returns:
        --------
        metadata : pd.DataFrame
            Sample metadata
        """
        metadata = pd.read_csv(metadata_file, index_col=0)
        return metadata
    
    def test_single_entity(self, enriched_matrix, metadata, 
                          case_col='disease_status',
                          case_value='case', 
                          control_value='control',
                          adjust_for_batch=True,
                          batch_col='plate'):
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
        
        results = []
        
        for entity in enriched_matrix.index:
            # Create 2x2 contingency table
            case_pos = enriched_matrix.loc[entity, cases].sum()
            case_neg = len(cases) - case_pos
            control_pos = enriched_matrix.loc[entity, controls].sum()
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
            
            if has_batch:
                try:
                    import statsmodels.api as sm
                    
                    # Prepare data for logistic regression
                    all_samples = list(cases) + list(controls)
                    y = np.array([1] * len(cases) + [0] * len(controls))  # 1=case, 0=control
                    X_peptide = enriched_matrix.loc[entity, all_samples].values
                    
                    # Get batch labels
                    batch_labels = metadata.loc[all_samples, batch_col].values
                    
                    # Create dummy variables for batches
                    from pandas import get_dummies
                    batch_dummies = get_dummies(batch_labels, drop_first=True)
                    
                    # Combine peptide status with batch dummies
                    X = pd.DataFrame({
                        'peptide': X_peptide,
                    })
                    X = pd.concat([X, batch_dummies], axis=1)
                    X = sm.add_constant(X)
                    
                    # Fit logistic regression
                    model = sm.Logit(y, X).fit(disp=0)
                    
                    # Extract peptide coefficient
                    batch_adjusted_or = np.exp(model.params['peptide'])
                    batch_adjusted_p = model.pvalues['peptide']
                    
                except Exception as e:
                    # If regression fails, keep as NaN
                    pass
            
            results.append({
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
                'batch_adjusted_pvalue': batch_adjusted_p
            })
        
        results_df = pd.DataFrame(results)
        
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
    
    def analyze_all_levels(self, peptide_enriched, protein_enriched, 
                          virus_enriched, metadata,
                          case_col='disease_status',
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
                      top_n=50, case_col='disease_status',
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
        case_col='cancer_status',
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
