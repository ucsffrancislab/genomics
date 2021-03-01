#!/usr/bin/env bash

vcf_files=bam/[^G]*.100.vcf.gz
samples=$( echo $vcf_files )
samples=${samples//bam\//}
samples=${samples//.100.vcf.gz/}

echo -n "|    |"
for sample in $samples ; do
	echo -n " ${sample} |"
done
echo

echo -n "| --- |"
for sample in $samples ; do
	echo -n " --- |"
done
echo

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
	echo -n "| Calls ${sub} |"
	for sample in $samples ; do
		c=$( cat bam/${sample}.${sub}.vcf.gz.count )
		echo -n " ${c} |"
	done
	echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
	echo -n "| % Calls ${sub}/100 |"
	for sample in $samples ; do
		n=$( cat bam/${sample}.${sub}.vcf.gz.count )
		d=$( cat bam/${sample}.100.vcf.gz.count )
		r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
		echo -n " ${r} |"
	done
	echo
done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
	echo -n "| isec Diff Calls 100 ${sub} |"
	for sample in $samples ; do
		c=$( cat bam/${sample}.${sub}.vcf.gz.diff_100_isec_count )
		echo -n " ${c} |"
	done
	echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
	echo -n "| % isec Diff Calls ${sub}/100 |"
	for sample in $samples ; do
		n=$( cat bam/${sample}.${sub}.vcf.gz.diff_100_isec_count )
		d=$( cat bam/${sample}.100.vcf.gz.shared_100_isec_count )
		r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
		echo -n " ${r} |"
	done
	echo
done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
	echo -n "| isec Shared Calls 100 ${sub} |"
	for sample in $samples ; do
		c=$( cat bam/${sample}.${sub}.vcf.gz.shared_100_isec_count )
		echo -n " ${c} |"
	done
	echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
	echo -n "| % isec Shared Calls ${sub}/100 |"
	for sample in $samples ; do
		n=$( cat bam/${sample}.${sub}.vcf.gz.shared_100_isec_count )
		d=$( cat bam/${sample}.100.vcf.gz.shared_100_isec_count )
		r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
		echo -n " ${r} |"
	done
	echo
done


