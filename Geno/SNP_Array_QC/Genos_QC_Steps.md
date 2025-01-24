

Copied from Genos_QC_Steps (Updated TCGA).docx

Polygenic Risk Score antigen and Glioma project – Data processing and QC steps
December 2020, January 2021, February 2021, March 2021
TCGA Updated Feb 2023 to correct filtering of certain “annotation.txt” files, and to check Topmed inversion issues

Details of WTCCC DNA collection https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2719288/#SD1

General job command:
`sbatch --mem=150G --ntasks=1 --time=20:00:00 --output=%x-%j.out --export=NONE`

TCGA GBM and LGG data
* Affy 6.0 data downloaded from GDC in birdseed format
* The Affy 6.0 Snp annotation file (release 35) downloaded from the Affymetrix website
* http://www.affymetrix.com/support/technical/byproduct.affx?product=genomewidesnp_6
* R script used to get TCGA barcodes and combine all birdseed files into a single file, with columns being each patient.
```
/home/gguerra/TCGA_Glioma_Data/TCGA_Birdseed_Shell.sh
```
* Remove all informational columns except affy id (col 1) for Rosalyns script
```
cut -f2,3,4,5,6 --complement -d$'\t' TCGA_glioma_data.tsv > TCGA_glioma_data2.tsv
```
* Using (modified) python script from Rosalyn to convert birdseed to tped plink format.
```
Birdseed_To_PLINK.sh
```
* Pull all known SNP information (Affy ID, chr, pos) to compare with WTCCC
```
awk '{print $1,$2,$3,$4}' TCGA_glioma_20210215.tped | grep -v "^---" > TCGA_known_SNPs.txt
```
* Move TCGA_known_SNPs.txt and TCGA_glioma_20210212.tped/tfam to TCGA_WTCCC_merged folder
```
scp TCGA_known_SNPs.txt  /home/gguerra/TCGA_WTCCC_merged/
scp TCGA_glioma_20210215.t* /home/gguerra/TCGA_WTCCC_merged/
```
* Go to Matching TCGA + WTCCC (BBC + NBD) SNP data
* Extract only SNPs from Common_SNP_IDs.txt from the tped file in TCGA_WTCCC_merged
```
grep -F -f Common_SNP_IDs.txt TCGA_glioma_20210215.tped > TCGA_common.tped
mv TCGA_glioma_20210215.tfam TCGA_common.tfam
```
* Convert to bed/bim/fam in a 3 step process.
```
sed -i 's/N N/0 0/g' TCGA_common.tped
plink --tfile TCGA_common --recode --out TCGA_common
plink --file TCGA_common --make-bed --out TCGA_common
```
* Use Affy_ID_to_rsid.R to match the affy Ids with rsids in the annotation file, produces Affy_common_rsids.txt and Affy_no_rsids.txt
* Use PLINK to filter out the Affy_no_rsids.txt SNPs
```
plink --bfile TCGA_common --exclude Affy_no_rsids.txt --make-bed --out TCGA_rsids
```
* Use awk to replace the Affy Ids in TCGA_rsids.bim with the first column of Affy_common_rsids.txt
```
awk 'BEGIN {FS="\t";OFS="\t"; print} FNR==NR{a[NR]=$1;next}{$2=a[FNR]}1' Affy_common_rsids.txt TCGA_rsids.bim > TCGA_rsids2.bim
mv TCGA_rsids2.bim TCGA_rsids.bim
```
* Filter for SNP and sample missingness using Programs/Missingness_filter.sh, need to edit the contents of the script first, run with TCGA_rsids
```
sbatch --mem=150G --ntasks=1 --time=4:00:00 --output=%x-%j.out --export=NONE Filter_Missingness.sh
```

