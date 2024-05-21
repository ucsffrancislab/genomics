#!/usr/bin/env python3



import os    
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

parser.add_argument('-n', '--normal', nargs=1, type=str, required=True, help='normal matrix  filename to %(prog)s (default: %(default)s)')
parser.add_argument('-t', '--tumor',  nargs=1, type=str, required=True, help='tumor matrix  filename to %(prog)s (default: %(default)s)')
parser.add_argument('-s', '--select', nargs=1, type=str, required=True, help='[GENE,Symbol,RE] select list  filename to %(prog)s (default: %(default)s)')
parser.add_argument('-o', '--output', nargs=1, type=str, default=['output.tsv'], help='output tsv filename to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()

#normal=args.normal[0]
print( "Using normal name: ", args.normal[0] )
#tumor=args.tumor[0]
print( "Using tumor name: ", args.tumor[0] )
#select=args.select[0]
print( "Using select name: ", args.select[0] )

#output=args.output[0]
print( "Using output name: ", args.output[0] )


#quit()


print("Reading Tumor "+ args.tumor[0])
#TCGA=pd.read_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv',sep='\t',index_col=0)
tumor=pd.read_csv(args.tumor[0] ,sep='\t',index_col=0)
#'/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.tsv'



print("Reading Normal "+ args.normal[0])
normal=pd.read_csv(args.normal[0] ,sep='\t',index_col=0)
#GTEx=pd.read_csv('/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.Cerebellum.correlation.tsv',sep='\t',index_col=0)

#GTEx.shape
#(55670, 4788)
#TCGA.shape
#(55662, 6515)

normal.shape
#(47024, 3583)
tumor.shape
#(52441, 4634)

diff=tumor-normal

#d.to_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv',sep='\t')







#TCGA=pd.read_csv('/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20240424-REdiscoverTE/GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.tsv',sep='\t',index_col=0)
#GTEx=pd.read_csv('/francislab/data1/working/20201006-GTEx/20240424-REdiscoverTE/Cerebellum_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.Cerebellum.correlation.tsv',sep='\t',index_col=0)
#diff=pd.read_csv("GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.TCGA-GTEx.tsv", sep="\t",index_col=0)

print("Reading Select "+ args.select[0])
z=pd.read_csv(args.select[0],sep="\t",header=None,names=['GENE','Symbol','RE','p-value'])
#"cocor.repFamily.both.1e-7.symbol.tsv"

def get_diff_value(row):
	return diff.loc[row['GENE'],row['RE']]

z['diff'] = z.apply(get_diff_value, axis=1)

def get_tumor_value(row):
	return tumor.loc[row['GENE'],row['RE']]

z['tumor'] = z.apply(get_tumor_value, axis=1)

def get_normal_value(row):
	return normal.loc[row['GENE'],row['RE']]

z['normal'] = z.apply(get_normal_value, axis=1)


#z.to_csv("GBMWTFirstTumors_REdiscoverTE_rollup_noquestion/GENE_x_RE_all_repFamily.GBMWTFirstTumors.correlation.TCGA-GTEx.cocor.repFamily.both.1e-7.tsv",sep="\t",index=False)
z.to_csv(args.output[0],sep="\t",index=False)





