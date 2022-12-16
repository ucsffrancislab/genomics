#!/usr/bin/env bash


#All complain `[W::bcf_hdr_check_sanity] GL should be declared as Number=G`, but still seem to work.



for vcf in *vcf.gz ; do
	echo $vcf
	vcfbase=${vcf%.vcf.gz}
	mkdir ${vcfbase}_sample_pairs
	zgrep -m1 "^#CHROM" ${vcf} | cut -f 10- | tr "\t" "\n" | grep "^..-....-01" > ${vcfbase}_sample_pairs/tumors
	zgrep -m1 "^#CHROM" ${vcf} | cut -f 10- | tr "\t" "\n" | grep "^..-....-10" > ${vcfbase}_sample_pairs/normals
	for tumor in $( cat ${vcfbase}_sample_pairs/tumors ) ; do
		echo tumor - $tumor
		subject=${tumor%-???-???-????}
		echo subject - $subject
		for normal in $( grep "^${subject}" ${vcfbase}_sample_pairs/normals ) ; do
			echo normal - $normal

			bcftools view --apply-filters PASS -s ${tumor},${normal} -o ${vcfbase}_sample_pairs/${tumor}:${normal}.vcf.gz -Oz ${vcf}
			bcftools index ${vcfbase}_sample_pairs/${tumor}:${normal}.vcf.gz
		done
	done

	for pair in ${vcfbase}_sample_pairs/*vcf.gz ; do
		echo $pair
		zcat ${pair} | awk 'BEGIN{FS=OFS="\t"}(!/^#/){
			split($10,t,":")
			split($11,n,":")
			if( t[1] != n[1] ) print $1":"$2",1"
		}' > ${pair%.vcf.gz}.positions.txt
	done

	./merge.py --int --out ${vcfbase}_sample_pairs.csv ${vcfbase}_sample_pairs/*txt 

done

