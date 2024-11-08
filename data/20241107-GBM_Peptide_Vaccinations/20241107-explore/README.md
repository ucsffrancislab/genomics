
#	20241107-GBM_Peptide_Vaccinations/20241107-explore


https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-024-51315-8/MediaObjects/41467_2024_51315_MOESM1_ESM.pdf



```

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=GBMMHCAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/GBMMHCAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCpan.bash -l 8,9,10,11,12 -f ${PWD}/GBM_vaccinated_peptides.faa

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --exclude=c4-n10 \
--job-name=GBMMHCIIAGS --time=14-0 --nodes=1 --ntasks=4 --mem=30GB \
--output=${PWD}/GBMMHCIIAGS.%j.$( date "+%Y%m%d%H%M%S%N" ).out.log \
~/.local/bin/netMHCIIpan.bash -l 9,10,11,12,13,14,15,16,17 -f ${PWD}/GBM_vaccinated_peptides.for_II.faa

```


```
Error: FASTA input sequence must be of length >= 9: 1

```




