#!/usr/bin/env bash



#	mkdir out.123456131415161718
#
#	merge_matrices.py --axis columns --de_nan --header_rows 3 --index_col id --index_col species --out ${PWD}/out.123456131415161718/Zscores.t.csv ${PWD}/out.plate*/Zscores.t.csv
#
#	merge_matrices.py --axis columns --de_nan --header_rows 3 --index_col id --index_col species --out ${PWD}/out.123456131415161718/Zscores.minimums.t.csv ${PWD}/out.plate*/Zscores.minimums.t.csv
#
#	cat out.123456131415161718/Zscores.minimums.t.csv | datamash transpose -t, > out.123456131415161718/tmp1.csv
#
#	head -2 out.123456131415161718/tmp1.csv > out.123456131415161718/tmp2.csv
#	awk -F, '($2 == "glioma serum")' out.123456131415161718/tmp1.csv >> out.123456131415161718/tmp2.csv
#
#	cat out.123456131415161718/tmp2.csv | datamash transpose -t, > out.123456131415161718/Zscores.minimums.t.glioma.csv




p=$1	# 3, 5, 10, 15, 20

z=$2	#	3.5 5 10 15 20 25 30 40 50

#	echo "Filter and Call"
#	
#	python3 - <<EOF
#	import pandas as pd
#	df = pd.read_csv('out.123456131415161718/Zscores.minimums.t.glioma.csv', header=[0,1,2], index_col=[0,1])
#	df=df[(df>=${z}).sum(axis='columns')>(len(df.columns)*float('${p}')/100)]
#	df=(df>=${z}).astype(int)
#	df.to_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv')
#	EOF
#	
#	
#	echo "Sort for joining"
#	
#	head -3 out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv > out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.to_join.csv
#	tail -n +4 out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv | sort -t, -k1,1 >> out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.to_join.csv
#	
#	
#	echo "Correlation"
#	
#	$PWD/correlation.py -i out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_edges.csv.gz
#	
#	
#	
#	#data = [ [member_id,comm_id]  for comm_id, members in enumerate(communities) for member_id in members ]
#	#pd.DataFrame(data,columns=['peptide_id','community_id']).drop(0).to_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.csv.gz',index=False)
#	
#	python3 - <<EOF
#	import pandas as pd
#	import igraph as ig
#	correlations_df = pd.read_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_edges.csv.gz')
#	g = ig.Graph.DataFrame(edges=correlations_df, directed=False, use_vids=False)
#	g.vs["name"] = [int(name) for name in g.vs["name"]]
#	communities = g.community_leiden(weights='weight', resolution=0.01)
#	memberships = communities.membership
#	all_names = g.vs["name"]
#	data = list(zip(all_names,memberships))
#	pd.DataFrame(data,columns=['peptide_id','community_id']).to_csv('out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.csv.gz',index=False)
#	EOF
#	
#	zcat out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.csv.gz | head -1 > out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.to_join.csv
#	zcat out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.csv.gz | tail -n +2 | sort -t, -k1,1 >> out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.to_join.csv
#	
#	
#	echo "Prepping communities per plate"
#	
#	for f in out.plate*/Zscores.t.csv ; do
#		echo $f
#		d=$( dirname ${f} )
#	
#		echo "Select just ${p}/${z} tiles"
#		head -3 ${f} > ${TMPDIR}/tmp0.csv
#		join -t, <( tail -n +4 out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.to_join.csv | cut -d, -f1 ) <( tail -n +4 ${f} ) >> ${TMPDIR}/tmp0.csv
#		ls -l ${TMPDIR}/tmp0.csv
#		wc -l ${TMPDIR}/tmp0.csv
#	
#		echo "Join to communities"
#		head -2 ${TMPDIR}/tmp0.csv > ${TMPDIR}/tmp1.csv
#		join --header -t, out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.to_join.csv <( tail -n +3 ${TMPDIR}/tmp0.csv ) >> ${TMPDIR}/tmp1.csv
#		ls -l ${TMPDIR}/tmp1.csv
#		wc -l ${TMPDIR}/tmp1.csv
#	
#		echo "Group by community"
#		sed -i '1,2s/^/z,/' ${TMPDIR}/tmp1.csv
#		group_by_community.py ${TMPDIR}/tmp1.csv | datamash transpose -t, > ${TMPDIR}/tmp2.csv
#		ls -l ${TMPDIR}/tmp2.csv
#		wc -l ${TMPDIR}/tmp2.csv
#	
#		echo "Prep output"
#		echo ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#		head -1 ${TMPDIR}/tmp2.csv > ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#		cat ${TMPDIR}/tmp2.csv >> ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#		sed -i '1s/^subject,type,sample,/y,x,id,/' ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#		sed -i '2s/^subject,type,sample,/subject,type,species,/' ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#	
#	done
#	
#	
#	echo "Running regressions"
#	
#	plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
#	
#	module load r
#	Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --study IPS --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv -o ${PWD}/out.123456 -p ${plates}
#	Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --study IPS --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv -o ${PWD}/out.123456 -p ${plates} --sex M
#	Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study AGS --study IPS --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv -o ${PWD}/out.123456 -p ${plates} --sex F
#	echo 
#	
#	plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )
#	
#	Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study PLCO --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv -o ${PWD}/out.15161718 -p ${plates}
#	Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study PLCO --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv -o ${PWD}/out.15161718 -p ${plates} --sex M
#	Multi_Plate_Case_Control_Community_Regression.R -z ${z} --study PLCO --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv -o ${PWD}/out.15161718 -p ${plates} --sex F
#	
#	
#	echo "Running BH tests on output"
#	
#	python3 - <<EOF
#	z="${z}"
#	p="${p}"
#	import pandas as pd
#	from statsmodels.stats.multitest import multipletests
#	
#	df = pd.read_csv(f'out.123456/Multiplate_Community_Comparison-Zscores.minimums.t.glioma.filtered-{p}%-{z}.threshold-{z}.correlation_communities-AGS-IPS-glioma_serum-case-control-Z-{z}-sex-.csv').dropna()
#	df['q']=multipletests(df['pval'], alpha=0.05, method='fdr_bh')[1]
#	print(df.head(), flush=True)
#	
#	df = pd.read_csv(f'out.15161718/Multiplate_Community_Comparison-Zscores.minimums.t.glioma.filtered-{p}%-{z}.threshold-{z}.correlation_communities-PLCO-glioma_serum-case-control-Z-{z}-sex-.csv').dropna()
#	df['q']=multipletests(df['pval'], alpha=0.05, method='fdr_bh')[1]
#	print(df.head(), flush=True)
#	EOF









