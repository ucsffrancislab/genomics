#!/usr/bin/env bash


echo -n "|    |"
for f in newvcf/*.100.vcf.gz ; do
c=$( basename $f .100.vcf.gz )
echo -n " ${c} |"
done
echo

echo -n "| --- |"
for f in newvcf/*.100.vcf.gz ; do
c=$( basename $f .100.vcf.gz )
echo -n " --- |"
done
echo

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| Calls ${sub} |"
for f in newvcf/*.${sub}.vcf.gz.count ; do
c=$( cat $f )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| % Calls ${sub}/100 |"
for f in newvcf/*.${sub}.vcf.gz.count ; do
b=$( basename $f .${sub}.vcf.gz.count )
n=$( cat $f )
d=$( cat newvcf/${b}.100.vcf.gz.count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| isec Diff Calls 100 ${sub} |"
for f in newvcf/*.${sub}.vcf.gz.diff_100_isec_count ; do
c=$( cat $f )
echo -n " ${c} |"
done
echo
done

#for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
#echo -n "| % isec Diff Calls ${sub}/100 |"
#for f in newvcf/*.${sub}.vcf.gz.diff_100_isec_count ; do
#b=$( basename $f .${sub}.vcf.gz.diff_100_isec_count )
#n=$( cat $f )
#d=$( cat newvcf/${b}.100.vcf.gz.shared_100_isec_count )
#r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
#echo -n " ${r} |"
#done
#echo
#done


for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| isec Shared Calls 100 ${sub} |"
for f in newvcf/*.${sub}.vcf.gz.shared_100_isec_count ; do
c=$( cat $f )
echo -n " ${c} |"
done
echo
done

for sub in 100 80a 80b 80c 60a 60b 60c 50a 50b 50c ; do
echo -n "| % isec Shared Calls ${sub}/100 |"
for f in newvcf/*.${sub}.vcf.gz.shared_100_isec_count ; do
b=$( basename $f .${sub}.vcf.gz.shared_100_isec_count )
n=$( cat $f )
d=$( cat newvcf/${b}.100.vcf.gz.shared_100_isec_count )
r=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l )
echo -n " ${r} |"
done
echo
done