* Run /Programs/Supervised_Admixture.sh to get ancestry estimates on each sample, need to edit the contents of the script first, run with TCGA_rsids_2
```
sbatch --mem=150G --ntasks=1 --time=15:00:00 --output=%x-%j.out --export=NONE Supervised_Admixture.sh
```
* Merge the .pop file and the .Q file from the admixture result
* Merge
```
paste -d " " TCGA_rsids_2_pruned.11.pop TCGA_rsids_2_pruned.11.Q | sed -e 's/\t/ /g' > TCGA_rsids_2_pruned.11.admix
```
* Run R script to return vectors of EUR, AFR, AMR, ASN, AMX individuals. (Get_Pop_assignments.R, need to edit in script)
* Run Choose_TCGA_samples.R to pick 1 aliqout of each sample, preferring blood over tumor.
* Filter each ancestry file to only include samples from TCGA_keepers.txt
```
grep -f TCGA_keepers.txt TCGA_rsids_EUR.txt > TCGA_EUR_2.txt
grep -f TCGA_keepers.txt TCGA_rsids_AFR.txt > TCGA_AFR_2.txt
grep -f TCGA_keepers.txt TCGA_rsids_ASA.txt > TCGA_ASA_2.txt
grep -f TCGA_keepers.txt TCGA_rsids_ADMX.txt > TCGA_ADMX_2.txt
```
* Properly get the list of names to keep, need FID and IID
```
grep -f TCGA_EUR_2.txt TCGA_rsids_2.fam | awk '{print $1,$2}' > TCGA_EUR_3.txt
mv TCGA_EUR_3.txt TCGA_EUR_2.txt
grep -f TCGA_AFR_2.txt TCGA_rsids_2.fam | awk '{print $1,$2}' > TCGA_AFR_3.txt
mv TCGA_AFR_3.txt TCGA_AFR_2.txt
grep -f TCGA_ASA_2.txt TCGA_rsids_2.fam | awk '{print $1,$2}' > TCGA_ASA_3.txt
mv TCGA_ASA_3.txt TCGA_ASA_2.txt
grep -f TCGA_ADMX_2.txt TCGA_rsids_2.fam | awk '{print $1,$2}' > TCGA_ADMX_3.txt
mv TCGA_ADMX_3.txt TCGA_ADMX_2.txt
```
* For each ancestry, run Filter_het_HWE_MAF and remove samples with het >3*sd  away from mean, and SNPs with HWE p <10^-6 and MAF<0.005, and removes duplicate SNPs. Produces *_POP.bed/bim/fam files.
* Go to Final Merge of TCGA + WTCCC data by Ancestry and then combined







* Find duplicate individuals, and tag the second if the names are identical
```
awk '{print $2}' TCGA_rsids.fam | sort |uniq -d > TCGA_rsids.dupid
paste TCGA_rsids.dupid TCGA_rsids.dupid  | sed 's/$/_1/' | sed 's/\t/ /g' > TCGA_rsids.dupt
awk '{print $1" "$1"\t" $2" "$2}' TCGA_rsids.dupt > TCGA_rsids.dup
mv TCGA_rsids.fam TCGA_rsids.oldfam
awk '{print $2}' TCGA_rsids.oldfam |  awk 'cnt[$0]++{$0=$0"_"cnt[$0]-1} 1' > TCGA_rsids.temp
paste TCGA_rsids.temp TCGA_rsids.temp <( cut -d ' ' -f3- TCGA_rsids.oldfam) |sed 's/\t/ /g' > TCGA_rsids.fam
```
*
* Run pairwise sample comparison using PLINK2
```
plink2
plink2 --bfile TCGA_rsids --sample-diff 'file=TCGA_rsids.dup' --id-delim ' ' --out TCGA_rsids_dup
```
* Get counts of each duplicated SNP
```
awk '{print $3}' TCGA_rsids_dup.sdiff | sort | uniq -cd > TCGA_rsids.discordant
```
* Filter out snps with >X% discordant (percent of replicate pairs)
*

*

WTCCC British Birth Cohort data
* Affy 6.0 data downloaded by Linda, PLINK format is available (tped).
* Join all .tped files together by stacking (ensuring tfam files match) using merge_tpeds.sh
* Pull all SNP information (Affy ID, chr, pos) from chr1-22 and “---" to try to fill in with TCGA.
```
awk '{print $1,$2,$3,$4}' WTCCC_merged.tped > BBC_SNPs.txt
```
* Copy the tfam file over from one chromosome
```
scp 58C_01_affymetrix.tfam WTCCC_merged.tfam
```
* Move WTCCC_SNPs.txt, and WTCCC_merged.tped/tfam to TCGA_WTCCC_merged folder
```
scp BBC_SNPs.txt /home/gguerra/TCGA_WTCCC_merged/
scp BBC_merged.t* /home/gguerra/TCGA_WTCCC_merged/
```

