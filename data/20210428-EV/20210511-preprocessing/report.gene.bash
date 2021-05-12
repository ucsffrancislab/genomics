#!/usr/bin/env bash

dir=output
#core=${dir}/??.bbduk?.unpaired

#core="${dir}/*_R1_001.*{bbduk,cutadapt}?"
#core="${dir}/*_R1_001.*\{bbduk,cutadapt\}?"
#
#	try this instead of curly braces
#	?(list): Matches zero or one occurrence of the given patterns.
#	*(list): Matches zero or more occurrences of the given patterns.
#	+(list): Matches one or more occurrences of the given patterns.
#	@(list): Matches one of the given patterns.
#	!(list): Matches anything but the given patterns.
#	The list inside the parentheses is a list of globs or extended globs separated by the | character.
#
#core="${dir}/*_R1_001.*@(bbduk|cutadapt)?"
#shopt -s extglob


samples="SFHH005aa SFHH005ab SFHH005ac SFHH005ad SFHH005ae SFHH005af SFHH005ag SFHH005ah SFHH005ai SFHH005aj SFHH005ak SFHH005al SFHH005am SFHH005an SFHH005ao SFHH005ap SFHH005aq SFHH005ar SFHH005a SFHH005b SFHH005c SFHH005d SFHH005e SFHH005f SFHH005g SFHH005h SFHH005i SFHH005j SFHH005k SFHH005l SFHH005m SFHH005n SFHH005o SFHH005p SFHH005q SFHH005r SFHH005s SFHH005t SFHH005u SFHH005v SFHH005w SFHH005x SFHH005y SFHH005z SFHH006aa SFHH006ab SFHH006ac SFHH006ad SFHH006ae SFHH006af SFHH006ag SFHH006ah SFHH006ai SFHH006aj SFHH006ak SFHH006al SFHH006am SFHH006an SFHH006ao SFHH006ap SFHH006aq SFHH006ar SFHH006a SFHH006b SFHH006c SFHH006d SFHH006e SFHH006f SFHH006g SFHH006h SFHH006i SFHH006j SFHH006k SFHH006l SFHH006m SFHH006n SFHH006o SFHH006p SFHH006q SFHH006r SFHH006s SFHH006t SFHH006u SFHH006v SFHH006w SFHH006x SFHH006y SFHH006z"

trimmers="bbduk1 bbduk2 bbduk3 cutadapt1 cutadapt2 cutadapt3"

suffix=""	#	_R1



echo -n "| STAR Gene Counts |"
for s in ${samples} ; do for t in ${trimmers} ; do
	#echo -n " --- |"
	echo -n " |"
done ; done
echo



#	In the next notebook, can you please pull the genes EGFR, IDH, ATRX, CDKN2A/B, NF1, tp53, RB1 and TERT and force box plots on those. They are known Glioma genes and I want to peek.

#		EGFR, Many IDH*, several CDKN2*, NF1, TP53, RB1, TERT

#cat ../20210428-preprocessing/post/gene_counts  | awk '{print $2}' | grep -E "^(EGFR|IDH|CDKN2|NF1|TP53|RB1|TERT)" | sort > requested_genes 

#		vi requested_genes

#touch requested_genes	#	just to make sure it exists
#head -50 post/gene_counts | awk '{print $2}' > post/top_genes

#for gene in $( head -50 post/gene_counts | awk '{print $2}' ) ; do
#for gene in $( awk '{if( seen[$0]++ == 1 )print;}' requested_genes post/top_genes | head -50 ) ; do
for gene in $( cat post/gene_counts | awk '{print $2}' ) ; do
	echo -n "| ${gene} |"
	for s in ${samples} ; do for t in ${trimmers} ; do
		c=$( awk -v gene=$gene '( $2 == gene ){print $1}' ${dir}/${s}.${t}.STAR.hg38.Aligned.toTranscriptome.out.bam.gene_counts 2> /dev/null)
		echo -n " ${c} |"
	done ; done
	echo
done


