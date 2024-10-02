
#	20240925-Illumina-PhIP/20240925c-PhIP


ONLY PRIMARY READS
ONLY WITH START NEAR 1
ONLY QUALITY > 40?
NOT idxstats


Most of this could be fully scripted. Next time.


```

mkdir -p out
module load samtools
for bam in ../20240925b-bowtie2/out/*bam ; do
  SAMPLE_ID=$( basename ${bam} .VIR3_clean.1-160.bam )
  echo $bam
  echo $SAMPLE_ID
  samtools view -F SECONDARY,SUPPLEMENTARY -q 40 ${bam} | awk '( $4 < 10 ){print $3}' | sort -k1n | uniq -c | awk '{print $2","$1}' | sed -e "1 i id,${SAMPLE_ID}" | gzip > out/${SAMPLE_ID}.q40.count.csv.gz
  chmod 440 out/${SAMPLE_ID}.q40.count.csv.gz
done

```



Note: To perform the Z-score analysis, count.combined files are merged into a table, and columns corresponding with no-serum controls are summed in a column called "input".

Separate the "input" samples

In this case, the dataset is 4 separate comparisono so do it separately

```

#mkdir out/input
#
#for sample in $( awk -F, '($2=="PBS"){print $1}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv ) ; do
# mv out/${sample}.q40.count.csv.gz out/input
#done


for condition in 1 2 3 4 ; do
samples=$( awk -F, -v condition=${condition} '( $6 == condition ){print $1}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv )
mkdir out/${condition}
for sample in $samples ; do
echo $condition $sample
mv out/${sample}.q40.count.csv.gz out/${condition}/
done
samples=$( awk -F, -v condition=${condition} '( $2 == "PBS" && $6 == condition ){print $1}' /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv )
mkdir out/${condition}/input
for sample in $samples ; do
echo $condition $sample
mv out/${condition}/${sample}.q40.count.csv.gz out/${condition}/input/
done ; done

```



Then sum them with `sum_counts_files.py`

```


#sum_counts_files.py -o out/input/All.count.csv out/input/*.q40.count.csv.gz
#sed -i '1s/sum/input/' out/input/All.count.csv
#gzip out/input/All.count.csv


for condition in 1 2 3 4 ; do
sum_counts_files.py -o out/${condition}/input/All.count.csv out/${condition}/input/*.q40.count.csv.gz
sed -i '1s/sum/input/' out/${condition}/input/All.count.csv
gzip out/${condition}/input/All.count.csv
done

chmod -w out/?/input/All.count.csv.gz

```


Create count matrices to feed to Z-score

```

#merge_all_combined_counts_files.py --int -o All.count.csv out/*.q40.count.csv.gz out/input/All.count.csv.gz
#chmod 400 All.count.csv

for condition in 1 2 3 4 ; do
merge_all_combined_counts_files.py --int -o ${condition}.count.csv \
  out/${condition}/*.q40.count.csv.gz out/${condition}/input/All.count.csv.gz
chmod 400 ${condition}.count.csv
done

```




Full pipeline … Process as 3 replicates (a,b,c), 2 replicates ( (a,b),(a,c),(b,c))

Multiple runs with differing blank / input  and data for Zscore analysis - 4 different conditions


Really doesn't take that long so could just run locally.

Create Zscores

```
#mkdir logs
#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#  --job-name=zscore --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
#  --output=${PWD}/logs/Zscore.$( date "+%Y%m%d%H%M%S%N" ).out.log \
#  --wrap "module load r; elledge_Zscore_analysis.R ${PWD}/All.count.csv"

#module load r; elledge_Zscore_analysis.R ${PWD}/All.count.csv

module load r
for condition in 1 2 3 4 ; do
elledge_Zscore_analysis.R ${condition}.count.csv
done

```



Zscores with public epitopes

```

#awk 'BEGIN{FS=OFS=","}{print $13,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' All.count.Zscores.csv > tmp
#head -1 tmp > All.count.Zscores.reordered.join_sorted.csv
#tail -n +2 tmp | sort -t, -k1,1 >> All.count.Zscores.reordered.join_sorted.csv
#join --header -t, /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.join_sorted.csv All.count.Zscores.reordered.join_sorted.csv > All.public_epitope_annotations.Zscores.csv 


for condition in 1 2 3 4 ; do
awk 'BEGIN{FS=OFS=","}{print $4,$1,$2,$3}' ${condition}.count.Zscores.csv > tmp
head -1 tmp > ${condition}.count.Zscores.reordered.join_sorted.csv
tail -n +2 tmp | sort -t, -k1,1 >> ${condition}.count.Zscores.reordered.join_sorted.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.join_sorted.csv ${condition}.count.Zscores.reordered.join_sorted.csv > ${condition}.public_epitope_annotations.Zscores.csv 
done

```





