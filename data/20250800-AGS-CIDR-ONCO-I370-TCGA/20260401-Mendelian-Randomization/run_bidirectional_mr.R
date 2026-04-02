#!/usr/bin/env Rscript
# =============================================================================
# Bidirectional Two-Sample Mendelian Randomization: ICVF → Glioma
# =============================================================================
# Requires: data.table, TwoSampleMR, MR-PRESSO (MRPRESSO), ggplot2, dplyr
#
# Install if needed:
#   install.packages(c("data.table", "ggplot2", "dplyr", "remotes", "forestplot"))
#   remotes::install_github("MRCIEU/TwoSampleMR")
#   remotes::install_github("rondolab/MR-PRESSO")
# =============================================================================

library(data.table)
library(TwoSampleMR)
library(MRPRESSO)
library(ggplot2)
library(dplyr)

# =============================================================================
# CONFIGURATION - EDIT THESE PATHS
# =============================================================================

# Directory containing the MR-ready ICVF exposure files (from format_icvf_for_mr.R)
ICVF_DIR <- "icvf_mr_ready"

# Directory containing your glioma GWAS summary stats
GLIOMA_DIR <- "../20260326-GWAS_summary_stats/20260330a-results"

# Glioma subtypes to test (subdirectory names)
GLIOMA_SUBTYPES <- c(
  "all_glioma",
  "idh_wildtype",
  "idh_mutant",
  "idh_mutant_intact",
  "idh_mutant_codel"
)

