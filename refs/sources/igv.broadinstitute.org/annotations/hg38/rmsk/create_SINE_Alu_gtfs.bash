#!/usr/bin/env bash
#	
#	
#	#	bed
#	#	chr1	16337936	16337947	Name=FRAM;Class=SINE;Family=Alu
#	#	chr1	17015238	17015249	Name=FRAM;Class=SINE;Family=Alu
#	#	chr1	19467967	19467978	Name=FRAM;Class=SINE;Family=Alu
#	#	chr1	22395697	22395708	Name=FRAM;Class=SINE;Family=Alu
#	
#	#	gtf
#	#	chr1    source  feature 14031284        14031334        .       -       .       feature_name "UCON35.1"
#	
#	echo "Selecting Alu's from SINE"
#	#	Create 6 column bed file with strand in correct position
#	zcat SINE.bed.gz | grep Family=Alu | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4,"1",$5}' | gzip > SINE.Alu.bed.gz
#	
#	#	Or keep 5 column bed file?
#	###zcat SINE.bed.gz | grep Family=Alu | gzip > SINE.Alu.bed.gz
#	
#	
#	#	Extract all of Alu names (about 50)
#	echo "Extracing names"
#	zcat SINE.Alu.bed.gz | awk '{print $4}' | awk -F\; '{print $1}' | awk -F= '{print $2}' | sort | uniq > SINE.Alu.Names.txt
#	
#	
#	
#	
#	#	Add the strand to name
#	#	Or add a 5th column of "1"
#	#	Or ignore and search for RC
#	
#	
#	echo "Creating bed files for each of the Alu's"
#	for name in $( cat SINE.Alu.Names.txt ) ; do
#		echo $name
#		#zcat SINE.Alu.bed.gz | grep "Name=${name};" | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,$4,"1",$5}' | gzip > SINE.Alu.${name}.bed.gz
#		#	correct or do not correct?
#		#	corrected in previous step
#		zcat SINE.Alu.bed.gz | grep "Name=${name};" | gzip > SINE.Alu.${name}.bed.gz
#	done
#	
#	
#	
#	echo "Extracting fasta sequences"
#	for bed in SINE.Alu*bed.gz ; do
#		echo $bed
#		fasta=${bed%.bed.gz}.fasta
#		echo $fasta
#		bedtools getfasta \
#			-fi /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa \
#			-bed ${bed} -fo ${fasta} -name+ -s
#		#	-s will add the strand to the name and reverse complement the sequence if -
#	done
#	
#	
#	
#	
#	echo "Counting"
#	
#	echo "Name,Count,AboxCount,BboxCount" > SINE.Alu.box_counts.csv
#	for n in $( cat SINE.Alu.Names.txt ) ; do 
#		echo ${n}
#		c1=$( grep -c "^>" SINE.Alu.${n}.fasta )
#		#c2=$( grep -ic -E "TGGCTCACGCC|GGCGTGATCCA" SINE.Alu.${n}.fasta )
#		#c3=$( grep -ic -E "GTTCGAGAC|GTCTCGAAC" SINE.Alu.${n}.fasta )
#		c2=$( grep -ic "TGGCTCACGCC" SINE.Alu.${n}.fasta )
#		c3=$( grep -ic "GTTCGAGAC" SINE.Alu.${n}.fasta )
#		echo ${n},${c1},${c2},${c3} >> SINE.Alu.box_counts.csv
#	done 
#	
#	
#	
#	
#	
#	##	#	awk index is 1-based.
#	##	
#	##	#	>Name=FRAM;Class=SINE;Family=Alu::chr1:1118974-1119127(-)
#	##	
#	##	echo "Searching for Aboxes and Bboxes in elements"
#	##	for fasta in SINE.Alu*.fasta ; do
#	##		base=${fasta%.fasta}
#	##		\rm ${base}.?box.gtf
#	##		cat $fasta | paste - - | awk '( $2 ~ /tggctcacgcc/ ){ 
#	##				split(substr($1,2),n,":")
#	##				a=index(n[1],"=")
#	##				b=index(n[1],";")
#	##				name=substr(n[1],a+1,b-a-1)
#	##				i[name]++
#	##				positions=substr(n[4],1)
#	##				split(positions,p,"-")
#	##				strand=substr(n[4],index(n[4],"(")+1,1)
#	##				if( strand == "+" ){
#	##					start=p[1]+index($2,"tggctcacgcc")
#	##					stop=start+length("tggctcacgcc")-1
#	##				} else {
#	##					start=p[2]-index($2,"tggctcacgcc")-length("tggctcacgcc")+2
#	##					stop=start+length("tggctcacgcc")-1
#	##				}
#	##				print n[3]"\tsource\tfeature\t"start"\t"stop"\t.\t"strand"\t.\tfeature_name \""name"."i[name]"\""
#	##			}' >> ${base}.Abox.gtf
#	##			cat $fasta | paste - - | awk '( $2 ~ /gttcgagac/ ){ 
#	##				split(substr($1,2),n,":")
#	##				a=index(n[1],"=")
#	##				b=index(n[1],";")
#	##				name=substr(n[1],a+1,b-a-1)
#	##				i[name]++
#	##				positions=substr(n[4],1)
#	##				split(positions,p,"-")
#	##				strand=substr(n[4],index(n[4],"(")+1,1)
#	##				if( strand == "+" ){
#	##					start=p[1]+index($2,"gttcgagac")
#	##					stop=start+length("gttcgagac")-1
#	##				} else {
#	##					start=p[2]-index($2,"gttcgagac")-length("gttcgagac")+2
#	##					stop=start+length("gttcgagac")-1
#	##				}
#	##				print n[3]"\tsource\tfeature\t"start"\t"stop"\t.\t"strand"\t.\tfeature_name \""name"."i[name]"\""
#	##			}' >> ${base}.Bbox.gtf
#	##	done
#	##	
#	##	#			bedtools getfasta -fi /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa -bed SINE.Alu.FRAM.Abox.gtf -fo test -name+ -s
#	##	
#	##	
#	##	#	chr1	26790	27053	Name=AluSp;Class=SINE;Family=Alu	+
#	##	
#	##	#	input bed only has 5 columns (no score)
#	##	
#	##	#	Beds are 0-based or exclusive? And gtfs are 1-based or inclusive?
#	##	#	Other conversion scripts I've seen add 1 to gtf starts (not stops)
#	##	
#	##	echo "Converting bed to gtf"
#	##	zcat SINE.bed.gz | grep Family=Alu | awk 'BEGIN{FS=OFS="\t"}{
#	##		a=index($4,"=")
#	##		b=index($4,";")
#	##		name=substr($4,a+1,b-a-1)
#	##		i[name]++
#	##		print $1,"source","feature",1+$2,$3,".",$5,".","feature_name \""name"."i[name]"\""
#	##	}' > SINE.Alu.gtf
#	
#	
#	
#	
#	#chr1	source	feature	6500017	6500025	.	-	.	feature_name "FLAM_C.3"
#	
#	
#	#	>Name=FRAM;Class=SINE;Family=Alu::chr1:1118974-1119127(-)
#	#	
#	#	
#	#	print n[3]"\t"start"\t"stop"\t"n[1]"\t1\t"strand}'
#	#	
#	#	strand has already been reverse complemented. Set to "+"? Leave
#	#	
#	
#	
#	#	It may be a good idea to include the initial elements chromosome and start position
#	#	in the name so that the full Alu, Abox and Bbox can more easily be synced.
#	
#	#	>Name=FRAM;Class=SINE;Family=Alu::chr1:1118974-1119127(-)
#	
#	echo "Converting bed to gtf and syncing element names by position"
#	zcat SINE.bed.gz | grep Family=Alu | awk 'BEGIN{FS=OFS="\t"}{
#		a=index($4,"=")
#		b=index($4,";")
#		name=substr($4,a+1,b-a-1)"-"$1"-"1+$2
#		print $1,"source","feature",1+$2,$3,".",$5,".","feature_name \""name"\""
#	}' > SINE.Alu.sync.gtf
#	
#	
#	# >Name=FRAM;Class=SINE;Family=Alu::chr1:1118974-1119127(-)
#	
echo "Searching for Aboxes and Bboxes in elements and syncing names based on full elements position"
for fasta in SINE.Alu*.fasta ; do
	base=${fasta%.fasta}
	\rm ${base}.?box.sync.gtf
	cat $fasta | paste - - | awk '( $2 ~ /tggctcacgcc/ ){ 
			split(substr($1,2),n,":")
			a=index(n[1],"=")
			b=index(n[1],";")
			positions=substr(n[4],1)
			split(positions,p,"-")
			name=substr(n[1],a+1,b-a-1)"-"n[3]"-"1+p[1]
			strand=substr(n[4],index(n[4],"(")+1,1)
			if( strand == "+" ){
				start=p[1]+index($2,"tggctcacgcc")
				stop=start+length("tggctcacgcc")-1
			} else {
				start=p[2]-index($2,"tggctcacgcc")-length("tggctcacgcc")+2
				stop=start+length("tggctcacgcc")-1
			}
			print n[3]"\tsource\tfeature\t"start"\t"stop"\t.\t"strand"\t.\tfeature_name \""name"\""
		}' >> ${base}.Abox.sync.gtf
		cat $fasta | paste - - | awk '( $2 ~ /gttcgagac/ ){ 
			split(substr($1,2),n,":")
			a=index(n[1],"=")
			b=index(n[1],";")
			positions=substr(n[4],1)
			split(positions,p,"-")
			name=substr(n[1],a+1,b-a-1)"-"n[3]"-"1+p[1]
			strand=substr(n[4],index(n[4],"(")+1,1)
			if( strand == "+" ){
				start=p[1]+index($2,"gttcgagac")
				stop=start+length("gttcgagac")-1
			} else {
				start=p[2]-index($2,"gttcgagac")-length("gttcgagac")+2
				stop=start+length("gttcgagac")-1
			}
			print n[3]"\tsource\tfeature\t"start"\t"stop"\t.\t"strand"\t.\tfeature_name \""name"\""
			next
		}( $2 ~ /gatcgagac/ ){ 
			split(substr($1,2),n,":")
			a=index(n[1],"=")
			b=index(n[1],";")
			positions=substr(n[4],1)
			split(positions,p,"-")
			name=substr(n[1],a+1,b-a-1)"-"n[3]"-"1+p[1]
			strand=substr(n[4],index(n[4],"(")+1,1)
			if( strand == "+" ){
				start=p[1]+index($2,"gatcgagac")
				stop=start+length("gatcgagac")-1
			} else {
				start=p[2]-index($2,"gatcgagac")-length("gatcgagac")+2
				stop=start+length("gatcgagac")-1
			}
			print n[3]"\tsource\tfeature\t"start"\t"stop"\t.\t"strand"\t.\tfeature_name \""name"\""
			next
		}' >> ${base}.Bbox.sync.gtf
done





#	Include gatcgagac as a Bbox as well



