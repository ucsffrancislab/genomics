# Comprehensive Guide to Requested Changes for PRS Survival Analysis Report

## Key Questions Answered

### 1. Sample Size Flow Through Analysis Pipeline

**Data flow:**
```
Raw PRS Scores (all imputed samples)
    ↓
Filtered to samples with covariates (in lists/*_covariates.tsv)
    ↓
Further filtered by case subset (lists/*_meta_cases.txt)
    ↓
Cox regression (N shown in results)
    ↓
Meta-analysis (combines Cox results)
```

The `N` column in Cox results shows the actual sample size used for each model/dataset/subset combination.

**To verify sample sizes are correct:** Check that Cox `N` matches the intersection of:
- Samples in PRS scores file
- Samples in covariates file  
- Samples in the specific case subset list

### 2. What Variables Were Used in Each Cox Model?

Variables are **dynamically selected** based on availability per dataset:

**Always included (if available):**
- Age: `age` or `Age`
- Sex: `SexFemale` (converted from sex column)
- PCs: `PC1` through `PC8`
- The PRS model being tested

**Conditionally included (if present AND has variance):**
- `chemo` - chemotherapy treatment
- `rad` - radiation treatment
- `ngrade` - tumor grade
- `dxyear` - diagnosis year
- `source` - data source (converted to SourceAGS indicator)

**Current limitation:** The exact covariates used per model are printed to the log file but NOT saved in the results table.

**Solution:** I'll add a "Model Specifications" section that documents which covariates were used for each dataset.

### 3. What is META in Forest Plots?

**META** = Meta-analyzed estimate combining all 4 datasets using inverse-variance weighting.

**How it works:**
1. Each dataset provides: Effect size + Standard Error
2. Weight = 1 / (SE²) - more precise estimates get more weight
3. META Effect = Σ(Weight × Effect) / Σ(Weight)

**Your boss is right to question it!** If META looks very different from individual estimates:
- Check for **heterogeneity** (HetPVal in METAL output)
- Verify **sample sizes** are correct (larger studies dominate)
- Look for **direction conflicts** (some HR>1, some HR<1)

### 4. How Are Risk Groups Determined?

**For Quartile Plots (Q1-Q4):**
```R
risk_group <- cut(PRS_zscore,
                  breaks = quantile(PRS_zscore, probs = c(0, 0.25, 0.5, 0.75, 1)),
                  labels = c("Q1-Low", "Q2", "Q3", "Q4-High"))
```
- Q1 = 0-25th percentile (lowest genetic risk)
- Q2 = 25-50th percentile
- Q3 = 50-75th percentile  
- Q4 = 75-100th percentile (highest genetic risk)

**For Binary Risk Groups (Low/High):**
```R
risk_group <- cut(PRS_zscore,
                  breaks = quantile(PRS_zscore, probs = c(0, 0.5, 1)),
                  labels = c("Low Risk", "High Risk"))
```
- Low = Below median
- High = Above median

**Important:** Quantiles are calculated **within each dataset** to account for population differences.

---

## Implementation Changes Required

### Change 1: Include All 10 Models in Raw Score Distributions

**Current:** Samples 20 random models  
**Requested:** Show all 10 custom models (7 split + 3 comma versions)

**File:** Line ~178-181  
**Change from:**
```R
set.seed(42)
available_models <- setdiff(all_models, c(comma_models, split_models))
n_to_sample <- min(20, length(available_models))
sample_prs <- sample(available_models, n_to_sample)
```

**Change to:**
```R
# Use ALL 10 custom models (comma + split versions)
sample_prs <- grep("glioma|gbm|idh", all_models, value = TRUE, ignore.case = TRUE)
```

**Also update:**
```R
labs(title = paste("Raw PRS Score Distributions (All", length(sample_prs), "Custom Models)"),
```

---

### Change 2: Create Z-Score Distributions Section

**Add new section after "Z-score Validation"** (around line 260):