# Corresponding filenames (adjust if different)
GLIOMA_FILES <- c(
  "all_glioma/final/all_glioma_meta_summary_stats.tsv",
  "idh_wildtype/final/idh_wildtype_meta_summary_stats.tsv",
  "idh_mutant/final/idh_mutant_meta_summary_stats.tsv",
  "idh_mutant_intact/final/idh_mutant_intact_meta_summary_stats.tsv",
  "idh_mutant_codel/final/idh_mutant_codel_meta_summary_stats.tsv"
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

# =============================================================================
# STEP 1: Load and format glioma outcome data
# =============================================================================

message("=== STEP 1: Loading glioma summary stats ===")

load_glioma_outcome <- function(filepath, subtype_name) {
  message("  Loading: ", subtype_name)
  dat <- fread(filepath, header = TRUE)

  # Your glioma files have columns:
  # CHR, BP, SNP, A1, A2, A1_FREQ, BETA, SE, P, OR, OR_95L, OR_95U,
  # N_STUDIES, DIRECTION, HET_P, HET_ISQ, HET_Q, N_CASES, N_CONTROLS

  dat <- as.data.frame(dat)

  # Compute total sample size per SNP
  dat$N <- dat$N_CASES + dat$N_CONTROLS

  outcome <- format_data(
    dat,
    type = "outcome",
    snp_col = "SNP",
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
  outcome$outcome <- subtype_name
  return(outcome)
}

# Pre-load all glioma outcomes
glioma_outcomes <- list()
for (i in seq_along(GLIOMA_SUBTYPES)) {
  fpath <- file.path(GLIOMA_DIR, GLIOMA_FILES[i])
  if (!file.exists(fpath)) {
    message("  WARNING: File not found: ", fpath)
    next
  }
  glioma_outcomes[[GLIOMA_SUBTYPES[i]]] <- load_glioma_outcome(fpath, GLIOMA_SUBTYPES[i])
}
message("  Loaded ", length(glioma_outcomes), " glioma subtypes\n")

# =============================================================================
# STEP 2: Forward MR — ICVF (exposure) → Glioma (outcome)
# =============================================================================

message("=== STEP 2: Forward MR — ICVF → Glioma ===\n")

# Find all ICVF instrument files
instrument_files <- list.files(ICVF_DIR, pattern = "_instruments_", full.names = TRUE)
message("  Found ", length(instrument_files), " ICVF instrument files\n")

# Collect all forward MR results
forward_results    <- list()
forward_het        <- list()
forward_pleio      <- list()
forward_presso     <- list()
forward_steiger    <- list()

for (inst_file in instrument_files) {
  # Parse PGS ID and trait from filename
  fname <- basename(inst_file)
  pgs_id <- sub("_instruments.*", "", fname)
  threshold <- ifelse(grepl("5e8", fname), "5e-8", "5e-6")

  message("--- Exposure: ", pgs_id, " (threshold: ", threshold, ") ---")

  # Load exposure instruments
  exposure_dat <- fread(inst_file, header = TRUE)
  exposure_dat <- as.data.frame(exposure_dat)

  if (nrow(exposure_dat) < MIN_INSTRUMENTS) {
    message("  Skipping: only ", nrow(exposure_dat), " instruments (need >= ", MIN_INSTRUMENTS, ")")
    next
  }

  # LD clump instruments
  # NOTE: This uses the IEU server for LD reference. If you have local plink + 1000G:
  #   exposure_clumped <- ld_clump_local(exposure_dat, clump_r2 = CLUMP_R2,
  #                                       clump_kb = CLUMP_KB,
  #                                       plink_bin = "/path/to/plink",
  #                                       bfile = "/path/to/1000G_EUR")
  tryCatch({
    exposure_clumped <- clump_data(exposure_dat, clump_r2 = CLUMP_R2, clump_kb = CLUMP_KB)
  }, error = function(e) {
    message("  WARNING: LD clumping failed (", e$message, ")")
    message("  Using unclumped instruments — consider local clumping with plink")
    exposure_clumped <<- exposure_dat
  })

  message("  Instruments after clumping: ", nrow(exposure_clumped))

  if (nrow(exposure_clumped) < MIN_INSTRUMENTS) {
    message("  Skipping: too few instruments after clumping")
    next
  }

  # Test against each glioma subtype
  for (subtype in names(glioma_outcomes)) {
    message("  vs. ", subtype)

    outcome_dat <- glioma_outcomes[[subtype]]

    # Harmonise
    harmonised <- tryCatch(
      harmonise_data(exposure_clumped, outcome_dat, action = 2),
      error = function(e) { message("    Harmonisation failed: ", e$message); NULL }
    )

    if (is.null(harmonised) || nrow(harmonised) < MIN_INSTRUMENTS) {
      message("    Skipping: too few SNPs after harmonisation")
      next
    }

    message("    Harmonised SNPs: ", nrow(harmonised[harmonised$mr_keep, ]))

    # --- Core MR ---
    mr_res <- mr(harmonised, method_list = c(
      "mr_ivw",
      "mr_egger_regression",
      "mr_weighted_median",
      "mr_weighted_mode"
    ))
    mr_res$subtype <- subtype
    mr_res$pgs_id  <- pgs_id
    forward_results <- c(forward_results, list(mr_res))

    # --- Heterogeneity ---
    het <- mr_heterogeneity(harmonised)
    het$subtype <- subtype
    het$pgs_id  <- pgs_id
    forward_het <- c(forward_het, list(het))

    # --- Pleiotropy (MR-Egger intercept) ---
    pleio <- mr_pleiotropy_test(harmonised)
    pleio$subtype <- subtype
    pleio$pgs_id  <- pgs_id
    forward_pleio <- c(forward_pleio, list(pleio))

    # --- MR-PRESSO (outlier detection) ---
    tryCatch({
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
      presso_summary <- data.frame(
        pgs_id = pgs_id,
        subtype = subtype,
        global_p = presso[[1]]$`MR-PRESSO results`$`Global Test`$Pvalue,
        n_outliers = sum(presso[[1]]$`MR-PRESSO results`$`Outlier Test`$Pvalue < 0.05, na.rm = TRUE),
        causal_estimate_raw = presso[[1]]$`Main MR results`$`Causal Estimate`[1],
        causal_estimate_corrected = presso[[1]]$`Main MR results`$`Causal Estimate`[2],
        distortion_p = ifelse(!is.null(presso[[1]]$`MR-PRESSO results`$`Distortion Test`$Pvalue),
                              presso[[1]]$`MR-PRESSO results`$`Distortion Test`$Pvalue, NA)
      )
      forward_presso <- c(forward_presso, list(presso_summary))
    }, error = function(e) {
      message("    MR-PRESSO failed: ", e$message)
    })

    # --- Steiger directionality test ---
    tryCatch({
      steiger <- directionality_test(harmonised)
      steiger$subtype <- subtype
      steiger$pgs_id  <- pgs_id
      forward_steiger <- c(forward_steiger, list(steiger))
    }, error = function(e) {
      message("    Steiger test failed: ", e$message)
    })
  }
}

# =============================================================================
# STEP 3: Reverse MR — Glioma (exposure) → ICVF (outcome)
# =============================================================================

message("\n=== STEP 3: Reverse MR — Glioma → ICVF ===\n")

# Load all ICVF full files as outcomes
icvf_full_files <- list.files(ICVF_DIR, pattern = "_mr_ready\\.tsv\\.gz$", full.names = TRUE)

reverse_results <- list()
reverse_het     <- list()
reverse_pleio   <- list()

for (subtype in names(glioma_outcomes)) {
  message("--- Exposure: ", subtype, " ---")

  # Load glioma as EXPOSURE
  fpath <- file.path(GLIOMA_DIR, GLIOMA_FILES[match(subtype, GLIOMA_SUBTYPES)])
  glioma_raw <- fread(fpath, header = TRUE)
  glioma_raw <- as.data.frame(glioma_raw)
  glioma_raw$N <- glioma_raw$N_CASES + glioma_raw$N_CONTROLS

  glioma_exposure <- format_data(
    glioma_raw,
    type = "exposure",
    snp_col = "SNP",
    beta_col = "BETA",
    se_col = "SE",
    pval_col = "P",
    effect_allele_col = "A1",
    other_allele_col = "A2",
    eaf_col = "A1_FREQ",
    samplesize_col = "N",
    chr_col = "CHR",
    pos_col = "BP",
    phenotype_col = NULL
  )
  glioma_exposure$exposure <- subtype

  # Select genome-wide significant glioma instruments
  glioma_instruments <- glioma_exposure[glioma_exposure$pval.exposure < P_THRESHOLD, ]
  if (nrow(glioma_instruments) < MIN_INSTRUMENTS) {
    message("  Only ", nrow(glioma_instruments), " instruments at p<5e-8, trying p<5e-6")
    glioma_instruments <- glioma_exposure[glioma_exposure$pval.exposure < P_RELAXED, ]
  }

  if (nrow(glioma_instruments) < MIN_INSTRUMENTS) {
    message("  Skipping ", subtype, ": too few instruments (", nrow(glioma_instruments), ")")
    next
  }

  # LD clump
  tryCatch({
    glioma_instruments <- clump_data(glioma_instruments, clump_r2 = CLUMP_R2, clump_kb = CLUMP_KB)
  }, error = function(e) {
    message("  WARNING: LD clumping failed — using unclumped")
  })

  message("  Glioma instruments: ", nrow(glioma_instruments))

  # Test against each ICVF tract as outcome
  for (icvf_file in icvf_full_files) {
    icvf_trait <- sub("_mr_ready\\.tsv\\.gz$", "", basename(icvf_file))
    icvf_trait <- sub("^PGS\\d+_", "", icvf_trait)
    pgs_id <- sub("_.*", "", basename(icvf_file))

    message("  → ", icvf_trait)

    # Load ICVF as outcome
    icvf_dat <- fread(icvf_file, header = TRUE)
    icvf_dat <- as.data.frame(icvf_dat)

    # Re-format as outcome (the file was saved as exposure format)
    icvf_outcome <- format_data(
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
    icvf_outcome$outcome <- paste0(pgs_id, "_", icvf_trait)

    # Harmonise
    harmonised <- tryCatch(
      harmonise_data(glioma_instruments, icvf_outcome, action = 2),
      error = function(e) { message("    Harmonisation failed"); NULL }
    )

    if (is.null(harmonised) || nrow(harmonised[harmonised$mr_keep, ]) < MIN_INSTRUMENTS) {
      message("    Too few SNPs after harmonisation")
      next
    }

    # Core MR
    mr_res <- mr(harmonised, method_list = c(
      "mr_ivw",
      "mr_egger_regression",
      "mr_weighted_median",
      "mr_weighted_mode"
    ))
    mr_res$subtype <- subtype
    mr_res$pgs_id  <- pgs_id
    mr_res$direction <- "reverse"
    reverse_results <- c(reverse_results, list(mr_res))

    # Heterogeneity & Pleiotropy
    het <- mr_heterogeneity(harmonised)
    het$subtype <- subtype; het$pgs_id <- pgs_id
    reverse_het <- c(reverse_het, list(het))

    pleio <- mr_pleiotropy_test(harmonised)
    pleio$subtype <- subtype; pleio$pgs_id <- pgs_id
    reverse_pleio <- c(reverse_pleio, list(pleio))
  }
}

# =============================================================================
# STEP 4: Combine and save results
# =============================================================================

message("\n=== STEP 4: Saving results ===\n")

# Forward MR
if (length(forward_results) > 0) {
  fwd_df <- bind_rows(forward_results)
  fwd_df$direction <- "forward_ICVF_to_glioma"
  fwrite(fwd_df, file.path(OUTPUT_DIR, "forward_mr_results.tsv"), sep = "\t")
  message("  Forward MR results: ", nrow(fwd_df), " rows")
}

if (length(forward_het) > 0) {
  fwd_het_df <- bind_rows(forward_het)
  fwrite(fwd_het_df, file.path(OUTPUT_DIR, "forward_heterogeneity.tsv"), sep = "\t")
}

if (length(forward_pleio) > 0) {
  fwd_pleio_df <- bind_rows(forward_pleio)
  fwrite(fwd_pleio_df, file.path(OUTPUT_DIR, "forward_pleiotropy.tsv"), sep = "\t")
}

if (length(forward_presso) > 0) {
  fwd_presso_df <- bind_rows(forward_presso)
  fwrite(fwd_presso_df, file.path(OUTPUT_DIR, "forward_mrpresso.tsv"), sep = "\t")
}

if (length(forward_steiger) > 0) {
  fwd_steiger_df <- bind_rows(forward_steiger)
  fwrite(fwd_steiger_df, file.path(OUTPUT_DIR, "forward_steiger.tsv"), sep = "\t")
}

# Reverse MR
if (length(reverse_results) > 0) {
  rev_df <- bind_rows(reverse_results)
  rev_df$direction <- "reverse_glioma_to_ICVF"
  fwrite(rev_df, file.path(OUTPUT_DIR, "reverse_mr_results.tsv"), sep = "\t")
  message("  Reverse MR results: ", nrow(rev_df), " rows")
}

if (length(reverse_het) > 0) {
  rev_het_df <- bind_rows(reverse_het)
  fwrite(rev_het_df, file.path(OUTPUT_DIR, "reverse_heterogeneity.tsv"), sep = "\t")
}

if (length(reverse_pleio) > 0) {
  rev_pleio_df <- bind_rows(reverse_pleio)
  fwrite(rev_pleio_df, file.path(OUTPUT_DIR, "reverse_pleiotropy.tsv"), sep = "\t")
}

# Combined summary
if (length(forward_results) > 0 && length(reverse_results) > 0) {
  combined <- bind_rows(fwd_df, rev_df)
  fwrite(combined, file.path(OUTPUT_DIR, "combined_mr_results.tsv"), sep = "\t")
  message("  Combined results: ", nrow(combined), " rows")
}

# =============================================================================
# STEP 5: Summary plots
# =============================================================================

message("\n=== STEP 5: Generating plots ===\n")

# --- Forward MR forest plot (IVW results only) ---
if (length(forward_results) > 0) {
  ivw_fwd <- fwd_df %>% filter(method == "Inverse variance weighted")

  if (nrow(ivw_fwd) > 0) {
    ivw_fwd$label <- paste0(ivw_fwd$pgs_id, " → ", ivw_fwd$subtype)
    ivw_fwd$or    <- exp(ivw_fwd$b)
    ivw_fwd$or_lo <- exp(ivw_fwd$b - 1.96 * ivw_fwd$se)
    ivw_fwd$or_hi <- exp(ivw_fwd$b + 1.96 * ivw_fwd$se)
    ivw_fwd$sig   <- ifelse(ivw_fwd$pval < 0.05 / nrow(ivw_fwd), "Bonferroni", 
                     ifelse(ivw_fwd$pval < 0.05, "Nominal", "NS"))

    p <- ggplot(ivw_fwd, aes(x = or, y = reorder(label, or), color = subtype)) +
      geom_point(size = 2) +
      geom_errorbarh(aes(xmin = or_lo, xmax = or_hi), height = 0.2) +
      geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") +
      scale_x_log10() +
      labs(
        title = "Forward MR: ICVF → Glioma (IVW)",
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
if (length(reverse_results) > 0) {
  ivw_rev <- rev_df %>% filter(method == "Inverse variance weighted")

  if (nrow(ivw_rev) > 0) {
    ivw_rev$label <- paste0(ivw_rev$subtype, " → ", ivw_rev$outcome)
    ivw_rev$beta_lo <- ivw_rev$b - 1.96 * ivw_rev$se
    ivw_rev$beta_hi <- ivw_rev$b + 1.96 * ivw_rev$se
    ivw_rev$sig <- ifelse(ivw_rev$pval < 0.05 / nrow(ivw_rev), "Bonferroni",
                   ifelse(ivw_rev$pval < 0.05, "Nominal", "NS"))

    p2 <- ggplot(ivw_rev, aes(x = b, y = reorder(label, b), color = subtype)) +
      geom_point(size = 2) +
      geom_errorbarh(aes(xmin = beta_lo, xmax = beta_hi), height = 0.2) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        title = "Reverse MR: Glioma → ICVF (IVW)",
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

if (length(forward_results) > 0) {
  message("\n--- Forward MR (ICVF → Glioma): Significant IVW results ---")
  sig_fwd <- fwd_df %>% filter(method == "Inverse variance weighted", pval < 0.05)
  if (nrow(sig_fwd) > 0) {
    for (r in 1:nrow(sig_fwd)) {
      message(sprintf("  %s → %s: b=%.4f, se=%.4f, p=%.2e, OR=%.3f",
                      sig_fwd$pgs_id[r], sig_fwd$subtype[r],
                      sig_fwd$b[r], sig_fwd$se[r], sig_fwd$pval[r], exp(sig_fwd$b[r])))
    }
  } else {
    message("  No nominally significant results")
  }
}

if (length(reverse_results) > 0) {
  message("\n--- Reverse MR (Glioma → ICVF): Significant IVW results ---")
  sig_rev <- rev_df %>% filter(method == "Inverse variance weighted", pval < 0.05)
  if (nrow(sig_rev) > 0) {
    for (r in 1:nrow(sig_rev)) {
      message(sprintf("  %s → %s: b=%.4f, se=%.4f, p=%.2e",
                      sig_rev$subtype[r], sig_rev$outcome[r],
                      sig_rev$b[r], sig_rev$se[r], sig_rev$pval[r]))
    }
  } else {
    message("  No nominally significant results")
  }
}

message("\n--- Output files ---")
message("  ", OUTPUT_DIR, "/forward_mr_results.tsv")
message("  ", OUTPUT_DIR, "/reverse_mr_results.tsv")
message("  ", OUTPUT_DIR, "/combined_mr_results.tsv")
message("  ", OUTPUT_DIR, "/forward_heterogeneity.tsv")
message("  ", OUTPUT_DIR, "/forward_pleiotropy.tsv")
message("  ", OUTPUT_DIR, "/forward_mrpresso.tsv")
message("  ", OUTPUT_DIR, "/forward_steiger.tsv")
message("  ", OUTPUT_DIR, "/reverse_heterogeneity.tsv")
message("  ", OUTPUT_DIR, "/reverse_pleiotropy.tsv")
message("  ", OUTPUT_DIR, "/plots/forward_mr_forest.pdf")
message("  ", OUTPUT_DIR, "/plots/reverse_mr_forest.pdf")

message("\n--- Next steps ---")
message("  1. Review IVW results — look for consistent direction across methods")
message("  2. Check MR-Egger intercept p-values for evidence of pleiotropy")
message("  3. Check heterogeneity (Cochran Q) — high Q suggests invalid instruments")
message("  4. MR-PRESSO global test — significant = outlier instruments present")
message("  5. Steiger test — confirms the causal direction is correct")
message("  6. Consider excluding HLA region instruments (chr6:25-34Mb)")
message("     HLA has extreme LD and strong glioma associations that may violate")
message("     MR assumptions. Re-run after filtering for robustness.")
message("  7. Apply Bonferroni correction for multiple testing:")
message("     18 tracts × 5 subtypes = 90 forward tests → p < 5.6e-4")
