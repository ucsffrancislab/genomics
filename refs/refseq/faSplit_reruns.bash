#!/usr/bin/env bash

set -x

for o in $( grep -l CANCELLED complete.*out ); do
	c=$( head -1 ${o} )
	echo $o
	echo $c
	$c
	mv ${o} ${o}.rerun
done


#	several timeout (> 5 hours)

#==> complete.genomic.20210929070303-262981_253.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2242.2.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_284.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2264.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_307.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2278.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_308.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2278.2.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_314.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2282.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_322.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2288.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#  > complete.genomic.20210929070303-262981_336.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2298.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_389.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2329.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_391.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2331.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_416.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2353.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_431.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2360.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_433.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2362.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_451.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2374.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_464.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2385.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_481.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2394.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_557.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2439.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_568.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2447.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_571.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2448.3.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/
#
#==> complete.genomic.20210929070303-262981_573.out <==
#faSplit byname /francislab/data1/refs/refseq/complete-20210920/complete.2450.1.genomic.fna /francislab/data1/refs/refseq/complete-20210920/split/