```R
## Z-Score Distributions by Dataset (All Custom Models)

```{r zscore_distributions_custom, fig.height=10}
# Get all custom models
custom_prs <- grep("glioma|gbm|idh", all_models, value = TRUE, ignore.case = TRUE)

# Combine datasets for z-scores
plot_data_z <- bind_rows(lapply(datasets, function(ds) {
  if(!is.null(zscores_list[[ds]])) {
    zscores_list[[ds]] %>%
      select(sample, dataset, all_of(custom_prs)) %>%
      pivot_longer(cols = all_of(custom_prs), 
                   names_to = "PRS", 
                   values_to = "ZScore")
  }
}))

# Plot z-score distributions
ggplot(plot_data_z, aes(x = ZScore, fill = dataset)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ PRS, scales = "free_y", ncol = 2) +
  scale_fill_manual(values = dataset_colors) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Z-Scored PRS Distributions (All 10 Custom Models)",
       subtitle = "All models standardized to mean=0, SD=1",
       x = "Z-Score", y = "Density") +
  theme(legend.position = "bottom")
```

**Observation:** All z-scored distributions should be centered at 0 with similar spreads across datasets.
```

---

### Change 3: Include All 9 Case Subsets in QQ Plots

**Current:** Shows first 6 subsets  
**Requested:** Show all 9 subsets

**File:** Line ~450  
**Change from:**
```R
n_subsets <- min(6, length(subsets))
qq_plots <- lapply(subsets[1:n_subsets], function(sub) {
```

**Change to:**
```R
qq_plots <- lapply(subsets, function(sub) {  # Use ALL subsets
```

**Also update grid arrangement:**
```R
do.call(grid.arrange, c(qq_plots, ncol = 3))  # 3 columns to fit 9 plots
```

---

### Change 4: Include All 9 Case Subsets in Volcano Plots

**File:** Line ~510  
**Same change as #3:**

```R
# Change from:
n_subsets <- min(6, length(unique_subsets))
volcano_plots <- lapply(unique_subsets[1:n_subsets], function(sub) {

# Change to:
volcano_plots <- lapply(unique_subsets, function(sub) {

# Update arrangement:
do.call(grid.arrange, c(volcano_plots, ncol = 3))
```

---

### Change 5: Fix Manhattan Plot X-Axis Readability

**File:** Line ~560  
**Problem:** Overlapping subset labels  
**Solution:** Rotate labels, use abbreviations, or create better spacing

```R
ggplot(metal_plot, aes(x = x_plot, y = neglog10p, color = subset)) +
  geom_point(alpha = 0.6, size = 1.5) +
  geom_hline(yintercept = -log10(0.05 / nrow(metal_results)), 
             linetype = "dashed", color = "red", size = 1) +
  scale_x_continuous(breaks = subset_centers$center, 
                     labels = gsub("_meta_cases", "", subset_centers$subset)) +  # Remove suffix
  scale_color_manual(values = rainbow(length(unique(metal_plot$subset)))) +  # Better colors
  labs(title = "Manhattan Plot: Meta-Analysis Results Across All Subsets",
       subtitle = "Red line = Bonferroni threshold; Each color = different subset",
       x = "Subset", y = "-log10(P-value)",
       color = "Subset") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 8),  # Rotate 90°
        legend.position = "right",
        legend.text = element_text(size = 7))
```

---

### Change 6: Make Custom Models Table Sortable

**File:** Line ~620  
**Change from:**
```R
kable(custom_summary,
      caption = "Custom Glioma PRS Results by Subset",
      digits = 4)
```

**Change to:**
```R
datatable(custom_summary,
          caption = "Custom Glioma PRS Results by Subset",
          options = list(pageLength = 20),
          rownames = FALSE) %>%
  formatRound(columns = c("Meta_HR"), digits = 3) %>%
  formatSignif(columns = c("Pvalue", "HetPVal"), digits = 3)
```

---

### Change 7: Include Comma Versions in Custom Models Table

