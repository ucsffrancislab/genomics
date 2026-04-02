#!/usr/bin/env bash
# =============================================================================
# Download ICVF GWAS Summary Statistics from Oxford BIG40
# For bidirectional two-sample Mendelian Randomization with glioma
# =============================================================================
# Source: Smith et al. (2021) Nature Neuroscience
#         "An expanded set of genome-wide association studies of brain
#          imaging phenotypes in UK Biobank"
# BIG40:  https://open.win.ox.ac.uk/ukbiobank/big40/
# N:      33,224 (discovery + replication combined)
# Build:  GRCh37/hg19
# Effect allele: a2 (alternative allele)
# =============================================================================

set -e
OUTDIR="icvf_gwas_sumstats"
mkdir -p "$OUTDIR"

echo "============================================"
echo "Downloading 18 ICVF GWAS summary statistics"
echo "from BIG40 (33k combined sample)"
echo "============================================"

# --- TBSS-based ICVF tracts (JHU white matter atlas) ---
declare -A TBSS_IDPS
TBSS_IDPS[1902]="middle_cerebellar_peduncle"       # PGS001471
TBSS_IDPS[1904]="genu_corpus_callosum"             # PGS001466
TBSS_IDPS[1905]="body_corpus_callosum"             # PGS001454
TBSS_IDPS[1916]="cerebral_peduncle_R"              # PGS001456
TBSS_IDPS[1921]="posterior_limb_int_capsule_L"     # PGS001474
TBSS_IDPS[1922]="retrolenticular_int_capsule_R"    # PGS001479
TBSS_IDPS[1923]="retrolenticular_int_capsule_L"    # PGS001478
TBSS_IDPS[1926]="superior_corona_radiata_R"        # PGS001485
TBSS_IDPS[1927]="superior_corona_radiata_L"        # PGS001484
TBSS_IDPS[1932]="sagittal_stratum_R"               # PGS001481
TBSS_IDPS[1933]="sagittal_stratum_L"               # PGS001480
TBSS_IDPS[1936]="cingulum_cingulate_gyrus_R"       # PGS001458
TBSS_IDPS[1937]="cingulum_cingulate_gyrus_L"       # PGS001457
TBSS_IDPS[1938]="cingulum_hippocampus_R"           # PGS001460
TBSS_IDPS[1939]="cingulum_hippocampus_L"           # PGS001459

# --- ProbtrackX-based ICVF tracts ---
declare -A PTX_IDPS
PTX_IDPS[1951]="acoustic_radiation_R"              # PGS001662
PTX_IDPS[1957]="parahippocampal_cingulum_R"        # PGS001679
PTX_IDPS[1960]="forceps_major"                     # PGS001669

BASE_URL="https://open.win.ox.ac.uk/ukbiobank/big40/release2/stats33k"

# Download TBSS tracts
for IDP in "${!TBSS_IDPS[@]}"; do
	TRACT="${TBSS_IDPS[$IDP]}"
	FNAME="ICVF_TBSS_${TRACT}_IDP${IDP}.txt.gz"
	if [ -f "$OUTDIR/$FNAME" ] ; then
		echo "Skipping $OUTDIR/$FNAME"
	else
		echo "Downloading IDP ${IDP}: ICVF ${TRACT} (TBSS)..."
		curl -o "$OUTDIR/$FNAME" -L -C - "${BASE_URL}/${IDP}.txt.gz"
		chmod -w "$OUTDIR/$FNAME"
	fi
done

# Download ProbtrackX tracts
for IDP in "${!PTX_IDPS[@]}"; do
	TRACT="${PTX_IDPS[$IDP]}"
	FNAME="ICVF_PTX_${TRACT}_IDP${IDP}.txt.gz"
	if [ -f "$OUTDIR/$FNAME" ] ; then
		echo "Skipping $OUTDIR/$FNAME"
	else
		echo "Downloading IDP ${IDP}: ICVF ${TRACT} (ProbtrackX)..."
		curl -o "$OUTDIR/$FNAME" -L -C - "${BASE_URL}/${IDP}.txt.gz"
		chmod -w "$OUTDIR/$FNAME"
	fi
done

echo ""
echo "============================================"
echo "All downloads complete!"
echo "Files saved to: $OUTDIR/"
echo ""
echo "File format (space-delimited, gzipped):"
echo "  chr rsid pos a1 a2 beta se pval(-log10)"
echo ""
echo "Key notes:"
echo "  - Effect allele = a2 (alternative allele)"
echo "  - pval is -log10 transformed (convert: 10^(-pval))"
echo "  - Genome build: GRCh37/hg19"
echo "  - Sample size: ~33,224 (varies slightly by IDP)"
echo "============================================"
