
#	20201006-GTEx/20230616-PanCancerAntigens-Viral


/francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/

viral_protein_accessions




```
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="blast" \
--time=20160 --nodes=1 --ntasks=8 --mem=60G --output=${PWD}/blast.$( date "+%Y%m%d%H%M%S%N" ).out.log \
${PWD}/blastx.bash
```

Really only uses about 1 thread and not much memory. It does take a LONG LONG time.










---

20230426-PanCancerAntigens/20230426-explore/

```

head -1 viral_proteins.names.tsv > viral_proteins.names.sorted.tsv
tail -n +2 viral_proteins.names.tsv | sort >> viral_proteins.names.sorted.tsv

head -1 viral_protein_accessions_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.tsv > viral_protein_accessions_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.sorted.tsv
tail -n +2 viral_protein_accessions_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.tsv | sort >> viral_protein_accessions_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.sorted.tsv

head -1 viral_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.05.tsv > viral_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.05.sorted.tsv
tail -n +2 viral_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.05.tsv | sort >> viral_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.05.sorted.tsv


join --header viral_proteins.names.sorted.tsv viral_protein_accessions_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.sorted.tsv > viral_protein_accessions_IN_S10_S1Brain_ProteinSequences.blastp.e0.05.sorted.descriptions.tsv
join --header viral_proteins.names.sorted.tsv viral_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.05.sorted.tsv > viral_protein_accessions_IN_S10_All_ProteinSequences.blastp.e0.05.sorted.descriptions.tsv




