#!/usr/bin/python

# change path to the python folder I can access
#export PATH="/home/xzyao/.local/bin:$PATH"

if __name__ == '__main__':

	# import libraries
	try: import sys
	except: sys.exit("Could not import module 'sys'")

	try: import os
	except: sys.exit("Could not import module 'os'")

	# parse arguments
	try: import argparse
	except: sys.exit("Could not import module 'argparse'")
	parser = argparse.ArgumentParser(description='Transcribe and translate DNA sequences to amino acid sequences.')
	parser.add_argument('in_dna', type=str)
	parser.add_argument('out_aa', type=str)
	args = vars(parser.parse_args())
	args['in_dna'] = args['in_dna'].split(',')


	try: from Bio.Seq import Seq
	except: sys.exit("Could not import module 'Bio.Seq'")

	try:from Bio.Alphabet import IUPAC
	except:	sys.exit("Could not import module 'Bio.Alphabet'")



for infile in args['in_dna']:
	if not os.path.isfile(infile):
		sys.exit("Input file %s not found" % infile)

	# create a list with all the lines in the input file
	with open(infile) as f:
		template_dna = f.readlines() 
		# remove whitespace characters like `\n` at the end of each line
		template_dna = [x.strip() for x in template_dna] 
	# creast empty string variable for taking DNA and aa sequences 
	dna_seq=""
	ind=-1

	# write to output file 
	with open(args['out_aa'], 'w') as outfile:
		# loop through the entire list
		for line in template_dna:
			ind=ind+1

			# starts with ">", indicate the sequence header 
			if line.startswith(">") and ind==0:
				# directly write name to output file
				outfile.write(line+'\n')
			elif line.startswith(">"):
				# dna sequences with the previous header
				dna_seq=Seq(dna_seq, IUPAC.ambiguous_dna)
				aa=dna_seq.translate(table=11, to_stop=True)
				outfile.write(str(aa)+'\n')
				# clear contents of the dna_seq
				dna_seq=str("")

				# write the current header
				outfile.write(line+'\n')
			else:
				dna_seq=dna_seq+line
		# the last loop 
		dna_seq=Seq(dna_seq, IUPAC.ambiguous_dna)
		aa=dna_seq.translate(table=11, to_stop=True)
		outfile.write(str(aa)+'\n')	


				#### another method I tried with list.....
				#dna.append(Seq(line, IUPAC.ambiguous_dna))
				#ind=ind+1

				# NCBI genetic code table 11 for bacterial DNA: https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi
				# Becasue we start with full length database sequence files, each sequence should be a complete coding sequence
				#aa.append(dna[ind].translate(table=11, to_stop=True))

				# write the aa sequence to file 
				#outfile.write(str(aa[ind])+'\n')







