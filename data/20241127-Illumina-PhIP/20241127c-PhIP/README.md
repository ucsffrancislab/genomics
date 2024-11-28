
#	20241127-Illumina-PhIP/20241127c-PhIP


==> /francislab/data1/raw/20241127-Illumina-PhIP/manifest.tsv <==
Number 	Name	 Index	% Reads	IDX #	READ	 # of Reads  
S1	Blank01_1	CTTGGTT	0.4989	IDX001	AACCAAG	
S2	14118-01	TGCGGTT	0.0004	IDX002	AACCGCA	 2,055,110 
S3	PLib01_1	GCAGGTT	0.5306	IDX003	AACCTGC	
S4	4207	GGTCGTT	0.0015	IDX004	AACGACC	 1,823,293 
S5	4460	ATGCGTT	0.0006	IDX005	AACGCAT	 2,241,270 
S6	14235-01	TAACGTT	0.0002	IDX006	AACGTTA	 1,876,334 
S7	Blank04_1	TCTAGTT	0.0004	IDX007	AACTAGA	 1,834,349 
S8	4129	CGGAGTT	0.0012	IDX008	AACTCCG	 1,383,458 
S9	Blank01_2	GTCAGTT	0.0007	IDX009	AACTGAC	 1,742,107 


remove _1, _2 and dup for subject


```
awk 'BEGIN{OFS=","}(NR>1){subject=$2;sub(/_1$/,"",subject);sub(/_2$/,"",subject);sub(/dup$/,"",subject); print subject,$2,"/francislab/data1/working/20241127-Illumina-PhIP/20241127b-bowtie2/out/"$1".VIR3_clean.1-70.bam,serum"}' /francislab/data1/raw/20241127-Illumina-PhIP/manifest.tsv | sort -t, -k1,2 > manifest.csv

sed -i '1isubject,sample,bampath,type' manifest.csv
sed -i '/^Blank/s/serum/input/' manifest.csv 
sed -i '/^PLib/d' manifest.csv
chmod -w manifest.csv
```




```
mkdir logs
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
  --job-name=phip_seq --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  --output=${PWD}/logs/phip_seq.$( date "+%Y%m%d%H%M%S%N" ).out.log \
  /c4/home/gwendt/.local/bin/phip_seq_process.bash -q 00 --manifest ${PWD}/manifest.csv --output ${PWD}/out
```


