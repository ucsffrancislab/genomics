#!/usr/bin/env bash


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
dir=/francislab/data1/raw/20191008_Stanford71/trimmed/unpaired

#threads=16
#vmem=8
threads=8
vmem=8
date=$( date "+%Y%m%d%H%M%S" )


function tablify_sample_uniq_counts {

	suffix=$1
	max=.${2}
	core=h38au.bowtie2-e2e.unmapped.${suffix}${max}.summary
	outbase=${dir}/${core}
	f=${outbase}.csv
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${suffix} -o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			~/.local/bin/tablify_sample_uniq_counts.bash -F \
				"-o ${f} ${dir}/*.${core}.txt.gz"
	fi

}

tablify_sample_uniq_counts kraken2.standard

for suffix in blastn.viral.masked blastn.viral.raw blastn.viral ; do
for max in 10 1e-10 1e-20 1e-30 ; do

	tablify_sample_uniq_counts ${suffix} ${max}

done ; done





for bambase in subread-dna subread-rna bowtie2-e2e bowtie2-loc ; do

	for Q in 40 20 00 ; do

		for feature in miRNA miRNA_primary_transcript ; do

			#for tag in ID Alias Name ; do
			for tag in Name ; do

				jobname=${bambase}.${feature}.${tag}.${Q}
				jobname=${jobname/ubread-}
				jobname=${jobname/owtie2-}
				jobname=${jobname/iRNA}
				jobname=${jobname/mary_transcript}

				outbase="${dir}/h38au.${bambase}.hsa.featureCounts.${feature}.${tag}.Q${Q}"

				f="${outbase}.csv"
				fcid=''
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f."
					fcid=$( qsub -N ${jobname} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						-o ${outbase}.${date}.out.txt \
						-e ${outbase}.${date}.err.txt \
						~/.local/bin/featureCounts.bash -F \
							"-T ${threads} -t ${feature} -g ${tag} -a ${FASTA}/hg38.chr.hsa.gff3 \
							-Q ${Q} -o ${f} ${dir}/??.h38au.${bambase}.bam" )
					echo $fcid
				fi

				#	counts=${f}
				#	outbase=${f}.deseq
				#	f=${outbase}.plots.pdf
				#	if [ -f $f ] && [ ! -w $f ] ; then
				#		echo "Write-protected $f exists. Skipping."
				#	else
				#		#echo "Creating $f"
				#		if [ ! -z ${fcid} ] ; then
				#			depend="-W depend=afterok:${fcid}"
				#		else
				#			depend=""
				#		fi
				#		qsub ${depend} -N deseq.${feature} -l vmem=4gb -o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				#			~/.local/bin/deseq.bash -F \
				#			"-f ${counts} -m /francislab/data1/raw/20191008_Stanford71/metadata.csv"
				#	fi

			done	#	for tag in ID Alias Name ; do

		done	#	for feature in miRNA miRNA_primary_transcript ; do


		for feature in exon CDS start_codon stop_codon ; do
		#for feature in exon ; do

			for tag in gene_id gene_name transcript_id tss_id ; do
			#for tag in gene_id tss_id ; do

				jobname=${bambase}.${feature}.${tag}.${Q}
				jobname=${jobname/ubread-}
				jobname=${jobname/owtie2-}
				jobname=${jobname/ene_}
				jobname=${jobname/ranscript_}
				jobname=${jobname/_codon}

				outbase="${dir}/h38au.${bambase}.genes.featureCounts.${feature}.${tag}.Q${Q}"

				f="${outbase}.csv"
				fcid=''
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					echo "Creating $f."
					fcid=$( qsub -N ${jobname} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						-o ${outbase}.${date}.out.txt \
						-e ${outbase}.${date}.err.txt \
						~/.local/bin/featureCounts.bash -F \
							"-T ${threads} -t ${feature} -g ${tag} -Q ${Q} \
							-a ${REFS}/Homo_sapiens/UCSC/hg38/Annotation/Genes/genes.gtf \
							-o ${f} ${dir}/??.h38au.${bambase}.bam" )
					echo $fcid
				fi

				#	counts=${f}
				#	outbase=${f}.deseq
				#	f=${outbase}.plots.pdf
				#	if [ -f $f ] && [ ! -w $f ] ; then
				#		echo "Write-protected $f exists. Skipping."
				#	else
				#		#echo "Creating $f"
				#		if [ ! -z ${fcid} ] ; then
				#			depend="-W depend=afterok:${fcid}"
				#		else
				#			depend=""
				#		fi
				#		qsub ${depend} -N deseq.${feature} -l vmem=4gb -o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				#			~/.local/bin/deseq.bash -F \
				#			"-f ${counts} -m /francislab/data1/raw/20191008_Stanford71/metadata.csv"
				#	fi

			done	#	for tag in gene_id gene_name transcript_id tss_id ; do

		done	#	for feature in exon CDS start_codon stop_codon ; do

	done	#	for Q in 00 20 ; do

