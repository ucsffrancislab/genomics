#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

#set -x


while [ $# -gt 0 ] ; do

	#echo $1

	samtools depth $1 | awk '
		function print_region(s,e){
			printf(" %s:%d-%d",$1,s,e)
		}
		BEGIN {
			grace=10
			min_count=5
		}
		(NR==1){
			s=e=$2
		}
		(NR>1 && $3>min_count){
			if($2>e+grace){
				print_region(s,e)
				s=e=$2
			}else{
				e=$2
			}
		}
		END{
			print_region(s,e)
			printf("\n")
		}'

	shift

done

