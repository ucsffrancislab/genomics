#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

#REF="/francislab/data1/refs/igv.org.genomes/hg38/rmsk"
REF="/francislab/data1/refs/sources/igv.broadinstitute.org/annotations/hg38/rmsk"
DIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200805-STAR_hg38"

for gtf in ${REF}/SINE.Alu{.,.Abox.,.Bbox.}sync.gtf ; do
	echo $gtf
	feature=$( basename $gtf .gtf )

	outbase=${DIR}/featureCounts/featureCounts.${feature}

	mkdir -p $( dirname ${outbase} )

	qsub -N $feature -l nodes=1:ppn=64 -l vmem=500gb \
		-l feature=nocommunal \
		-j oe -o ${outbase}.${date}.out.txt \
		~/.local/bin/featureCounts.bash \
		-F "-T 64 -a $gtf -t feature -g feature_name -o ${outbase}.csv ${DIR}/out/*.STAR.hg38.Aligned.sortedByCoord.out.bam"

done

