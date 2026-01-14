
#	20250925-Illumina-PhIP/20260108-CellImmunityPaper

Phage display sequencing reveals that genetic, environmental, and intrinsic factors influence variation of human antibody epitope repertoire

https://www.cell.com/immunity/fulltext/S1074-7613(23)00171-1



We interrogated a total of 344,000 peptides in 1,778 samples from 1,437 individuals (for 341 of whom we had data at two time points 4 years apart) from a northern Dutch population cohort (LLD) (Figure 1A).

Based on peptide sequence identity and prevalence we chose 2,815 peptides for further analyses


https://zenodo.org/records/7307894

https://github.com/erans99/PhIPSeq_external/tree/immunity


https://zenodo.org/records/7773433

https://github.com/abourgonje/Phip-Seq_LLD-IBD/tree/PhIPSeq_LLD_IBD


I asked Claude to access the paper and software and create a guide and code to implement the pipeline.
It appears to have written its own code and doesn't use theirs.


https://claude.ai/chat/3c8691f2-1f4a-4ac8-ab88-c7b68b73d1dd

```bash
# Python packages

python3 -m pip install --user --upgrade numpy pandas scipy matplotlib seaborn scikit-learn statsmodels biopython pysam
```

```R
install.packages(c("tidyverse", "vegan", "corrplot", "igraph", 
                   "pheatmap", "patchwork"))
if (!require("BiocManager")) install.packages("BiocManager")
BiocManager::install("WGCNA")
```





PREP phipseq_counts.csv to match the following expectations






```python

# Example data structure
import pandas as pd
import numpy as np

# Load your alignment counts
counts = pd.read_csv("phipseq_counts.csv", index_col=0)
# Shape: (n_peptides, n_samples)

print(f"Data dimensions: {counts.shape}")
print(f"Total reads per sample:\n{counts.sum(axis=0).describe()}")

```



##	20260112

Formating data to run in Claude's code.

Testing on the known CMV AGS samples

```bash

mkdir CMV_test

awk 'BEGIN{FS=OFS=","}(NR==1 || $6==0 || $6==1){print $1,$6}' /francislab/data1/refs/AGS/AGS.csv > CMV_test/CMV.csv

```


Just sample ids and peptide ids for JUST THE glioma serum AGS subjects

```bash
peptide_id,sample_001,sample_002,...,sample_1000
pep_0001,150,203,...,89
pep_0002,5,8,...,23
```

```bash

cut -d, -f1,3- ../20250414-PhIP-MultiPlate/out.123456131415161718/Counts.csv | datamash transpose -t, > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv
cut -d, -f1,10- tmp2.csv > tmp3.csv
join --header -t, <( cut -d, -f1 CMV_test/CMV.csv ) tmp3.csv | datamash transpose -t, | sed '1s/^UCSFid/peptide_id/' > CMV_test/phipseq_counts_experimental_only.csv

```


Format the VIR3 CSV

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
  | tail -n +2 | awk 'BEGIN{OFS=",";FPAT="([^,]*)|(\"[^\"]+\")"}{gsub(/,/,"",$10);print $17,$10,$12,$21}' | sort | uniq | sort -t, -k1,1 > peptide_metadata.csv


sed -i '1ipeptide_id,protein_name,organism,sequence' peptide_metadata.csv
sed -i '/^89962,/d' peptide_metadata.csv
chmod a-w peptide_metadata.csv

```



```bash

head -1 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv > tmp1.csv
tail -n +2 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv | sort -t, -k1,1 >> tmp1.csv

join --header -t, CMV_test/CMV.csv tmp1.csv > tmp2.csv

awk 'BEGIN{FS=OFS=","}($2==0){$2="control"}($2==1){$2="case"}{print $1,$2,$7,$8,$9}' tmp2.csv > tmp3.csv

sed '1c\sample_id,status,age,sex,plate' tmp3.csv > CMV_test/sample_metadata.csv

```




```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name enrichment --wrap="./CMV_enrichment.py"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name casecontrol --wrap="./CMV_case_control_analysis.py"

```


##	20260113


```bash

head -1 CMV_test/results/case_control/case_control_peptide.csv > tmp1.csv
tail -n +2 CMV_test/results/case_control/case_control_peptide.csv | sort -t, -k1,1 >> tmp1.csv
join --header -t, peptide_metadata.csv tmp1.csv > tmp2.csv
head -1 tmp2.csv > CMV_test/results/case_control/case_control_peptide_with_protein_species.csv
tail -n +2 tmp2.csv | sort -t, -k14g,14 >> CMV_test/results/case_control/case_control_peptide_with_protein_species.csv

```


I'd call this a successful test of peptides analysis. By far the top peptides are HHV5 which is known.
The problem is with the protein and virus seropositivity calls.
It looks like it only takes 1 peptide to result in a positive seropositivity.
Moving forward, we'd need to do something about that.








Percentages rather than fixed counts for calling proteins and viruses?

How to merge replicates? Before or after enrichment analysis?



Checking CMV findings

```bash
join --header -t, CMV_test/CMV.csv <( awk -F, '(NR==1 || $1=="Human herpesvirus 5")' CMV_test/results/virus_enrichment_binary.csv | datamash transpose -t, ) | awk -F, '($2!=$3)'
```

```bash
head -1 CMV_test/results/peptide_enrichment_binary.csv > tmp1.csv
tail -n +2 CMV_test/results/peptide_enrichment_binary.csv | sort -t, -k1,1 >> tmp1.csv
join --header -t, peptide_metadata.csv tmp1.csv | cut -d, -f1,2,3,5- | awk -F, '(NR==1 || $3=="Human herpesvirus 5")' | datamash transpose -t, > tmp2.csv
join --header -t, <( head -1 CMV_test/CMV.csv ) <( tail -n +1 tmp2.csv | head -n 1 ) > tmp3.csv
join --header -t, <( head -1 CMV_test/CMV.csv ) <( tail -n +2 tmp2.csv | head -n 1 ) >> tmp3.csv
join --header -t, CMV_test/CMV.csv <( tail -n +3 tmp2.csv ) >> tmp3.csv
```


```python3
import pandas as pd
df=pd.read_csv('tmp3.csv',header=[0,1,2],index_col=0)
df.head()
df.T.groupby(level=[1,2]).sum()
df.T.groupby(level=[1,2]).sum().to_csv('protein_counts.csv')
```





```bash

head -1 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv > tmp1.csv
tail -n +2 ../20250414-PhIP-MultiPlate/out.123456131415161718/manifest.csv | sort -t, -k1,1 >> tmp1.csv

join --header -t, CMV_test/CMV.csv tmp1.csv > tmp2.csv

awk 'BEGIN{FS=OFS=","}($2==0){$2="control"}($2==1){$2="case"}{print $1,$3,$2,$7,$8,$9}' tmp2.csv > tmp3.csv

sed '1c\sample_id,subject_id,status,age,sex,plate' tmp3.csv > CMV_test/sample_metadata.csv

```



```bash

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name enrichment --wrap="./CMV_enrichment.py"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name casecontrol --wrap="./CMV_case_control_analysis.py"

```






##	20260114

Glioma AGS / IPS





