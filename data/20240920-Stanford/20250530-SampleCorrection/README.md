
#	20240920-Stanford/20250530-SampleCorrection


Noted that some subjects had multiple samples so the correct count is not 715, but 623.

Gonna look into reproducing the results files like `All TE-derived Alternative Isoforms Statistics.csv`
after filtering.


Input - TEProF2-aggregation-20241010
Output - TEProF2-aggregation-20250530





```
ln -s /wittelab/data5/lkachuri/myeloma/TEProF2-aggregation-20241010
ln -s /wittelab/data5/lkachuri/myeloma/TEProF2-aggregation-20250530
ln -s /wittelab/data5/lkachuri/myeloma/TEProF2-individual

tail -n +2 sample_list_primary_bm.txt | sort | cut -f1 > TEProF2-aggregation-20250530/filelist
sed -i '1ifile' TEProF2-aggregation-20250530/filelist

cat TEProF2-aggregation-20241010/table_frac_tot_cand | datamash transpose > TEProF2-aggregation-20250530/tmp1.tsv
join --header TEProF2-aggregation-20250530/tmp1.tsv TEProF2-aggregation-20250530/filelist \
  | tr " " "\t" | datamash transpose > TEProF2-aggregation-20250530/table_frac_tot_cand

cat TEProF2-aggregation-20241010/table_tpm_cand | datamash transpose > TEProF2-aggregation-20250530/tmp1.tsv
join --header TEProF2-aggregation-20250530/tmp1.tsv TEProF2-aggregation-20250530/filelist \
  | tr " " "\t" | datamash transpose > TEProF2-aggregation-20250530/table_tpm_cand

cat TEProF2-aggregation-20241010/table_i_all | datamash transpose > TEProF2-aggregation-20250530/tmp1.tsv
head -3 TEProF2-aggregation-20250530/tmp1.tsv > TEProF2-aggregation-20250530/tmp2.tsv
join --header <( tail -n +4 TEProF2-aggregation-20250530/tmp1.tsv | sort -k1,1 ) TEProF2-aggregation-20250530/filelist \
  | tr " " "\t" >> TEProF2-aggregation-20250530/tmp2.tsv
cat TEProF2-aggregation-20250530/tmp2.tsv | datamash transpose > TEProF2-aggregation-20250530/table_i_all

\rm TEProF2-aggregation-20250530/tmp?.tsv

cp TEProF2-aggregation-20241010/Step10.RData TEProF2-aggregation-20250530/

CPC2=/c4/home/gwendt/github/nakul2234/CPC2_Archive/bin/CPC2.py
TEPROF2=/c4/home/gwendt/github/ucsffrancislab/TEProf2Paper/bin
ARGUMENTS=/francislab/data1/refs/TEProf2/TEProF2.arguments.txt

OUT=${PWD}/TEProF2-aggregation-20250530

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name="finalStatisticsOutput" \
  --time=14-0 --nodes=1 --ntasks=64 --mem=490G \
  --output=${OUT}/finalStatisticsOutput.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  --export=None --chdir=${OUT} \
  --wrap="module load r;${TEPROF2}/finalStatisticsOutput.R --threads 64 -a ${ARGUMENTS} --reference_merged_candidates_gtf /francislab/data1/refs/TEProf2/rnapipelinerefhg38/reference_merged_candidates.gtf --in ${PWD}/TEProF2-individual/ --out ${OUT}"

```



