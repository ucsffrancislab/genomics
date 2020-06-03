#!/bin/sh

#/my/home/jwendt/ftp/APL


for dir in `ls -d *-*`; do

	echo $dir	#	/my/home/ccls/data/working/APL_RNA-Seq
                
#	dir=${file%%/nobackup/trinity_non_human_paired.fasta}
#	echo $dir		#	P-NB4-stranded
#	base=${file%%.fasta}
#	echo $base	#	P-NB4-stranded/nobackup/trinity_non_human_paired

	mkdir -p /my/home/jwendt/ftp/APL/$dir
	cp $dir/trinity_non_human_paired.tblastx_viral.txt.gz /my/home/jwendt/ftp/APL/$dir/
	
	echo
done
