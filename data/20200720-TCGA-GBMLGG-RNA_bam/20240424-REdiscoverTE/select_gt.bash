#!/usr/bin/env bash

tsv=$1

echo $tsv
base=$( basename ${tsv} .tsv )
for min in 0.8 0.9 0.95 0.99 ; do
	echo $min
	out=${base}.gt${min}.tsv
	if [ ! -f ${out} ] ; then
		cat ${tsv} | head -1 > ${out}.tmp1
		cat ${tsv} | tail -n +2 | awk -v min=${min} 'BEGIN{FS=OFS="\t"}{ for(i=2;i<=NF;i++){ if($i!="NA" && $i>min){ print; break } } }' >> ${out}.tmp1
		cat ${out}.tmp1 | datamash transpose > ${out}.tmp2
		head -1 ${out}.tmp2 > ${out}.tmp3
		tail -n +2 ${out}.tmp2  | awk -v min=${min} 'BEGIN{FS=OFS="\t"}{ for(i=2;i<=NF;i++){ if($i!="NA" && $i>min){ print; break } } }' >> ${out}.tmp3
		cat ${out}.tmp3 | datamash transpose > ${out}
		chmod 400 ${out}

		\rm ${out}.tmp?
	fi
done

