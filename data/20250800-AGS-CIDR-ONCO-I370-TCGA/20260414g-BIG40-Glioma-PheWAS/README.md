
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
