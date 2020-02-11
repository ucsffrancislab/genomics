#!/usr/bin/env bash



#	rsync -avz --progress --exclude \*.diffexpr-results.csv --include \*csv --exclude \* ucsf:/francislab/data1/raw/20191008_Stanford71/trimmed/unpaired/ ~/20191008_Stanford71/



#	Final PDF has the name of the notebook used as a title so doing it in 2 steps.
#	HTML's don't add a title ON the page, but does have a title tag


outpath="/Users/jakewendt/20191008_Stanford71"
export metadata="${outpath}/metadata.csv"



for fc in ${outpath}/h38au.bowtie2-*.unmapped.*.summary.csv ; do
	echo $fc
	export featureCounts="${fc}"

	output=${featureCounts}.deseq.html
	if [ -f ${output} ] && [ ! -w ${output} ] ; then
		echo "Write-protected ${output} exists. Skipping."
	else
		jupyter_nbconvert.bash --to html --execute --ExecutePreprocessor.timeout=600 \
			--output ${output} ~/.local/bin/deseq.ipynb
		b=$( basename $fc .summary.csv )
		sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${output}
		sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${output}
	fi
done



for fc in ${outpath}/h38*featureCounts*csv ; do
	echo $fc
	export featureCounts=${fc}

	output=${featureCounts}.deseq.html
	if [ -f ${output} ] && [ ! -w ${output} ] ; then
		echo "Write-protected ${output} exists. Skipping."
	else
		jupyter_nbconvert.bash --to html --execute --ExecutePreprocessor.timeout=600 \
			--output ${output} ~/.local/bin/deseq.ipynb
		b=$( basename $fc .csv )
		sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${output}
		sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${output}
	fi
done



#	rsync -avz --progress --include \*kallisto\*/ --include \*kallisto\*/abundance.h5 --exclude \* ucsf:/francislab/data1/raw/20191008_Stanford71/trimmed/unpaired/ ~/20191008_Stanford71/kallisto/


#	at so <- sleuth_fit(so, ~cc, 'full'), ami_11 yields
#	Error in simpleLoess(y, x, w, span, degree = degree, parametric = parametric, : invalid 'x'


export datapath="${outpath}/kallisto"

#for a in rsg vm mt hp mi ami amt ahp hrna rsrna ; do
#for b in 11 13 15 17 19 21 31 ; do
#	export suffix="kallisto.single.${a}_${b}"

for k in ${datapath}/01.kallisto.single.* ; do

	k=$( basename ${k} )
	export suffix=${k#01.}

	echo "Processing ${suffix}"

	if [ $( ls -d ${datapath}/*.${suffix}/abundance.h5 | wc -l ) -eq 77 ] ; then
		output=${outpath}/${suffix}.sleuth.html
		if [ -f ${output} ] && [ ! -w ${output} ] ; then
			echo "Write-protected ${output} exists. Skipping."
		else
			jupyter_nbconvert.bash --to html --execute --ExecutePreprocessor.timeout=600 \
				--output ${output} ~/.local/bin/sleuth.ipynb
			sed -i "s/<title>sleuth<\/title>/<title>${suffix}<\/title>/" ${output}
			sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${suffix}'<\/h1>/' ${output}
		fi
	fi

done	#	for k in ${datapath}/01.kallisto.single.* ; do

#done ; done



for infile in ${outpath}/h38au.bowtie2-*.unmapped.*.summary.csv ; do
	export featureCounts="${infile/summary.csv/summary.summed.csv}"

	output=${featureCounts}.deseq.html
	if [ -f ${output} ] && [ ! -w ${output} ] ; then
		echo "Write-protected ${output} exists. Skipping."
	else
		./sum_summary.bash ${infile} > ${featureCounts}
		jupyter_nbconvert.bash --to html --execute --ExecutePreprocessor.timeout=600 \
			--output ${output} ~/.local/bin/deseq.ipynb
		b=$( basename $featureCounts .summary.summed.csv )
		sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${output}
		sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${output}
	fi
done




#	export metadata="/Users/jakewendt/20191008_Stanford71/metadata.csv"
#	for infile in /Users/jakewendt/20191008_Stanford71/h38au.bowtie2-e2e.unmapped.*.summary.csv ; do
#
#	export featureCounts="${infile/summary.csv/summary.phage.csv}"
#	grep -E "phage|Geneid" ${infile} > ${featureCounts}
#	jupyter_nbconvert.bash --to html --execute --output ${featureCounts}.deseq.html --ExecutePreprocessor.timeout=600 ~/.local/bin/deseq.ipynb
#	b=$( basename $featureCounts .summary.phage.csv )
#	sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${featureCounts}.deseq.html
#	sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${featureCounts}.deseq.html
#
#	export featureCounts="${infile/summary.csv/summary.adeno.csv}"
#	grep -E "adeno|Geneid" ${infile} > ${featureCounts}
#	jupyter_nbconvert.bash --to html --execute --output ${featureCounts}.deseq.html --ExecutePreprocessor.timeout=600 ~/.local/bin/deseq.ipynb
#	b=$( basename $featureCounts .summary.adeno.csv )
#	sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${featureCounts}.deseq.html
#	sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${featureCounts}.deseq.html
#
#	export featureCounts="${infile/summary.csv/summary.herpes.csv}"
#	grep -E "herpes|Geneid" ${infile} > ${featureCounts}
#	jupyter_nbconvert.bash --to html --execute --output ${featureCounts}.deseq.html --ExecutePreprocessor.timeout=600 ~/.local/bin/deseq.ipynb
#	b=$( basename $featureCounts .summary.herpes.csv )
#	sed -i "s/<title>deseq<\/title>/<title>${b}<\/title>/" ${featureCounts}.deseq.html
#	sed -i 's/\(id="notebook-container">\)$/\1<h1 align="center">'${b}'<\/h1>/' ${featureCounts}.deseq.html
#
#	done


