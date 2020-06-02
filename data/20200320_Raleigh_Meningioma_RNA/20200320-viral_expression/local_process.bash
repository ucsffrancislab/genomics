#!/usr/bin/env bash

for f in e10/*.STAR.hg38.Unmapped.out.diamond.e10.nr.csv.gz ; do 
	echo $f
	#b=${f%.csv.gz}
	b=$( basename $f .csv.gz )
	csv=$( basename $f )
	echo $b

	for e in 1 0.1 0.01 ; do
		mkdir -p e${e}
		out="e${e}/${csv/e10/e${e}}"
		if [ -f $out ] && [ ! -w $out ] ; then
			echo "$out done. Skipping"
		else
			echo "Selecting subset from base"
			zcat $f | awk -F"\t" -v e=${e} '($11 <= e)' | gzip > ${out}
			chmod -w ${out}
		fi
	done
	
	for e in 10 1 0.1 0.01 ; do
		#in=${f/e10/e${e}}
		#out=${b/e10/e${e}}.rma6
		in="e${e}/${csv/e10/e${e}}"
		out="e${e}/${b/e10/e${e}}.rma6"
		if [ -f $out ] && [ ! -w $out ] ; then
			echo "$out done. Skipping"
		else
			/Applications/MEGAN/tools/blast2rma --in ${in} \
				--format BlastTab \
				--blastMode BlastN \
				--mapDB ~/Downloads/megan-map-Oct2019.db \
				--out ${out}
				#--mapDB ~/Downloads/megan-nucl-Oct2019.db \
			chmod -w ${out}
		fi
	done
done