* Go to Matching TCGA + WTCCC (BBC + NBD) SNP data
* Extract only SNPs from Common_SNP_IDs.txt from the tped file in TCGA_WTCCC_merged
```
grep -F -f Common_SNP_IDs.txt BBC_merged.tped > BBC_common.tped
mv BBC_merged.tfam BBC_common.tfam
```
* Extract the SNP order so that I can reorder the Common_SNPs.txt to put into the file
```
awk '{print $2}' BBC_common.tped > BBC_SNP_order.txt
```
* Run WTCCC_SNP_reorder.R to get the SNP info correctly ordered in BBC_SNP_order.txt
* Replace the first four columns of the data with the correct chr/bp info file (from BBC_SNP_order.txt)
```
paste <( cut -d$'\t' -f1-4 BBC_SNP_order.txt ) <( cut -d$'\t' -f5- BBC_common.tped ) > BBC_common_1.tped
sed -i 's/ /\t/g' BBC_common_1.tped
```

* Move the tfam file to match the tped name
```
mv BBC_common.tfam BBC_common_1.tfam
```

* Convert to bed/bim/fam in a three step process.
```
sed -i 's/N\tN/0\t0/g' BBC_common_1.tped
plink --tfile BBC_common_1 --recode --out BBC_common_1
plink --file BBC_common_1 --make-bed --out BBC_common_1
```
* Use PLINK to filter out the Affy_no_rsids.txt SNPs
```
plink --bfile BBC_common_1 --exclude Affy_no_rsids.txt --make-bed --out BBC_rsids
```
* Use awk to replace the Affy Ids in BBC_rsids.bim with the first column of Affy_common_rsids.txt
```
awk 'BEGIN {FS="\t";OFS="\t"; print} FNR==NR{a[NR]=$1;next}{$2=a[FNR]}1' Affy_common_rsids.txt BBC_rsids.bim > BBC_rsids2.bim
mv BBC_rsids2.bim BBC_rsids.bim
```
* Filter for SNP and sample missingness using Programs/Missingness_filter.sh
```
sbatch --mem=150G --ntasks=1 --time=4:00:00 --output=%x-%j.out --export=NONE Filter_Missingness.sh
```
* Run /Programs/Supervised_Admixture.sh to get ancestry estimates on each sample, output is BBC_rsids_log11.out and BBC_rsids.mylog
```
sbatch --mem=150G --ntasks=1 --time=15:00:00 --output=%x-%j.out --export=NONE Supervised_Admixture.sh
```
* Merge the .pop file and the .Q file from the admixture result
* Merge
```
paste -d " " BBC_rsids_2_pruned.11.pop BBC_rsids_2_pruned.11.Q | sed -e 's/\t/ /g' > BBC_rsids_2_pruned.11.admix
```
* Run R script to return vectors of EUR, AFR, AMR, ASN, AMX individuals.
* Properly get the list of names to keep, need FID and IID
```
grep -f BBC_rsids_EUR.txt BBC_rsids_2.fam | awk '{print $1,$2}' > BBC_EUR_3.txt
mv BBC_EUR_3.txt BBC_EUR.txt
grep -f BBC_rsids_AFR.txt BBC_rsids_2.fam | awk '{print $1,$2}' > BBC_AFR_3.txt
mv BBC_AFR_3.txt BBC_AFR.txt
grep -f BBC_rsids_ASA.txt BBC_rsids_2.fam | awk '{print $1,$2}' > BBC_ASA_3.txt
mv BBC_ASA_3.txt BBC_ASA.txt
grep -f BBC_rsids_ADMX.txt BBC_rsids_2.fam | awk '{print $1,$2}' > BBC_ADMX_3.txt
mv BBC_ADMX_3.txt BBC_ADMX.txt
```
* For each ancestry, run Filter_het_HWE_MAF and remove samples with het >3*sd  away from mean, and SNPs with HWE p <10^-6 and MAF<0.005 and removes duplicate snps Produces *_{pop}_2_het.txt, with list of keepers AFTER filtering. Produces *_POP.bed/bim/fam files.
* Go to Final Merge of TCGA + WTCCC data by Ancestry and then combined


WTCCC National Blood Donor data
* Affy 6.0 data downloaded by Linda, PLINK format is available (tped).
* Join all .tped files together by stacking (ensuring tfam files match) using merge_tpeds.sh
* Pull all SNP information (Affy ID, chr, pos) from chr1-22 and “---" to try to fill in with TCGA.
```
awk '{print $1,$2,$3,$4}' NBD_WTCCC_merged.tped > NBD_SNPs.txt
```

