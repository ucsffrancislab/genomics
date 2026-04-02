#!/usr/bin/env Rscript
# =============================================================================
# Format BIG40 ICVF GWAS summary stats for TwoSampleMR
# =============================================================================
# Run this AFTER downloading files with download_icvf_sumstats.sh
# Requires: tidyverse, data.table, TwoSampleMR
# =============================================================================

library(data.table)
library(TwoSampleMR)	# for format_data()

# --- Configuration ---
SUMSTATS_DIR <- "icvf_gwas_sumstats"
OUTPUT_DIR	 <- "icvf_mr_ready"
SAMPLE_SIZE  <- 33224  # BIG40 combined sample

dir.create(OUTPUT_DIR, showWarnings = FALSE)

# --- Mapping: filename pattern -> PGS ID and trait ---
tract_info <- data.frame(
	idp = c(1902, 1904, 1905, 1916, 1921, 1922, 1923, 1926, 1927,
					1932, 1933, 1936, 1937, 1938, 1939, 1951, 1957, 1960),
	pgs_id = c("PGS001471", "PGS001466", "PGS001454", "PGS001456",
						 "PGS001474", "PGS001479", "PGS001478", "PGS001485",
						 "PGS001484", "PGS001481", "PGS001480", "PGS001458",
						 "PGS001457", "PGS001460", "PGS001459", "PGS001662",
						 "PGS001679", "PGS001669"),
	trait = c("ICVF middle cerebellar peduncle",
						"ICVF genu corpus callosum",
						"ICVF body corpus callosum",
						"ICVF cerebral peduncle (R)",
						"ICVF posterior limb int capsule (L)",
						"ICVF retrolenticular int capsule (R)",
						"ICVF retrolenticular int capsule (L)",
						"ICVF superior corona radiata (R)",
						"ICVF superior corona radiata (L)",
						"ICVF sagittal stratum (R)",
						"ICVF sagittal stratum (L)",
						"ICVF cingulum cingulate gyrus (R)",
						"ICVF cingulum cingulate gyrus (L)",
						"ICVF cingulum hippocampus (R)",
						"ICVF cingulum hippocampus (L)",
						"ICVF acoustic radiation (R)",
						"ICVF parahippocampal cingulum (R)",
						"ICVF forceps major"),
	stringsAsFactors = FALSE
)

# --- Process each file ---
for (i in 1:nrow(tract_info)) {
	idp_num  <- tract_info$idp[i]
	pgs_id	 <- tract_info$pgs_id[i]
	trait_nm	<- tract_info$trait[i]

	# Find the matching file
	pattern <- paste0("IDP", idp_num, "\\.txt\\.gz$")
	fpath <- list.files(SUMSTATS_DIR, pattern = pattern, full.names = TRUE)

	if (length(fpath) == 0) {
		message("WARNING: No file found for IDP ", idp_num, " (", trait_nm, ")")
		next
	}

	message("Processing: ", trait_nm, " (IDP ", idp_num, ", ", pgs_id, ")")

	# Read data
	dat <- fread(fpath[1], header = TRUE)
	colnames(dat) <- c("chr", "SNP", "pos", "other_allele", "effect_allele",
											"beta", "se", "neglog10p")

	# Convert -log10(p) to p-value
	dat[, pval := 10^(-neglog10p)]

	# Add metadata
	dat[, samplesize := SAMPLE_SIZE]
	dat[, Phenotype := trait_nm]

	# Filter: remove very rare variants and low-quality
	# (recommended: MAF >= 0.01, equivalent to AF between 0.01 and 0.99)
	# Note: AF is not in the stats33k file, but we can filter on se
	# Extremely large se indicates rare variants
	dat <- dat[se < 1 & se > 0]  # basic QC

	# Format for TwoSampleMR (as exposure data)
	# TwoSampleMR::format_data() expects specific column names
	dat <- as.data.frame(dat)

	exposure_dat <- format_data(
		dat,
		type = "exposure",
		snp_col = "SNP",
		beta_col = "beta",
		se_col = "se",
		pval_col = "pval",
		effect_allele_col = "effect_allele",
		other_allele_col = "other_allele",
		samplesize_col = "samplesize",
		phenotype_col = "Phenotype",
		chr_col = "chr",
		pos_col = "pos"
	)

	# Save full formatted data
	outfile <- file.path(OUTPUT_DIR,
											 paste0(pgs_id, "_", gsub(" ", "_", trait_nm), "_mr_ready.tsv.gz"))
	fwrite(exposure_dat, outfile, sep = "\t")
	message("  Saved: ", outfile, " (", nrow(exposure_dat), " variants)")

	# Also save genome-wide significant instruments (p < 5e-8)
	instruments <- exposure_dat[exposure_dat$pval.exposure < 5e-8, ]
	if (nrow(instruments) > 0) {
		inst_file <- file.path(OUTPUT_DIR,
													 paste0(pgs_id, "_instruments_5e8.tsv"))
		fwrite(instruments, inst_file, sep = "\t")
		message("  Instruments (p<5e-8): ", nrow(instruments))
	} else {
		message("  WARNING: No genome-wide significant instruments!")
		# Try a more relaxed threshold
		instruments_relaxed <- exposure_dat[exposure_dat$pval.exposure < 5e-6, ]
		if (nrow(instruments_relaxed) > 0) {
			inst_file <- file.path(OUTPUT_DIR,
														 paste0(pgs_id, "_instruments_5e6.tsv"))
			fwrite(instruments_relaxed, inst_file, sep = "\t")
			message("  Instruments (p<5e-6, relaxed): ", nrow(instruments_relaxed))
		}
	}

	rm(dat, exposure_dat)
	gc()
}

message("\n=== DONE ===")
message("MR-ready files saved to: ", OUTPUT_DIR)
message("\nNext steps:")
message("1. Load glioma GWAS as outcome data")
message("2. Harmonise with: harmonise_data(exposure_dat, outcome_dat)")
message("3. Run MR:         mr(harmonised_dat)")
message("4. Sensitivity:    mr_pleiotropy_test(), mr_heterogeneity()")

