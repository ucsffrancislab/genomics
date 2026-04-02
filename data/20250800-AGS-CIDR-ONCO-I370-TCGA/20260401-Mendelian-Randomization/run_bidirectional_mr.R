#!/usr/bin/env Rscript
# =============================================================================
# Bidirectional Two-Sample Mendelian Randomization: ICVF → Glioma
# =============================================================================
# PARALLELIZED version — uses mclapply across available cores
#
# Requires: data.table, TwoSampleMR, MRPRESSO, ggplot2, dplyr, parallel
#
# Install if needed:
#   install.packages(c("data.table", "ggplot2", "dplyr", "remotes"))
#   remotes::install_github("MRCIEU/TwoSampleMR")
#   remotes::install_github("rondolab/MR-PRESSO")
#
# Usage:
#   Rscript run_bidirectional_mr.R
# =============================================================================

library(data.table)
library(TwoSampleMR)
library(MRPRESSO)
library(ggplot2)
library(dplyr)
library(parallel)

# =============================================================================
# CONFIGURATION - EDIT THESE PATHS
# =============================================================================

# --- OpenGWAS JWT Authentication ---
# Required for LD clumping via IEU server (since May 2024)
# Read token from file and set for ieugwasr
TOKEN_FILE <- "OpenGWASToken"
if (file.exists(TOKEN_FILE)) {
  token <- trimws(readLines(TOKEN_FILE, n = 1, warn = FALSE))
  Sys.setenv(OPENGWAS_JWT = token)
  ieugwasr::check_access_token()
  message("OpenGWAS JWT token loaded from: ", TOKEN_FILE)
} else {
  message("WARNING: OpenGWAS token file not found: ", TOKEN_FILE)
  message("  LD clumping via IEU server will fail.")
  message("  Either provide the token file or use local plink clumping.")
}

# Directory containing the MR-ready ICVF exposure files (from format_icvf_for_mr.R)
ICVF_DIR <- "icvf_mr_ready"

# Directory containing your glioma GWAS summary stats
GLIOMA_DIR <- "../20260326-GWAS_summary_stats/20260330a-results"

# Glioma subtypes to test (subdirectory names)
GLIOMA_SUBTYPES <- c(
  "all_glioma",
  "idhwt",
  "idhmt",
  "idhmt_intact",
  "idhmt_codel"
)

# Corresponding filenames (.tsv.gz for faster loading)
GLIOMA_FILES <- c(
  "all_glioma/final/all_glioma_meta_summary_stats.tsv.gz",
  "idhwt/final/IDHwt_meta_summary_stats.tsv.gz",
  "idhmt/final/IDHmut_meta_summary_stats.tsv.gz",
  "idhmt_intact/final/IDHmut_1p19q_intact_meta_summary_stats.tsv.gz",
  "idhmt_codel/final/IDHmut_1p19q_codel_meta_summary_stats.tsv.gz"
)

# Output directory
OUTPUT_DIR <- "mr_results"
dir.create(OUTPUT_DIR, showWarnings = FALSE)
dir.create(file.path(OUTPUT_DIR, "plots"), showWarnings = FALSE)

# --- MR Parameters ---
P_THRESHOLD     <- 5e-8   # Instrument selection threshold
P_RELAXED       <- 5e-6   # Fallback if too few instruments at 5e-8
MIN_INSTRUMENTS <- 3      # Minimum instruments needed for MR
CLUMP_R2        <- 0.001  # LD clumping r2 threshold
CLUMP_KB        <- 10000  # LD clumping window (kb)

# --- Parallelization ---
N_CORES <- min(detectCores() - 1, 60)  # Leave a couple cores free
message("Using ", N_CORES, " cores for parallel execution")

# =============================================================================
# HELPER: Run MR for one exposure-outcome pair
# =============================================================================

