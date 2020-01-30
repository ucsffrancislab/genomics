#!/usr/bin/env python2

import gzip
from itertools import islice

import io


import sys
if( len(sys.argv) != 7 ):
  sys.exit("Expecting 2 input and 4 output fastq.gz filenames")
r1_in_filename = sys.argv[1]
r2_in_filename = sys.argv[2]
r1_out_good_filename = sys.argv[3]
r2_out_good_filename = sys.argv[4]
r1_out_bad_filename = sys.argv[5]
r2_out_bad_filename = sys.argv[6]

#r1_in_filename='/Users/jakewendt/20191008_Stanford71-22-trim-test/cutadapt-aAopm15/22_R1.fastq.gz'
#r2_in_filename='/Users/jakewendt/20191008_Stanford71-22-trim-test/cutadapt-aAopm15/22_R2.fastq.gz'
#r1_out_good_filename="r1.out_good.fastq.gz"
#r2_out_good_filename="r2.out_good.fastq.gz"
#r1_out_bad_filename="r1.out_bad.fastq.gz"
#r2_out_bad_filename="r2.out_bad.fastq.gz"


with gzip.open(r1_in_filename, 'rb') as r1in, \
		gzip.open(r2_in_filename, 'rb') as r2in, \
		io.BufferedWriter( gzip.open(r1_out_good_filename, 'wb', 3) ) as r1outgood, \
		io.BufferedWriter( gzip.open(r2_out_good_filename, 'wb', 3) ) as r2outgood, \
		io.BufferedWriter( gzip.open(r1_out_bad_filename, 'wb', 3) ) as r1outbad, \
		io.BufferedWriter( gzip.open(r2_out_bad_filename, 'wb', 3) ) as r2outbad:

	#	Not a fan of the "while true break" style
	#	but can't find an alternative
	while True:
		r1lines = list(islice(r1in,4))
		if( len(r1lines) ) != 4:
			break
		r2lines = list(islice(r2in,4))
		if( len(r2lines) ) != 4:
			break
		
		if(len(r1lines[1]) == len(r2lines[1])):
			for i in 0,1,2,3:
				r1outgood.write(r1lines[i])
				r2outgood.write(r2lines[i])
		else:
			for i in 0,1,2,3:
				r1outbad.write(r1lines[i])
				r2outbad.write(r2lines[i])


#	works but takes WAY TOO LONG
#	bbduk only takes 6 minutes to process these files. this is like 10x longer

#	just reading
#	time scripts/filter_paired_fastq_on_equal_read_length.py  
#	real	4m3.845s

#	writing text
#	real	5m20.393s

#	writing gzip with default compression (9)
#	real	74m14.706s

#	buffered writing gzip with compression 9
#	real	65m19.876s

#	writing gzip with compression 3
#	real	15m34.028s

#	buffered writing gzip with compression 3
#	real	10m9.084s


