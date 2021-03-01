#!/usr/bin/env bash


vcf_files=bam/*.100.vcf.gz
base_dirs=out/*100.manta_strelka
samples=$( echo $base_dirs )
samples=${samples//out\//}
samples=${samples//.100.manta_strelka/}

#out/983899.100.manta_strelka/strelka/results/variants/somatic.snvs.vcf.gz
core="manta_strelka/strelka/results/variants/somatic.snvs.vcf.gz"


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
c=$( cat out/${sample}.${sub}.${core}.count )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| % Calls ${sub}/100 |"
for sample in $samples ; do
n=$( cat out/${sample}.${sub}.${core}.count )
d=$( cat out/${sample}.100.${core}.count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| isec Diff Calls 100 ${sub} |"
for sample in $samples ; do
c=$( cat out/${sample}.${sub}.${core}.diff_100_isec_count )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| % isec Diff Calls ${sub}/100 |"
for sample in $samples ; do
n=$( cat out/${sample}.${sub}.${core}.diff_100_isec_count )
d=$( cat out/${sample}.100.${core}.shared_100_isec_count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| isec Shared Calls 100 ${sub} |"
for sample in $samples ; do
c=$( cat out/${sample}.${sub}.${core}.shared_100_isec_count )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| % isec Shared Calls ${sub}/100 |"
for sample in $samples ; do
n=$( cat out/${sample}.${sub}.${core}.shared_100_isec_count )
d=$( cat out/${sample}.100.${core}.shared_100_isec_count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done




#	PASS only


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| PASS Calls ${sub} |"
for sample in $samples ; do
c=$( cat out/${sample}.${sub}.${core}.PASS_count )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| PASS % Calls ${sub}/100 |"
for sample in $samples ; do
n=$( cat out/${sample}.${sub}.${core}.PASS_count )
d=$( cat out/${sample}.100.${core}.PASS_count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| PASS isec Diff Calls 100 ${sub} |"
for sample in $samples ; do
c=$( cat out/${sample}.${sub}.${core}.PASS_diff_100_isec_count )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| PASS % isec Diff Calls ${sub}/100 |"
for sample in $samples ; do
n=$( cat out/${sample}.${sub}.${core}.PASS_diff_100_isec_count )
d=$( cat out/${sample}.100.${core}.PASS_shared_100_isec_count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| PASS isec Shared Calls 100 ${sub} |"
for sample in $samples ; do
c=$( cat out/${sample}.${sub}.${core}.PASS_shared_100_isec_count )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| PASS % isec Shared Calls ${sub}/100 |"
for sample in $samples ; do
n=$( cat out/${sample}.${sub}.${core}.PASS_shared_100_isec_count )
d=$( cat out/${sample}.100.${core}.PASS_shared_100_isec_count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done


