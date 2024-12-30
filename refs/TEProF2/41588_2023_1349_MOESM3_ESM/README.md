
#	TEProF2/41588_2023_1349_MOESM3_ESM


```
head S10.csv 
Supplementary Table 10. Protein prediction of candidate transcripts,,,,,,,,,,,,,,,,,
Transcript ID,Subfam,Chr TE,Start TE,End TE,Location TE,Gene,Splice Target,Strand,Index of Start Codon,Frame,Frame Type,Protein Sequence,Original Protein Sequence,Strategy,,,


```


```

tail -n +3 S10.csv | awk 'BEGIN{FS=OFS=","}($13!="None"){print ">Modified-"$1"-"$10;print $13; print ">Original-"$1"-"$10;print $14}' > S10.faa

faSplit byname S10.faa S10/

rename .fa .faa S10/*fa

chmod -w S10/*.faa


alphafold_array_wrapper.bash --time 14-0 --threads 16 S10/Modified-TCONS_00000820-9.faa

```



##	20241028

```

mkdir -p links

for f in S10/*-TCONS_00000820-9/ranked_?.pdb ; do
b=$( basename $( dirname $f ) )
i=$( basename $f .pdb )
i=${i#ranked_}
ln -s ../$f links/${b}_${i}.pdb
done

~/.local/foldseek/bin/foldseek createdb links/Original-TCONS_00000820-9_*.pdb Original-TCONS_00000820-9

~/.local/foldseek/bin/foldseek easy-search links/Modified-TCONS_00000820-9_?.pdb Original-TCONS_00000820-9 --format-mode 3 TCONS_00000820-9.html tmp

```






```
~/.local/netMHCpan-4.1/netMHCpan S10/Modified-TCONS_00000820-9.faa > Modified-TCONS_00000820-9.netMHCpan.txt

~/.local/netMHCIIpan-4.3/netMHCIIpan -f S10/Modified-TCONS_00000820-9.faa > Modified-TCONS_00000820-9.netMHCIIpan.txt

~/.local/netMHCpan-4.1/netMHCpan S10/Original-TCONS_00000820-9.faa > Original-TCONS_00000820-9.netMHCpan.txt

~/.local/netMHCIIpan-4.3/netMHCIIpan -f S10/Original-TCONS_00000820-9.faa > Original-TCONS_00000820-9.netMHCIIpan.txt

~/.local/netMHCpan-4.1/netMHCpan /francislab/data1/refs/alphafold/HHV3-VZV/NP_040188.faa > NP_040188.netMHCpan.txt

~/.local/netMHCIIpan-4.3/netMHCIIpan -f /francislab/data1/refs/alphafold/HHV3-VZV/NP_040188.faa > NP_040188.netMHCIIpan.txt

```





##	20241029

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=AGS2ModifiedMHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/AGS2ModifiedMHC.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
${PWD}/MHC.bash -l1 9,10,11,12 -f /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Modified-TCONS_00000820-9.faa

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=AGS2OriginalMHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/AGS2OriginalMHC.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
${PWD}/MHC.bash -l1 9,10,11,12 -f /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Original-TCONS_00000820-9.faa


awk -F, '(NR>2){gsub("TCONS_","",$1);print ">"$1"-"$3"-"$4;print $5}' S14.csv > S14.faa



sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=AGSS14MHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/S14MHC.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
${PWD}/MHC.bash -l1 9 -l2 9 -f ${PWD}/S14.faa




sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=AGS2NP_MHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/AGS2NP_MHC.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
${PWD}/MHC.bash -l1 9,10,11,12 -f ${PWD}/NP_040188.faa

```



##	20241104


Create separate S14 9mer fasta files for folding.


NOT ALL 9-mer sequences are 9 mer????
Some names are duplicated!!

```
awk -F, '(NR>2){gsub("TCONS_","",$1);cmd="mkdir -p S14/"$1; cmd | getline; close(cmd); print ">"$1"-"$3"-"$4 > "S14/"$1"/"$1"-"$3"-"$4".faa";print $5 >> "S14/"$1"/"$1"-"$3"-"$4".faa"; close("S14/"$1"/"$1"-"$3"-"$4".faa")}' S14.csv

