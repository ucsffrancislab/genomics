
For TEProF2

wget -O rmsk.unsorted.bed "https://genome.ucsc.edu/cgi-bin/hgTables?hgsid=1610086357_bNc7ydZ0fr7iTXuKTOQKvNyRAgc2&boolshad.hgta_printCustomTrackHeaders=0&hgta_ctName=tb_rmsk&hgta_ctDesc=table+browser+query+on+rmsk&hgta_ctVis=pack&hgta_ctUrl=&fbQual=whole&fbUpBases=200&fbDownBases=200&hgta_doGetBed=get+BED"

module load htslib
bedSort rmsk.unsorted.bed rmsk.bed
bgzip rmsk.bed
tabix -p bed rmsk.bed.gz


Getting repeatmasker.lst requires a POST so can't figure it out at the command line.

cat repeatmasker.lst | awk 'NR>1{print $11"\t"$12"\t"$13}' | sort | uniq > repeatmasker_hg38_description_uniq.lst