* Copy the tfam file over from one chromosome scp NBS_01_affymetrix.tfam NBD_WTCCC_merged.tfam
* Move NBD_WTCCC_SNPs.txt and NBD_merged.tped/tfam to TCGA_WTCCC_merged folder
```
scp NBD_SNPs.txt /home/gguerra/TCGA_WTCCC_merged/
scp NBD_WTCCC_merged.t* /home/gguerra/TCGA_WTCCC_merged/
```
Renamed to NBD_merged.t* in the new folder.
* Go to Matching TCGA + WTCCC (BBC + NBD) SNP data
* Extract only SNPs from Common_SNP_IDs.txt from the tped file in TCGA_WTCCC_merged
```
grep -F -f Common_SNP_IDs.txt NBD_merged.tped > NBD_common.tped
mv NBD_merged.tfam NBD_common.tfam
```
* Extract the SNP order so that I can rearrange the Common_SNPs.txt to put into the file
```
awk '{print $2}' NBD_common.tped > NBD_SNP_order.txt
```
* Run WTCCC_SNP_reorder.R to get the SNP info correctly ordered in NBD_SNP_order.txt
* Replace the first four columns of the data with the correct chr/bp info file (from NBD_SNP_order.txt)
```
paste <( cut -d " " -f1-4 NBD_SNP_order.txt ) <( cut -d$'\t' -f5- NBD_common.tped ) > NBD_common_1.tped
sed -i 's/ /\t/g' NBD_common_1.tped
```

* Move the tfam file to match the tped name
```
mv NBD_common.tfam NBD_common_1.tfam
```
* Convert to bed/bim/fam in a 3 step process.
```
sed -i 's/N\tN/0\t0/g' NBD_common_1.tped
plink --tfile NBD_common_1 --recode --out NBD_common_1
plink --file NBD_common_1 --make-bed --out NBD_common_1
```
* Use PLINK to filter out the Affy_no_rsids.txt SNPs
```
plink --bfile NBD_common_1 --exclude Affy_no_rsids.txt --make-bed --out NBD_rsids
```
* Use awk to replace the Affy Ids in NBD_rsids.bim with the first column of Affy_common_rsids.txt
```
awk 'BEGIN {FS="\t";OFS="\t"; print} FNR==NR{a[NR]=$1;next}{$2=a[FNR]}1' Affy_common_rsids.txt NBD_rsids.bim > NBD_rsids2.bim
mv NBD_rsids2.bim NBD_rsids.bim
```
* Filter for SNP and sample missingness using Programs/Missingness_filter.sh
```
sbatch --mem=150G --ntasks=1 --time=4:00:00 --output=%x-%j.out --export=NONE Filter_Missingness.sh
```
* Run /Programs/Supervised_Admixture.sh to get ancestry estimates on each sample, output is NBD_rsids_log11.out and NBD_rsids.mylog
```
sbatch --mem=150G --ntasks=1 --time=15:00:00 --output=%x-%j.out --export=NONE Supervised_Admixture.sh
```
* Merge the .pop file and the .Q file from the admixture result
```
paste -d " " NBD_rsids_2_pruned.11.pop NBD_rsids_2_pruned.11.Q | sed -e 's/\t/ /g' > NBD_rsids_2_pruned.11.admix
```
Run R script to return vectors of EUR, AFR, AMR, ASN, AMX individuals
* Properly get the list of names to keep, need FID and IID
```
grep -f NBD_rsids_EUR.txt NBD_rsids_2.fam | awk '{print $1,$2}' > NBD_EUR_3.txt
mv NBD_EUR_3.txt NBD_EUR.txt
grep -f NBD_rsids_AFR.txt NBD_rsids_2.fam | awk '{print $1,$2}' > NBD_AFR_3.txt
mv NBD_AFR_3.txt NBD_AFR.txt
grep -f NBD_rsids_ASA.txt NBD _rsids_2.fam | awk '{print $1,$2}' > NBD_ASA_3.txt
mv NBD_ASA_3.txt NBD_ASA.txt
grep -f NBD_rsids_ADMX.txt NBD_rsids_2.fam | awk '{print $1,$2}' > NBD_ADMX_3.txt
mv NBD_ADMX_3.txt NBD_ADMX.txt
```
* For each ancestry, run Filter_het_HWE_MAF and remove samples with het >3*sd  away from mean, and SNPs with HWE p <10^-6 and MAF<0.005 and duplicate snps. Produces *_{pop}_2_het.txt, with list of keepers AFTER filtering. Produces *_POP.bed/bim/fam files.
* Go to Final Merge of TCGA + WTCCC data by Ancestry and then combined



