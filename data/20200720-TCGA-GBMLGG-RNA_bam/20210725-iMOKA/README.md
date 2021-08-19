
Raw data length varies, either 48 or 76

~171 / 686 are 48bp



```
mkdir -p raw
for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*fastq.gz ; do
echo $f
base=$( basename $f .fastq.gz )
ln -s $f raw/${base}.fastq.gz
done
```



sample - group - filelist

```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}($6!="not reported"){print $1,$6}' ) > source.gender.tsv
```



Preprocessing all ~700 samples is taking a while. 
Since the kmer tsv is the same no matter the field, share them and create a separate create_matrix.tsv file.



```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$3}' ) > source.primary_diagnosis.tsv

mkdir 31.primary_diagnosis
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/31.primary_diagnosis/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$3}' ) > 31.primary_diagnosis/create_matrix.tsv
```


```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$8}' ) > source.IDH.tsv

mkdir 31.IDH
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/31.IDH/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}($8!="NA"){print $1,$8}' ) > 31.IDH/create_matrix.tsv
```



```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$9}' ) > source.x1p19q.tsv

mkdir 31.x1p19q
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/31.x1p19q/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}($9!="NA"){print $1,$9}' ) > 31.x1p19q/create_matrix.tsv
```



```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$10}' ) > source.TERT.tsv

mkdir 31.TERT
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/31.TERT/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}($10!="NA"){print $1,$10}' ) > 31.TERT/create_matrix.tsv
```



```
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "${s}\t${field}\t${f}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$11}' ) > source.IDH_1p19q_status.tsv

mkdir 31.IDH_1p19q_status
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/31.IDH_1p19q_status/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}($11!~/NA/){print $1,$11}' ) > 31.IDH_1p19q_status/create_matrix.tsv
```




```
mkdir 31.WHO_groups
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/31.WHO_groups/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}($12!~/NA/){print $1,$12}' ) > 31.WHO_groups/create_matrix.tsv
```







```
mkdir 71.primary_diagnosis
while read subject field; do
s=${subject#TCGA-}
f=$( ls ${PWD}/raw/${s}-01* 2> /dev/null | paste -sd";" )
if [ -n "${f}" ] ; then
field=${field/,/}
field=${field/ /_}
echo -e "/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/71.primary_diagnosis/preprocess/${s}/${s}.tsv\t${s}\t${field}"
fi
done < <( tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $1,$3}' ) > 71.primary_diagnosis/create_matrix.tsv
ln -s ../71.gender/preprocess 71.primary_diagnosis/
```



Many files, likely with shorter reads, will cause the create step to crash.
```
date=$( date "+%Y%m%d%H%M%S" )
mv create_matrix.tsv create_matrix.${date}.tsv
while read file subject field ; do
if [ -f "${file}.sorted.bin" ] ; then
echo -e "${file}\t${subject}\t${field}"
fi
done < create_matrix.${date}.tsv > create_matrix.tsv
```




tail -n +2 TCGA.Glioma.metadata.tsv | awk 'BEGIN{FS=OFS="\t"}{print $12}' | sort | uniq -c


case_submitter_id	project_id	primary_diagnosis	race	ethnicity	gender	RE_names	IDH	x1p19q	TERT	IDH_1p19q_status	WHO_groups	Triple_group	Tissue_sample_location	MGMT	Age	Survival_months	Vital_status




/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/

/francislab/data1/raw/20200603-TCGA-GBMLGG-WGS/metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv 

I also think running the TGGA glioma RNA by WHO subtype could be informative


```
awk -v dir=${PWD}/raw/ 'BEGIN{FS=",";OFS="\t"}(NR>1){print $1,$2,dir$1"_R1.fastq.gz;"dir$1"_R2.fastq.gz"}' /francislab/data1/raw/20200720-TCGA-GBMLGG-RNA_bam/WES_samples_classified.csv > source.tumor_type.tsv
```

```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for i in 31 ; do
s=${i}.gender_test
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
done

s=31.IDH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/${s}/output_models"
curl -netrc -X MKCOL "${BOX}/"
for f in ${s}/output_models/*_tree_acc_*.png ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```



```
module load WitteLab python3/3.9.1

python3


import pickle
unpickled = []
f = open('9_RF.pickle', 'rb')
while True:
	try:          
		unpickled.append(pickle.load(f))
	except EOFError:
		break

f.close()

model = unpickled[0][0]

from sklearn.tree import export_graphviz
from subprocess import call

for i in range(len(model.estimators_)):
	# Extract single tree - 0-99
	estimator = model.estimators_[i]
	
	# Export as dot file
	export_graphviz(estimator, out_file='tree'+str(i)+'.dot', 
		feature_names = unpickled[0][1],
		class_names = unpickled[0][2],
		rounded = True, proportion = False, 
		precision = 2, filled = True)
	
	# Convert to png using system command (requires Graphviz)
	call(['dot', '-Tpng', 'tree'+str(i)+'.dot', '-o', 'tree'+str(i)+'.png', '-Gdpi=600'])

```

```
s=31.IDH_1p19q_status
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/${s}"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T ${s}/aggregated.json "${BOX}/"
curl -netrc -T ${s}/output.json "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210725-iMOKA/${s}/output_models"
curl -netrc -X MKCOL "${BOX}/"
for f in ${s}/output_models/*_tree_acc_*.png ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```

