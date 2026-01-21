
#	20250925-Illumina-PhIP/20260116-phippery

Starting fresh ...


Format your input files according to specifications 

```bash
head -1 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv > tmp1.csv
tail -n +2 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv | sort -t, -k1,1 >> tmp1.csv
awk 'BEGIN{FS=OFS=","}(NR>1){
if( $3 == "Phage Library" ){ control_status = "library" }
else if( $3 == "input" ){ control_status = "beads_only" }
else { control_status = "empirical" }
print "samp_"$1,"subj_"$2,control_status,"plate_"$8,$6,$7}' tmp1.csv > tmp2.csv
sed '1isample_name,subject_id,control_status,plate,age,sex' tmp2.csv > sample_metadata.csv
\rm tmp?.csv
```


Drop the duplicated 89962

```bash

zcat /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz \
  | sed -e 's/Chikungunya virus (CHIKV)/Chikungunya virus/g' \
  -e 's/Eastern equine encephalitis virus (EEEV) (Eastern equine encephalomyelitis virus)/Eastern equine encephalitis virus/g' \
  -e 's/Uukuniemi virus (Uuk)/Uukuniemi virus/g' \
  -e 's/Human torovirus (HuTV)/Human torovirus/g' \
  -e 's/BK polyomavirus (BKPyV)/BK polyomavirus/g' \
  -e 's/Human cytomegalovirus (HHV-5) (Human herpesvirus 5)/Human herpesvirus 5/g' \
  -e 's/New York virus (NYV)/New York virus/g' \
  -e 's/Capsid scaffolding protein (Capsid protein P40) (Protease precursor) (pPR) (Virion structural gene 33 protein) \[Cleaved into: Assemblin (EC 3.4.21.97) (Capsid protein VP24) (Protease); Assembly protein (Capsid protein VP22A)\]/Capsid protein P40/g' \
  -e 's/Tripartite terminase subunit UL15 homolog (DNA-packaging protein 45) (Terminase large subunit) \[Cleaved into: Gene 42 protein\]/Tripartite terminase subunit UL15 homolog/g' \
  | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{gsub(/,/,"",$10);printf "VS_%06d,%s,%s,%s,%s,%d,%d\n",$17,$18,$12,$10,$21,$20,$16 }' | sort | uniq | sort -t, -k1,1 > peptide_table.csv
sed -i '1ipeptide_name,oligo,virus,protein,peptide_seq,start_pos,end_pos' peptide_table.csv
sed -i '/^89962,/d' peptide_table.csv
chmod a-w peptide_table.csv

```


The above results in many duplicates. 
All that I've checked are due to repeat entries with slightly varying protein names.
This is problematic and I really should clean this core "clean" file.
It will continue to be a problem that I'll continue to have to deal with until I do.



counts_matrix.csv

```bash
cut -d, -f1,3- ../20250414-PhIP-MultiPlate/out.123456131415161718/Counts.csv | datamash transpose -t, > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv
cut -d, -f1,10- tmp2.csv > tmp3.csv
head -1 tmp3.csv | tr , '\n' | awk '(NR==1){print}(NR>1){printf "VS_%06d\n",$1}' | datamash transpose -t, > tmp4.csv
tail -n +2 tmp3.csv | sed 's/^/samp_/' >> tmp4.csv
cat tmp4.csv | datamash transpose -t, > counts_matrix.csv
\rm tmp?.csv
```



```bash
python3 format_for_phippery.py \
    --sample-table sample_metadata.csv \
    --peptide-table peptide_table.csv \
    --counts-matrix counts_matrix.csv \
    --output-dir formatted_data > format_for_phippery.log
```


```bash
bash 00_install_phippery.sh |& tee 00_install_phippery.log
```


```bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name phippery --wrap="singularity exec containers/phippery.sif phippery load-from-csv -s formatted_data/sample_table.csv -p formatted_data/peptide_table.csv -c formatted_data/counts_matrix.csv -o dataset.phip"
```

So this command has a bug. 
```bash
# in phippery/cli.py
def load_from_csv(
    sample_table,
    peptide_table,
    counts_matrix,
    output,
):

# eventually calls the function ...
ds = utils.dataset_from_csv(counts_matrix, peptide_table, sample_table)

#	but in phippery/utils.py
def dataset_from_csv(
    peptide_table_filename, sample_table_filename, counts_table_filename
):
#	it is expecting them in a different order?

```



```bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name phippery --wrap="singularity exec containers/phippery.sif python3 01_load_dataset_from_csvs.py"
```

So the normalization is really the only thing that phippery does.
Disappointing but let's see how this goes.

```bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name phippery --wrap="singularity exec containers/phippery.sif python3 02_normalize_dataset.py"
```


```bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name phippery --wrap="singularity exec containers/phippery.sif python3 03_export.py"
```







##	20260121

Phippery doesn't really provide much else other than the z-score matrix.

Accidentally deleted the phippery files! But I still have the exported so we're good.

Create a QC sample metadata file

Your metadata file needs columns: sample_id (or sample_name matching zscore columns), subject_id, sample_type, study, group, age, sex, plate. Missing columns are handled gracefully.

```bash
mkdir phipseq_qc
head -1 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv > tmp1.csv
tail -n +2 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv | sort -t, -k1,1 >> tmp1.csv
sed '1c\sample_id,subject_id,sample_type,study,group,age,sex,plate' tmp1.csv > phipseq_qc/sample_metadata.csv
sed -i '2,$s/^/samp_/' phipseq_qc/sample_metadata.csv
\rm tmp?.csv
```



Convert the exported z-scores for QC. 
    zscore-matrix: Peptides (rows) x Samples (columns), gzipped OK

Remap the phippery sample id to our sample id plus "samp_" prefix.
Remap the phippery peptide id to our peptide id.

```bash
zcat exported_data/zscore.csv.gz | head -1 | awk -F, '{print NF}'
1150

zcat exported_data/zscore.csv.gz | wc -l
1150000
```

```bash
join --header -t, <( cut -d, -f1,2 formatted_data/peptide_table.csv ) <( zcat exported_data/zscore.csv.gz ) | cut -d, -f2- > tmp1.csv
cat tmp1.csv | datamash transpose -t, > tmp2.csv
join --header -t, formatted_data/sample_table.csv tmp2.csv | cut -d, -f2,8- > tmp3.csv
cat tmp3.csv | datamash transpose -t, | gzip > phipseq_qc/zscore.csv.gz 
\rm tmp?.csv
```

Using a Claude script to QC the data. It should be applicable to any z-score matrix with appropriate metadata.

```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name qc --wrap="python3 phipseq_qc.py --zscore-matrix phipseq_qc/zscore.csv.gz --sample-metadata phipseq_qc/sample_metadata.csv --output-dir phipseq_qc/results"

```


```bash
box_upload.bash phipseq_qc/phipseq_qc.txt phipseq_qc/sample_metadata.csv phipseq_qc/results/*
```