######################################################################

echo "Prepping tile filters per plate"

for f in out.plate*/Zscores.t.csv ; do
	echo $f
	d=$( dirname ${f} )

	echo "Select just ${p}/${z} tiles"
	head -3 ${f} > ${TMPDIR}/tmp0.csv
	join -t, <( tail -n +4 out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.to_join.csv | cut -d, -f1 ) <( tail -n +4 ${f} ) >> ${TMPDIR}/tmp0.csv
	ls -l ${TMPDIR}/tmp0.csv
	wc -l ${TMPDIR}/tmp0.csv

	echo "Prep output"
	echo ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv
	cat ${TMPDIR}/tmp0.csv | datamash transpose -t, > ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv


#	echo "Join to communities"
#	head -2 ${TMPDIR}/tmp0.csv > ${TMPDIR}/tmp1.csv
#	join --header -t, out.123456131415161718/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation.communities.to_join.csv <( tail -n +3 ${TMPDIR}/tmp0.csv ) >> ${TMPDIR}/tmp1.csv
#	ls -l ${TMPDIR}/tmp1.csv
#	wc -l ${TMPDIR}/tmp1.csv
#
#	echo "Group by community"
#	sed -i '1,2s/^/z,/' ${TMPDIR}/tmp1.csv
#	group_by_community.py ${TMPDIR}/tmp1.csv | datamash transpose -t, > ${TMPDIR}/tmp2.csv
#	ls -l ${TMPDIR}/tmp2.csv
#	wc -l ${TMPDIR}/tmp2.csv
#
#	echo "Prep output"
#	echo ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#	head -1 ${TMPDIR}/tmp2.csv > ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#	cat ${TMPDIR}/tmp2.csv >> ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#	sed -i '1s/^subject,type,sample,/y,x,id,/' ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv
#	sed -i '2s/^subject,type,sample,/subject,type,species,/' ${d}/Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.correlation_communities.csv

done


echo "Running regressions"

plates=$( ls -d ${PWD}/out.plate{1,2,3,4,5,6} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

module load r
Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --study IPS --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o ${PWD}/out.123456 -p ${plates}
Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --study IPS --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o ${PWD}/out.123456 -p ${plates} --sex M
Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study AGS --study IPS --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o ${PWD}/out.123456 -p ${plates} --sex F
echo 

plates=$( ls -d ${PWD}/out.plate{15,16,17,18} 2>/dev/null | paste -sd, | sed 's/,/ -p /g' )

Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PLCO --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o ${PWD}/out.15161718 -p ${plates}
Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PLCO --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o ${PWD}/out.15161718 -p ${plates} --sex M
Multi_Plate_Case_Control_Peptide_Regression.R -z ${z} --study PLCO --type "glioma serum" -a case -b control --zfile_basename Zscores.minimums.t.glioma.filtered-${p}%-${z}.threshold-${z}.csv -o ${PWD}/out.15161718 -p ${plates} --sex F


echo "Running BH tests on output"

python3 - <<EOF
z="${z}"
p="${p}"
import pandas as pd
from statsmodels.stats.multitest import multipletests

df = pd.read_csv(f'out.123456/Multiplate_Peptide_Comparison-Zscores.minimums.t.glioma.filtered-{p}%-{z}.threshold-{z}-AGS-IPS-glioma_serum-case-control-Z-{z}-sex-.csv').dropna()
df['q']=multipletests(df['pval'], alpha=0.05, method='fdr_bh')[1]
print(df.head(), flush=True)

df = pd.read_csv(f'out.15161718/Multiplate_Peptide_Comparison-Zscores.minimums.t.glioma.filtered-{p}%-{z}.threshold-{z}-PLCO-glioma_serum-case-control-Z-{z}-sex-.csv').dropna()
df['q']=multipletests(df['pval'], alpha=0.05, method='fdr_bh')[1]
print(df.head(), flush=True)
EOF





