#!/usr/bin/env bash


while read depth file ; do
	if [ -n "${depth}" ] && [ -n "${file}" ] ; then
		depth=$( printf "%.2f\n" ${depth} )
		base=$( basename ${file} )
		path=$( realpath /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in/${base} )
		size=$( ls -l ${path} | awk '{print $5/1000000000}' )
		echo -e "${base}\t${depth}\t${path}\t${size}"
	fi
done < <( grep --no-group-separator --no-filename --after-context 1 "^Computed depth of coverage at " logs/*out | sed -e '1~2s/Computed depth of coverage at //' -e '2~2s/Running MELT IndivAnalysis on //' | paste - - )


#	more logs/MELT1.20230307084059504287010-1188875_1283.out
#	ll $( realpath /francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in/Patient522.X00173.bam )
#	-rwxrwxr-x 1 root costellolab 0 Sep 15 10:24 /costellolab/data3/jocostello/LG3/exomes_recal/Patient522/X00173.bwa.realigned.rmDups.recal.bam


#	sort -k2nr,2 depth.tsv | tail
#	Patient211.Z00254.bam	0.21	/costellolab/data3/jocostello/LG3/exomes_recal/Patient211/Z00254.bwa.realigned.rmDups.recal.bam	1.61543
#	Patient157t.Z00599t.bam	0.19	/costellolab/data3/jocostello/LG3/exomes_recal/Patient157t/Z00599t.bwa.realigned.rmDups.recal.bam	1.42428
#	Patient157t.Z00601t.bam	0.12	/costellolab/data3/jocostello/LG3/exomes_recal/Patient157t/Z00601t.bwa.realigned.rmDups.recal.bam	1.1121
#	Patient157t10.Z00599t10.bam	0.04	/costellolab/data3/jocostello/LG3/exomes_recal/Patient157t10/Z00599t10.bwa.realigned.rmDups.recal.bam	0.214725
#	Patient157t10.Z00600t10.bam	0.04	/costellolab/data3/jocostello/LG3/exomes_recal/Patient157t10/Z00600t10.bwa.realigned.rmDups.recal.bam	0.210538
#	Patient157t10.Z00601t10.bam	0.03	/costellolab/data3/jocostello/LG3/exomes_recal/Patient157t10/Z00601t10.bwa.realigned.rmDups.recal.bam	0.190668
#	GBM02.Z00384.bam	0.01	/costellolab/data3/jocostello/LG3/exomes_recal/GBM02/Z00384.bwa.realigned.rmDups.recal.bam	14.4968
#	Patient211.Z00386-trim-b30.bam	0.01	/costellolab/data3/jocostello/LG3/exomes_recal/Patient211/Z00386-trim-b30.bwa.realigned.rmDups.recal.bam	0.657831
#	Patient211.Z00386.bam	0.00	/costellolab/data3/jocostello/LG3/exomes_recal/Patient211/Z00386.bwa.realigned.rmDups.recal.bam	1.42055
#	Patient211.Z00386.bam	0.00	/costellolab/data3/jocostello/LG3/exomes_recal/Patient211/Z00386.bwa.realigned.rmDups.recal.bam	1.42055


#	ls -1 out/*bam | xargs -I% basename % | sort | uniq > out_bam_list.txt &
#	ls -1 in/*bam | xargs -I% basename % | sort | uniq > in_bam_list.txt &
#	cut -f1 depth.tsv | sort | uniq > depth_bam_list.txt &


