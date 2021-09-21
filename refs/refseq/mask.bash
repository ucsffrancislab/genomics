#!/usr/bin/env bash


mkdir raw
mkdir masks

#for f in /francislab/data1/refs/refseq/viral-20210916/split/NC_056*.fa.gz ; do
#for f in /francislab/data1/refs/refseq/viral-20210916/split/NC_00*.fa.gz ; do
for f in ${PWD}/*complete_genome.fa.gz ; do

	#	sequence names longer that 50 are not permitted by repeat masker so only use
	#	>NC_053004.1 Salmonella phage TS13, complete genome
	#		NOT
	#	>NC_053004.1_Salmonella_phage_TS13,_complete_genome

	#accession=$( head -1 $f | sed -e 's/_/ /g' -e 's/^>NC />NC_/' -e 's/^>AC />AC_/' -e 's/^>//' | awk '{print $1}' )
	#accession=$( zcat $f | head -1 | sed -e 's/_/ /g' -e 's/^>NC />NC_/' -e 's/^>AC />AC_/' -e 's/^>//' | awk '{print $1}' )
	accession=$( zcat $f | head -1 | sed -e 's/^>//' | awk '{print $1}' )
	echo $accession

	l=raw/${accession}.fa.gz
	#l=raw/${accession}.fa

	if [ ! -e ${l} ] ; then
		#cat ${f} | sed -e '1s/_/ /g' -e '1s/^>NC />NC_/' -e 's/^>AC />AC_/' > ${l}
		#zcat ${f} | sed -e '1s/_/ /g' -e '1s/^>NC />NC_/' -e '1s/^>AC />AC_/' | gzip > ${l}
		#zcat ${f} | sed -e '1s/_/ /g' -e '1s/^>NC />NC_/' -e '1s/^>AC />AC_/' > ${l}
		#zcat ${f} ${l}
		cp ${f} ${l}
		chmod +w ${l}
		#ln -s $f $l
	fi

#  #m=masks/$( basename $f .fa.gz ).fa
#  #m=masks/$( basename $l .fa.gz )
#  m=masks/$( basename $l .fa )
  m=masks/$( basename $l .fa.gz )
  #if [ ! -f ${m}.masked.fa.gz ] ; then
  if [ ! -f ${m}.fa.cat ] ; then
    #echo ~/.local/RepeatMasker/RepeatMasker -pa 8 $l
    #~/.local/RepeatMasker/RepeatMasker -pa 8 -dir masks $l
		#chmod +w $l
    ~/.local/RepeatMasker/RepeatMasker -pa 8 -dir masks $l
		#chmod -w $l
    if [ -f ${m}.fa.masked ] ; then
      mv ${m}.fa.masked ${m}.masked.fa
			gzip ${m}.masked.fa
    fi  
    chmod -w ${m}* #${m}
  fi

done