run_single_mr <- function(exposure_dat, outcome_dat, pgs_id, subtype, direction) {
  result <- list(
    mr = NULL, het = NULL, pleio = NULL, presso = NULL, steiger = NULL,
    pgs_id = pgs_id, subtype = subtype, direction = direction, error = NULL
  )

  # Harmonise
  harmonised <- tryCatch(
    harmonise_data(exposure_dat, outcome_dat, action = 2),
    error = function(e) NULL
  )

  if (is.null(harmonised) || sum(harmonised$mr_keep) < MIN_INSTRUMENTS) {
    n_harm <- if (!is.null(harmonised)) nrow(harmonised) else 0
    n_keep <- if (!is.null(harmonised)) sum(harmonised$mr_keep) else 0
    result$error <- paste0("Too few SNPs after harmonisation (matched: ", n_harm, ", kept: ", n_keep, ")")
    return(result)
  }

  n_snps <- sum(harmonised$mr_keep)

  # Core MR
  result$mr <- tryCatch(
    mr(harmonised, method_list = c(
      "mr_ivw", "mr_egger_regression",
      "mr_weighted_median", "mr_weighted_mode"
    )),
    error = function(e) NULL
  )

  # Heterogeneity
  result$het <- tryCatch(mr_heterogeneity(harmonised), error = function(e) NULL)

  # Pleiotropy (MR-Egger intercept)
  result$pleio <- tryCatch(mr_pleiotropy_test(harmonised), error = function(e) NULL)

  # MR-PRESSO (only if enough instruments — permutation-heavy)
  if (n_snps >= 4) {
    result$presso <- tryCatch({
      presso <- mr_presso(
        BetaOutcome = "beta.outcome",
        BetaExposure = "beta.exposure",
        SdOutcome = "se.outcome",
        SdExposure = "se.exposure",
        data = harmonised[harmonised$mr_keep, ],
        OUTLIERtest = TRUE,
        DISTORTIONtest = TRUE,
        NbDistribution = 1000,
        SignifThreshold = 0.05
      )
      data.frame(
        global_p = presso[[1]]$`MR-PRESSO results`$`Global Test`$Pvalue,
        n_outliers = sum(presso[[1]]$`MR-PRESSO results`$`Outlier Test`$Pvalue < 0.05, na.rm = TRUE),
        causal_estimate_raw = presso[[1]]$`Main MR results`$`Causal Estimate`[1],
        causal_estimate_corrected = presso[[1]]$`Main MR results`$`Causal Estimate`[2],
        distortion_p = ifelse(
          !is.null(presso[[1]]$`MR-PRESSO results`$`Distortion Test`$Pvalue),
          presso[[1]]$`MR-PRESSO results`$`Distortion Test`$Pvalue, NA
        )
      )
    }, error = function(e) NULL)
  }

  # Steiger directionality
  result$steiger <- tryCatch(directionality_test(harmonised), error = function(e) NULL)

  return(result)
}

# =============================================================================
# STEP 1: Load and format glioma outcome data
# =============================================================================

message("\n=== STEP 1: Loading glioma summary stats ===")

load_glioma <- function(filepath, subtype_name, type = "outcome") {
  dat <- fread(filepath, header = TRUE)
  dat <- as.data.frame(dat)
  dat$N <- dat$N_CASES + dat$N_CONTROLS

  # Create chr:pos SNP identifier for matching with ICVF (which uses rsIDs)
  # Both datasets have chr + pos, so chr:pos is the common key
  dat$SNP_chrpos <- paste0(dat$CHR, ":", dat$BP)

  formatted <- format_data(
    dat,
    type = type,
    snp_col = "SNP_chrpos",
    beta_col = "BETA",
    se_col = "SE",
    pval_col = "P",
    effect_allele_col = "A1",
    other_allele_col = "A2",
    eaf_col = "A1_FREQ",
    samplesize_col = "N",
    chr_col = "CHR",
    pos_col = "BP"
  )

  if (type == "outcome") {
    formatted$outcome <- subtype_name
  } else {
    formatted$exposure <- subtype_name
  }
  return(formatted)
}

# Pre-load all glioma outcomes (sequential — shared data)
glioma_outcomes <- list()
for (i in seq_along(GLIOMA_SUBTYPES)) {
  fpath <- file.path(GLIOMA_DIR, GLIOMA_FILES[i])
  if (!file.exists(fpath)) {
    message("  WARNING: File not found: ", fpath)
    next
  }
  message("  Loading: ", GLIOMA_SUBTYPES[i])
  glioma_outcomes[[GLIOMA_SUBTYPES[i]]] <- load_glioma(fpath, GLIOMA_SUBTYPES[i], "outcome")
}
message("  Loaded ", length(glioma_outcomes), " glioma subtypes\n")

# =============================================================================
# STEP 2: Forward MR — ICVF (exposure) → Glioma (outcome) [PARALLEL]
# =============================================================================

