#!/usr/bin/env bash


#All complain `[W::bcf_hdr_check_sanity] GL should be declared as Number=G`, but still seem to work.



for vcf in {HERV,SVA,LINE}*vcf.gz ; do
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
			#if( t[1] != n[1] ) print $1":"$2",1"
			#if( t[1] != n[1] ) print $1"\t"$2"\t1"
			
			if( ( n[1] == "./." ) || ( t[1] == "./." ) ){
				print $1"\t"$2"\t-5"
				#next
			} else {
				#if( ( n[1] == "./." ) || ( n[1] == "0/0" ) ) gtn=0
				if( n[1] == "0/0" ) gtn=0
				if( n[1] == "0/1" ) gtn=1
				if( n[1] == "1/1" ) gtn=2

				#if( ( t[1] == "./." ) || ( t[1] == "0/0" ) ) gtt=0
				if( t[1] == "0/0" ) gtt=0
				if( t[1] == "0/1" ) gtt=1
				if( t[1] == "1/1" ) gtt=2

				#if( gtt != gtn ){
					print $1"\t"$2"\t"gtt-gtn
				#}
			}
		}' > ${pair%.vcf.gz}.positions.txt
	done

	./merge.py --int --out ${vcfbase}_sample_pairs.tsv ${vcfbase}_sample_pairs/*txt

done

