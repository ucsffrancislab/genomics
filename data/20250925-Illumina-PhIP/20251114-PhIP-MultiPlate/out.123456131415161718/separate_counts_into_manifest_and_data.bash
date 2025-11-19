#!/usr/bin/env bash

#Separate the meta data

head -9 Counts.csv | datamash transpose -t, | tail -n +3 | cut -d, -f1,2,4- | \
awk 'BEGIN{FS=OFS=","}{
	if( $8 ~ /^(1|13)$/ ){
		lane = "L1"
	} else if( $8 ~ /^(2|14)$/ ){
		lane = "L2"
	} else if( $8 ~ /^(3|4)$/ ){
		lane = "L3"
	} else if( $8 ~ /^(5|6)$/ ){
		lane = "L4"
	} else if( $8 ~ /^(15|16)$/ ){
		lane = "L5"
	} else if( $8 ~ /^(17|18)$/ ){
		lane = "L6"
	} else {
		lane = "L0"
	}
	if( $1 ~ /^CSE/ ){
		class = "control"
	} else if( $1 ~ /^Blank/ ){
		class = "blank"
	} else if( $1 ~ /^PLib/ ){
		class = "phage_library"
	} else {
		class = "subject"
	}
	print $0,lane,class
}' | sort -t, -k1,1 | sed '1isample,subject,type,study,group,age,sex,plate,lane,class' | sed 's/Unnamed: [[:digit:]]\{1,2\}_level_[[:digit:]]\{1,2\},/,/g' > manifest.csv


head -1 Counts.csv | cut -d, -f1,3- > tmp1.csv

tail -n +10 Counts.csv | cut -d, -f1,3- >> tmp1.csv

cat tmp1.csv | datamash transpose -t, > tmp2.csv

head -1 tmp2.csv > data.csv

tail -n +2 tmp2.csv | sort -t, -k1,1 >> data.csv

sed -i '1s/^id/sample/' data.csv

\rm tmp?.csv

