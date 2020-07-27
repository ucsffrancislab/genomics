#!/usr/bin/env bash



#./SNP2HLA.csh DATA (.bed/.bim/.fam) REFERENCE (.bgl.phased/.markers) OUTPUT plink {optional: max_memory[mb] window_size}


~/.local/SNP2HLA_package_v1.0.3/SNP2HLA/SNP2HLA.csh \
	ukb.antigen.chr6.filtered \
	HM_CEU_REF \
	ukb.antigen.chr6.filtered.imputed.1000 \
	plink 100000 1000

~/.local/SNP2HLA_package_v1.0.3/SNP2HLA/SNP2HLA.csh \
	ukb.antigen.chr6.filtered \
	HM_CEU_REF \
	ukb.antigen.chr6.filtered.imputed.10000 \
	plink 100000 10000

~/.local/SNP2HLA_package_v1.0.3/SNP2HLA/SNP2HLA.csh \
	ukb.antigen.chr6.filtered \
	HM_CEU_REF \
	ukb.antigen.chr6.filtered.imputed.100 \
	plink 100000 100

