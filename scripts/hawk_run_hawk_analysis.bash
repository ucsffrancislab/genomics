#!/usr/bin/env bash


set -x


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


isDiploid=1
kmersize=13

while [ $# -gt 0 ] ; do
	case $1 in
#		-t|--t*)
#			shift; threads=$1; shift ;;
		-k|--k*|-m|--m*)
			shift; kmersize=$1; shift ;;
		-g|--g*)
			shift; gwas_file=$1; shift ;;
		*)
			shift;;
	esac
done




#	These have fixed names so put everything in named directory
BASE="hawk_${kmersize}mers"
mkdir -p ${BASE}
cd ${BASE}





#	my mods moved from countKmers script
f=total_kmer_counts.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#cat *_total_kmer_counts.txt > ${f}
	cat ../*.${kmersize}mers.total_counts.txt > ${f}
	chmod a-w $f
fi

f=sorted_files.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	ls -1 ../*.${kmersize}mers.sorted.txt.gz > ${f}
	chmod a-w $f
fi


noInd=$(cat sorted_files.txt | wc -l)



#Next step requires a gwas_info.txt in the format of ...
#'gwas_info.txt' containing three columns separated by tabs giving a 
#	sample ID, male/female/unknown denoted by M/F/U and Case/Control status of the sample for each sample.
#
#SAMPLE1	M	Case
#SAMPLE2	F	Case
#SAMPLE3	M	Control
#SAMPLE4	F	Control
#
#	gwas_info.txt MUST be TAB separated

#cp ../gwas_info.txt ./
cp ${gwas_file} ./gwas_info.txt





f="case.ind"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	split gwas_info / total_kmer_counts.txt / sorted_files.txt into case/control files
	hawk_preProcess
	chmod a-w $f

	#-rw-rw-r-- 1 jake            0 Jun 21 07:38 control_total_kmers.txt
	#-rw-rw-r-- 1 jake            0 Jun 21 07:38 control_sorted_files.txt
	#-rw-rw-r-- 1 jake            0 Jun 21 07:38 control.ind
	#-rw-rw-r-- 1 jake           39 Jun 21 07:38 case_total_kmers.txt
	#-rw-rw-r-- 1 jake           71 Jun 21 07:38 case_sorted_files.txt
	#-rw-rw-r-- 1 jake           41 Jun 21 07:38 case.ind

	chmod a-w control_total_kmers.txt control_sorted_files.txt control.ind
	chmod a-w case_total_kmers.txt case_sorted_files.txt "case.ind"

fi


f=gwas_eigenstratX.total
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	cat case_total_kmers.txt control_total_kmers.txt > ${f}
	chmod a-w $f
fi

f=gwas_eigenstratX.ind
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	cat 'case.ind' control.ind > ${f}
	chmod a-w $f
fi


caseCount=$(cat case_sorted_files.txt | wc -l)
controlCount=$(cat control_sorted_files.txt | wc -l)

date
f=gwas_eigenstratX.snp
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	This can take about a day
	#	It produces 7 files
	hawkgz $caseCount $controlCount
	chmod a-w $f

	#-rw-rw-r-- 1 jake            0 Jun 21 07:39 control_out_wo_bonf.kmerDiff
	#-rw-rw-r-- 1 jake            0 Jun 21 07:39 case_out_wo_bonf.kmerDiff
	#-rw-rw-r-- 1 jake   1015772985 Jun 22 00:47 gwas_eigenstratX.snp
	#-rw-rw-r-- 1 jake    158009131 Jun 22 00:47 gwas_eigenstratX.geno
	#-rw-rw-r-- 1 jake            0 Jun 22 00:47 control_out_w_bonf.kmerDiff
	#-rw-rw-r-- 1 jake            0 Jun 22 00:47 case_out_w_bonf.kmerDiff
	#-rw-rw-r-- 1 jake           11 Jun 22 00:47 total_kmers.txt

	chmod a-w gwas_eigenstratX.snp gwas_eigenstratX.geno
	chmod a-w case_out_w_bonf.kmerDiff case_out_wo_bonf.kmerDiff
	chmod a-w control_out_w_bonf.kmerDiff control_out_wo_bonf.kmerDiff total_kmers.txt

fi
date


#	Using /usr/bin/smartpca, this "abort". Not clear why.

#	Using the included ~/HAWK-0.9.8-beta/supplements/EIG6.0.1-Hawk/bin/smartpca
#		initially ...
#	/home/jake/HAWK-0.9.8-beta/supplements/EIG6.0.1-Hawk/bin/smartpca: error while loading shared libraries: libgsl.so.0: cannot open shared object file: No such file or directory
#		so ...
#[jake@system76-server /raid/data/working/CCLS/20190617-HAWK]$ cd /usr/lib/x86_64-linux-gnu/
#[jake@system76-server /usr/lib/x86_64-linux-gnu]$ ll libgsl*
#-rw-r--r-- 1 root 4635026 Dec  7  2015 libgsl.a
#-rw-r--r-- 1 root  471562 Dec  7  2015 libgslcblas.a
#lrwxrwxrwx 1 root      20 Dec  7  2015 libgslcblas.so -> libgslcblas.so.0.0.0
#lrwxrwxrwx 1 root      20 Dec  7  2015 libgslcblas.so.0 -> libgslcblas.so.0.0.0
#-rw-r--r-- 1 root  251936 Dec  7  2015 libgslcblas.so.0.0.0
#lrwxrwxrwx 1 root      16 Dec  7  2015 libgsl.so -> libgsl.so.19.0.0
#lrwxrwxrwx 1 root      16 Dec  7  2015 libgsl.so.19 -> libgsl.so.19.0.0
#-rw-r--r-- 1 root 2352808 Dec  7  2015 libgsl.so.19.0.0
#[jake@system76-server /usr/lib/x86_64-linux-gnu]$ sudo ln -s libgsl.so.19.0.0 libgsl.so.0

cat > parfile.txt << EOF
genotypename: gwas_eigenstratX.geno
snpname:      gwas_eigenstratX.snp
indivname:    gwas_eigenstratX.ind
evecoutname:  gwas_eigenstrat.evec
evaloutname:  gwas_eigenstrat.eval
usenorm:        YES
numoutlieriter: 0
numoutevec:     10
EOF


f=log_eigen.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	if [ "$isDiploid" == "0" ]; then
		hawk_smartpca -V -p parfile.txt > ${f}
	else
		hawk_smartpca -p parfile.txt > ${f}
	fi
	chmod a-w $f
	chmod a-w gwas_eigenstrat.evec "gwas_eigenstrat.eval"
fi
date





#	guessing that this produces gwas_eigenstrat.pca

f=gwas_eigenstrat.pca
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	hawk_evec2pca.perl 10 gwas_eigenstrat.evec gwas_eigenstratX.ind gwas_eigenstrat.pca
	chmod a-w $f
fi
date






f=pcs.evec
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	tail -${noInd} gwas_eigenstrat.pca > ${f}
	chmod a-w $f
fi

date

f=case_out_w_bonf_sorted.kmerDiff
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	sort -g  -k 4 -t $'\t' case_out_w_bonf.kmerDiff > ${f}
	chmod a-w $f
fi
date

f=case_out_w_bonf_top.kmerDiff
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	head -200000 case_out_w_bonf_sorted.kmerDiff > ${f}
	chmod a-w $f
fi
date

f=control_out_w_bonf_sorted.kmerDiff
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	sort -g  -k 4 -t $'\t' control_out_w_bonf.kmerDiff > ${f}
	chmod a-w $f
fi
date

f=control_out_w_bonf_top.kmerDiff
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	head -200000 control_out_w_bonf_sorted.kmerDiff > ${f}
	chmod a-w $f
fi
date




f=pvals_case_top.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	hawk_log_reg.R -c 'case'
	chmod a-w $f
fi
date

f=pvals_control_top.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	hawk_log_reg.R -c 'control'
	chmod a-w $f
fi
date


f=pvals_case_top_merged.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	paste pvals_case_top.txt case_out_w_bonf_top.kmerDiff  > ${f}
	chmod a-w $f
fi
date

f=pvals_case_top_merged_sorted.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	sort -g -k 1 -t $'\t' pvals_case_top_merged.txt > ${f}
	chmod a-w $f
fi
date

f=pvals_control_top_merged.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	paste pvals_control_top.txt control_out_w_bonf_top.kmerDiff  > ${f}
	chmod a-w $f
fi
date

f=pvals_control_top_merged_sorted.txt
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	sort -g -k 1 -t $'\t' pvals_control_top_merged.txt > ${f}
	chmod a-w $f
fi
date

f=control_kmers.fasta
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	hawk_convertToFasta
	chmod a-w case_kmers.fasta control_kmers.fasta
fi
date


#rm case_out_w_bonf.kmerDiff
#rm case_out_wo_bonf.kmerDiff
#rm control_out_w_bonf.kmerDiff
#rm control_out_wo_bonf.kmerDiff

