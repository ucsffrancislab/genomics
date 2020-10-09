#!/usr/bin/env python

import pandas as pd
import sys











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

input_filename = sys.argv[1]
base_filename = input_filename.rstrip('.txt.gz')

df = pd.read_csv( input_filename,
	sep=" ",
	header=None,
	names=["mer","count"],
	dtype={"count": int},
	index_col=["mer"] )
#	usecols=[0,1],

for i in range(4**2):
	prefix=num2dna(fromb10tob4("%02d" % i))
	outfile=base_filename+"-"+prefix+".txt.gz"
	print("Creating "+outfile)
	df[df.index.str.startswith(prefix)].to_csv(filename,header=False,sep=" ")

