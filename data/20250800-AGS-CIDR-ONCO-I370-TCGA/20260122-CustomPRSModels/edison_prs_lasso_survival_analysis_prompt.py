#!/usr/bin/env python3

import os
import asyncio
from edison_client import EdisonClient
from edison_client import JobNames
from edison_client import TaskRequest
from edison_client.models import RuntimeConfig

with open("/c4/home/gwendt/EDISON_API_TOKEN", 'r') as file:
	api_key = file.read()

api_key = api_key.rstrip()	# Cannot include a carriage return
print(api_key)

client = EdisonClient(api_key=api_key)
print("Set client")


#	https://edisonscientific.gitbook.io/edison-cookbook/edison-client/docs/edison_analysis_tutorial

async def upload():
	print("Uploading", flush=True)
	# Uploading a directory to the data storage service
	response = await client.astore_file_content(
    	name="Directory containing the cidr/i370/onco/tcga covariates",
    	file_path="./edison_prs_lasso_survival_analysis",  # ADD DATASET FOLDER PATH HERE
    	description="This is a directory that will be be analysed by Edison Analysis",
    	as_collection=True,
	)
	print("Finished Uploading", flush=True)
	return response

directory_upload_response = asyncio.run(upload())



#query = """
#PRS LASSO Survival Analysis #1
#
#Included in the provided directory are data from 4 different datasets/cohorts (cidr,i370,onco,tcga).
#Each dataset was genotyped separately on a different SNP array.
#Each dataset was then imputed separately on the UMich imputation servers.
#Each dataset was then lifted over to hg38, filtered with R2>0.8 and normalized.
#These vcf files were then scored against the majority of the 5000 model PGS catalog plus 7 additional custom models using pgs-calc.
#pgs-calc generated a DATASET.scores.info json file that contains a variety of metadata from the scoring of each model such as how many SNPs are in the model and what portion were used during scoring which could be used for filtering models included.
#Each dataset then had its scores scaled generating the DATASET.scores.z-scores.txt.gz file.
#In addition each dataset has the same set of covariates in DATASET-covariates.csv.
#
#Running this entire pipeline will take too long so instead, take a small subset, a few percent, or whatever sounds doable, of the models and create a pipeline with all of the necessary python code and bash wrapper scripts that I could run on our local slurm HPC cluster, either in an array job or a single large job that will take full advantage of our 64 CPU 490GB node using parallelization, that will import multiple datasets, in this case i370, onco and tcga, and combine them, creating a new field for the dataset/cohort, then
#builds a LASSO regression model and validates on a separate dataset/cohort, in this case cidr.
#
#Create a PGS survival-style pipeline that uses these scores and run/build a LASSO model 
#1. Fixed-effects inverse-variance weighted meta-analysis across discovery cohorts
#2. Pre-filter: meta p<0.05, consistent direction of effect across cohorts, tested in ≥2 cohorts
#3. Cap candidates by events/5 rule
#4. LASSO Cox PH with differential penalization (covariates unpenalized, PRS penalized)
#
#I'm not sure if I got all of the wording correct on that.
#
#
#Define any pipeline variables in a single file config.py that is imported by any others that need it.
#
#Use the variable
#
#COVARIATES = ['source', 'age', 'sex', 'grade', 'treated', 'PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8']
#
#to control the covariates used in the regression.
#Some of these may not vary in a dataset or selection as a whole, particularly if stratfied on, so should be checked and confirmed in the pipeline.
#Check each covariate to ensure that there is variance as I suspect that is a requirement of the regression model.
#
#survdays contains the survival time and vstatus contains the event status where 1=deceased and 0=still alive last we knew.
#
#Use a variable like 
#
#SUBTYPES = {
#  'idh_wildtype': {'case': 1, 'idh': 0},
#  'lgg_idh_mutant_pq_intact': {'case': 1, 'grade': 'LGG', 'idh': 1, 'pq': 0},
#  'hgg_idh_mutant_pq_intact': {'case': 1, 'grade': 'HGG', 'idh': 1, 'pq': 0},
#  'lgg_idh_mutant_pq_codel': {'case': 1, 'grade': 'LGG', 'idh': 1, 'pq': 1}
#}
#
#to control the glioma subtypes analyzed.
#
#As you will see, the tcga dataset only has about 20 samples in hgg_idh_mutant_pq_intact and i370 only has about 9 in lgg_idh_mutant_pq_codel so the variables to check thresholds may be necesary, again defined in the central location config.py.
#
#The dataset onco is the only one that includes samples from 2 different sources.
#
#Use 10 fold cross validation and refine the predictive model as best as possible to avoid over fitting. 
#
#Test/validate the model on the CIDR cohort on the 4 subtypes of glioma. 
#Report the model fit in the validation cohort.
#Provide detailed graphics including KM curves and c-index metrics. 
#Provide forest plots of the subtype specific PGSs used in the final models and provide a table of subtype specific PGSs used in the final model and the weights.
#
#Be sure to print output, particularly if an exception is raised.
#Add a debug parameter that will trigger more printing to help debug any issues.
#
#Be sure to include all commands that I need to run beforehand, like installing python packages.
#Be sure that this code works and includes some testing.
#Include the commands needed to test that that code works so that I can run it before trying to run the full analysis.
#Include instructions and parameters that I can use to select the appropriate files.
#
#"""

