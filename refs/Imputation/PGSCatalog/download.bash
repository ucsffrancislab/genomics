#!/usr/bin/env bash


for i in {1..5999} ; do
	pgs=$( printf "PGS%06d" $i )
	wget https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/${pgs}/ScoringFiles/Harmonized/${pgs}_hmPOS_GRCh37.txt.gz
done