done	#	for bambase in subread-dna subread-rna bowtie2-e2e bowtie2-loc ; do

#for ref in mi mt hp ami amt ahp ; do
#	for size in 11 13 15 17 19 21 ; do
#
#		ext=${ref}_${size}
#
#		#for ext in mi_11 mt_11 hp_11 ; do
#
#		#	hp 80, mi 64, mt 8
#		#	mi_11 .............................=>> PBS: job killed: vmem 51231789056 exceeded limit 17179869184
#
#			vmem=128
#		#		vmem=64
#		#	if [ ${ext} == 'mi_11' ] ; then
#		#		vmem=32
#		#	else
#		#		vmem=16
#		#	fi
#
#
#		#Job Name:   sleuth.mi_11
#		#Exit_status=-10 resources_used.cput=00:00:52 resources_used.mem=12915356kb resources_used.vmem=93678352kb resources_used.walltime=00:00:46
#
#
#		#Job Name:   sleuth.hp_11
#		#Exit_status=-10 resources_used.cput=00:02:09 resources_used.mem=6352032kb resources_used.vmem=69998936kb resources_used.walltime=00:00:51
#		#
#		#Job Name:   sleuth.mt_11
#		#Exit_status=-10 resources_used.cput=00:00:51 resources_used.mem=9133452kb resources_used.vmem=58483792kb resources_used.walltime=00:00:51
#
#
#
#		#Job Name:   sleuth.hp_11
#		#Exit_status=-10 resources_used.cput=00:00:26 resources_used.mem=8617044kb resources_used.vmem=86286160kb resources_used.walltime=00:00:38
#		#
#		#Job Name:   sleuth.mt_11
#		#Exit_status=-10 resources_used.cput=00:00:30 resources_used.mem=9159716kb resources_used.vmem=99378064kb resources_used.walltime=00:00:38
#		#
#
#
#		#	case $ext in
#		#		rsg)
#		#			vmem=64;;
#		#			#vmem=32;;	#	SOME rsg runs fail with bad_alloc so upping to 64GB
#		#		mi_*|mt_*|hp_*)
#		#			vmem=8;;
#		#		*)
#		#			vmem=16;;
#		#	esac
#
#
#		#	produces kallisto.single.hp_11.sleuth.plots.pdf
#
##		suffix="kallisto.single.${ext}"
##		outbase=${dir}/${suffix}.sleuth
##		f=${outbase}.plots.pdf
##		if [ -f $f ] && [ ! -w $f ] ; then
##			echo "Write-protected $f exists. Skipping."
##		else
##			qsub -N sleuth.${ext} -l vmem=${vmem}gb -o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
##				~/.local/bin/sleuth.bash -F \
##					"--suffix ${suffix} --path ${dir} \
##					--metadata /francislab/data1/raw/20191008_Stanford71/metadata.csv"
##		fi
#
#	done	#	for size in 11 13 15 ; do
#
#done	#	for ref in mi mt hp ; do

