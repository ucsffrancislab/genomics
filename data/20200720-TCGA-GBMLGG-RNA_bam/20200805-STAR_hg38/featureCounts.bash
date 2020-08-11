#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

REF="/francislab/data1/refs/igv.org.genomes/hg38/rmsk"
DIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200805-STAR_hg38"

for gtf in ${REF}/hg38_rmsk_{LTR,Retroposon}.ind.gtf ; do
echo $gtf
feature=$( basename $gtf .ind.gtf )
feature=${feature#hg38_rmsk_}

outbase=${DIR}/featureCounts.${feature}

mkdir -p $( dirname ${outbase} )

~/.local/bin/featureCounts.bash -T 64 -a $gtf -t feature -g feature_name -o ${outbase}.csv ${DIR}/out/*.STAR.hg38.Aligned.sortedByCoord.out.bam > ${outbase}.${date}.out.txt 2>&1

done

