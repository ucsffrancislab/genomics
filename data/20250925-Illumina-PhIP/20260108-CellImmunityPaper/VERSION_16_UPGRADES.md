# Version 16 Upgrades - Analysis Enhancements

## Summary of Changes

All requested features have been implemented and tested!

---

## 1. ✅ Peptide Metadata in Results File

### What Changed:
- `entity_id` renamed to `peptide_id` (more specific and clear)
- Added `organism` and `protein_name` columns at the beginning
- Columns automatically merged from peptide_metadata.csv

### New Column Order:
```
organism, protein_name, peptide_id, case_positive, case_total, control_positive, 
control_total, case_prevalence, control_prevalence, prevalence_diff, odds_ratio, 
risk_ratio, fisher_pvalue, chi2_pvalue, batch_adjusted_OR, batch_adjusted_pvalue, 
fisher_qvalue, batch_adjusted_qvalue, fisher_bonferroni, fdr, significant_fdr
```

### Why "entity_id" was used:
- The function `test_single_entity()` can test peptides, proteins, or viruses
- "entity" is a generic term that works for all levels
- Now renamed to `peptide_id` since you're doing peptide-level analysis

### Implementation:
```python
results = analyzer.test_single_entity(
    peptide_enriched,
    metadata_subjects,
    peptide_metadata=peptide_metadata  # NEW parameter
)
```

The merger happens automatically if peptide_metadata is provided!

---

## 2. ✅ Organism-Specific Manhattan Plots

### What Changed:
- Added `organism_filter` parameter to `create_manhattan_plot()`
- Can now create Manhattan plots for specific viruses/organisms
- Automatically added for HHV3, HHV4, HHV5, and Influenza A

### Usage:
```python
# All peptides
analyzer.create_manhattan_plot(
    results,
    output_file='manhattan_plot_all.png'
)

# Specific organism
analyzer.create_manhattan_plot(
    results,
    output_file='manhattan_plot_HHV5.png',
    organism_filter='Human herpesvirus 5'
)
```

### Files Created:
- `manhattan_plot_all.png` - All peptides
- `manhattan_plot_HHV3.png` - Human herpesvirus 3
- `manhattan_plot_HHV4.png` - Human herpesvirus 4
- `manhattan_plot_HHV5.png` - Human herpesvirus 5 (CMV)
- `manhattan_plot_InfluenzaA.png` - Influenza A virus

If an organism has no peptides, it skips gracefully with a warning.

---

## 3. ✅ Peptide-ID Sorting (Not P-value)

### What Changed:
- Manhattan plots now sort by `peptide_id` instead of p-value
- Keeps neighboring peptides (overlapping sequences) together
- Uses numeric sorting when possible, falls back to string sorting

### Why This Matters:
- Overlapping peptides often have similar p-values
- Sorting by peptide_id shows regional patterns along proteins
- Can identify "hot spots" of immunogenicity

### Visual Effect:
**Before (p-value sorted)**: Scattered spikes across the x-axis
**After (peptide_id sorted)**: Clusters of neighboring significant peptides

### Example:
```
Peptide 5001, 5002, 5003 from same protein region
→ All show significance
→ Appear together in plot
→ Suggests epitope cluster
```

---

## 4. ✅ Directional Effect in Manhattan Plots

### What Changed:
- Y-axis now shows **signed** -log10(p-value)
- Direction indicates which group is enriched:
  - **Positive (UP)**: Enriched in **cases** (OR > 1)
  - **Negative (DOWN)**: Enriched in **controls** (OR < 1)

### Interpretation:
```
         +10 ┃ Highly significant, enriched in CASES
          +5 ┃ Moderately significant, enriched in CASES
           0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          -5 ┃ Moderately significant, enriched in CONTROLS  
         -10 ┃ Highly significant, enriched in CONTROLS
```

### Visual Elements:
- **Black line at 0**: No effect
- **Green dashed lines** (±FDR threshold): Standard significance
- **Red dashed lines** (±Bonferroni): Stringent significance
- **Colors alternate** by region for visual grouping

### Example Use Case:
**CMV Study**:
- CMV peptides should be **UP** (enriched in CMV+ cases)
- Seeing them DOWN would be wrong!

**Glioma Study**:
- UP: Peptides enriched in glioma patients
- DOWN: Peptides enriched in healthy controls
- Can identify both tumor antigens AND protective responses

---

## Implementation Details

