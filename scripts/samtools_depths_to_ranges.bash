#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI samtools	#/1.10
fi

#set -x

#	ARGS=$*
#	
#	#	Search for the output file
#	while [ $# -gt 0 ] ; do
#		case $1 in
#	#		-o)
#	#			shift; output=$1; shift;;
#			*)
#				shift;;
#		esac
#	done
#	
#	
#	f=${output}
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		echo "Creating $f"
#		#	samtools $SELECT_ARGS > ${f}
#		#	eval "samtools $SELECT_ARGS > ${f}"
#	#	if [ ${output: -3} == '.gz' ] ; then
#	#		cmd="${cmd} | gzip --best"
#	#	fi
#	#	cmd="${cmd} > ${f}"
#	#	eval "${cmd}"
#		samtools view $ARGS
#		chmod a-w $f
#	fi

min=0
gap=0
length=0
while [ $# -gt 0 ] ; do
	case $1 in
		-m|--min)
			shift; min=$1; shift;;
		-g|--gap)
			shift; gap=$1; shift;;
		-l|--length)
			shift; length=$1; shift;;
#		-o)
#			shift; output=$1; shift;;
		*)
			samtools depth $1 | awk -v gap=${gap} -v min=${min} -v len=${length} '
				function reset(){
					seq=$1
					r1=r2=$2
				}
				function print_range(){
					l=r2-r1+1
					if( l >= len ){
						print seq" : "r1" - "r2" ( "l" )"
					}
				}
				( $3 > min ){
					if( seq == "" ){ reset() }
					if( ( $1 == seq ) && ( $2 <= (r2+gap+1) ) ){
						r2=$2
					}else{
						print_range();
						reset()
					}
				}
				END{ print_range() }
			'
			shift;;
	esac
done

