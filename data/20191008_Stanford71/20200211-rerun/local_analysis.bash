#!/usr/bin/env bash

set -v

outpath="/Users/jakewendt/20200211-20191008_Stanford71"

export metadata="/Users/jakewendt/github/ucsffrancislab/genomics/data/20191008_Stanford71/raw/metadata.csv"

export datapath="${outpath}"	#/kallisto"


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




#	
#	process a lot of data all on the command line. At the request of a researcher, I just started using Diamond and Megan and I like that I can take the daa output from Diamond and create rma6 files for Megan. However, there is still much to do in the analysis.
#	
#	Is there a way to create a megan file from these rma6 files, trim the #SampleID from something like 51.h38au.bowtie2-e2e.unmapped.diamond.nr.daa to just 51, add a column like “Classification” containing “Case” and “Control”, add @Color and @GroupId columns, all from the command line?
#	
#	
#	
#	please consider using daa-meganizer rather than daa2rma.
#	daa-meganizer adds a block to the end of the daa file and the file can then be opened in MEGAN. This is much faster and saves you one file.
#	
#	You can add meta data to an rma file or meganized-daa file during daa2rma or daa-meganizer using the -mdf option.
#	
#	You can extract a .megan file from an rma or meganized-daa file using the program rma2info or daa2info, respectively. The .megan files are text-based and you can easily identify and change the line that contains all the metadata.
#	
#	There isn’t a program currently for adding or modifying the metadata stored in an rma or meganized-daa file. I will look into adding this feature to the programs rma2info and daa2info
#	
#	
#	There is a program called MEGAN/tools/compute-comparison that does that.
#	
#	The metadata format is the same as used for QIIME.
#	You have a header line that starts with #Samples and is followed by the names of the attributes.
#	Then subsequent lines start with the name of a dataset and then contains the values of the named attributes. Everything is tab-separated.
#	
#	Here is an example:
#	
#	#SampleID Day Subject antibiotic Treatment Health
#	Alice00-1mio 0 Alice cirprofloxacin no good
#	Alice01-1mio 1 Alice cirprofloxacin yes good
#	Alice03-1mio 3 Alice cirprofloxacin yes good
#	



