I think that the output of the zscore command needs to have the columns reordered.

They are "all of the samples ...,id,group,input"

Not sure if "input" is needed anymore or what "group" is.

I don't use this.


```

#awk 'BEGIN{FS=OFS=","}(NR==1){print $5,$6,$1,$2,$3,$4,$7}(NR>1){printf "%d,%d,%.2g,%.2g,%.2g,%.2g,%d\n",$5,$6,$1,$2,$3,$4,$7}' \
#  Elledge/fastq_files/merged.combined.count.Zscores.csv > Elledge/fastq_files/merged.combined.count.Zscores.reordered.csv

```




Determine actual hits by zscore threshold in both replicates





```

#for condition in 1 2 3 4 ; do
#all_samples=$( awk -F, -v condition=${condition} '($2=="SE" && $6==condition){print $1}' \
#  /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv | paste -sd' ' )
#booleanize_Zscore_replicates.py --sample S${condition} --matrix All.count.Zscores.csv \
#  --output ${condition}.count.Zscores.1-2-3-hits.csv $all_samples
#booleanize_Zscore_replicates.py --sample S${condition} --matrix All.count.Zscores.csv \
#  --output ${condition}.count.Zscores.1-2-hits.csv $( echo $all_samples | cut -d' ' -f1,2 )
#booleanize_Zscore_replicates.py --sample S${condition} --matrix All.count.Zscores.csv \
#  --output ${condition}.count.Zscores.1-3-hits.csv $( echo $all_samples | cut -d' ' -f1,3 )
#booleanize_Zscore_replicates.py --sample S${condition} --matrix All.count.Zscores.csv \
#  --output ${condition}.count.Zscores.2-3-hits.csv $( echo $all_samples | cut -d' ' -f2,3 )
#done


for condition in 1 2 3 4 ; do
all_samples=$( awk -F, -v condition=${condition} '($2=="SE" && $6==condition){print $1}' \
  /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv | paste -sd' ' )
booleanize_Zscore_replicates.py --sample S${condition} --matrix ${condition}.count.Zscores.csv \
  --output ${condition}.count.Zscores.1-2-3-hits.csv $all_samples
booleanize_Zscore_replicates.py --sample S${condition} --matrix ${condition}.count.Zscores.csv \
  --output ${condition}.count.Zscores.1-2-hits.csv $( echo $all_samples | cut -d' ' -f1,2 )
booleanize_Zscore_replicates.py --sample S${condition} --matrix ${condition}.count.Zscores.csv \
  --output ${condition}.count.Zscores.1-3-hits.csv $( echo $all_samples | cut -d' ' -f1,3 )
booleanize_Zscore_replicates.py --sample S${condition} --matrix ${condition}.count.Zscores.csv \
  --output ${condition}.count.Zscores.2-3-hits.csv $( echo $all_samples | cut -d' ' -f2,3 )
done

#chmod -w All.count.Zscores.csv
#booleanize_Zscore_replicates.py -s SE1 -m ${PWD}/All.count.Zscores.csv S1 S2
#booleanize_Zscore_replicates.py -s SE2 -m ${PWD}/All.count.Zscores.csv S5 S6
#booleanize_Zscore_replicates.py -s SE3 -m ${PWD}/All.count.Zscores.csv S9 S10
#gzip All.count.csv All.count.Zscores.csv

```



**Account for public epitopes BEFORE virus score**


Create a list of viral species sorted by number of hits for all samples

```


tail -n +2 ?.count.Zscores.*-hits.csv | sort -t, -k1,1 | awk -F, '($2=="True")' > All.count.Zscores.merged_trues.csv
#tail -n +2 All.count.Zscores.SE?.csv | sort -t, -k1,1 | awk -F, '($2=="True")' > All.count.Zscores.merged_trues.csv

sed -i '1iid,all' All.count.Zscores.merged_trues.csv

join --header -t, All.count.Zscores.merged_trues.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv > tmp

awk -F, '(NR>1){print $3}' tmp | sort | uniq -c | sort -k1nr,1 | sed 's/^ *//' | cut -d' ' -f2- > species_order.txt
\rm tmp

```


