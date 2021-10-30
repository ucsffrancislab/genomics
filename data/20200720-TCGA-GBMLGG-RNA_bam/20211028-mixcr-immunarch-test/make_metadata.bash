#!/usr/bin/env bash

meta="/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20211028-mixcr-immunarch-test/TCGA.Glioma.metadata.tsv"

h=$( head -1 ${meta} )

echo -e "Sample\t${h}"

for f in data/??-????-???.txt ; do
	s=$( basename $f .txt )
	b=${s%-*}
	l=$( grep "^TCGA-${b}" ${meta} )
	echo -e "$s\t$l"
done