message("=== STEP 2: Forward MR — ICVF → Glioma (parallel) ===\n")

# Find all ICVF instrument files
instrument_files <- list.files(ICVF_DIR, pattern = "_instruments_", full.names = TRUE)
message("  Found ", length(instrument_files), " ICVF instrument files")

# Build task list: all (instrument_file, subtype) combinations
forward_tasks <- expand.grid(
  inst_file = instrument_files,
  subtype = names(glioma_outcomes),
  stringsAsFactors = FALSE
)
message("  Forward tasks to run: ", nrow(forward_tasks), "\n")

# LD-clump each instrument set FIRST (sequential — hits the API)
message("  LD-clumping ICVF instruments...")
clumped_exposures <- list()
for (inst_file in instrument_files) {
  fname <- basename(inst_file)
  pgs_id <- sub("_instruments.*", "", fname)

  exposure_dat <- fread(inst_file, header = TRUE)
  exposure_dat <- as.data.frame(exposure_dat)

  if (nrow(exposure_dat) < MIN_INSTRUMENTS) {
    message("    ", pgs_id, ": skipping (", nrow(exposure_dat), " instruments)")
    next
  }

  clumped <- tryCatch({
    clump_data(exposure_dat, clump_r2 = CLUMP_R2, clump_kb = CLUMP_KB)
  }, error = function(e) {
    message("    ", pgs_id, ": clumping failed (", e$message, ") — using unclumped")
    exposure_dat
  })

  if (nrow(clumped) >= MIN_INSTRUMENTS) {
    # Convert rsID → chr:pos AFTER clumping (API needs rsIDs for clumping)
    if ("chr.exposure" %in% names(clumped) & "pos.exposure" %in% names(clumped)) {
      clumped$SNP <- paste0(clumped$chr.exposure, ":", clumped$pos.exposure)
    }
    clumped_exposures[[inst_file]] <- clumped
    message("    ", pgs_id, ": ", nrow(clumped), " instruments after clumping")
  } else {
    message("    ", pgs_id, ": too few after clumping (", nrow(clumped), ")")
  }
}

# Filter tasks to only those with valid clumped exposures
forward_tasks <- forward_tasks[forward_tasks$inst_file %in% names(clumped_exposures), ]
message("\n  Running ", nrow(forward_tasks), " forward MR tests in parallel...\n")

# Run forward MR in parallel
forward_raw <- if (nrow(forward_tasks) > 0) mclapply(seq_len(nrow(forward_tasks)), function(idx) {
  inst_file <- forward_tasks$inst_file[idx]
  subtype   <- forward_tasks$subtype[idx]
  pgs_id    <- sub("_instruments.*", "", basename(inst_file))

  run_single_mr(
    exposure_dat = clumped_exposures[[inst_file]],
    outcome_dat  = glioma_outcomes[[subtype]],
    pgs_id       = pgs_id,
    subtype      = subtype,
    direction    = "forward"
  )
}, mc.cores = N_CORES) else list()

message("  Forward MR complete.\n")

# =============================================================================
# STEP 3: Reverse MR — Glioma (exposure) → ICVF (outcome) [PARALLEL]
# =============================================================================

message("=== STEP 3: Reverse MR — Glioma → ICVF (parallel) ===\n")

# Load glioma as exposure + clump instruments (sequential — API calls)
message("  Preparing glioma exposure instruments...")
glioma_exposures_clumped <- list()
for (i in seq_along(GLIOMA_SUBTYPES)) {
  subtype <- GLIOMA_SUBTYPES[i]
  if (!subtype %in% names(glioma_outcomes)) next

  fpath <- file.path(GLIOMA_DIR, GLIOMA_FILES[i])
  message("    ", subtype, ": formatting as exposure...")

  glioma_exp <- load_glioma(fpath, subtype, "exposure")

  # Select instruments
  n_total <- nrow(glioma_exp)
  instruments <- glioma_exp[glioma_exp$pval.exposure < P_THRESHOLD, ]
  message("      Total SNPs: ", n_total, ", at p<5e-8: ", nrow(instruments))
  if (nrow(instruments) < MIN_INSTRUMENTS) {
    message("      Only ", nrow(instruments), " at p<5e-8, trying p<5e-6")
    instruments <- glioma_exp[glioma_exp$pval.exposure < P_RELAXED, ]
    message("      At p<5e-6: ", nrow(instruments))
  }

  if (nrow(instruments) < MIN_INSTRUMENTS) {
    message("      Skipping: too few instruments (", nrow(instruments), ")")
    next
  }

  # LD clump
  clumped <- tryCatch({
    clump_data(instruments, clump_r2 = CLUMP_R2, clump_kb = CLUMP_KB)
  }, error = function(e) {
    message("      Clumping failed — using unclumped")
    instruments
  })

  if (nrow(clumped) >= MIN_INSTRUMENTS) {
    glioma_exposures_clumped[[subtype]] <- clumped
    message("      ", nrow(clumped), " instruments after clumping")
  }
}

