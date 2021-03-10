#!/usr/bin/env bash


date=$( date "+%Y%m%d%H%M%S" )

mkdir -p imputed
mkdir -p matchedimputed

for windowsize in 100 1000 ; do

	sbatch --job-name=WTCCC-${windowsize} --time=9999 --ntasks=8 --mem=250G \
		--output=${PWD}/imputed/snp2hla.${windowsize}.output.${date}.txt \
		--export=NONE \
		~/.local/bin/SNP2HLA.bash \
			${PWD}/chr6.annotated \
			${PWD}/T1DGC_REF \
			${PWD}/imputed/chr6.annotated.${windowsize} \
			${PWD}/plink 200000 ${windowsize}

			#${PWD}/../20210304-snp2hla/chr6-t1dgc-matched \
	sbatch --job-name=mWTCCC-${windowsize} --time=9999 --ntasks=8 --mem=250G \
		--output=${PWD}/matchedimputed/snp2hla.${windowsize}.output.${date}.txt \
		--export=NONE \
		~/.local/bin/SNP2HLA.bash \
			${PWD}/chr6-t1dgc-matched.filtered \
			${PWD}/T1DGC_REF \
			${PWD}/matchedimputed/chr6-t1dgc-matched.filtered.${windowsize} \
			${PWD}/plink 200000 ${windowsize}

done


#[4] Performing HLA imputation (see /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/matchedimputed/chr6-t1dgc-matched.filtered.10000.bgl.log for progress).
#beagle markers=/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/T1DGC_REF.markers unphased=/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/matchedimputed/chr6-t1dgc-matched.filtered.10000.MHC.QC.bgl phased=/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/T1DGC_REF.bgl.phased gprobs=true niterations=10 nsamples=4 missing=0 verbose=true maxwindow=10000 out=/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/matchedimputed/chr6-t1dgc-matched.filtered.10000.IMPUTED log=/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/matchedimputed/chr6-t1dgc-matched.filtered.10000.phasing lowmem=true >> /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-snp2hla/matchedimputed/chr6-t1dgc-matched.filtered.10000.bgl.log
#Exception in thread "main" java.lang.StackOverflowError
#	at a.a.a(Unknown Source)
#	at a.a.a(Unknown Source)
#
#for windowsize in 10000 ; do
#
#	sbatch --job-name=WTCCC-${windowsize} --time=999 --ntasks=8 --mem=500G \
#		--output=${PWD}/imputed/snp2hla.${windowsize}.output.${date}.txt \
#		--export=NONE \
#		~/.local/bin/SNP2HLA.bash \
#			${PWD}/chr6.annotated \
#			${PWD}/T1DGC_REF \
#			${PWD}/imputed/chr6.annotated.${windowsize} \
#			${PWD}/plink 500000 ${windowsize}
#
#			#${PWD}/../20210304-snp2hla/chr6-t1dgc-matched \
#	sbatch --job-name=mWTCCC-${windowsize} --time=999 --ntasks=8 --mem=400G \
#		--output=${PWD}/matchedimputed/snp2hla.${windowsize}.output.${date}.txt \
#		--export=NONE \
#		~/.local/bin/SNP2HLA.bash \
#			${PWD}/chr6-t1dgc-matched.filtered \
#			${PWD}/T1DGC_REF \
#			${PWD}/matchedimputed/chr6-t1dgc-matched.filtered.${windowsize} \
#			${PWD}/plink 400000 ${windowsize}
#
#done

