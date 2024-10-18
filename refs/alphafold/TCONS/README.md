
#	alphafold/TCONS



```

ll /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-???.fa | wc -l
2090
ll /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-??.fa | wc -l
462
ll /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-?.fa | wc -l
26

```


```

for f in /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-???.fa \
  /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-??.fa \
  /francislab/data1/working/20230426-PanCancerAntigens/20230426-explore/Allergens/S10/TCONS_????????-?.fa ; do
ln $f
done

```



```

alphafold_array_wrapper.bash --time 14-0 --threads 8 --extension .fa TCONS_????????-?.fa


```



