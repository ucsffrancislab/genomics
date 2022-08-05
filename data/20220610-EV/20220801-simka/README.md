



for s in SFHH011AC SFHH011BB SFHH011BZ SFHH011CH SFHH011I SFHH011S SFHH011Z SFHH011BO ; do
echo ${s}: /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/${s}.quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz
done


tail -n +2 ../20220707-REdiscoverTE/metadata.test.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz"}' > datasets3

tail -n +2 ../20220707-REdiscoverTE/metadata.test.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz"}' > datasets4



tail -n +2 ../20220707-REdiscoverTE/metadata.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz"}' > datasets5

tail -n +2 ../20220707-REdiscoverTE/metadata.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz"}' > datasets6




grep GBM,Primary,BTC,M ../20220707-REdiscoverTE/metadata.csv | head -6 | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz"}' > datasets7
grep GBM,Recurrent,BTC,M ../20220707-REdiscoverTE/metadata.csv | head -6 | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz"}' >> datasets7
grep control,control,AGS,M ../20220707-REdiscoverTE/metadata.csv | head -6 | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz"}' >> datasets7
grep Test ../20220707-REdiscoverTE/metadata.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz"}' >> datasets7

grep GBM,Primary,BTC,M ../20220707-REdiscoverTE/metadata.csv | head -6 | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz"}' > datasets8
grep GBM,Recurrent,BTC,M ../20220707-REdiscoverTE/metadata.csv | head -6 | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz"}' >> datasets8
grep control,control,AGS,M ../20220707-REdiscoverTE/metadata.csv | head -6 | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz"}' >> datasets8
grep Test ../20220707-REdiscoverTE/metadata.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.un.fagz"}' >> datasets8







python3 ~/github/GATB/simka/scripts/visualization/run-visualization.py -in out-datasets5-kmer-size_15_-abundance-min_2_-simple-dist_-complex-dist -out out-datasets5-kmer-size_15_-abundance-min_2_-simple-dist_-complex-dist-figures -pca -heatmap -tree

python3 ~/github/GATB/simka/scripts/visualization/run-visualization.py -in out-datasets5-kmer-size_31_-abundance-min_2_-simple-dist_-complex-dist -out out-datasets5-kmer-size_31_-abundance-min_2_-simple-dist_-complex-dist-figures -pca -heatmap -tree



tail -n +2 ../20220707-REdiscoverTE/metadata.csv | awk -F, '{print $1": /francislab/data1/working/20220610-EV/20220624-preprocessing_with_custom_umi_sequence_extraction/out/"$1".quality.umi.t1.t3.hg38.rx.marked.reference.rmsk.fagz"}' > datasets-rmskonly

python3 ~/github/GATB/simka/scripts/visualization/run-visualization.py -in out-datasets-rmskonly-kmer-size_15_-abundance-min_2_-simple-dist_-complex-dist -out out-datasets-rmskonly-kmer-size_15_-abundance-min_2_-simple-dist_-complex-dist-figures -pca -heatmap -tree

python3 ~/github/GATB/simka/scripts/visualization/run-visualization.py -in out-datasets-rmskonly-kmer-size_31_-abundance-min_2_-simple-dist_-complex-dist -out out-datasets-rmskonly-kmer-size_31_-abundance-min_2_-simple-dist_-complex-dist-figures -pca -heatmap -tree

