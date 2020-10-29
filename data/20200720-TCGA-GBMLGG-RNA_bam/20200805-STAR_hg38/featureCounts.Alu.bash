#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

#REF="/francislab/data1/refs/igv.org.genomes/hg38/rmsk"
REF="/francislab/data1/refs/sources/igv.broadinstitute.org/annotations/hg38/rmsk"
DIR="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200805-STAR_hg38"

for gtf in ${REF}/SINE.Alu{.,.Abox.,.Bbox.}sync.gtf ; do
	echo $gtf
	feature=$( basename $gtf .gtf )

	outbase=${DIR}/featureCounts.20201028/featureCounts.${feature}

	mkdir -p $( dirname ${outbase} )

	qsub -N $feature -l nodes=1:ppn=64 -l vmem=500gb \
		-l feature=nocommunal \
		-j oe -o ${outbase}.${date}.out.txt \
		~/.local/bin/featureCounts.bash \
		-F "-B -P -Q 255 -T 64 -a $gtf -t feature -g feature_name -o ${outbase}.csv ${DIR}/out/*.STAR.hg38.Aligned.sortedByCoord.out.bam"


#  -B                  Only count read pairs that have both ends aligned.
#
#  -P                  Check validity of paired-end distance when counting read 
#                      pairs. Use -d and -D to set thresholds.
#
#  -d <int>            Minimum fragment/template length, 50 by default.
#
#  -D <int>            Maximum fragment/template length, 600 by default.
#
#	samtools view out/02-0047-01A-01R-1849-01+1.STAR.hg38.Aligned.sortedByCoord.out.bam | awk -F"\t" '{print $5}' | sort | uniq -c
#	30914588 0
#	1952532 1
#	87091756 255
#	3910924 3

done

