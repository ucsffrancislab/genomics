
https://github.com/parklab/xTea/blob/master/Demo/demo_readme.md


cat ~/github/parklab/xTea/Demo/run_gnrt_pipeline.sh 


```
SAMPLE_ID=sample_id.txt
BAMS=sample_bam.txt
X10_BAM=null
WFOLDER=/francislab/data1/working/CEPH-ENA-PRJEB3381/20220406-xTea-Demo
OUT_SCRTP=submit_jobs.sh
TIME=0-05:00
REP_LIB=/francislab/data1/refs/xTea/rep_lib_annotation
REF=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa
GENE=/francislab/data1/refs/sources/ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_33/gencode.v33.annotation.gff3
BLK_LIST=/francislab/data1/refs/xTea/rep_lib_annotation/rep_lib_annotation/blacklist/hg19/centromere.bed
XTEA=/xtea/

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=xTea --time=60 --nodes=1 --ntasks=8 --mem=30G --output=${PWD}/xTea.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img python /xtea/gnrt_pipeline_local.py -i ${SAMPLE_ID} -b ${BAMS} -x ${X10_BAM} -p ${WFOLDER} -o ${OUT_SCRTP} -q short -n 8 -m 16 -t ${TIME} -l ${REP_LIB} -r ${REF} -g ${GENE} --nclip 4 --cr 2 --nd 5 --nfclip 4 --nfdisc 5 --flklen 3000 -f 5907 -y 15 --blacklist ${BLK_LIST} --xtea ${XTEA}"

chmod +x ${PWD}/NA12878/*/run_xTEA_pipeline.sh


/francislab/data1/working/CEPH-ENA-PRJEB3381/20220406-xTea-Demo/NA12878/L1/run_xTEA_pipeline.sh
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220406-xTea-Demo/NA12878/Alu/run_xTEA_pipeline.sh
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220406-xTea-Demo/NA12878/SVA/run_xTEA_pipeline.sh
/francislab/data1/working/CEPH-ENA-PRJEB3381/20220406-xTea-Demo/NA12878/HERV/run_xTEA_pipeline.sh




base=HERV
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=4320 --nodes=1 --ntasks=16 --mem=60G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img ${PWD}/NA12878/${base}/run_xTEA_pipeline.sh"

base=L1
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=4320 --nodes=1 --ntasks=16 --mem=60G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img ${PWD}/NA12878/${base}/run_xTEA_pipeline.sh"

base=Alu
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=4320 --nodes=1 --ntasks=16 --mem=60G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img ${PWD}/NA12878/${base}/run_xTEA_pipeline.sh"

base=SVA
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=${base} --time=4320 --nodes=1 --ntasks=16 --mem=60G --output=${PWD}/${base}.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img ${PWD}/NA12878/${base}/run_xTEA_pipeline.sh"

```






