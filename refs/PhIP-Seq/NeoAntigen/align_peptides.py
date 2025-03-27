#!/usr/bin/env python3

import os
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))
#parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.0')

parser.add_argument('-s', '--sequences_filename', type=str, required=True,
	help='Filename containing sequences to align : (default: %(default)s)')
parser.add_argument('-r', '--references_filename', type=str, required=True,
	help='Filename containing reference sequences to align to : (default: %(default)s)')

# parser.add_argument('--proteins', type=str, action='append', default=[],
#   help='Limit proteins to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()


file=open(args.references_filename, 'r') 
references = [line.strip() for line in file]

print("@HD\tVN:1.0\tSO:unsorted")
#	@HD	VN:1.0	SO:unsorted
r=0
for ref in references:
	r+=1
	print("@SQ\tSN:",r,"\tLN:",len(ref),sep="")
#	@SQ	SN:chr1	LN:248956422

q=0
with open(args.sequences_filename, 'r') as file:
	for line in file:
		q+=1
		line=line.strip()
		found=False
		r=0
		for ref in references:
			r+=1
			if line in ref:
				#print(line,"in",ref)
				found=True
				break
		if found:
			print(q,64,r,ref.index(line)+1,99,str(len(line))+'M','*',0,0,line,'*',sep="\t")

#	write a sam file so can view in IGV
#	@HD	VN:1.0	SO:unsorted
#	@SQ	SN:chr1	LN:248956422
#	@SQ	SN:chr2	LN:242193529
#	@SQ	SN:chr3	LN:198295559
#	@SQ	SN:chr4	LN:190214555
#	@SQ	SN:chr5	LN:181538259
#
#	Col	Field	Type	Brief description
#	1	QNAME	String	Query template NAME
#	2	FLAG	Int	bitwise FLAG
#	3	RNAME	String	References sequence NAME
#	4	POS	Int	1- based leftmost mapping POSition
#	5	MAPQ	Int	MAPping Quality
#	6	CIGAR	String	CIGAR string
#	7	RNEXT	String	Ref. name of the mate/next read
#	8	PNEXT	Int	Position of the mate/next read
#	9	TLEN	Int	observed Template LENgth
#	10	SEQ	String	segment SEQuence
#	11	QUAL	String	ASCII of Phred-scaled base QUALity+33

#	T7-Pep2_PCR2_F_P5	0	T7Select_10-3b_Vector_Sequence	20374	255	20=	*	0	0	GGAGCTGTCGTATTCCAGTC	IIIIIIIIIIIIIIIIIIII	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:20	YT:Z:UU
#	4	0	XP_030868015.1	657	255	43M	*	0	0	CTQQLRRDSDHRERAMMTMAVLSKRKGGNVGKSKRDQIVTVSV	*	AS:i:82	NM:i:1	ZL:i:699	ZR:i:201	ZE:f:7.9e-17	ZI:i:97	ZF:i:1	ZS:i:1	MD:Z:39A3
#	4	0	XP_030871595.1	657	255	43M	*	0	0	CTQQLRRDSDHRERAMMTMAVLSKRKGGNVGKSKRDQIVTVSV	*	AS:i:82	NM:i:1	ZL:i:699	ZR:i:201	ZE:f:7.9e-17	ZI:i:97	ZF:i:1	ZS:i:1	MD:Z:39A3

