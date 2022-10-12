
#	RepEnrich2

https://github.com/nerettilab/RepEnrich2

First actually try

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING
Found bug in UMI processing




cat data/20200909-TARGET-ALL-P2-RNA_bam/20220309-RepEnrich2-test/README.md 






out/SFHH011AM/SFHH011AM_fraction_counts.txt
out/SFHH011AN/SFHH011AN_fraction_counts.txt
out/SFHH011AO/SFHH011AO_fraction_counts.txt
out/SFHH011AP/SFHH011AP_fraction_counts.txt
out/SFHH011AQ/SFHH011AQ_fraction_counts.txt


module load r

R

read.delim('young_r1_fraction_counts.txt', header=FALSE)
