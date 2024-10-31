
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
--job-name=MHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/MHC.$( date "+%Y%m%d%H%M%S%N" ).%j.out.log \
${PWD}/MHC.bash /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Modified-TCONS_00000820-9.faa

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=MHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/MHC.$( date "+%Y%m%d%H%M%S%N" ).%j.out.log \
${PWD}/MHC.bash /francislab/data1/refs/TEProf2/41588_2023_1349_MOESM3_ESM/S10/Original-TCONS_00000820-9.faa


awk -F, '(NR>2){gsub("TCONS_","",$1);print ">"$1"-"$3"-"$4;print $5}' S14.csv > S14.faa

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=MHC --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/MHC.$( date "+%Y%m%d%H%M%S%N" ).%j.out.log \
${PWD}/MHC.bash ${PWD}/S14.faa 

```


