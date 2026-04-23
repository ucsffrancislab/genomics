
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260413-BIG40-Glioma-PheWAS



TAKE WAY WAY TOO LONG.

Parallel attempts appear to be blocked.

They said that part of their network is down for maintenance.

```bash/

mkdir -p /francislab/data1/refs/BIG40

nohup ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/01_download_big40.sh /francislab/data1/refs/BIG40 10 > 01_download_big40.log 2>&1 &

```



```bash

~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/02_download_ebi.sh /francislab/data1/refs/BIG40 > 02_download_ebi.log 2>&1 &

```




```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=validate --time=14-0 --export=None --output="${PWD}/03_validate_ebi.$( date "+%Y%m%d%H%M%S%N" ).log" --nodes=1 --ntasks=2 --mem=15G ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/03_validate_ebi.sh /francislab/data1/refs/BIG40

```




```bash

bash ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/04_validate_stats33k.sh /francislab/data1/refs/BIG40

```


```bash
bash ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/05_install_prscs.sh ~/.local/

```

```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=format --time=14-0 --export=None --output="${PWD}/06_format_for_prscs.$( date "+%Y%m%d%H%M%S%N" ).log" --nodes=1 --ntasks=16 --mem=120G ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/06_format_for_prscs.sh /francislab/data1/refs/BIG40 16
```



```bash
basedir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA
mkdir -p input
cd input

for ds in onco i370 tcga ; do
ln -s ${basedir}/20251218-survival_gwas/imputed-umich-${ds}
done

ds=cidr
ln -s /francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/imputed-umich-${ds}
cd ..
```



```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=extract_bim --time=14-0 --export=None --output="${PWD}/07_extract_bim.$( date "+%Y%m%d%H%M%S%N" ).log" --nodes=1 --ntasks=16 --mem=120G ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/07_extract_bim.sh ${PWD}/input /francislab/data1/refs/BIG40/target_bim
```





The hdf5 files are in ~/.local/ld_ref/ldblk_1kg_eur/



```bash

BIM_DIR=/francislab/data1/refs/BIG40/target_bim
SNPINFO=~/.local/ld_ref/ldblk_1kg_eur/snpinfo_1kg_hm3
REMAP=~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/07c_remap_bim_rsids.py

for cohort in cidr i370 onco tcga; do
    python3 $REMAP \
        $BIM_DIR/imputed-umich-${cohort}.bim \
        $BIM_DIR/${cohort}.bim \
        $SNPINFO
    echo
done

```


```bash
bash ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/patch_prscs_numpy2.sh          # patches ~/.local/PRScs/mcmc_gtb.py
# expected output:
#   patched: /c4/home/gwendt/.local/PRScs/mcmc_gtb.py
#   backup:  /c4/home/gwendt/.local/PRScs/mcmc_gtb.py.bak
```






THIS TAKES TOO LONG ..


sbatch --array=1 ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/08_run_prscs.sh cidr ${PWD}/ct_output


```bash
#sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=run_prscs --time=14-0 --export=None --output="${PWD}/08_run_prscs.$( date "+%Y%m%d%H%M%S%N" ).log" --nodes=1 --ntasks=16 --mem=120G ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/08_run_prscs.sh ${PWD}/input /francislab/data1/refs/BIG40/target_bim
```


This as it would take about 60 days of uninterupted compute time on our node.
We have opted to filter the 3935 traits to the top by literature and the top by our own C+T run which we are doing next.

/francislab/data1/refs/sources/fileserve.mrcieu.ac.uk/ld/




THIS TAKES TOO LONG AS WELL



```bash
mkdir -p logs

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0  --job-name=ct \
  --output="logs/ct-%j.out" --error="logs/ct-%j.err" \
  --ntasks=1 --cpus-per-task=64 --mem=490G  \
  ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/08b_run_ct.sh \
  ${PWD}/input \
  ${PWD}/ct_output

```






GOnna preextract the SNPs and create new plink files once, then score them


This took about an hour an a half

```bash
mkdir -p ct_output

sbatch --output="ct_output/ct_prep-%j.out" --error="ct_output/ct_prep-%j.err" \
       --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --job-name=ct_prep \
       --ntasks=1 --cpus-per-task=64 --mem=490G \
       ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/08b_prep_target.sh \
       ${PWD}/input ${PWD}/ct_output
```



This took about 25 hours

```bash

sbatch --output="ct_output/ct-%j.out" --error="ct_output/ct-%j.err" \
       --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --job-name=ct \
       --ntasks=1 --cpus-per-task=64 --mem=490G \
       ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/08b_run_ct.sh \
       ${PWD}/ct_output

```




Link covariates

```bash
cd input
for f in /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/*-covariates.csv ; do
ln -s $f
done
cd ..
```


Takes about a minute

```bash

sbatch --output="ct_output/ct_association-%j.out" --error="ct_output/ct_association-%j.err" \
       --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --job-name=ct_association \
       --ntasks=1 --cpus-per-task=64 --mem=490G \
       --wrap="module load r; ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/09_ct_association.R \
         ${PWD}/ct_output ${PWD}/input 64"

```


Based on these results there are only a couple hundred worthy (these times are under reported. C would've been about 120 days)

```
PRS-CS Selection Options
Option	                     IDPs	Time (500 iter)	Time (1000 iter)
A: C+T p<0.01 only	          221	~1 day	         ~2 days
B: C+T p<0.05 only	          847	~3 days	         ~7 days
C: Literature ∪ C+T p<0.05	2,503	~9 days	        ~18 days
```

This is gonna peg CPU and memory and probably crash a bit.

It will need rerun with fewer cpus-per-task to fix.

```bash

# One job per cohort, all 4 can run in parallel if nodes are available
mkdir -p prscs_output
for cohort in cidr i370 onco tcga; do
    sbatch --output="prscs_output/prscs-${cohort}-%j.out" \
           --error="prscs_output/prscs-${cohort}-%j.err" \
           --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 \
           --job-name=prscs-${cohort} \
           --ntasks=1 --cpus-per-task=64 --mem=490G \
           ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/08_run_prscs.sh \
           ${PWD}/prscs_output "$cohort" ~/github/ucsffrancislab/Claude-BIG40-Glioma-PheWAS/prscs_idp_list.txt
done

```


