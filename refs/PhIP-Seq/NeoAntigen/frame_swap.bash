#!/usr/bin/env bash

#	Try to not use ...
#	CTA, ATA, CCC, CGA, CGG, AGA, AGG, and GGA

#	Input Codon,Amino Acid,Synonymous Codons
#	CTA,Leucine (Leu),TTA, TTG, CTT, CTC, CTG
#	ATA,Isoleucine (Ile),ATT, ATC
#	CCC,Proline (Pro),CCT, CCA, CCG
#	CGA,Arginine (Arg),CGT, CGC,         CGG, AGA, AGG
#	CGG,Arginine (Arg),CGT, CGC, 				CGA, AGA, AGG
#	AGA,Arginine (Arg),CGT, CGC, 				CGA, CGG, AGG
#	AGG,Arginine (Arg),CGT, CGC, 				CGA, CGG, AGA
#	GGA,Glycine (Gly),GGT, GGC, GGG

#	head oligos-ref-56-28.fasta | sed ':a;/^[^>]/s/^\(\(...\)*\)TAT/\1---/;ta' | sed ':a;/^[^>]/s/^\(\(...\)*\)GGA/\1---/;ta'


#	Skip first 16 bases, swap only CTA's preceded by multiple of 3 nts to CTG, 
#	echo "abcdefghijklmnopCTAqrCTAstuvCTAwxyz" | sed ':a;/^[^>]/s/^\(.\{16\}\)\(\(...\)*\)CTA/\1\2CTG/;ta'
#	abcdefghijklmnopCTGqrCTAstuvCTGwxyz


cat oligos-ref-56-28.fasta \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)CTA/\1CTG/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)ATA/\1ATC/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)CCC/\1CCG/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)CGA/\1CGT/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)CGG/\1CGC/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)AGA/\1CGT/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)AGG/\1CGC/;ta' \
	| sed ':a;/^[^>]/s/^\(\(...\)*\)GGA/\1GGT/;ta' > tmp.fasta


#	THEN NEED TO RE-ADD THE PREFIX AND SUFFIX

