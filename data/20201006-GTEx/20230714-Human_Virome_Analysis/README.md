
#	20201006-GTEx/20230714-Human_Virome_Analysis


```

Human_Virome_Analysis_array_wrapper.bash --threads 4 --extension .Aligned.sortedByCoord.out.bam \
--out ${PWD}/out ${PWD}/../20230714-STAR/out/*.Aligned.sortedByCoord.out.bam 

```



How to tablify results to compare to paper

```
head ../Human_Virome_analysis/12915_2020_785_MOESM3_ESM.tsv 
Additional file 3: Table S3. Read count of the respective 39 viral species detected in this study.									
Run	Acute bee paralysis	Acyrthosiphon pisum virus	AAV2	Anopheles gambiae densonuclosis	mellifera filamentous virus	Bovine coronavirus	HCOSV-A	Deformed wing virus	GBV (HGV)	Gemycircularvirus_HV-GcV1	HCV	Hubei picorna virus	Hubei arthropod virus 1	HHV-6A	HCoV-229E	EBV (HHV-4)	HSV-1	HHV-3	CMV (HHV-5)	HHV-6B	HHV-7	Human parainfluenza virus 3	Lassa virus	MSSI2.225 virus	Merkel cell polyomavirus	Papiloma	RSV	TTV	Tomato spotted wilt virus
SRR1068687	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0.000121038037326959	00
SRR1068788	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
SRR1068832	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	00
SRR1068855	0	0	0	0	0	0	0	0	0	0	0	0.000522880869233328	0	0	0	0.000189142443922233	0	0	0	0	0	0	0	0	0	0	0	0	0
```


```
cat out/*count.txt
```

```
cat /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/SRR808614_R1.fastq.gz.read_count.txt
59085492
```


```
1000*160/(2*59085492)
```



```
for f in out/*.count.txt ; do
echo $f
srr=$( basename ${f} .count.txt )
rc=$( cat /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/${srr}_R1.fastq.gz.read_count.txt )
awk -v rc=${rc} 'BEGIN{FS=OFS="\t"}(NR==1){print;next}(/^ID_/){print $1,(1000*$2/(2*rc))}' ${f} > ${f%.txt}.normalized.txt
done

```

```
python3 ./merge.py --out merged.tsv out/*.count.normalized.txt
```


```
( ( head -1 merged.tsv ) && ( tail -n +2 merged.tsv | sort -k1,1 ) ) > merged.sorted.tsv
( ( head -2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | tail -n 1 | sed 's/Refseq ID/Refseq_ID/' ) && ( tail -n +3 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM11_ESM.tsv | sed 's/[",]//g' | sort -k3 ) ) | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3}' > 12915_2020_785_MOESM11_ESM.sorted.tsv

join --header -1 3 -2 1 12915_2020_785_MOESM11_ESM.sorted.tsv merged.sorted.tsv | datamash transpose -t ' ' | tail -n +3 | sed 's/ /\t/g' > transposed.tsv

join --header transposed.tsv <( tail -n +2 ~/github/ucsffrancislab/Human_Virome_analysis/12915_2020_785_MOESM3_ESM.tsv | sed 's/ /_/g' ) | sed 's/ /,/g' > compared.csv
```





```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in compared.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```

