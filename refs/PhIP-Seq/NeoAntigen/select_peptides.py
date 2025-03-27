#!/usr/bin/env python3

import sys

#$ ls | ./filein.py          # Prints a directory listing to stdout.
#$ ./filein.py /etc/passwd   # Reads /etc/passwd to stdout.
#$ ./filein.py < /etc/passwd # Reads /etc/passwd to stdout.

peptides=[]

import fileinput
with fileinput.input() as f_input:

	for line in f_input:
		print(line, end='')
		line = line.strip()

		if line in peptides:
			print(line,"is in peptides. Skipping.")

		else:
			if len(peptides) == 0:
				print("Adding starter",line)
				peptides.append(line)

			else:
				found=False
				to_remove=[]
				for existing in peptides:
					if len(existing) >= len(line):
						print("Checking if",line,"is in",existing)
						if line in existing:
							print(line,"is in",existing)
							found=True
							break
						else:
							print("Nope")
					else:
						print("Checking if",existing,"is in",line)
						if existing in line:
							print(existing,"is in",line,". Swapping.")
							to_remove.append(existing)  
						else:
							print("Nope")

				if not found:
					peptides.append(line)

				for peptide in to_remove:
					peptides.remove(peptide)
					
with open("selected_peptides_full.txt", "w") as file:
    for peptide in sorted(peptides):
        file.write(str(peptide) + "\n")

