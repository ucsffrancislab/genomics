#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

for gtf in /francislab/data1/refs/igv.org.genomes/hg38/rmsk/hg38_rmsk_LTR.MLT1I-int.ind.gtf ; do
echo $gtf
feature=$( basename $gtf .ind.gtf )
feature=${feature#hg38_rmsk_LTR.}

outbase=/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200722-STAR_hg38/featureCounts.individual/featureCounts.${feature}

mkdir -p $( dirname ${outbase} )

~/.local/bin/featureCounts.bash -T 64 -a $gtf -t feature -g feature_name -o ${outbase}.csv /francislab/data1/raw/20200320_Raleigh_Meningioma_RNA/bam/???.bam > ${outbase}.${date}.out.txt 2>&1

#/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200722-STAR_hg38/out/*.STAR.hg38.Aligned.out.bam 

done

