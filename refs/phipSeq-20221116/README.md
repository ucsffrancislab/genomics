
#	



```

NP_000468.1_albumin_preproprotein -> ../mRNA_Prot-20210528/NP_000468.1_albumin_preproprotein/
NP_040190.1_envelope_glycoprotein_E_Human_alphaherpesvirus_3 -> ../viral-20220923/NP_040190.1_envelope_glycoprotein_E_Human_alphaherpesvirus_3
NP_579894.2_Envelope_surface_glycoprotein_gp120_Human_immunodeficiency_virus_1 -> ../viral-20220923/NP_579894.2_Envelope_surface_glycoprotein_gp120_Human_immunodeficiency_virus_1/

ls -1 NP_*/*fa
NP_000468.1_albumin_preproprotein/NP_000468.1_albumin_preproprotein.fa
NP_040190.1_envelope_glycoprotein_E_Human_alphaherpesvirus_3/NP_040190.1_envelope_glycoprotein_E_Human_alphaherpesvirus_3.fa
NP_579894.2_Envelope_surface_glycoprotein_gp120_Human_immunodeficiency_virus_1/NP_579894.2_Envelope_surface_glycoprotein_gp120_Human_immunodeficiency_virus_1.fa

cat NP_*/*fa > select_sequences.faa


nohup ./phipseq.bash 56 28 select_sequences.faa > phipseq.56.28.out.txt 2>&1 &

```