**File:** Line ~600  
**Change from:**
```R
custom_meta <- metal_results %>%
  filter(grepl("glioma|gbm|idh", MarkerName, ignore.case = TRUE)) %>%
  # Remove comma versions for cleaner visualization
  filter(!grepl("\\.commas$", MarkerName))
```

**Change to:**
```R
custom_meta <- metal_results %>%
  filter(grepl("glioma|gbm|idh", MarkerName, ignore.case = TRUE))
  # KEEP comma versions for comparison
```

---

### Change 8: Include Comma Versions in Heatmap

**File:** Line ~640  
**Same as Change 7** - remove the filter that excludes comma versions:

```R
# Create matrix for heatmap
heat_data <- custom_meta %>%  # custom_meta now includes .commas versions
  select(MarkerName, subset, neglog10p) %>%
  pivot_wider(names_from = subset, values_from = neglog10p, values_fill = 0) %>%
  column_to_rownames("MarkerName") %>%
  as.matrix()
```

---

### Change 9: Clarify META in Forest Plots

**Add explanation before forest plots section:**

```R
# Forest Plots: Effect Sizes Across Datasets

Forest plots show hazard ratios (HR) and 95% confidence intervals for each dataset, plus the **META-ANALYZED** estimate.

**What is META?**
- META = Combined estimate across all 4 datasets using inverse-variance weighting
- Datasets with more precise estimates (smaller standard errors) contribute more weight
- If META differs substantially from individual estimates, check for heterogeneity (HetPVal)

**Interpretation:**
- Points = Hazard ratio per 1-SD increase in PRS
- Horizontal lines = 95% confidence intervals
- Vertical dashed line at HR=1 = null effect
- HR > 1 = increased risk; HR < 1 = protective effect
```

---

### Change 10: Include Comma Versions in Custom Model Forest Plots

**File:** Line ~820  
**Change from:**
```R
custom_model_names <- grep("\\.commas$", custom_model_names, 
                           value = TRUE, invert = TRUE)
```

**Remove this line** to keep comma versions.

---

### Change 11: Create KM Plots for All 4 Datasets × All 10 Models

**File:** Line ~900 (Example KM section)  
**Replace entire section with:**

```R
## Kaplan-Meier Curves by Dataset and Model

**Risk Groups:** Patients stratified into quartiles (Q1-Q4) based on their PRS z-score within each dataset.
- **Q1-Low:** Bottom 25% (lowest genetic risk, best prognosis expected)
- **Q2:** 25-50th percentile
- **Q3:** 50-75th percentile  
- **Q4-High:** Top 25% (highest genetic risk, worst prognosis expected)

```{r km_all_combinations, fig.height=8, results='asis'}
# Get all custom models
all_custom_models <- grep("glioma|gbm|idh", names(zscores_list[[1]]), 
                         value = TRUE, ignore.case = TRUE)

# Create function (already defined earlier)
# Loop through all combinations
for(ds in datasets) {
  if(!is.null(survival_data_list[[ds]]) && !is.null(zscores_list[[ds]])) {
    cat("\n\n### Dataset:", toupper(ds), "\n\n")
    
    for(model in all_custom_models) {
      if(model %in% names(zscores_list[[ds]])) {
        cat("\n#### ", model, "\n\n")  # Keep FULL name
        
        tryCatch({
          km_plot <- create_km_plot(toupper(ds), model, 
                                     survival_data_list[[ds]], 
                                     zscores_list[[ds]])
          print(km_plot$plot)
          print(km_plot$table)
        }, error = function(e) {
          cat("Error creating KM plot for", model, ":", e$message, "\n\n")
        })
        
        cat("\n\n")
      }
    }
  }
}
```

**This generates:** 4 datasets × 10 models = 40 Kaplan-Meier plots

---

### Change 12: Keep Full Model Names in Template Section

**Already addressed in Change 11** - removed `gsub("_scoring_system", "", model)`

---

### Change 13: Multi-Dataset KM for All 10 Models

**File:** Line ~1130  
**Replace with:**

```R
## Multi-Dataset Kaplan-Meier Comparison

