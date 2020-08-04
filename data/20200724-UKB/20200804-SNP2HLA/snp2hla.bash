#!/usr/bin/env bash



#./SNP2HLA.csh DATA (.bed/.bim/.fam) REFERENCE (.bgl.phased/.markers) OUTPUT plink {optional: max_memory[mb] window_size}

for windowsize in 100 1000 10000 ; do

	~/.local/SNP2HLA_package_v1.0.3/SNP2HLA/SNP2HLA.csh \
		ukb.antigen.chr6.filtered \
		T1DGC_REF \
		ukb.antigen.chr6.filtered.imputed.${windowsize} \
		plink 100000 ${windowsize}

done

