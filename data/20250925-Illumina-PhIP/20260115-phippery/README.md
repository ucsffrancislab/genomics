
#	20250925-Illumina-PhIP/20260115-phippery

Test out phip-flow / phippery / phip-viz

https://matsen.group/phippery/


https://claude.ai/chat/dd4b4f89-61d5-41ea-b8c2-179e3687394f


I asked Claude to read the phippery paper and pointed him to the documentation and github repositories.

I told him that we already had our alignment counts and to create some code to use the phippery pipeline.

The initial code has been included here.


This downloads a container and installs pips so CANNOT be run as a job






```bash
./scripts/00_install_phippery.sh 
``` 


Format your input files according to specifications 

```bash
head -1 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv > tmp1.csv
tail -n +2 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv | sort -t, -k1,1 >> tmp1.csv
awk 'BEGIN{FS=OFS=","}(NR>1){
if( $3 == "Phage Library" ){ control_status = "library" }
else if( $3 == "input" ){ control_status = "beads_only" }
else { control_status = "empirical" }
print "samp_"$1,"subj_"$2,control_status,"plate_"$8,$6,$7}' tmp1.csv > tmp2.csv
sed '1isample_name,subject_id,control_status,plate,sex,age' tmp2.csv > sample_metadata.csv
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


counts_matrix.csv

```bash
cut -d, -f1,3- ../20250414-PhIP-MultiPlate/out.123456131415161718/Counts.csv | datamash transpose -t, > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv
cut -d, -f1,10- tmp2.csv > tmp3.csv
head -1 tmp3.csv | tr , '\n' | awk '(NR==1){print}(NR>1){printf "VS_%06d\n",$1}' | datamash transpose -t, > tmp4.csv
tail -n +2 tmp3.csv | sed 's/^/samp_/' >> tmp4.csv
cat tmp4.csv | datamash transpose -t, > counts_matrix.csv
```



```bash
sbatch scripts/run_all.sh
```



Claude crashed and this is getting way out of hand.
Starting over asking for minimal scripts.


