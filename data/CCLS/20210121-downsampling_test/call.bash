#!/usr/bin/env bash


mkdir -p vcf

#for bam in ${PWD}/bam/18*bam ; do
#for bam in ${PWD}/bam/120207.60a.bam ; do
for bam in ${PWD}/bam/120207.50a.bam ; do
#for bam in ${PWD}/bam/??????.50?.bam ; do
	echo $bam
	basename=$( basename $bam .bam )

	#bcftools mpileup -Ou -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${bam} | bcftools call -mv -Oz -o vcf/${basename}.vcf.gz
	#bcftools index vcf/${basename}.vcf.gz

	#echo "bcftools mpileup -Ob -o ${PWD}/vcf/${basename}.mpileup.bcf.gz -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${bam}" | qsub -N ${basename} -l feature=nocommunal -l nodes=1:ppn=4 -l vmem=30gb -j oe -o ${PWD}/vcf/${basename}.mpileup.out.txt

	#	bcftools call -mv -Oz -o vcf/${basename}.vcf.gz
	#	bcftools index vcf/${basename}.vcf.gz

	#qsub -N ${basename} -l feature=nocommunal -l nodes=1:ppn=4 -l vmem=30gb -j oe -o ${PWD}/vcf/${basename}.mpileup.out.txt ${PWD}/bcftools_call.bash -F ${bam}

	f=${base}.${p}a.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		sbatch --time=3600 --parsable --ntasks=2 --mem=4G --job-name ${basename} \
			--output ${PWD}/vcf/${basename}.mpileup.out.txt \
			${PWD}/bcftools_call.bash ${bam}
	fi

done


#	122997
#	60% took < 19hours
#	80% took ...
#	100 took ...
