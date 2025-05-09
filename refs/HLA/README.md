
#	HLA



http://www.allelefrequencies.net/hla.asp


http://www.allelefrequencies.net/BrowseGenotype.aspx


Allele and Haplotype Frequencies of HLA-A, -B, -C, and -DRB1 Genes in 3,750 Cord Blood Units From a Kinh Vietnamese Population

https://pmc.ncbi.nlm.nih.gov/articles/PMC9277059





http://www.allelefrequencies.net/hla6006a_scr.asp?hla_locus=&hla_locus_type=Classical&hla_allele1=&hla_allele2=&hla_selection=&hla_pop_selection=&hla_population=3562&hla_country=&hla_dataset=&hla_region=&hla_ethnic=&hla_study=&hla_sample_size=&hla_sample_size_pattern=&hla_sample_year=&hla_sample_year_pattern=&hla_level=&hla_level_pattern=&hla_show=&hla_order=order_1&standard=

allelefreqs1.tsv




* Allele Frequency: Total number of copies of the allele in the population sample (Alleles / 2n) in decimal format.
   Important: This field has been expanded to four decimals to better represent frequencies of large datasets (e.g. where sample size > 1000 individuals)
* % of individuals that have the allele: Percentage of individuals who have the allele in the population (Individuals / n).
* Allele Frequencies shown in green were calculated from Phenotype Frequencies assuming Hardy-Weinberg proportions.
   AF = 1-square_root(1-PF)
   PF = 1-(1-AF)2
   AF = Allele Frequency; PF = Phenotype Frequency, i.e. (%) of the individuals carrying the allele.
* Allele Frequencies marked with (*) were calculated from all alleles in the corresponding G group.

¹ IMGT/HLA Database - For more details of the allele.
² Distribution - Graphical distribution of the allele.
³ Haplotype Association - Find HLA haplotypes with this allele.
ª Notes - See notes for ambiguous combinations of alleles.





http://www.allelefrequencies.net/hla6006a_scr.asp?hla_locus=&hla_locus_type=Classical&hla_allele1=&hla_allele2=&hla_selection=&hla_pop_selection=&hla_population=1358&hla_country=&hla_dataset=&hla_region=&hla_ethnic=&hla_study=&hla_sample_size=&hla_sample_size_pattern=equal&hla_sample_year=&hla_sample_year_pattern=equal&hla_level=&hla_level_pattern=equal&hla_show=&hla_order=order_1&standard=a

allelefreqs2.tsv





http://www.allelefrequencies.net/hla6006a_scr.asp?hla_locus=&hla_locus_type=Classical&hla_allele1=&hla_allele2=&hla_selection=&hla_pop_selection=&hla_population=3210&hla_country=&hla_dataset=&hla_region=&hla_ethnic=&hla_study=&hla_sample_size=&hla_sample_size_pattern=equal&hla_sample_year=&hla_sample_year_pattern=equal&hla_level=&hla_level_pattern=equal&hla_show=&hla_order=order_1&standard=a

allelefreqs.USANMDPEuropeanCaucasian.tsv






```
awk -F"\t" '{sub(":","",$1);print "HLA-"$1","$4}' allelefreqs.USANMDPEuropeanCaucasian.tsv > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv
mv tmp2.csv allelefreqs.USANMDPEuropeanCaucasian.for_joining.csv
\rm tmp1.csv

join --header -t, allelefreqs.USANMDPEuropeanCaucasian.for_joining.csv /francislab/data1/refs/PhIP-Seq/MHC/VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.csv > VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv 
```

Not really sure how to combine these


```
awk 'BEGIN{FS=OFS=","}(NR==1){print}(NR>1){for(i=3;i<=NF;i++){if($i!=""){$i=$2}else{$i=0} }print}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv | datamash --headers -t, sum 3-$( awk -F, '(NR==1){print NF}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv ) | datamash transpose -t, | sed -e 's/sum(//' -e 's/)//' > tile_sum_HLA_freqs.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print}(NR>1){for(i=3;i<=NF;i++){if($i!=""){$i=$2}else{$i=0} }print}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv | datamash --headers -t, mean 3-$( awk -F, '(NR==1){print NF}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv ) | datamash transpose -t, | sed -e 's/mean(//' -e 's/)//' > tile_mean_HLA_freqs.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print}(NR>1){for(i=3;i<=NF;i++){if($i!=""){$i=$2}else{$i=0} }print}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv | datamash --headers -t, median 3-$( awk -F, '(NR==1){print NF}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv ) | datamash transpose -t, | sed -e 's/median(//' -e 's/)//' > tile_median_HLA_freqs.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print}(NR>1){for(i=3;i<=NF;i++){if($i!=""){$i=$2}else{$i=0} }print}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv | datamash --headers -t, max 3-$( awk -F, '(NR==1){print NF}' VIR3_clean.gte9.netMHCpan.AGS.separate.pivot.freqs.csv ) | datamash transpose -t, | sed -e 's/max(//' -e 's/)//' > tile_max_HLA_freqs.csv
```


```
sed -i '1itile,freq' tile_sum_HLA_freqs.csv

head -1 /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/3plates/20250130-Multiplate_Peptide_Comparison-case-control-Prop_test_results-10.csv > tmp1.csv
tail -n +2 /francislab/data1/working/20250128-Illumina-PhIP/20250128c-PhIP/3plates/20250130-Multiplate_Peptide_Comparison-case-control-Prop_test_results-10.csv | sort -t, -k1,1 >> tmp1.csv

join --header -t, tile_sum_HLA_freqs.csv tmp1.csv > tmp2.csv


```





