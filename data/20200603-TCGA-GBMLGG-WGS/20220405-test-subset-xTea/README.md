
https://github.com/parklab/xTea

See `/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220302-xTea-test/README.md`


```
ln -s /francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20220302-xTea-test/rep_lib_annotation



for bam in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20220328-test-subset/out.alts/*bam ; do
base=$( basename $bam .bam )
echo -e "${base}\t${bam}" >> bam_list.txt
echo -e "${base}" >> sample_id.txt
done
```



```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=xTea --time=60 --nodes=1 --ntasks=8 --mem=30G --output=${PWD}/xTea.txt --wrap "singularity exec --bind /francislab,/scratch /francislab/data1/refs/singularity/xTea.img xtea -i ${PWD}/sample_id.txt -b ${PWD}/bam_list.txt -x null -p ${PWD}/tmp/ -o submit_jobs.sh -l ${PWD}/rep_lib_annotation/ -r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa -g /francislab/data1/refs/sources/ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_33/gencode.v33.annotation.gff3 -f 5907 -y 8 -n 16 -m 60"

chmod +x ${PWD}/tmp/*/HERV/run_xTEA_pipeline.sh



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S" )

sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-6%1 --job-name="xTea" --output="${PWD}/logs/array.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=16 --mem=60G ${PWD}/array_wrapper.bash
```


Produces lots of empty candidate_disc_filtered_cns files. Must be doing something wrong.



gff3 file does not include alternates. The chr_patch_hapl_scaff version does, but they don't include the chr prefix. Yet another inconsistency. Everybody does it differently.



