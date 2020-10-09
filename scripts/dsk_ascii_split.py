#!/usr/bin/env python

import os    
import sys
import pandas as pd

# include standard modules
import argparse

# initiate the parser
parser = argparse.ArgumentParser(prog=os.path.basename(__file__))

parser.add_argument('files', nargs='*', help='files help')
parser.add_argument('-V','--version', action='version', version='%(prog)s 1.1')
parser.add_argument('-l', '--prefix_length', nargs=1, type=int, default=2,
	help='prefix length when grouping mers to %(prog)s (default: %(default)s)')

#parser.add_argument('-o', '--output', nargs=1, type=str, default='merged.csv.gz',
#	help='output csv filename to %(prog)s (default: %(default)s)')
#parser.add_argument('-s', '--sep', nargs=1, type=str, default='\t',
#	help='the separator to %(prog)s (default: %(default)s)')

#	store_true means "int=False unless --int passed, then int=True" (store_false is the inverse)
#parser.add_argument('--int', action='store_true',
#	help='convert values to ints to %(prog)s (default: %(default)s)')

# read arguments from the command line
args = parser.parse_args()


#	Note that nargs=1 produces a list of one item. This is different from the default, in which the item is produced by itself.
#	THAT IS JUST STUPID! And now I have to check it manually. Am I the only one?


#if isinstance(args.output,list):
#	output=args.output[0]
#else:
#	output=args.output
#print( "Using output name: ", output )

if isinstance(args.prefix_length,list):
	prefix_length=args.prefix_length[0]
else:
	prefix_length=args.prefix_length
print( "Using prefix_length :", prefix_length, ":" )





#		http://www.enoriver.net/python/2009/08/13/genetics-with-python/

def fromb4tob10(numstr): # convert padded base-4 to padded base-10 string
   j=0
   for i in range(len(numstr)):
      j=j+int(numstr[i])*4**(len(numstr)-i-1)
   return "%0*d" % (len(numstr),j)

def fromb10tob4(numstr): # convert padded base-10 to base-4 string
   mystr=''
   myint=int(numstr)
   while (myint-myint%4)>0:
      mystr=str(myint%4)+mystr
      myint=(myint-myint%4)/4
   mystr=str(myint%4)+mystr
   return "%0*d" % (len(numstr),int(mystr))

def checkb4(dnanumstr): # if input string is base-10, convert to base-4
   for i in range(len(dnanumstr)):
      if int(dnanumstr[i])>=4:
         #print( "input string is base 10, will change to base 4" )
         return fromb10tob4(dnanumstr)
   return dnanumstr

def dna2num(str):
   num=0
   add=0
   check=0
   bases=['A','C','G','T']
   for i in range(len(str)):
      for base in bases:
         if str[i]==base:
            check=1
      if check==0: # if this letter is not A,C,G, or T, then exit.
         #print( "this is not a valid dna sequence" )
         return 0
      else:
         for base in bases:
            if str[i]==base:
               add=(bases.index(base))*(10**(len(str)-i-1))
               num=num+add
   return fromb4tob10("%0*d" % (len(str),num))

def num2dna(dnanumstr):
   num=0
   dnastring=''
   dnastart=''
   dnanumstr=checkb4(dnanumstr)
   n=int(dnanumstr)
   print( "input string translates to (padded) base-4 integer: ", "%0*d" % (len(dnanumstr),n) )
   s=str(n) # will need this to check if input string is padded with zeroes
   if len(s)!=len(dnanumstr):              # in that case, we should
      dnastart='A'*(len(dnanumstr)-len(s)) # intialize dnastring with
   bases=['A','C','G','T']                 # the same number of A's
   digits=[0,1,2,3]
   while (n-n%10)>=0:
      num=n%10
      for i in range(len(digits)):
         if num==digits[i]:
            dnastring=bases[i]+dnastring
      n=(n-num)/10
      if n==0:
         return dnastart+dnastring


for filename in args.files:  
	print(filename)
	if os.path.isfile(filename) and os.path.getsize(filename) > 0:
		#basename=os.path.basename(filename)
		#sample=basename.split(".")[0]	#	everything before the first "."
		#print("Reading "+filename+": Sample "+sample)
		print("Reading "+filename)

		basedir = filename.rstrip('.txt.gz')
		if not os.path.exists(basedir):
			os.mkdir(basedir)
		basefile=os.path.basename(basedir)

		df = pd.read_csv( filename,
			sep=" ",
			header=None,
			names=["mer","count"],
			dtype={"count": int},
			index_col=["mer"] )
		#	usecols=[0,1],
		
		for i in range(4**prefix_length):
			prefix=num2dna(fromb10tob4(("%0"+str(prefix_length)+"d") % i))
			outfile=basedir+"/"+basefile+"-"+prefix+".txt.gz"
			print("Creating "+outfile)
			df[df.index.str.startswith(prefix)].to_csv(outfile,header=False,sep=" ")
	else:
		print(filename+" not found or of 0 size")

