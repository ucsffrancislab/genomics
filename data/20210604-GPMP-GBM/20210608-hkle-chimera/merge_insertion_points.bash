#!/usr/bin/env bash

#outdir=merged1k
#
#mkdir $outdir
#
#for c in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY ; do
#
#	echo $c
#
#	./merge_insertion_points.py -c $c -o $outdir/merged.rounded.csv.gz -p 'premerge1k/*ts' > $outdir/merge.${c}.out 2> $outdir/merge.${c}.err
#
#done


dir=20210119-merged

for k in 1k 10k ; do

	echo "Processing ${k}"

	outdir=${dir}

	mkdir -p ${outdir}

	for hkle in HERVK113 SVA_A SVA_B SVA_C SVA_D SVA_E SVA_F ; do
		echo ${hkle}

		for q in Q00 Q10 Q20 ; do
			echo ${q}

			outbase=${outdir}/merged.rounded${k}.${hkle}.${q}

			echo ./merge_insertion_points.py -o ${outbase}.csv.gz -p premerge${k}/\*.${hkle}.\*.${q}.\*ts 

			./merge_insertion_points.py -o ${outbase}.csv.gz -p premerge${k}/\*.${hkle}.\*.${q}.\*ts > ${outbase}.out 2> ${outbase}.err

		done

	done

done