Mayo data (Oncoarray)
* Plink format data received from Mayo, sequenced on Oncoarray/ Located in /home/gguerra/Mayo_Data/Observed (bed bim fam format)
* Pull all known SNP information (rsid, chr, pos) to compare with AGS Oncoarray
```
awk '{print $1,$2,$4}' /home/gguerra/Mayo_Data/Observed/Mayo_dbGap.bim  > /home/gguerra/Mayo_Data/Observed/Mayo_SNPs.txt
mv /home/gguerra/Mayo_Data/Observed/Mayo_SNPs.txt /home/gguerra/AGS_Mayo_Oncoarray_Merged/
```
* Go to Matching Mayo + AGS SNP data
* Use plink to filter down to the common snps
```
plink --bfile /home/gguerra/Mayo_Data/Observed/Mayo_dbGap --extract /home/gguerra/AGS_Mayo_Oncoarray_Merged/Common_SNP_IDs.txt --make-bed --out /home/gguerra/AGS_Mayo_Oncoarray_Merged/Mayo_merged
```
* Run /home/gguerra/AGS_Mayo_Oncoarray_Merged/chr_and_pos_filler.R to fill in any chr/pos gaps
* Move the new bim to the old place
```
mv Mayo_merged.bim.new Mayo_merged.bim
```
* Filter for only chrs 1-22
```
plink --bfile /home/gguerra/AGS_Mayo_Oncoarray_Merged/Mayo_merged --chr 1-22 --make-bed --out /home/gguerra/AGS_Mayo_Oncoarray_Merged/Mayo
```
* Run Supervised_Admixture.sh
* Merge the .pop file and the .Q file from the admixture result
```
paste -d " " /home/gguerra/AGS_Mayo_Oncoarray_Merged/Mayo_2_pruned.11.pop /home/gguerra/AGS_Mayo_Oncoarray_Merged/Mayo_2_pruned.11.Q | sed -e 's/\t/ /g' > /home/gguerra/AGS_Mayo_Oncoarray_Merged/Mayo_2_pruned.11.admix
```
* Run Get_Pop_assignments.R to get the individual files for population assignments. Keep these files!
* Properly get the list of names to keep, need FID and IID.. different bc Mayo has numeric ids
```
awk '{print $1,$2}' Mayo_2.fam > Mayo.list
grep -Fwf Mayo_EUR.txt Mayo.list > Mayo_EUR_3.txt
mv Mayo_EUR_3.txt Mayo_EUR.txt
grep -Fwf Mayo_AFR.txt Mayo.list > Mayo_AFR_3.txt
mv Mayo_AFR_3.txt Mayo_AFR.txt
grep -Fwf Mayo_ASA.txt Mayo.list > Mayo_ASA_3.txt
mv Mayo_ASA_3.txt Mayo_ASA.txt
grep -Fwf Mayo_ADMX.txt Mayo.list > Mayo_ADMX_3.txt
mv Mayo_ADMX_3.txt Mayo_ADMX.txt
rm Mayo.list
```
* For each ancestry, run Filter_het_HWE_MAF and remove samples with het >3*sd  away from mean, and SNPs with HWE p <10^-6 and MAF<0.005 and duplicate snps. Produces *_{pop}_2_het.txt, with list of keepers AFTER filtering. Produces *_POP.bed/bim/fam files.
* Go to Final Merge of AGS+Mayo oncoarray data by Ancestry and then combined
AGS data (Oncoarray)
* Plink format in /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347*
* Pull all known SNP information (rsid, chr, pos) to compare with Mayo
```
awk '{print $1,$2,$4}' /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347.bim  > /home/gguerra/AGS_Data/AGS_Onco_SNPs.txt
mv /home/gguerra/AGS_Data/AGS_Onco_SNPs.txt /home/gguerra/AGS_Mayo_Oncoarray_Merged/
```
* Go to Matching Mayo + AGS SNP data
* Use plink to filter down to the common snps
```
plink --bfile /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347 --extract /home/gguerra/AGS_Mayo_Oncoarray_Merged/Common_SNP_IDs.txt --make-bed --out /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_onco_merged
```
* Run /home/gguerra/AGS_Mayo_Oncoarray_Merged/chr_and_pos_filler.R to fill in any chr/pos gaps
* Move the new bim to the old place
```
mv AGS_onco_merged.bim.new AGS_onco_merged.bim
```
* Filter for only chrs 1-22
```
plink --bfile /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_onco_merged --chr 1-22 --make-bed --out /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_onco
```
* Run Supervised_Admixture.sh
* Merge the .pop.file and the .Q file from the admixture result
```
paste -d " " /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_onco_2_pruned.11.pop /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_onco_2_pruned.11.Q | sed -e 's/\t/ /g' > /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_onco_2_pruned.11.admix
```
* Run Get_Pop_assignments.R to get the individual files for population assignments. Keep these files!
* Properly get the list of names to keep, need FID and IID
```
grep -f AGS_onco_EUR.txt AGS_onco_2.fam | awk '{print $1,$2}' > AGS_onco_EUR_3.txt
mv AGS_onco_EUR_3.txt AGS_onco_EUR.txt
grep -f AGS_onco_AFR.txt AGS_onco_2.fam | awk '{print $1,$2}' > AGS_onco_AFR_3.txt
mv AGS_onco_AFR_3.txt AGS_onco_AFR.txt
grep -f AGS_onco_ASA.txt AGS_onco_2.fam | awk '{print $1,$2}' > AGS_onco_ASA_3.txt
mv AGS_onco_ASA_3.txt AGS_onco_ASA.txt
grep -f AGS_onco_ADMX.txt AGS_onco_2.fam | awk '{print $1,$2}' > AGS_onco_ADMX_3.txt
mv AGS_onco_ADMX_3.txt AGS_onco_ADMX.txt
grep -f AGS_onco_AMR.txt AGS_onco_2.fam | awk '{print $1,$2}' > AGS_onco_AMR_3.txt
mv AGS_onco_AMR_3.txt AGS_onco_AMR.txt
```

