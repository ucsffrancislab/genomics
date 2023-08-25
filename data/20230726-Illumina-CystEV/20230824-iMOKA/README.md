
#	20230726-Illumina-CystEV/20230824-iMOKA


Create kmers from select kmers from models from 20210428-EV iMOKA runs for the "CSF Liquid biopsy protocol" data




ONLY DEDUPED READS THAT ALIGNED TO HUMAN


```
mkdir -p in
for id in \
  $( awk -F, '($7=="CSF Liquid biopsy protocol"){print $1}' \
  /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv ) ; do
  for f in $( ls ../20230809-preprocess/out/${id}.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.??.fastq.gz 2> /dev/null ) ; do
    echo $f
    l=$( basename ${f} .fastq.gz )
    r=${l#*.deduped.}
    l=${l%.format.*}
    ln -s ../${f} in/${l}_${r}.fastq.gz
  done
done
```






Paired data, so R1;R2 and also O1;O2 (never any S0)

NO SPACES IN GROUP NAMES

```
awk -v pwd=${PWD} 'BEGIN{FS=",";OFS="\t"}($7=="CSF Liquid biopsy protocol"){ if(system("test -f in/"$1"_R1.fastq.gz")==0){ print $1,$8,pwd"/in/"$1"_R1.fastq.gz;"pwd"/in/"$1"_R2.fastq.gz;"pwd"/in/"$1"_O1.fastq.gz;"pwd"/in/"$1"_O2.fastq.gz" } }' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv | sed 's/ /_/g' > source.all.tsv

```


```
for k in 13 16 21 31 35 39 43 ; do
  iMOKA_count.bash -k ${k} --threads 32 --mem 240
done
```

```
chmod -w out/*/preprocess/*/*bin
```





```
\rm iMOKA_commands
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
for k in 13 16 21 31 35 39 43 ; do
mkdir -p ${PWD}/all/${k}
if [ -f ${PWD}/../../20210428-EV/20230606-iMOKA/out/IDH-Lexogen-${k}/output.json ] ; then
cat ${PWD}/../../20210428-EV/20230606-iMOKA/out/IDH-Lexogen-${k}/output_models/*.features | sort | uniq > ${PWD}/all/${k}/select_kmers.txt
cp ${PWD}/out/${k}/create_matrix.tsv ${PWD}/all/${k}/create_matrix.tsv
echo "export SINGULARITY_BINDPATH=/francislab; export APPTAINER_BINDPATH=/francislab; export OMP_NUM_THREADS=8; export IMOKA_MAX_MEM_GB=50; singularity exec ${img} iMOKA_core create -i ${PWD}/all/${k}/create_matrix.tsv -o ${PWD}/all/${k}/create_matrix.json; singularity exec ${img} iMOKA_core extract -s ${PWD}/all/${k}/create_matrix.json -i ${PWD}/all/${k}/select_kmers.txt -o ${PWD}/all/${k}/select_kmers.tsv" >> iMOKA_commands
fi
done

commands_array_wrapper.bash --array_file iMOKA_commands --time 720 --threads 8 --mem 60G 
```






```
cat all/*/select_kmers.tsv

```


Almost all non-existant