# Load ICVF full files as outcomes
icvf_full_files <- list.files(ICVF_DIR, pattern = "_mr_ready\\.tsv\\.gz$", full.names = TRUE)
message("\n  Loading ", length(icvf_full_files), " ICVF outcome files...")

icvf_outcomes <- list()
for (icvf_file in icvf_full_files) {
  pgs_id <- sub("_.*", "", basename(icvf_file))
  trait <- sub("_mr_ready\\.tsv\\.gz$", "", basename(icvf_file))
  trait <- sub("^PGS\\d+_", "", trait)

  icvf_dat <- fread(icvf_file, header = TRUE)
  icvf_dat <- as.data.frame(icvf_dat)

  icvf_out <- format_data(
    icvf_dat,
    type = "outcome",
    snp_col = "SNP",
    beta_col = "beta.exposure",
    se_col = "se.exposure",
    pval_col = "pval.exposure",
    effect_allele_col = "effect_allele.exposure",
    other_allele_col = "other_allele.exposure",
    samplesize_col = "samplesize.exposure",
    chr_col = "chr.exposure",
    pos_col = "pos.exposure"
  )
  icvf_out$outcome <- paste0(pgs_id, "_", trait)
  icvf_outcomes[[icvf_file]] <- icvf_out
  message("    Loaded: ", pgs_id, " ", trait)
}

# Build reverse task list
reverse_tasks <- expand.grid(
  subtype = names(glioma_exposures_clumped),
  icvf_file = names(icvf_outcomes),
  stringsAsFactors = FALSE
)
if (length(glioma_exposures_clumped) == 0) {
  message("\n  WARNING: No glioma subtypes had enough instruments for reverse MR.")
  message("  This likely means no glioma SNPs reached genome-wide significance (p<5e-8)")
  message("  or the relaxed threshold (p<5e-6). This is common for smaller GWAS or subtypes.")
  message("  Reverse MR will be skipped.\n")
} else {
  message("  Glioma subtypes with instruments: ", paste(names(glioma_exposures_clumped), collapse = ", "))
}

message("\n  Running ", nrow(reverse_tasks), " reverse MR tests in parallel...\n")

# Run reverse MR in parallel
reverse_raw <- if (nrow(reverse_tasks) > 0) mclapply(seq_len(nrow(reverse_tasks)), function(idx) {
  subtype   <- reverse_tasks$subtype[idx]
  icvf_file <- reverse_tasks$icvf_file[idx]
  pgs_id    <- sub("_.*", "", basename(icvf_file))

  run_single_mr(
    exposure_dat = glioma_exposures_clumped[[subtype]],
    outcome_dat  = icvf_outcomes[[icvf_file]],
    pgs_id       = pgs_id,
    subtype      = subtype,
    direction    = "reverse"
  )
}, mc.cores = N_CORES) else list()

message("  Reverse MR complete.\n")

# =============================================================================
# STEP 4: Collect and save results
# =============================================================================

message("=== STEP 4: Saving results ===\n")

