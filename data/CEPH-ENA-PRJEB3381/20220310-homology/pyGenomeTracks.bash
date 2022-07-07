#!/usr/bin/env bash

#	BAM to BED for pyGenomeTracks

module load CBI samtools bedtools2/2.29

mkdir -p bed_file_comparison_images

basedir=/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology
BDIR=/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/bed_file_comparison_images
MDIR=/francislab/data1/working/20211111-hg38-viral-homology/bed_file_comparison_images

#for accession in $( samtools view -H /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam | grep "^@SQ" | awk '{print $2}' | awk -F: '{print $2}' ) ; do

for accession in NC_000898.1 NC_001716.2 NC_007605.1 NC_032111.1 NC_001650.2 NC_004812.1 NC_001806.2 NC_006273.2 NC_009333.1 NC_038524.1 NC_009334.1 NC_041925.1 NC_006146.1 NC_055142.1 ; do
	echo ${accession}
	
	for bam in ${basedir}/out/ERR194147.{Raw,RM,RawHM,RMHM}.bam ; do
		echo $bam
		
		chars=$( samtools view -H ${bam} | grep "SN:${accession}" | awk -F: '{print $NF}' )
		echo ${chars}
		
		bed=bed_file_comparison_images/$( basename ${bam} .bam ).${accession}.bed
		echo ${bed}
		
		samtools depth -r ${accession} ${bam} | awk -F"\t" -v a=${accession} -v c=${chars} 'BEGIN{true=1;false=0;start=0}
		function append(){ if( prev>start ){ blockSizes=blockSizes""prev-start","; blockStarts=blockStarts""start-1","; blockCount++ } }
		( !start ){ start=$2; prev=$2; next }
		(  start && $2 == prev+1 ){ prev=$2 }
		(  start && $2 >= prev+1 ){ append(); start=$2; prev=$2 }
		END{ append(); print a"\t1\t"c"\t.\t0\t+\t0\t0\t0\t"blockCount+2"\t0,"blockSizes"0,\t0,"blockStarts""c-1"," }' > ${bed}
	
	done
	
	rawbam=${basedir}/out/ERR194147.Raw.bam
	echo ${rawbam}
	#chars=$( samtools view -H ${rawbam} | grep "SN:${accession}" | awk -F: '{print $NF}' )
	
#	ini=bed_file_comparison_images/$( basename ${rawbam} .Raw.bam ).${accession}.ini
#	echo ${ini}

	title="ERR194147 - ${accession}"
	echo ${title}
	
#	pyGenomeTracks --tracks ${ini} \
#		--region ${accession}:0-${chars} \
#		--trackLabelFraction 0.15 \
#		--width 30 \
#		--dpi 120 \
#		--title "${title}                " \
#		--fontSize 16 \
#		-o ${ini%.ini}.png 
	
	ini=bed_file_comparison_images/$( basename ${rawbam} .Raw.bam ).${accession}.plus.ini
	echo ${ini}

	sed -e "s'RAW_HM_FASTA_MASK_BED_FILE'${MDIR}/raw.split.HM.bt2/${accession}.split.25.mask.fasta.bed'" \
		-e "s'RM_FASTA_MASK_BED_FILE'${MDIR}/RM/${accession}.masked.fasta.bed'" \
		-e "s'RM_HM_FASTA_MASK_BED_FILE'${MDIR}/RM.split.HM.bt2/${accession}.masked.split.25.mask.fasta.bed'" \
		-e "s'RAW_ALIGNMENT_BED_FILE'${BDIR}/ERR194147.Raw.${accession}.bed'" \
		-e "s'RAW_HM_ALIGNMENT_BED_FILE'${BDIR}/ERR194147.RawHM.${accession}.bed'" \
		-e "s'RM_ALIGNMENT_BED_FILE'${BDIR}/ERR194147.RM.${accession}.bed'" \
		-e "s'RM_HM_ALIGNMENT_BED_FILE'${BDIR}/ERR194147.RMHM.${accession}.bed'" \
		${BDIR}/ERR194147.template.plus.ini > ${ini}
	
	cmd="pyGenomeTracks --tracks ${ini} \
		--region ${accession}:0-${chars} \
		--trackLabelFraction 0.15 \
		--width 30 \
		--dpi 120 \
		--title '${title}                ' \
		--fontSize 16 \
		-o ${ini%.ini}.png"
	echo $cmd
	eval $cmd