Create virus scores in same order for all samples using the previous species order file.

```
#for sample in SE1 SE2 SE3 ; do
#echo ${sample}
#elledge_calc_scores_nofilter_forceorder.py --hits All.count.Zscores.${sample}.csv --oligo_metadata /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.csv --species_order species_order.txt > tmp 
#head -1 tmp > All.count.Zscores.${sample}.virus_scores.csv
#tail -n +2 tmp | sort -t, -k1,1 >> All.count.Zscores.${sample}.virus_scores.csv
#done



for condition in 1 2 3 4 ; do
for cols in 1-2-3 1-2 1-3 2-3 ; do
elledge_calc_scores_nofilter_forceorder.py --hits ${condition}.count.Zscores.${cols}-hits.csv --oligo_metadata /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.csv --species_order species_order.txt > tmp 
head -1 tmp > ${condition}.count.Zscores.${cols}-hits.virus_scores.csv
tail -n +2 tmp | sort -t, -k1,1 >> ${condition}.count.Zscores.${cols}-hits.virus_scores.csv
done ; done


./merge.py -o merged.virus_scores.csv --int *-hits.virus_scores.csv

```










Threshold check


~/github/ucsffrancislab/PhIP-Seq/Elledge/VirScan_viral_thresholds.csv 


A sample is determined to be seropositive for a virus if the virus_score > VirScan_viral_threshold and if at least one public epitope from that virus scores as a hit. The file “VirScan_viral_thresholds” contains the thresholds for each virus (Supplementary materials).


GREATER THAN THRESHOLD. NOT GREATER THAN OR EQUAL TO THE THRESHOLD.

```

for virus_scores in ?.count.Zscores.*-hits.virus_scores.csv ; do
echo ${virus_scores}
join --header -t, ~/github/ucsffrancislab/PhIP-Seq/Elledge/VirScan_viral_thresholds.csv ${virus_scores} | awk 'BEGIN{FS=OFS=","}(NR==1){print "Species",$3}(NR>1 && $3>$2){print $1,$3}' > ${virus_scores%.csv}.threshold.csv
done 

```















```

#for sample in SE1 SE2 SE3 ; do
#echo ${sample}
#join -t, <( tail -n +2 All.count.Zscores.${sample}.csv | sort -t, -k1,1 ) <( tail -n +2 /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.sorted.csv ) | awk -F, '($2=="True"){print $6}' | sort | uniq > All.count.Zscores.${sample}.found_public_epitopes.BEFORE_scoring.txt
#sed -i '1iSpecies' All.count.Zscores.${sample}.found_public_epitopes.BEFORE_scoring.txt
#done

for hits in ?.count.Zscores.*-hits.csv ; do
echo ${hits}
join -t, <( tail -n +2 ${hits} | sort -t, -k1,1 ) <( tail -n +2 /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.sorted.csv ) | awk -F, '($2=="True"){print $6}' | sort | uniq > ${hits%.csv}.found_public_epitopes.BEFORE_scoring.txt
sed -i '1iSpecies' ${hits%.csv}.found_public_epitopes.BEFORE_scoring.txt
done

```


```

#for sample in SE1 SE2 SE3 ; do
#echo ${sample}
#join -t, <( sort -t, -k1,1 All.count.Zscores.${sample}.peptides.txt ) <( tail -n +2 /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.sorted.csv ) | awk -F, '{print $2}' | sort | uniq > All.count.Zscores.${sample}.found_public_epitopes.AFTER_scoring.txt
#sed -i '1iSpecies' All.count.Zscores.${sample}.found_public_epitopes.AFTER_scoring.txt
#done

for peptides in ?.count.Zscores.*-hits.7.peptides.txt ; do
echo ${peptides}
join -t, <( sort -t, -k1,1 ${peptides} ) <( tail -n +2 /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.sorted.csv ) | awk -F, '{print $2}' | sort | uniq > ${peptides%.7.peptides.txt}.found_public_epitopes.AFTER_scoring.txt
sed -i '1iSpecies' ${peptides%.7.peptides.txt}.found_public_epitopes.AFTER_scoring.txt
done

```