collect_results <- function(raw_list, direction_label) {
  mr_list     <- list()
  het_list    <- list()
  pleio_list  <- list()
  presso_list <- list()
  steiger_list <- list()

  for (res in raw_list) {
    if (is.null(res) || !is.list(res)) next
    if (!is.null(res$error)) { message("    Skipped: ", res$error); next }

    pgs_id  <- res$pgs_id
    subtype <- res$subtype

    if (!is.null(res$mr)) {
      tmp <- res$mr
      tmp$pgs_id <- pgs_id; tmp$subtype <- subtype; tmp$direction <- direction_label
      mr_list <- c(mr_list, list(tmp))
    }
    if (!is.null(res$het)) {
      tmp <- res$het
      tmp$pgs_id <- pgs_id; tmp$subtype <- subtype
      het_list <- c(het_list, list(tmp))
    }
    if (!is.null(res$pleio)) {
      tmp <- res$pleio
      tmp$pgs_id <- pgs_id; tmp$subtype <- subtype
      pleio_list <- c(pleio_list, list(tmp))
    }
    if (!is.null(res$presso)) {
      tmp <- res$presso
      tmp$pgs_id <- pgs_id; tmp$subtype <- subtype
      presso_list <- c(presso_list, list(tmp))
    }
    if (!is.null(res$steiger)) {
      tmp <- res$steiger
      tmp$pgs_id <- pgs_id; tmp$subtype <- subtype
      steiger_list <- c(steiger_list, list(tmp))
    }
  }

  list(
    mr     = if (length(mr_list) > 0) bind_rows(mr_list) else NULL,
    het    = if (length(het_list) > 0) bind_rows(het_list) else NULL,
    pleio  = if (length(pleio_list) > 0) bind_rows(pleio_list) else NULL,
    presso = if (length(presso_list) > 0) bind_rows(presso_list) else NULL,
    steiger = if (length(steiger_list) > 0) bind_rows(steiger_list) else NULL
  )
}

# Collect forward results
fwd <- collect_results(forward_raw, "forward_ICVF_to_glioma")
if (!is.null(fwd$mr))      fwrite(fwd$mr,      file.path(OUTPUT_DIR, "forward_mr_results.tsv"), sep = "\t")
if (!is.null(fwd$het))     fwrite(fwd$het,     file.path(OUTPUT_DIR, "forward_heterogeneity.tsv"), sep = "\t")
if (!is.null(fwd$pleio))   fwrite(fwd$pleio,   file.path(OUTPUT_DIR, "forward_pleiotropy.tsv"), sep = "\t")
if (!is.null(fwd$presso))  fwrite(fwd$presso,  file.path(OUTPUT_DIR, "forward_mrpresso.tsv"), sep = "\t")
if (!is.null(fwd$steiger)) fwrite(fwd$steiger, file.path(OUTPUT_DIR, "forward_steiger.tsv"), sep = "\t")

# Collect reverse results
rev <- collect_results(reverse_raw, "reverse_glioma_to_ICVF")
if (!is.null(rev$mr))    fwrite(rev$mr,    file.path(OUTPUT_DIR, "reverse_mr_results.tsv"), sep = "\t")
if (!is.null(rev$het))   fwrite(rev$het,   file.path(OUTPUT_DIR, "reverse_heterogeneity.tsv"), sep = "\t")
if (!is.null(rev$pleio)) fwrite(rev$pleio, file.path(OUTPUT_DIR, "reverse_pleiotropy.tsv"), sep = "\t")

# Combined
if (!is.null(fwd$mr) && !is.null(rev$mr)) {
  combined <- bind_rows(fwd$mr, rev$mr)
  fwrite(combined, file.path(OUTPUT_DIR, "combined_mr_results.tsv"), sep = "\t")
  message("  Combined MR results: ", nrow(combined), " rows")
}

# =============================================================================
# STEP 5: Summary plots
# =============================================================================

message("\n=== STEP 5: Generating plots ===\n")

# --- Forward MR forest plot (IVW) ---
if (!is.null(fwd$mr)) {
  ivw_fwd <- fwd$mr %>% filter(method == "Inverse variance weighted")

  if (nrow(ivw_fwd) > 0) {
    ivw_fwd$label <- paste0(ivw_fwd$pgs_id, " -> ", ivw_fwd$subtype)
    ivw_fwd$or    <- exp(ivw_fwd$b)
    ivw_fwd$or_lo <- exp(ivw_fwd$b - 1.96 * ivw_fwd$se)
    ivw_fwd$or_hi <- exp(ivw_fwd$b + 1.96 * ivw_fwd$se)

    p <- ggplot(ivw_fwd, aes(x = or, y = reorder(label, or), color = subtype)) +
      geom_point(size = 2) +
      geom_errorbarh(aes(xmin = or_lo, xmax = or_hi), height = 0.2) +
      geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") +
      scale_x_log10() +
      labs(
        title = "Forward MR: ICVF -> Glioma (IVW)",
        subtitle = "Odds ratio per SD increase in ICVF",
        x = "OR (95% CI)", y = NULL, color = "Glioma subtype"
      ) +
      theme_minimal(base_size = 11) +
      theme(legend.position = "bottom")

    ggsave(file.path(OUTPUT_DIR, "plots", "forward_mr_forest.pdf"),
           plot = p, width = 12, height = max(6, nrow(ivw_fwd) * 0.3 + 2))
    message("  Saved: forward_mr_forest.pdf")
  }
}

