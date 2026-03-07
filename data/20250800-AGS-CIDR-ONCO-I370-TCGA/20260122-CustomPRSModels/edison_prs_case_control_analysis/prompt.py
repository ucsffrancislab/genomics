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
    	name="Directory containing the data",
    	file_path="./upload",  # ADD DATASET FOLDER PATH HERE
    	description="This is a directory that will be be analysed by Edison Analysis",
    	as_collection=True,
	)
	print("Finished Uploading", flush=True)
	return response

directory_upload_response = asyncio.run(upload())

#	Claude created prompt

query = """

# PGS Case/Control Logistic Regression Meta-Analysis Pipeline

## Project Context

We are running a glioma polygenic score (PGS) analysis across multiple cohorts. For each of ~5,000 PGS Catalog models, we previously computed z-scored PGS values for every sample. We now need a **case/control logistic regression meta-analysis pipeline** that mirrors the architecture of our existing LASSO Cox PH survival pipeline: per-cohort analysis → result aggregation → random-effects meta-analysis → visualization.

This pipeline must be production-ready, SLURM-compatible, modular, parameterized via a config file, and include verbose progress logging and a `--test` mode that limits to a small number of models for rapid validation before full runs.

---

## Data Layout

All cohort data lives under a base directory (configurable). Each cohort has:

```
data/{cohort}/
    pgs_scores_zscored.csv   # rows=samples, cols=PGS model IDs (first col = sample_id)
    covariates.csv           # rows=samples; cols include sample_id, case, age, sex,
                             # PC1..PC8, and optionally: source, grade, treated, idh, pq
```

**Cohort constraints — critical:**
- `onco`: cases + controls → INCLUDE; has two recruitment sources, include `source` as covariate
- `i370`: cases + controls → INCLUDE
- `tcga`: cases + controls → INCLUDE; has two sample sources (TCGA and WTCCC), include `source` as covariate

**Exclude column — applies to ALL cohorts:**
- Every covariates file contains an `exclude` column (0 = include, 1 = exclude)
- Filter to `exclude == 0` as the very first step before any analysis; never use samples with `exclude == 1`
- This is the mechanism used to remove tumor-derived samples from TCGA and any other QC exclusions

**Additional covariate notes:**
- Controls do NOT have tumor fields (grade, idh, pq, treated). Do NOT include these as covariates in logistic regression.
- Covariates may differ between cohorts. Drop any covariate that is missing >20% or has zero variance within a given cohort+model fit.

---

## Pipeline Architecture

Build the following modular files:

### `config.py`
Central configuration. Must include:
- `BASE_DIR`, `OUTPUT_DIR` as Path objects (easily changed)
- `COHORTS` dict mapping cohort name → dict with `path`, `extra_covariates` list
- `BASE_COVARIATES = ['age', 'sex', 'PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8']`
- `MIN_CASES`, `MIN_CONTROLS` thresholds (default: 10 each)
- `FDR_ALPHA = 0.05`
- `TOP_N_FOREST = 20` (number of top models to generate individual forest plots for)
- `TEST_N_MODELS = 50` (number of models to use in `--test` mode)
- `VERBOSE = True`
- `LOG_LEVEL` (DEBUG / INFO / WARNING)

### `utils.py`
Shared utilities:
- `setup_logging(verbose, log_level)` — configure Python logging with timestamps; log to both console and a per-run log file in OUTPUT_DIR
- `load_cohort_data(cohort_cfg)` — load and merge PGS scores with covariates on sample_id; validate columns; log shape and missingness summary
- `drop_zero_variance_covariates(df, covariates)` — remove covariates with zero variance; log which ones were dropped
- `check_min_samples(cases_n, controls_n, min_cases, min_controls)` → bool

### `01_logistic_regression.py`

**Arguments:** `--test` (run TEST_N_MODELS only), `--verbose`, `--cohort` (optional: run a single cohort), `--n-jobs` (default: SLURM_CPUS_PER_TASK or 1)

For each eligible cohort, for each PGS model:
1. Filter to `exclude == 0` before anything else
2. Merge PGS column onto covariates by sample_id
3. Drop samples missing outcome (`case`) or PGS value
4. Drop zero-variance covariates for this cohort+model
5. Check MIN_CASES / MIN_CONTROLS — skip and log if not met
6. Fit: `case ~ PGS + age + sex + PC1..PC8 [+ source if onco or tcga]` using `statsmodels.formula.api.logit`
7. Extract: `log_or`, `se`, `z`, `pvalue`, `n_cases`, `n_controls`, `n_total`, `converged` (bool), `covariate_list` (which covariates were actually used)
8. On any exception: log warning with model ID and error message; record as failed; continue

Parallelize model loop with `joblib.Parallel(n_jobs=n_jobs)`. Log progress every 500 models (or every 10 in test mode). Log a summary at the end: N models attempted, N succeeded, N failed, N skipped (insufficient samples).

Output per cohort: `results/{cohort}_logistic_results.tsv` with all fields above plus `pgs_id`, `cohort`.

### `02_meta_analysis.R`

Called from Python as a subprocess or run independently. Uses `metafor` package.

Reads all per-cohort `_logistic_results.tsv` files. For each PGS model:
- If results from 2+ cohorts: run `rma(yi=log_or, sei=se, method="REML")` (random-effects)
- If results from only 1 cohort: pass through single-cohort estimate; flag as `single_cohort=TRUE`
- If 0 cohorts: skip

Extract per model: `pooled_log_or`, `pooled_se`, `ci_lower`, `ci_upper`, `meta_pvalue`, `i2`, `q_stat`, `q_pvalue`, `tau2`, `n_cohorts`, `single_cohort`

Apply Benjamini-Hochberg FDR correction across all models → `fdr_qvalue`.

Output: `results/meta_analysis_results.tsv`

Log to console: total models meta-analyzed, N with both cohorts, N single-cohort, N significant at FDR<0.05.

### `03_plots.R`

Called from Python or run independently. Requires `metafor`, `ggplot2`, `ggrepel`.

**Volcano plot (priority):**
- x-axis: `pooled_log_or`, y-axis: `-log10(meta_pvalue)`
- Color: red = FDR < 0.05, orange = nominal p < 0.05, gray = NS
- Label top 20 hits by p-value with ggrepel
- Save as `plots/volcano_plot.pdf` and `.png`

**Global funnel plot:**
- All models with both cohorts, using metafor `funnel()`
- Save as `plots/funnel_plot_all.pdf`

**Forest plots (top N models):**
- For each of the top TOP_N_FOREST models by meta p-value, generate one forest plot showing per-cohort estimates + pooled with 95% CI
- Save as `plots/forest_{pgs_id}.pdf`
- Also generate a single multi-model summary forest plot of just the pooled estimates for top 50 models
- Save as `plots/forest_summary_top50.pdf`

All plots: clean theme, labeled axes, title including PGS ID and OR direction. Log each plot saved.

### `04_run_pipeline.py`

Master runner that calls steps 01–03 in order, passing through `--test` and `--verbose` flags. Logs start/end time and wall-clock duration for each step. On step failure, print the stderr and exit with non-zero code.

### `run_pipeline.sh`

SLURM submission script:
```
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=4:00:00
```
Activates appropriate conda/singularity environment. Runs `04_run_pipeline.py`. Accepts `--test` as a passthrough argument so `sbatch run_pipeline.sh --test` runs test mode.

---

## Testing Instructions

After writing all files, run the full pipeline end-to-end in `--test` mode using TEST_N_MODELS=50. Use whatever small sample data you can construct or infer from the config to validate:
1. `01_logistic_regression.py --test --verbose` completes without error
2. `02_meta_analysis.R` reads those results and produces meta output
3. `03_plots.R` produces at least the volcano plot

Report any errors encountered and fix them before delivering. The goal is that the pipeline runs cleanly out of the box when pointed at real data.

---

## Deliverables

Provide all source files with clear inline comments. The pipeline should be ready to point at real cohort data by editing only `config.py`. Include a brief `README.md` describing each file, how to run in test mode, and how to run the full pipeline on SLURM.

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


