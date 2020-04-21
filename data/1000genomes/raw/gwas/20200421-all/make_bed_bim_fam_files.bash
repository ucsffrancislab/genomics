#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

basedir=/francislab/data1/raw/1000genomes/gwas
dir=${PWD}

for population in afr amr eas eur sas ; do
	echo $population
	outdir="${dir}/${population}"
	mkdir -p "${outdir}"

for vcf in /francislab/data1/raw/1000genomes/release/20130502/ALL.chr*vcf.gz ; do
	echo $vcf
	base=$( basename $vcf )
	base=${base%.phase3*}
	base=${base#ALL.}
	echo $base

	#	-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \

	outbase="${outdir}/${base}.plink-make-bed"

	qsub -N ${population}:${base} \
		-j oe -o ${outbase}.${date}.out.txt \
		~/.local/bin/plink.bash \
		-F "--check ${outdir}/${base}.bed \
			--make-bed \
			--keep ${basedir}/${population^^}_ids.txt \
			--update-sex ${basedir}/${population^^}_ids.txt \
			--vcf ${vcf} \
			--out ${outdir}/${base}"

done ; done


