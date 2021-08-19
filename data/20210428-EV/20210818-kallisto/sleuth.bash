#!/usr/bin/env bash


#	
#	outpath="/Users/jakewendt/20191008_Stanford71/20190926-E-GEOD-105052-exploratory"
#	export metadata="${outpath}/metadata.csv"
#	
#	for fc in ${PWD}/*Counts.csv ; do
#		export featureCounts="${fc}"
#		echo $featureCounts
#	
#		output=${featureCounts}.deseq.html
#		if [ -f ${output} ] && [ ! -w ${output} ] ; then
#			echo "Write-protected ${output} exists. Skipping."
#		else
#			jupyter_nbconvert.bash --to html --execute --ExecutePreprocessor.timeout=600 \
#				--output ${output} ~/.local/bin/deseq.ipynb
#			b=$( basename $fc .csv )
#			sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${output}
#			sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${output}
#		fi
#	
#	done
#	
#	
#	
#	#	rsync -avz --progress --include \*kallisto\*/ --include \*kallisto\*/abundance.h5 --exclude \* ucsf:/francislab/data1/raw/E-GEOD-105052/fastq/trimmed/ ~/20191008_Stanford71/20190926-E-GEOD-105052-exploratory/kallisto/
#	
#	
#	
#	
#	
#	export datapath="${outpath}/kallisto"
#	
#	#for a in rsg vm mt hp mi ami amt ahp hrna rsrna ; do
#	#for b in 11 13 15 17 19 21 31 ; do
#	#	export suffix="kallisto.single.${a}_${b}"
#	
#	for k in ${datapath}/SRR6182239.kallisto.single.* ; do
#	
#		k=$( basename ${k} )
#		export suffix=${k#SRR6182239.}
#	
#		echo "Processing ${suffix}"
#	
#		if [ $( ls -d ${datapath}/*.${suffix}/abundance.h5 | wc -l ) -eq 42 ] ; then
#			output=${outpath}/${suffix}.sleuth.html
#			if [ -f ${output} ] && [ ! -w ${output} ] ; then
#				echo "Write-protected ${output} exists. Skipping."
#			else
#				jupyter_nbconvert.bash --to html --execute --ExecutePreprocessor.timeout=600 \
#					--output ${output} ~/.local/bin/sleuth.ipynb
#				sed -i "s/<title>sleuth<\/title>/<title>${suffix}<\/title>/" ${output}
#				sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${suffix}'<\/h1>/' ${output}
#			fi
#		fi
#	
#	done	#	for k in ${datapath}/01.kallisto.single.* ; do
#	
#	#done ; done
#	
#	
#	#	ERROR: Error in simpleLoess(y, x, w, span, degree = degree, parametric = parametric, : invalid 'x'
#	#	for rsrna_31