* For each ancestry, run Filter_het_HWE_MAF and remove samples with het >3*sd  away from mean, and SNPs with HWE p <10^-6 and MAF<0.005 and duplicate snps. Produces *_{pop}_2_het.txt, with list of keepers AFTER filtering. Produces *_POP.bed/bim/fam files.
* Go to Final Merge of AGS+Mayo oncoarray data by Ancestry and then combined

AGS data (Illumina)
* Plink format in /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677*
* Filter for only chrs 1-22
```
plink --bfile /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677 --chr 1-22 --make-bed --out /home/gguerra/AGS_illumina/AGS_il
```
* Filter for relatedness
```
plink2 --bfile AGS_il --make-king triangle bin --out AGSKing
plink2 --bfile AGS_il --king-cutoff AGSKing 0.12 --out AGS_relations
plink2 --bfile AGS_il --remove AGS_relations.king.cutoff.out.id --make-bed --out AGS_il_2
```
* Run Supervised_Admixture.sh
* Merge the .pop file and the .Q file from the admixture result
```
paste -d " " /home/gguerra/AGS_illumina/AGS_il_2_2_pruned.11.pop /home/gguerra/AGS_illumina/AGS_il_2_2_pruned.11.Q | sed -e 's/\t/ /g' > /home/gguerra/AGS_illumina/AGS_il_2_2_pruned.11.admix
```
* Run Get_Pop_assignments.R to get the individual files for population assignments. Keep these files!
* Properly get the list of names to keep, need FID and IID
```
grep -f AGS_il_2_EUR.txt AGS_il_2_2.fam | awk '{print $1,$2}' > AGS_il_2_EUR_3.txt
mv AGS_il_2_EUR_3.txt AGS_il_2_EUR.txt
grep -f AGS_il_2_AFR.txt AGS_il_2_2.fam | awk '{print $1,$2}' > AGS_il_2_AFR_3.txt
mv AGS_il_2_AFR_3.txt AGS_il_2_AFR.txt
grep -f AGS_il_2_ASA.txt AGS_il_2_2.fam | awk '{print $1,$2}' > AGS_il_2_ASA_3.txt
mv AGS_il_2_ASA_3.txt AGS_il_2_ASA.txt
grep -f AGS_il_2_ADMX.txt AGS_il_2_2.fam | awk '{print $1,$2}' > AGS_il_2_ADMX_3.txt
mv AGS_il_2_ADMX_3.txt AGS_il_2_ADMX.txt
grep -f AGS_il_2_AMR.txt AGS_il_2_2.fam | awk '{print $1,$2}' > AGS_il_2_AMR_3.txt
mv AGS_il_2_AMR_3.txt AGS_il_2_AMR.txt
```
* For each ancestry, run Filter_het_HWE_MAF and remove samples with het >3*sd  away from mean, and SNPs with HWE p <10^-6 and MAF<0.005 and duplicate snps. Produces *_{pop}_2_het.txt, with list of keepers AFTER filtering. Produces *_POP.bed/bim/fam files.
* Merge all pop datasets with Merge_final_for_imputation.sh


