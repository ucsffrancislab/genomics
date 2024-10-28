
#	20241024-Q02413/20241024-explore

** Q02413 · DSG1_HUMAN **

https://www.uniprot.org/uniprotkb/Q02413/entry

https://www.rcsb.org/structure/AF_AFQ02413F1

https://alphafold.ebi.ac.uk/

https://alphafold.ebi.ac.uk/entry/Q02413

https://alphafold.ebi.ac.uk/files/AF-Q02413-F1-model_v4.cif



This is a side request for the pemphigus grant i’m working on. 

Can you please find a peptide sequence for desmoglein 1 (DSG1), and blast it against the VIR3 peptides. 

We are looking for viruses that share homology.

There is a AA sequence here: https://www.uniprot.org/uniprotkb/Q02413/entry#sequences


```
wget https://rest.uniprot.org/uniprotkb/Q02413.fasta
```

```
cat Q02413.fasta 
>sp|Q02413|DSG1_HUMAN Desmoglein-1 OS=Homo sapiens OX=9606 GN=DSG1 PE=1 SV=2
MDWSFFRVVAMLFIFLVVVEVNSEFRIQVRDYNTKNGTIKWHSIRRQKREWIKFAAACRE
GEDNSKRNPIAKIHSDCAANQQVTYRISGVGIDQPPYGIFVINQKTGEINITSIVDREVT
PFFIIYCRALNSMGQDLERPLELRVRVLDINDNPPVFSMATFAGQIEENSNANTLVMILN
ATDADEPNNLNSKIAFKIIRQEPSDSPMFIINRNTGEIRTMNNFLDREQYGQYALAVRGS
DRDGGADGMSAECECNIKILDVNDNIPYMEQSSYTIEIQENTLNSNLLEIRVIDLDEEFS
ANWMAVIFFISGNEGNWFEIEMNERTNVGILKVVKPLDYEAMQSLQLSIGVRNKAEFHHS
IMSQYKLKASAISVTVLNVIEGPVFRPGSKTYVVTGNMGSNDKVGDFVATDLDTGRPSTT
VRYVMGNNPADLLAVDSRTGKLTLKNKVTKEQYNMLGGKYQGTILSIDDNLQRTCTGTIN
INIQSFGNDDRTNTEPNTKITTNTGRQESTSSTNYDTSTTSTDSSQVYSSEPGNGAKDLL
SDNVHFGPAGIGLLIMGFLVLGLVPFLMICCDCGGAPRSAAGFEPVPECSDGAIHSWAVE
GPQPEPRDITTVIPQIPPDNANIIECIDNSGVYTNEYGGREMQDLGGGERMTGFELTEGV
KTSGMPEICQEYSGTLRRNSMRECREGGLNMNFMESYFCQKAYAYADEDEGRPSNDCLLI
YDIEGVGSPAGSVGCCSFIGEDLDDSFLDTLGPKFKKLADISLGKESYPDLDPSWPPQST
EPVCLPQETEPVVSGHPPISPHFGTTTVISESTYPSGPGVLHPKPILDPLGYGNVTVTES
YTTSDTLKPSVHVHDNRPASNVVVTERVVGPISGADLHGMLEMPDLRDGSNVIVTERVIA
PSSSLPTSLTIHHPRESSNVVVTERVIQPTSGMIGSLSMHPELANAHNVIVTERVVSGAG
VTGISGTTGISGGIGSSGLVGTSMGAGSGALSGAGISGGGIGLSSLGGTASIGHMRSSSD
HHFNQTIGSASPSTARSRITKYSTVQYSK
```





