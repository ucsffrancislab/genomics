#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		--execute)
			shift; notebook=${1}; shift;;
		*)
			shift;;
	esac
done

#	pip install --user --upgrade jupyter nbconvert pandoc

#	If R notebook, but sure to install the necessary packages
#	install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))
#	devtools::install_github('IRkernel/IRkernel')
#	IRkernel::installspec()
#		also needed a bunch of other packages for many projects.
#	BiocManager::install(c('pheatmap','pachterlab/sleuth','cowplot','biomaRt','RColorBrewer','gplots','genefilter','calibrate','DESeq2','optparse','Cairo'))

#	Required pandoc binary https://github.com/jgm/pandoc
#	and python pip package ( pip install --upgrade --user pandoc )

#	Required xelatex / TexLive
#	http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
#	TEXLIVE_INSTALL_PREFIX=~/.local/texlive ./install-tl

#	jupyter nbconvert --to pdf --execute jupyter_R_1.ipynb 
#	creates jupyter_R_1.pdf

#	Nbconvert will fail if any cell takes longer than 30s to run, you may want to add --ExecutePreprocessor.timeout=600. – bckygldstn Jan 24 at 17:14



f=${notebook/.ipynb/.pdf}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	jupyter nbconvert $ARGS
	chmod a-w $f
fi

