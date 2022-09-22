#!/usr/bin/env bash


SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
		--k)
			shift; k=$1; shift;;
		--source_file)
			shift; source_file=$1; shift;;
		--step)
			shift; step=$1; shift;;
		--stopstep)
			shift; stopstep=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		--random_forest)
			shift; random_forest="${random_forest} $1 $2"; shift; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done



echo random_forest ${random_forest}
echo threads ${threads}
echo SELECT_ARGS ${SELECT_ARGS}




