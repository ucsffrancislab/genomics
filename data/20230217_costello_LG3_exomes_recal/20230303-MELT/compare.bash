#!/usr/bin/env bash

module load bcftools

mkdir -p MELT.Compare

for mei in ALU LINE1 SVA ; do
	echo $mei
	for vcf in out/DISCOVERYVCF/${mei}.final_comp.vcf.gz ; do
		echo $vcf
		for sample in $( zgrep -m 1 "^#CHROM" ${vcf} | cut -f10- ); do
			echo $sample

			#sample_type=$( echo ${sample} | cut -c9,10 )
			#if [ ${sample_type} == "01" ] || [ ${sample_type} == "10" ] ; then
			#	echo processing
			#fi

			#f="MELT.Compare/${sample}.${mei}.final_comp.vcf.gz"
			f="MELT.Compare/${sample}.${mei}.genotypes"
			if [ -f ${f} ] && [ ! -w ${f} ] ; then
				echo "$f exists. skipping"
			else
				echo "extracting $f"
				#bcftools view -Oz -s ${sample} -o ${f} ${vcf} 2> /dev/null
				bcftools query -s ${sample} -o ${f} -f '%CHROM\t%POS\t%REF\t%ALT\t[%GT]\n' ${vcf}
				chmod -w ${f}
			fi

#			if [ -f ${f}.csi ] && [ ! -w ${f}.csi ] ; then
#				echo "$f exists. skipping"
#			else
#				echo "extracting $f"
##				bcftools index ${f}
#			fi



#	
#	
#		sdiff -s <( bcftools view -H $tumor.${mei}.final_comp.vcf.gz 2> /dev/null | awk '{split($10,a,":");print $1,$2,a[1]}' ) <( bcftools view -H $normal.${mei}.final_comp.vcf.gz 2> /dev/null | awk '{split($10,a,":");print $1,$2,a[1]}' ) | awk -v b=$base -v m=$mei 'BEGIN{OFS=","}{print m,$1,$2,$NF"->"$3}' > ${base}.${mei}.csv
#		#sdiff -s <( bcftools view -H $tumor.${mei}.final_comp.vcf.gz 2> /dev/null | awk '{split($10,a,":");print $1,$2,a[1]}' ) <( bcftools view -H $normal.${mei}.final_comp.vcf.gz 2> /dev/null | awk '{split($10,a,":");print $1,$2,a[1]}' ) | awk '($2 != $6)'
#
#
#
#
#		#sdiff -s <( bcftools view -H $tumor.${mei}.final_comp.vcf.gz 2> /dev/null | awk '{split($10,a,":");print $1,$2,a[1]}' ) <( bcftools view -H $normal.${mei}.final_comp.vcf.gz 2> /dev/null | awk '{split($10,a,":");print $1,$2,a[1]}' ) #| wc -l
#
#		#bcftools isec $tumor.${mei}.final_comp.vcf.gz $normal.${mei}.final_comp.vcf.gz -p dir -n -1 -c all -w 1 2> /dev/null
#	
#		#bcftools view -H dir/0000.vcf 2> /dev/null | wc -l
#	
#		#/bin/rm -rf dir
#	
#		#bcftools view -h HERVK.final_comp.vcf.gz 2> /dev/null | awk '($1=="#CHROM"){for(i=10;i<=NF;i++)print $i}'
#	
#	done < pairs
#
#done

		done
	done
done


