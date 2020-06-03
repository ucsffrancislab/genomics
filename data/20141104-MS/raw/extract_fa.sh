for file in `ls -1d /my/home/ccls/working/MS/*.bam`
do 
echo STARTING `basename $file`

outfile="/my/home/ccls/working/MS/"`basename $file`

bam2fastx --fasta --all -N $file > ${outfile}.fa

echo DONE `basename $file`

done