### File Structure:
```
case_control_v16.py
├── test_single_entity()         # Now accepts peptide_metadata parameter
├── create_manhattan_plot()      # Enhanced with organism_filter & directionality
└── All other plot methods       # Unchanged

CMV_case_control_v16.py
├── Loads peptide_metadata.csv
├── Passes to test_single_entity()
└── Creates 2 Manhattan plots (all + CMV-specific)

Glioma_AGS_IPS_case_control_v16.py
├── Loads peptide_metadata.csv  
├── Passes to test_single_entity()
└── Creates 5 Manhattan plots (all + 4 viruses)
```

### Peptide Metadata Requirements:
Your `peptide_metadata.csv` must have these columns:
- `peptide_id` (or first column will be used)
- `organism` (or any column with 'organism' or 'virus')
- `protein_name` (or any column with 'protein')

The code auto-detects and standardizes column names!

---

## Usage Examples

### Basic Usage:
```python
# Load data
peptide_enriched = pd.read_csv("results/peptide_enrichment_binary.csv", index_col=0)
metadata = pd.read_csv("sample_metadata.csv", index_col=0)
peptide_metadata = pd.read_csv("peptide_metadata.csv")  # NEW

# Prepare metadata
metadata_subjects = metadata.groupby('subject_id').first()

# Run analysis with metadata
results = analyzer.test_single_entity(
    peptide_enriched,
    metadata_subjects,
    peptide_metadata=peptide_metadata  # NEW parameter
)

# Results now have organism and protein_name columns!
```

### Create Organism-Specific Manhattan Plots:
```python
# Check which organisms are in your data
if 'organism' in results.columns:
    organisms = results['organism'].value_counts()
    print("Organisms in dataset:")
    print(organisms.head(10))
    
    # Create plot for each major organism
    for org in ['Human herpesvirus 5', 'Influenza A virus']:
        analyzer.create_manhattan_plot(
            results,
            output_file=f'manhattan_{org.replace(" ", "_")}.png',
            organism_filter=org
        )
```

---

## Expected Output

### Results CSV:
```csv
organism,protein_name,peptide_id,case_positive,case_total,...
Human herpesvirus 5,UL83,55867,23,47,...
Human herpesvirus 5,UL55,32103,23,47,...
Influenza A virus,Hemagglutinin,20922,18,47,...
```

### Manhattan Plots:
1. **All peptides**: Shows full landscape of immune responses
2. **HHV3**: Varicella-zoster virus (chickenpox/shingles)
3. **HHV4**: Epstein-Barr virus (mononucleosis)
4. **HHV5**: Cytomegalovirus (CMV)
5. **Influenza A**: Flu virus

Each plot:
- Sorted by peptide_id (neighbors together)
- Directional (up/down shows case/control enrichment)
- Color-coded for readability
- Significance thresholds marked

---

## Troubleshooting

### "organism column not in results"
**Cause**: peptide_metadata not loaded or missing columns
**Fix**: 
```python
peptide_metadata = pd.read_csv("peptide_metadata.csv")
print(peptide_metadata.columns)  # Check what columns exist
```

### "No peptides found for organism 'X'"
**Cause**: Organism name doesn't match exactly
**Fix**: Check exact organism names in data:
```python
print(results['organism'].unique())
```

### Manhattan plot looks wrong
**Check**:
1. Are peptides sorted by peptide_id? (Yes)
2. Is direction correct? (UP = cases, DOWN = controls)
3. Are significance lines visible? (Green = FDR, Red = Bonferroni)

---

## Scientific Impact

### Why These Changes Matter:

1. **Organism/Protein Columns**: 
   - Easier to identify biological context
   - Can filter/sort by virus family
   - Essential for publication tables

2. **Organism-Specific Plots**:
   - Focus on viruses of interest
   - Clearer signal without noise from other organisms
   - Can compare responses across viruses

3. **Peptide-ID Sorting**:
   - Identifies epitope clusters
   - Shows regional immunogenicity patterns
   - Helps design peptide panels

4. **Directional Effects**:
   - Immediately see if peptide is case/control enriched
   - Critical for biological interpretation
   - Prevents misinterpretation of "significance"

### Example Interpretation:

**Glioma Manhattan plot shows**:
- HHV5 peptides cluster UP → Glioma patients have more CMV exposure?
- Influenza peptides scattered → No pattern (normal population variation)
- Some peptides DOWN → Controls have better immune memory?

This tells a biological story that p-values alone cannot!

---

## Files Updated

✅ `case_control_v16.py` - Core analyzer with all enhancements
✅ `CMV_case_control_v16.py` - Updated CMV analysis script
✅ `Glioma_AGS_IPS_case_control_v16.py` - Updated Glioma analysis script

All three files are ready to use immediately!