Matching TCGA + WTCCC (BBC + NBD) SNP data
* Find list of Affy ID’s contained in all three datasets which have chr/bp information from TCGA, using R.  TCGA_WTCCC_SNP_overlap.R
* Filters down to 868,356 SNPs
* Output file /home/gguerra/TCGA_WTCCC_merged/ Common_SNPs.txt which contains Affy ID chr and bp information.
* Filter out 1 SNP_A-2013519 0 53343880 because it was acting very strange on the command line.
```
grep -v "SNP_A-2013519”
```
* Use Common_SNPs.txt to filter each tped file to contain the correct information.
Extract column 2 of common_snps to get affy Ids to grep
```
grep -v "SNP_A-2013519" Common_SNPs.txt | awk '{print $2}' >Common_SNP_IDs.txt
```

Final Merge of TCGA + WTCCC data by Ancestry and then combined
* For each ancestry and data type, get list of SNPs
(EUR and ADMX only ones with common, AFR is TCGA only)
Use the TCGA_WTCCC_SNP_overlap_Pop_Specific.R script.
* Run Merge_Pop_Specific_Datasets.sh for each common population
* Results in binary files titled Merged_* for * population.
* Remove chr 23 from each, shouldn’t have made it this far.
```
plink --bfile --chr 1-22 --make-bed --out (included in the below script)
```
* Merge all population files together, and just code things as missing.
```
/Programs/QC_scripts/Merge_final_for_imputation.sh
```
* Run triple-liftover script on the merged dataset. (in TCGA_WTCCC_merged folder)

Matching Mayo + AGS SNP data
* Run /home/gguerra/AGS_Mayo_Oncoarray_Merged/AGS_Mayo_Oncoarray_SNP_overlap.R
* Generate a common SNP ID file to use in plink
```
awk '{print $2}' Common_SNPs.txt > Common_SNP_IDs.txt
```

Final Merge of AGS+Mayo oncoarray data by Ancestry and then combined
* For each ancestry and data type, get list of SNPs -- use AGS_Mayo_Pop_Specific_SNP_Overlap.R
* For ancestries that Mayo and AGS share, use Merge_Pop_Specific_Datasets.sh
* Try and only use two files at a time
* Merge all pop datasets with Merge_final_for_imputation.sh
* DID THESE STEPS LATER, SO NOT REFLECTED IN IMPUTED DATASET UNTIL AFTER I FILTERED IT
Check for relatedness between Mayo and AGS, and there can be overlap in the controls.
```
plink2 --bfile AGS_Mayo_Oncoarray_for_QC --make-king triangle bin --out AGS_Mayo_King
plink2 --bfile AGS_Mayo_Oncoarray_for_QC --king-cutoff AGS_Mayo_King 0.12 --out AGS_Mayo_relations
```
Move AGS_Mayo_relations.king.cutoff.out.id to the working/covariates folder
scp
```
scp AGS_Mayo_relations.king.cutoff.out.id /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-covariates/AGS_Mayo_duplicate_controls.txt
```
Convert it so the name matches properly
```
sed -i 's/\t/_/g' AGS_Mayo_duplicate_controls.txt
```
* Redid PCs to filter out these individuals before calculations too.
*
Post-imputation Filter and Processing (New file only ran on the TCGA WTCCC so far)
* Run /home/gguerra/Programs/QC_scripts/Process_imputed_data_2.sh
* Filter out SNPs with Rsq < 0.3
* Filter for MAF >0.0001
* Generate an HWE file using controls only
* Convert file to pgen/pvar/psam plink2 format.

Matching to snp2HLA rsIDs
* I converted the HM_CEU reference SNPs to hg38 coords using liftOver
* Results in /home/gguerra/reference/snp_2_hla_hg38_coords.txt
* Filter the input dataset down to just these SNPs