done


exit



pyGenomeTracks --tracks bed_file_comparison_images/ERR194147.NC_001716.2.plus.0-11000.ini --region NC_001716.2:1-11000 --trackLabelFraction 0.15 --width 30 --dpi 120 --title 'ERR194147 - NC_001716.2:1-11000 ' --fontSize 16 -o bed_file_comparison_images/ERR194147.NC_001716.2.plus.1-11000.png

pyGenomeTracks --tracks bed_file_comparison_images/ERR194147.NC_001716.2.plus.0-11000.ini --region NC_001716.2:143000-153000 --trackLabelFraction 0.15 --width 30 --dpi 120 --title 'ERR194147 - NC_001716.2:143000-153000 ' --fontSize 16 -o bed_file_comparison_images/ERR194147.NC_001716.2.plus.143000-153000.png


samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1


[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
5322	0	1591.8160083342	1195	1654	2021
[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
5322	0	1585.3491150777	1191	1651	2021
[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
5322	0	1553.5625963928	1166	1615	2001
[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_007605.1 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
5322	0	1548.7571512545	1165	1614	2001



samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1




[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
185	0	0.77882806375751	0	0	0
[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
0	0	0	0	0	0
[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
40218	0	72.668767964463	0	0	0
[gwendt@c4-dev2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology]$ samtools depth -a -r NC_001716.2 /francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam | awk '{print $3}' | datamash max 1 min 1 mean 1 q1 1 median 1 q3 1
0	0	0	0	0	0


The lower quartile, or first quartile (Q1), is the value under which 25% of data points are found when they are arranged in increasing order. The upper quartile, or third quartile (Q3), is the value under which 75% of data points are found when arranged in increasing order.


basedir=/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology
for accession in NC_000898.1 NC_001716.2 NC_007605.1 NC_032111.1 NC_001650.2 NC_004812.1 NC_001806.2 NC_006273.2 NC_009333.1 NC_038524.1 NC_009334.1 NC_041925.1 NC_006146.1 NC_055142.1 ; do
echo ${accession}
for bam in ${basedir}/out/ERR194147.{Raw,RM,RawHM,RMHM}.bam ; do
echo $bam
samtools depth -a -r ${accession} ${bam} | awk '{print $3}' | datamash min 1 q1 1 mean 1 q3 1 max 1 median 1
done
done

NC_000898.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	27.12708341044	0	7052	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0.00062301836978916	0	1	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_001716.2
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.77882806375751	0	185	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	72.668767964463	0	40218	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_007605.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	1195	1591.8160083342	2021	5322	1654
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	1166	1553.5625963928	2001	5322	1615
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	1191	1585.3491150777	2021	5322	1651
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	1165	1548.7571512545	2001	5322	1614
NC_032111.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	4898.646924941	0	5749587	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_001650.2
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.014758266960892	0	12	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0.15812816161441	0	99	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_004812.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.096441714661105	0	109	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0.005752954607785	0	4	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0.0019325335323269	0	1	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0.0032145112220883	0	4	0
NC_001806.2
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.17071119811854	0	182	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0.0019510977388288	0	3	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_006273.2
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_009333.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.0043922910218962	0	6	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0.010241431046105	0	14	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_038524.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_009334.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	12	433.68736542335	794	1665	336
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	8	431.60393947813	798	1665	324
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	14	436.33401055776	796	2663	342
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	9	434.03101340557	800	2676	328
NC_041925.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	170.74589685608	0	19790	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	165.36616456343	0	19788	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0	0	0	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	0	0	0	0
NC_006146.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.064811567774816	0	4	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	1.9000853322112	0	541	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0.064811567774816	0	4	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	1.9000853322112	0	541	0
NC_055142.1
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.Raw.bam
0	0	0.15240208098185	0	29	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RM.bam
0	0	5.2702097847663	0	5529	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RawHM.bam
0	0	0.13934404961144	0	29	0
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220310-homology/out/ERR194147.RMHM.bam
0	0	5.2689059276846	0	5529	0



