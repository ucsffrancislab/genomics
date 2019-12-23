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

#	pip install --user --upgrade jupyter

#	If R notebook, but sure to install the necessary packages
#	install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))
#	devtools::install_github('IRkernel/IRkernel')
#	IRkernel::installspec()

#	jupyter nbconvert --to pdf --execute jupyter_R_1.ipynb 
#	creates jupyter_R_1.pdf

f=${notebook/.ipynb/.pdf}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	jupyter nbconvert $ARGS
	chmod a-w $f
fi