```
blastp -db /francislab/data1/refs/refseq/viral-20231129/viral.protein -query Q02413.fasta -outfmt 6 -out Q02413.blastp.viral.tsv
chmod -w Q02413.blastp.viral.tsv
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=jackhmmer --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/jackhmmer.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="singularity exec --writable-tmpfs --bind /francislab,/scratch /francislab/data1/refs/singularity/AlphaFold.sif /usr/bin/jackhmmer -o ${PWD}/Q02413.jackhmmer.out -A ${PWD}/Q02413.jackhmmer.sto --noali --F1 0.0005 --F2 5e-05 --F3 5e-07 --incE 0.0001 -E 0.0001 --cpu 8 -N 1 ${PWD}/Q02413.fasta /francislab/data1/refs/alphafold/databases/mgnify/mgy_clusters_2022_05.fa"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=hhsearch --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/hhsearch.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="singularity exec --writable-tmpfs --bind /francislab,/scratch /francislab/data1/refs/singularity/AlphaFold.sif /usr/bin/hhsearch -cpu 8 -i ${PWD}/Q02413.fasta -o ${PWD}/Q02413.hhsearch -maxseq 1000000 -d /francislab/data1/refs/alphafold/databases/pdb70/pdb70"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=hhblits --time=14-0 --nodes=1 --ntasks=8 --mem=60GB \
--output=${PWD}/hhblits.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="singularity exec --writable-tmpfs --bind /francislab,/scratch /francislab/data1/refs/singularity/AlphaFold.sif /usr/bin/hhblits -i ${PWD}/Q02413.fasta -cpu 8 -oa3m ${PWD}/Q02413.hhblits.a3m -o ${PWD}/Q02413.hhblits.out -n 3 -e 0.001 -maxseq 1000000 -realign_max 100000 -maxfilt 100000 -min_prefilter_hits 1000 -d /francislab/data1/refs/alphafold/databases/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt -d /francislab/data1/refs/alphafold/databases/uniref30/UniRef30_2021_03"

```






```
alphafold_array_wrapper.bash --threads 8 --extension .fasta Q02413.fasta 
```


foldseek





```
curl https://1d-coordinates.rcsb.org/graphql?query=$(echo '{alignment(from:UNIPROT,to:PDB_ENTITY,queryId:"Q02413"){target_alignment{target_id}}}' | jq -Rr @uri )
{"data":{"alignment":{"target_alignment":[{"target_id":"AF_AFQ02413F1_1"}]}}}
```



```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek4 --time=14-0 --nodes=1 --ntasks=32 --mem=240GB \
--output=${PWD}/foldseek4.UniProt.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 4 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/UniProt aln.UniProt.tsv tmp4"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek3 --time=14-0 --nodes=1 --ntasks=32 --mem=240GB \
--output=${PWD}/foldseek3.UniProt.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 3 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/UniProt aln.UniProt.html tmp3"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek4 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek4.PDB.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 4 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/PDB aln.PDB.tsv tmp4"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek3 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek3.PDB.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 3 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/PDB aln.PDB.html tmp3"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek4 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek4.BFVD.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 4 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/BFVD aln.BFVD.tsv tmp4"

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek3 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek3.BFVD.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 3 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/BFVD aln.BFVD.html tmp3"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek4 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek4.UniProt50.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 4 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/UniProt50 aln.UniProt50.tsv tmp4"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek3 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek3.UniProt50.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 3 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/UniProt50 aln.UniProt50.html tmp3"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek4 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek4.SwissProt.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 4 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/SwissProt aln.SwissProt.tsv tmp4"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek3 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek3.SwissProt.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 3 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/SwissProt aln.SwissProt.html tmp3"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek4 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek4.Proteome.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 4 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/Proteome aln.Proteome.tsv tmp4"


sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=foldseek3 --time=14-0 --nodes=1 --ntasks=16 --mem=120GB \
--output=${PWD}/foldseek3.Proteome.$( date "+%Y%m%d%H%M%S%N" ).out.log \
--wrap="~/.local/foldseek/bin/foldseek easy-search --format-mode 3 AF-Q02413-F1-model_v4.cif /francislab/data1/refs/foldseek/Proteome aln.Proteome.html tmp3"

```



