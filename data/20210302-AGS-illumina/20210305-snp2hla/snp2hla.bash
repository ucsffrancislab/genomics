#!/usr/bin/env bash


date=$( date "+%Y%m%d%H%M%S" )

mkdir -p imputed
mkdir -p matchedimputed

#for windowsize in 100 1000 ; do
#
##	sbatch --job-name=AGS-${windowsize} --time=999 --ntasks=8 --mem=250G \
##		--output=${PWD}/imputed/snp2hla.${windowsize}.output.${date}.txt \
##		--export=NONE \
##		~/.local/bin/SNP2HLA.bash \
##			${PWD}/chr6.annotated \
##			${PWD}/T1DGC_REF \
##			${PWD}/imputed/chr6.annotated.${windowsize} \
##			${PWD}/plink 200000 ${windowsize}
#
##			${PWD}/../20210304-snp2hla/chr6-t1dgc-matched \
#	sbatch --job-name=mAGS-${windowsize} --time=999 --ntasks=8 --mem=250G \
#		--output=${PWD}/matchedimputed/snp2hla.${windowsize}.output.${date}.txt \
#		--export=NONE \
#		~/.local/bin/SNP2HLA.bash \
#			${PWD}/chr6-t1dgc-matched.filtered \
#			${PWD}/T1DGC_REF \
#			${PWD}/matchedimputed/chr6-t1dgc-matched.filtered.${windowsize} \
#			${PWD}/plink 200000 ${windowsize}
#
#done

for windowsize in 10000 ; do

#	sbatch --job-name=AGS-${windowsize} --time=999 --ntasks=8 --mem=500G \
#		--output=${PWD}/imputed/snp2hla.${windowsize}.output.${date}.txt \
#		--export=NONE \
#		~/.local/bin/SNP2HLA.bash \
#			${PWD}/chr6.annotated \
#			${PWD}/T1DGC_REF \
#			${PWD}/imputed/chr6.annotated.${windowsize} \
#			${PWD}/plink 500000 ${windowsize}

#			${PWD}/../20210304-snp2hla/chr6-t1dgc-matched \
	sbatch --job-name=mAGS-${windowsize} --time=999 --ntasks=8 --mem=400G \
		--output=${PWD}/matchedimputed/snp2hla.${windowsize}.output.${date}.txt \
		--export=NONE \
		~/.local/bin/SNP2HLA.bash \
			${PWD}/chr6-t1dgc-matched.filtered \
			${PWD}/T1DGC_REF \
			${PWD}/matchedimputed/chr6-t1dgc-matched.filtered.${windowsize} \
			${PWD}/plink 400000 ${windowsize}

done

