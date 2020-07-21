#!/usr/bin/env bash



date=$( date "+%Y%m%d%H%M%S" )
for pp in . .PP. ; do
#for gtf in /francislab/data1/refs/igv.org.genomes/hg38/rmsk/hg38_rmsk*ind.gtf ; do
#echo $gtf
#feature=$( basename $gtf .gtf )
#feature=${feature#hg38_rmsk_}

for gtf in /francislab/data1/refs/igv.org.genomes/hg38/rmsk/hg38_rmsk_LTR.MLT1I-int.ind.gtf ; do
echo $gtf
feature=$( basename $gtf .ind.gtf )
feature=${feature#hg38_rmsk_LTR.}

outbase=/francislab/data1/working/20200529_Raleigh_WES/20200605-hg38/featureCounts.individual/featureCounts${pp}${feature}
~/.local/bin/featureCounts.bash -T 64 -a $gtf -t feature -g feature_name -o ${outbase}.csv /francislab/data1/working/20200529_Raleigh_WES/20200605-hg38/out/*e2e${pp}bam > ${outbase}.${date}.out.txt 2>&1
done
done

#qsub -N ${feature} -l nodes=1:ppn=8 -l vmem=60gb -l feature=nocommunal -j oe -o ${outbase}.${date}.out.txt ~/.local/bin/featureCounts.bash -F "-T 8 -a $gtf -t feature -g feature_name -o ${outbase}.csv /scratch/gwendt/tmp/*.bam"