#	Claude modified the above, with a couple questions, into ... (which is 9902 characters)

query = """
# PRS LASSO Cox Survival Analysis Pipeline — Edison Analysis Request

## Overview

Included in the provided directory are data from 4 different cohorts: **cidr**, **i370**, **onco**, and **tcga**.

Each cohort was genotyped separately on a different SNP array, imputed separately on the UMich imputation servers, lifted over to hg38, filtered with R2 > 0.8, and normalized. These VCF files were scored against the majority of the ~5,000 PGS Catalog models plus 7 additional custom glioma-specific models using pgs-calc.

- `DATASET.scores.info` — JSON file containing metadata per scoring run (e.g., number of SNPs in the model, proportion used during scoring). This can be used to filter models.
- `DATASET.scores.z-scores.txt.gz` — Gzip-compressed z-scored PRS scores per sample. All file reading must handle gzip transparently.
- `DATASET-covariates.csv` — Covariates file, same structure across all cohorts.

---

## Goal

Build a LASSO Cox proportional hazards (Cox PH) survival model using **i370**, **onco**, and **tcga** as pooled discovery cohorts, then validate it on the held-out **cidr** cohort. All discovery cohorts are to be **pooled into a single joint analysis** with cohort membership included as a covariate (see COVARIATES below), rather than analyzed separately and meta-analyzed. This pooled approach is preferred to maximize sample size given limited numbers in some strata.

---

## Survival Outcome

- **Survival time**: `survdays`
- **Event status**: `vstatus` (1 = deceased, 0 = alive/censored)

---

## Central Configuration File: `config.py`

Define **all pipeline variables** in a single `config.py` that is imported by every other script. This must include at minimum:

```python
# Cohorts
DISCOVERY_COHORTS = ['i370', 'onco', 'tcga']
VALIDATION_COHORT = 'cidr'

# Covariates used in all Cox PH models
# 'source' distinguishes two recruitment sources within the onco cohort only;
# it should be included as a covariate when fitting models within or across cohorts
# that include onco samples, but checked for variance before use (see below).
COVARIATES = ['source', 'age', 'sex', 'grade', 'treated', 'PC1', 'PC2', 'PC3',
              'PC4', 'PC5', 'PC6', 'PC7', 'PC8']

# Glioma subtypes to analyze
# grade column contains string values: 'LGG' or 'HGG'
SUBTYPES = {
    'idh_wildtype':              {'case': 1, 'idh': 0},
    'lgg_idh_mutant_pq_intact':  {'case': 1, 'grade': 'LGG', 'idh': 1, 'pq': 0},
    'hgg_idh_mutant_pq_intact':  {'case': 1, 'grade': 'HGG', 'idh': 1, 'pq': 0},
    'lgg_idh_mutant_pq_codel':   {'case': 1, 'grade': 'LGG', 'idh': 1, 'pq': 1},
}

# Minimum thresholds
MIN_SAMPLES_PER_SUBTYPE = 20      # Skip subtype if fewer samples than this
MIN_EVENTS_PER_SUBTYPE  = 10      # Skip subtype if fewer events than this
EPV_RATIO               = 5       # Events-per-variable: max predictors = n_events / EPV_RATIO

# Pre-filtering thresholds (applied to pooled univariate Cox PH results)
META_P_THRESHOLD        = 0.05    # Nominal p-value threshold for pre-filtering PGS candidates
REQUIRE_CONSISTENT_DIR  = True    # Require consistent direction of effect across cohorts

# Cross-validation
CV_FOLDS = 10

# Output
OUTPUT_DIR = 'results'

# Parallelization
N_JOBS = 64   # Match available CPUs on the HPC node

# Debug mode (set via --debug flag; triggers verbose printing)
DEBUG = False
```

---

## Pipeline Steps

### Step 1 — Load and Pool Discovery Data

- Load z-scored PRS files (`DATASET.scores.z-scores.txt.gz`) and covariate files (`DATASET-covariates.csv`) for all discovery cohorts.
- Add a `cohort` column identifying the source dataset for each sample.
- The `source` field distinguishes two recruitment sources **within the onco cohort only**. For samples from other cohorts, assign a consistent placeholder value so the column is present but non-informative. Before including `source` in any model, check that it has variance within the analysis subset (see Step 3).
- Merge all discovery cohorts into a single pooled dataframe.

### Step 2 — Subset by Glioma Subtype

For each entry in `SUBTYPES`:
- Filter the pooled discovery data to the matching samples.
- Check minimum sample and event thresholds (`MIN_SAMPLES_PER_SUBTYPE`, `MIN_EVENTS_PER_SUBTYPE`); skip and log a warning if not met.
- Note: **tcga** has approximately 20 samples in `hgg_idh_mutant_pq_intact` and **i370** has approximately 9 in `lgg_idh_mutant_pq_codel`. The thresholds above should handle these gracefully.

### Step 3 — Covariate Variance Check

Before any model fit, check every covariate in `COVARIATES` for variance within the current analysis subset:
- Drop any covariate with zero variance (or near-zero variance for continuous variables).
- Print a warning identifying which covariates were dropped and why.
- This check must run independently per subtype and per cohort where relevant.

### Step 4 — Univariate Pre-filtering (Pooled)

Fit a univariate Cox PH model for each PGS model in the pooled discovery data (for the current subtype), adjusting for `cohort` and any surviving covariates from Step 3.

Pre-filter candidates by:
1. Nominal p-value < `META_P_THRESHOLD`
2. If `REQUIRE_CONSISTENT_DIR` is True: consistent direction of effect (sign of log HR) across all cohorts in which the model was tested
3. Tested in at least 2 of the 3 discovery cohorts (i.e., non-missing results in ≥ 2 cohorts)

To assess direction consistency across cohorts, fit per-cohort univariate Cox models in addition to the pooled model. These per-cohort results are used only for the direction-consistency filter, not for meta-analysis (since all discovery data is pooled).

### Step 5 — Events-Per-Variable Cap

Apply the EPV rule to cap the number of LASSO predictors:
- `max_predictors = n_events / EPV_RATIO`
- If the number of pre-filtered candidates exceeds `max_predictors`, retain the top candidates ranked by pooled univariate p-value.
- Print the number of candidates before and after capping.

### Step 6 — LASSO Cox PH Model (Pooled Discovery)

Fit a penalized Cox PH model using the pre-filtered PGS candidates plus covariates:
- Use **differential penalization**: covariates (including `cohort`) are **unpenalized**; PGS predictors are **penalized** (LASSO, L1).
- Tune the regularization parameter lambda via **10-fold cross-validation** within the pooled discovery data.
- Select lambda that minimizes cross-validated partial likelihood deviance (or equivalently maximizes cross-validated concordance).
- Use parallelization (`N_JOBS`) wherever possible.
- Use an appropriate Python library (e.g., `lifelines`, `scikit-survival`, or `glmnet`-style implementations).

### Step 7 — Validation on CIDR

Apply the final LASSO model to the CIDR cohort for each subtype:
- Load CIDR z-scores and covariates; subset to matching subtype.
- Apply the same covariate variance checks.
- Generate a composite PRS risk score (linear predictor from the LASSO model) for each CIDR sample.
- Split CIDR samples into risk tertiles (or quartiles if n is sufficient) based on the linear predictor.
- Report model fit.

---

## Outputs and Reporting

For each subtype, generate:

1. **Kaplan-Meier curves** stratified by risk group (tertile/quartile) in the CIDR validation cohort, with log-rank p-value annotated.
2. **C-index** (concordance index) with 95% confidence interval in the CIDR validation cohort. Also report training-set C-index for comparison.
3. **Forest plot** of the PGS predictors retained in the final LASSO model (non-zero coefficients), showing log HR and 95% CI.
4. **Summary table** of subtype-specific PGS predictors in the final model, including: PGS ID, coefficient (log HR), HR, 95% CI, and univariate pre-filter p-value.
5. **Lambda selection plot** from cross-validation (log lambda vs. CV deviance).

All figures should be saved to `OUTPUT_DIR/{subtype}/` as high-resolution PNG or PDF files. Tables should be saved as CSV files.

---

## SLURM HPC Execution

Provide both:
- A **single large job script** that runs all subtypes in parallel using Python multiprocessing/joblib, targeting a **64-CPU, 490GB RAM node**.
- An **array job script** as an alternative, with one array task per subtype.

Both scripts should:
- Load required modules (Python, etc.)
- Activate the appropriate virtual environment
- Accept command-line parameters for input data directory, output directory, and optionally a subset of models (for testing)
- Include a `--debug` flag that passes through to all Python scripts to enable verbose output
- Print stdout and stderr to per-job log files

---

## Model Subsetting for Development and Testing

- Include a `--n-models N` argument (or equivalent in `config.py`) that randomly samples N PGS models for a fast test run. Default for development: **100 models**. Full run: all available models.
- Include a `--test` flag that runs a smoke test on a small synthetic or subsampled dataset to verify the pipeline end-to-end before committing to a full run. The smoke test should complete in under 5 minutes and print PASS/FAIL clearly.
- Provide explicit instructions for how to run the smoke test before launching the full analysis.

---

## Installation and Setup

Provide a complete list of required Python packages with recommended installation commands (e.g., `pip install ...` ). Note any version constraints.

---

## Additional Notes

- All file I/O must handle gzip compression transparently (`.txt.gz` files).
- Print informative output at each major step. If an exception is raised, print the full traceback and a human-readable explanation of what failed.
- Use the `--debug` flag to trigger additional verbose output throughout.
- Validate that `survdays` is positive and `vstatus` is binary before fitting any model; print a warning and drop invalid rows.
- The pipeline should be **reproducible**: set and expose a random seed in `config.py`.

---

## New restrictions

- DO NOT USE conda


"""


