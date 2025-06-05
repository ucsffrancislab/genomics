#!/usr/bin/env python3

import sys

peptides=[]

def assemble(s1, s2,min_overlap=2):
	for i in range(min(len(s1), len(s2)), min_overlap, -1):
		if s1[-i:] == s2[:i]:
			return s1[:(len(s1)-i)] + s2
	return ''


import fileinput
with fileinput.input() as f_input:

	for line in f_input:
		#print(line, end='')
		line = line.strip()

		if line in peptides:
			print(line,"is in peptides. Skipping.",file=sys.stderr)

		else:
			if len(peptides) == 0:
				print("Adding starter",line,file=sys.stderr)
				peptides.append(line)

			else:
				to_remove=[]
				to_append=[]

				print("line:",line,file=sys.stderr)


#				#	this is all a bit problematic
#
#
				found=False
				for existing in peptides:
					print("existing:",existing,file=sys.stderr)


					if ( line in existing ):
						found=True
						break
					elif ( existing in line ):
						print("marking",existing,"for removal",file=sys.stderr)
						to_remove.append(existing)
						break

					ab=assemble(line,existing,30)
					print("ab",ab,len(ab),file=sys.stderr)
					ba=assemble(existing,line,30)
					print("ba",ba,len(ba),file=sys.stderr)

					if (len(ab) >= len(ba) and len(ab) > 30 ):
						print("ab is longer",file=sys.stderr)
						print("marking",existing,"for removal",file=sys.stderr)
						to_remove.append(existing)
						print("marking",ab,"for appending",file=sys.stderr)
						to_append.append(ab)
						found=True
						break

					elif (len(ba) >= len(ab) and len(ba) > 30):
						print("ba is longer",file=sys.stderr)
						print("marking",existing,"for removal",file=sys.stderr)
						to_remove.append(existing)
						print("marking",ba,"for appending",file=sys.stderr)
						to_append.append(ba)
						found=True
						break

					else:
						print("no good overlap",file=sys.stderr)

				if not found:
					print("marking",line,"for appending",file=sys.stderr)
					to_append.append(line)

				for peptide in to_append:
					print("appending",peptide,file=sys.stderr)
					peptides.append(peptide)
				to_append=[]

				for peptide in to_remove:
					print("removing",peptide,file=sys.stderr)
					peptides.remove(peptide)
				to_remove=[]

#				for existing in peptides:
#					print("existing:",existing)
#
#					ab=assemble(line,existing,30)
#					print("ab",ab,len(ab))
#					ba=assemble(existing,line,30)
#					print("ba",ba,len(ba))
#
#					if (len(ab) >= len(ba) and len(ab) > 30 ):
#						print("ab is longer")
#						peptides[peptides.index(existing)] = ab
#						print(peptides)
#
#					elif (len(ba) >= len(ab) and len(ba) > 30):
#						print("ba is longer")
#						peptides[peptides.index(existing)] = ba
#						print(peptides)
#
#					else:
#						print("no good overlap")
#						peptides.append(line)
#						print(peptides)


print('---',file=sys.stderr)

#with open("assembled_peptides.txt", "w") as file:
#    for peptide in sorted(peptides):
#        file.write(str(peptide) + "\n")
for peptide in sorted(peptides):
	print(peptide)