# --- Reverse MR forest plot ---
if (!is.null(rev$mr)) {
  ivw_rev <- rev$mr %>% filter(method == "Inverse variance weighted")

  if (nrow(ivw_rev) > 0) {
    ivw_rev$label <- paste0(ivw_rev$subtype, " -> ", ivw_rev$outcome)
    ivw_rev$beta_lo <- ivw_rev$b - 1.96 * ivw_rev$se
    ivw_rev$beta_hi <- ivw_rev$b + 1.96 * ivw_rev$se

    p2 <- ggplot(ivw_rev, aes(x = b, y = reorder(label, b), color = subtype)) +
      geom_point(size = 2) +
      geom_errorbarh(aes(xmin = beta_lo, xmax = beta_hi), height = 0.2) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        title = "Reverse MR: Glioma -> ICVF (IVW)",
        subtitle = "Effect of genetic liability to glioma on ICVF (SD units)",
        x = "Beta (95% CI)", y = NULL, color = "Glioma subtype"
      ) +
      theme_minimal(base_size = 11) +
      theme(legend.position = "bottom")

    ggsave(file.path(OUTPUT_DIR, "plots", "reverse_mr_forest.pdf"),
           plot = p2, width = 12, height = max(6, nrow(ivw_rev) * 0.3 + 2))
    message("  Saved: reverse_mr_forest.pdf")
  }
}

# =============================================================================
# STEP 6: Print summary
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("MR ANALYSIS COMPLETE")
message(paste(rep("=", 70), collapse = ""))

if (!is.null(fwd$mr)) {
  message("\n--- Forward MR (ICVF -> Glioma): Significant IVW results ---")
  sig_fwd <- fwd$mr %>% filter(method == "Inverse variance weighted", pval < 0.05)
  if (nrow(sig_fwd) > 0) {
    for (r in 1:nrow(sig_fwd)) {
      message(sprintf("  %s -> %s: b=%.4f, se=%.4f, p=%.2e, OR=%.3f",
                      sig_fwd$pgs_id[r], sig_fwd$subtype[r],
                      sig_fwd$b[r], sig_fwd$se[r], sig_fwd$pval[r], exp(sig_fwd$b[r])))
    }
  } else {
    message("  No nominally significant results")
  }
}

if (!is.null(rev$mr)) {
  message("\n--- Reverse MR (Glioma -> ICVF): Significant IVW results ---")
  sig_rev <- rev$mr %>% filter(method == "Inverse variance weighted", pval < 0.05)
  if (nrow(sig_rev) > 0) {
    for (r in 1:nrow(sig_rev)) {
      message(sprintf("  %s -> %s: b=%.4f, se=%.4f, p=%.2e",
                      sig_rev$subtype[r], sig_rev$outcome[r],
                      sig_rev$b[r], sig_rev$se[r], sig_rev$pval[r]))
    }
  } else {
    message("  No nominally significant results")
  }
}

message("\n--- Output files actually created ---")
output_files <- list.files(OUTPUT_DIR, recursive = TRUE, full.names = TRUE)
if (length(output_files) > 0) {
  for (f in output_files) message("  ", f)
} else {
  message("  (none)")
}

message("\n--- Next steps ---")
message("  1. Review IVW results - look for consistent direction across methods")
message("  2. Check MR-Egger intercept p-values for evidence of pleiotropy")
message("  3. Check heterogeneity (Cochran Q) - high Q suggests invalid instruments")
message("  4. MR-PRESSO global test - significant = outlier instruments present")
message("  5. Steiger test - confirms the causal direction is correct")
message("  6. Consider excluding HLA region instruments (chr6:25-34Mb)")
message("     HLA has extreme LD and strong glioma associations that may violate")
message("     MR assumptions. Re-run after filtering for robustness.")
message("  7. Apply Bonferroni correction for multiple testing:")
message("     18 tracts x 5 subtypes = 90 forward tests -> p < 5.6e-4")