```

#for when in BEFORE_scoring AFTER_scoring ; do
#for sample in SE1 SE2 SE3 ; do
#echo ${sample}.${when}
#join --header -t, All.count.Zscores.${sample}.found_public_epitopes.${when}.txt All.count.Zscores.${sample}.virus_scores.threshold.csv > All.count.Zscores.${sample}.${when}.seropositive.csv
#done 
#./merge.py -o merged.${when}.seropositive.csv --int All*.${when}.seropositive.csv
#done



for scoring in ?.count.Zscores.*-hits.found_public_epitopes.*_scoring.txt ; do
echo ${scoring}
join --header -t, ${scoring} ${scoring%.found_public_epitopes.*_scoring.txt}.virus_scores.threshold.csv > ${scoring%.txt}.seropositive.csv
done 

./merge.py -o merged.seropositive.csv --int *_scoring.seropositive.csv


```





##	20240917
#
#
#```
#
#head public_epitope_annotations.clean.csv 
#id,species,public_epitope
#395,Enterovirus B,FSVRMLKDTPFIEQSNELQGDVKEAVENAMGRVADTIRSGPTNSEAIPALTAVETG
#758,Human adenovirus D,KQVAPGLGVQTVDIQIPTDMDVDKKPSTSIEVQTDPWLPASTATVSTSTAATATEP
#843,Rhinovirus B,PEHQLASHTQGNVSVKYKYTHPGEQGIDLDSVAETGGASHDPVYSMNGTLIGNLLI
#1181,Human adenovirus E,MGDDHPEPPTPFETPSLHDLYDLEVDVPEDDPNEKAVNDLFSDAALLAAEEASSPS
#1198,Human adenovirus E,PPLDKRGDKRPRPDAEETLLTHTDEPPPYEEAVKLGLPTTRPIAPLATGVLKPESS
#1250,Hepatitis B virus,QHFRKLLLLDEEAGPLEEELPRLADEGLNRRVAEDLNLGNLNVSIPWTHKVGNFTG
#1334,Alphapapillomavirus 10,QKPTPEKEKQDPYKDMSFWEVNLKEKFSSELDQFPLGR
#2206,Tanapox virus,KFFKKKNKPVCIELKKIINTNKTLTLNSEDWTDMGSCEIYANFRSSKREKSFKLKD
#2250,Tanapox virus,NKKDVSYSPLNKNIVIERKNKPKGMLNIDSSSGIYANSKENVAITPSSSNVNVFKE
#
#
#```
#
#```
#head /francislab/data1/refs/PhIP-Seq/VIR3_clean.select.csv out/S1.q40.count.csv.gz All.count.Zscores.SE1.csv All.count.Zscores.SE1.csv.7.peptides.txt /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.clean.csv
#
#python3 ./mega_merge.py /francislab/data1/refs/PhIP-Seq/VIR3_clean.select.csv out/S1.q40.count.csv.gz All.count.Zscores.SE1.csv All.count.Zscores.SE1.csv.7.peptides.txt /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.clean.csv
#
#
#python3 ./mega_merge.py -o SE1.merged.data.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.select.csv out/S1.q40.count.csv.gz out/S2.q40.count.csv.gz All.count.Zscores.SE1.csv All.count.Zscores.SE1.csv.7.peptides.txt /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.clean.csv
#
#python3 ./mega_merge.py -o SE2.merged.data.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.select.csv out/S5.q40.count.csv.gz out/S6.q40.count.csv.gz All.count.Zscores.SE2.csv All.count.Zscores.SE2.csv.7.peptides.txt /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.clean.csv
#
#python3 ./mega_merge.py -o SE3.merged.data.csv /francislab/data1/refs/PhIP-Seq/VIR3_clean.select.csv out/S9.q40.count.csv.gz out/S10.q40.count.csv.gz All.count.Zscores.SE3.csv All.count.Zscores.SE3.csv.7.peptides.txt /francislab/data1/refs/PhIP-Seq/public_epitope_annotations.clean.csv
#
#```
#
#Create list of novel peptides



##	20241002

```

for f in processed_separately_by_condition/?.count.Zscores.csv ; do
awk 'BEGIN{FS=OFS=","}{print $4,$1,$2,$3}' ${f} > tmp
head -1 tmp > ${f%.csv}.reordered.join_sorted.csv
tail -n +2 tmp | sort -t, -k1,1 >> ${f%.csv}.reordered.join_sorted.csv
join --header -t, /francislab/data1/refs/PhIP-Seq/VIR3_clean.virus_score.join_sorted.csv ${f%.csv}.reordered.join_sorted.csv > ${f%.csv}.species_peptides.Zscores.csv 
done

```