# Create a task
task_data = TaskRequest(
    name=JobNames.ANALYSIS,
    query=query,
    runtime_config=RuntimeConfig(
        environment_config={
            "language": "PYTHON",
            "data_storage_uris": [
                f"data_entry:{directory_upload_response.data_storage.id}"
            ],
        },
    ),
)
trajectory_id = client.create_task(task_data)
print(
    f"Task running on platform, you can view progress live at:https://platform.edisonscientific.com/trajectories/{trajectory_id}"
)


"""

mkdir edison_prs_lasso_survival_analysis
for d in cidr i370 onco tcga ; do
cp edison_prs_survival_analysis/${d}-covariates.csv edison_prs_lasso_survival_analysis/
cp edison_prs_survival_analysis/${d}.scores.info edison_prs_lasso_survival_analysis/
cp edison_prs_survival_analysis/${d}.scores.z-scores.txt.gz edison_prs_lasso_survival_analysis/
done




"Z-scored PRS files and covariates merged via IID suffix matching (after first underscore)."

So, likely because the covariates and scores were sorted differently and the covariates don't include all of the samples scored, Edison determined that the IID and sample needed to be split on the first undescore in order to merge. This is incorrect. I pointed it out. He confirmed it.

The scores `sample` should match the covariates `IID`. There are scores for samples that do not have an IID in the covariates files.

Edison provided virtualy no instructions at all and no required python package list.

A bit disappointing.

Also, rather than run a small testing subset for development, it actually ran all models and all 4 subtypes.

Neither good, nor bad, just unexpected given the prompt.

"""