alphafold_array_wrapper.bash --time 14-0 --extension .faa $PWD/S14/00000???/00000*faa

```




##	20241107

```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=S14MHCAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/S14MHCAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCpan.bash -l 9 --start_allele HLA-A3112 -f ${PWD}/S14.faa

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=S14MHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/S14MHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -l 9 -f ${PWD}/S14.faa

```




NOT ALL 9-mer sequences are 9 mer????
Some names are duplicated!!

```

awk -F, '(NR>2 && length($5)>=9){gsub("TCONS_","",$1);$2=substr($2,1,1);print ">"$1$2$3"-"$4;print $5}' S14.csv > S14b.faa


awk -F, '(NR>2){gsub("TCONS_","",$1);cmd="mkdir -p S14b/"$1; cmd | getline; close(cmd);$2=substr($2,1,1); print ">"$1$2$3"-"$4 > "S14b/"$1"/"$1$2$3"-"$4".faa";print $5 >> "S14b/"$1"/"$1$2$3"-"$4".faa"; close("S14b/"$1"/"$1$2$3"-"$4".faa")}' S14.csv

```





##	20241121


```
ll S14/00000???/*faa | wc -l

ll S14/00000???/*/*ranked_0.pdb | wc -l

grep "^++ dirname" $( grep -L "^Runtime" logs/alphafold_array_wrapper.bash.*-188304_*.out.log )



alphafold_array_wrapper.bash --time 14-0 --extension .faa $PWD/S14/0000[1-9]???/*faa

```






```
grep -vs "^>" S14.faa | sort | uniq > S14.9mers.sorted.uniq

tail -n +3 S10.csv | awk 'BEGIN{FS=OFS=","}($13!="None"){ print ">Modified-"$1"-"$10 >> "S10-Modified.faa"; print $13 >> "S10-Modified.faa"; print ">Original-"$1"-"$10 >> "S10-Original.faa"; print $14 >> "S10-Original.faa"; }'

sed -i -e 's/\*//g' -e 's/ //g' S10-Original.faa

for k in 8 9 10 11 12 13 14 15 ; do
for k in 5 20 25 ; do
~/github/raw-lab/mercat2/bin/mercat2.py -k ${k} -c 1 -i S10-Original.faa -o S10-Original.mercat.${k}
~/github/raw-lab/mercat2/bin/mercat2.py -k ${k} -c 1 -i S10-Modified.faa -o S10-Modified.mercat.${k}
done

```

A lot of errors in processing, but it's not clear if they have any impact on the kmer counting as they are after that.

Just noticed that the original sequences contain some spaces. Why? Is removing OK?

```
wc -l S14.9mers.sorted.uniq S10-*.mercat.*/combined_protein.tsv
   56981 S14.9mers.sorted.uniq
  702766 S10-Modified.mercat.12/combined_protein.tsv
  705467 S10-Modified.mercat.9/combined_protein.tsv
 1124864 S10-Original.mercat.12/combined_protein.tsv
 1124681 S10-Original.mercat.9/combined_protein.tsv
 3714759 total
```


I would expect that increasing k would increase the number of kmers.

I don't think that we are using these kmer results.




##	20241211


netMHCIIpan fails if ANY read is less than 9 bp

```

awk -F, '(NR>2 && length($5)>=9){gsub("TCONS_","",$1);$2=substr($2,1,1);print ">"$1$2$3"-"$4;print $5}' S14.csv > S14.uniq.gte9.faa

```


```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=S14MHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/S14MHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -l 9 -f ${PWD}/S14.uniq.gte9.faa

```




##	20241230

```
ll /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM//S14/0000????/*faa | wc -l
4113
ll -tr /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S14/*/*-*-*/ranked_0.pdb | wc -l
4113
```


```
find /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S14/????????/ -name \*.faa | wc -l
64190
```

Stopping this fiasco. Gonna take the better part of a year and for what exactly.





