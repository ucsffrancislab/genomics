#!/usr/bin/env python3


#def find_overlap(s1, s2):
#	for i in range(min(len(s1), len(s2)), 0, -1):
#		if s1[-i:] == s2[:i]:
#			return s1[-i:]
#	return ""
#
#string1 = "abcdefg"
#string2 = "cdefgh"
#print(find_overlap(string1, string2)) # Returns "cdefg"

def assemble(s1, s2,min_overlap=2):
	for i in range(min(len(s1), len(s2)), min_overlap, -1):
		if s1[-i:] == s2[:i]:
			return s1[:(len(s1)-i)] + s2
	return None

print(assemble('abcdefg', 'cdefghi')) # Returns "abcdefghi"

#	This is asymetrical so need to try both ways
print(assemble( 'cdefghi', 'abcdefg')) # Returns None

#	Need to add a minimum overlap requirement as this will ...
print(assemble('abcdefg', 'gcdefghi',0)) # Returns "abcdefgcdefghi"

print(assemble('abcdefg', 'gcdefghi',1)) # Returns None

print(assemble('abcdefg', 'gcdefghi')) # Returns None

print(assemble('appleappleapple', 'appleapple'))	#	returns appleappleapple
print(assemble('appleapple', 'appleappleapple'))	#	also returns appleappleapple





#	Starts at the beginning so should get the longest match	
print(assemble('abcdede', 'dedefghi')) # Returns "abcdedefghi"

#	range(start, stop, step)	#	apparently stop is exclusive
#
#s1='abcdefg'
#s2='efgh'
#for i in range(min(len(s1), len(s2)), 0, -1):
#	print(i)
#	print(s1[-i:])
#	print(s2[:i])
#
#4
#defg
#efgh
#3
#efg
#efg	#	would return here
#2
#fg
#ef
#1
#g
#e