**Risk Groups:** Patients stratified into **Low Risk** (below median) vs **High Risk** (above median) based on PRS z-score **within each dataset**.

This allows comparison of survival curves across datasets while accounting for population differences.

```{r km_multi_all_models, fig.height=8, results='asis'}
# Get all custom models
all_custom_models <- grep("glioma|gbm|idh", names(zscores_list[[1]]), 
                         value = TRUE, ignore.case = TRUE)

for(model in all_custom_models) {
  cat("\n\n### ", model, "\n\n")
  
  tryCatch({
    km_result <- create_multi_dataset_km(model)
    if(!is.null(km_result)) {
      print(km_result)
    } else {
      cat("No data available for", model, "\n")
    }
  }, error = function(e) {
    cat("Error creating multi-dataset KM for", model, ":", e$message, "\n")
  })
  
  cat("\n\n")
}
```

---

## Additional Section: Model Specifications

**Add new section after "Cox Regression Results" summary:**

```R
## Cox Model Specifications

### Covariates Used by Dataset

```{r model_specifications}
# Document which covariates were available and used for each dataset

covariate_info <- lapply(datasets, function(ds) {
  if(!is.null(survival_data_list[[ds]])) {
    df <- survival_data_list[[ds]]
    
    # Check which covariates are present and have variance
    present_covs <- c()
    
    if("age" %in% names(df) || "Age" %in% names(df)) present_covs <- c(present_covs, "Age")
    if("sex" %in% names(df)) present_covs <- c(present_covs, "Sex")
    if("chemo" %in% names(df) && length(unique(df$chemo)) > 1) present_covs <- c(present_covs, "Chemo")
    if("rad" %in% names(df) && length(unique(df$rad)) > 1) present_covs <- c(present_covs, "Radiation")
    if("ngrade" %in% names(df) && length(unique(df$ngrade)) > 1) present_covs <- c(present_covs, "Grade")
    if("dxyear" %in% names(df) && length(unique(df$dxyear)) > 1) present_covs <- c(present_covs, "Dx Year")
    if("source" %in% names(df) && length(unique(df$source)) > 1) present_covs <- c(present_covs, "Source")
    
    # PCs always included
    pcs <- paste0("PC", 1:8)
    present_pcs <- pcs[pcs %in% names(df)]
    
    data.frame(
      Dataset = toupper(ds),
      Clinical_Covariates = paste(present_covs, collapse = ", "),
      Principal_Components = paste(present_pcs, collapse = ", "),
      PRS = "Each model tested individually"
    )
  }
}) %>% bind_rows()

kable(covariate_info,
      caption = "Covariates Included in Cox Proportional Hazards Models by Dataset")
```

**Cox Model Formula Structure:**
```
Surv(survdays, vstatus) ~ PRS + Age + Sex + Chemo + Radiation + Grade + DxYear + Source + PC1 + PC2 + ... + PC8
```

Where each covariate is only included if:
1. The column exists in the dataset
2. There is variance (not all same value)

**Note:** The exact formula varies by dataset based on available covariates.
```

---

## Summary of Changes

1. ✅ Raw score plots: All 10 models
2. ✅ Z-score plots: New section with all 10 models
3. ✅ QQ plots: All 9 subsets
4. ✅ Volcano plots: All 9 subsets
5. ✅ Manhattan plot: Rotated labels, better colors
6. ✅ Custom table: Made sortable/interactive
7. ✅ Custom table: Include comma versions
8. ✅ Heatmap: Include comma versions
9. ✅ Forest plots: Explained META
10. ✅ Custom forest plots: Include comma versions
11. ✅ KM example: All 4 datasets × 10 models, explained risk groups
12. ✅ KM template: Keep full names, all 10 models
13. ✅ Multi-dataset KM: All 10 models, explained risk groups
14. ✅ NEW: Model specifications section

---

## How to Apply These Changes

I'll now create the updated Rmd file with all these changes implemented.
