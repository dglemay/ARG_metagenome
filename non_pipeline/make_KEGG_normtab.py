#!/usr/bin/env python

'''This script requies 4 input files 2 and output file paths:
	Input:
	(1) (Optional) MicrobeCensus output txt file. 
	(2) (Optional) Organized table of KEGG database amino acid sequence length. (3*aa+3)
	(3) (Optional) Orgnized KEGG count table per sample with one column in gene names and the other in counts.
	(4) (Optional) A wildcard input indicating normalized tables to be merged. 
	Output:
	(1) (Required for python 2.x) Individual normalized table.
	(2) (Optional) Merged normalized table containg multiple samples from Input(4). Can be omitted to not have a merged table.
	'''

import pandas as pd
import csv
import numpy
import os
import re


# parse input argument 
import argparse
parser = argparse.ArgumentParser(description='Normalize KEGG count tables with AMR gene length and sample genome equivalents estimated by MicrobeCensus.')
parser.add_argument('--mc', type=str, help='File path to MicrobeCensus output txt file.', required=False)
parser.add_argument('--genelen', type=str, help='File path to organized gene length table.', required=False)
parser.add_argument('--count', type=str, help='File path to count table.', required=False)
parser.add_argument('--out', type=str, help='File path to write the normalized count table.', required=False)
# althoug not required for argparse, the wildcard input is required by the merge_normtab() function
parser.add_argument('--mergein', type=str, help='File path to a number of normalized count tables per sample.', nargs='+', required=False) 
parser.add_argument('--mergeout', type=str, help='File path to write the normalized count table.', required=False)
args = vars(parser.parse_args())


# Define function to calculate normalized table
def make_RPKG_normtab(mcfp=None, lenfp=None, countfp=None, outfp=None):
	# 1 # read in MicrobeCensus genome equivalents output
	try:
		mctab = pd.read_csv(mcfp, sep="\t") # read in file
		ge = float(mctab.at['genome_equivalents:', 'Parameters']) # get the value for genome equivalents
	except: 
		print('did not read in MicrobeCensus output')
		pass

	# 2 # read in organized gene length table 
	try: 
		lentab = pd.read_csv(lenfp, sep='\t', index_col=0, names=["Len"])
		lentab.astype({'Len': 'float'})
	except:
		print('did not read in length table')
		pass

	# 3 # read in count table 
	try:
		# assumes sample name is the character string after the last / and before .csv
		# The sample name is 5007 from the path /file/to/your/path/5007.csv
		fn = os.path.basename(countfp) # get the xx.csv file name
		samid = re.search('(.+?).csv', fn).group(1)

		countab_fin = pd.read_csv(countfp, sep=',', index_col=0, header=0)
	except:
		print('did not read in count table')
		pass	

	# 4 # Calculate to get the final normalized table 
	try:
		RPKG = [] # initialize with an empty 
		normtab = countab_fin.copy()

		for i in normtab.index:
			# equation: Hits/((len in kb)*GE)
			len = (3+3*float(lentab.at[i,'Len']))/1000 #3*aa+3 for dna length from aa length
			norm_val = float(normtab.at[i,'Counts'])/(len*ge)
			RPKG.append(norm_val)
		normtab.insert(1, 'RPKG', RPKG, True) # add a new column with RPKG
	
		# remove sample column and replace the RPKG column header with sample name
		# remove Sample, Hits and GeneFrac column
		normtab_fin = normtab.rename(columns={'RPKG':samid}).drop(columns=['Counts'])
	except:
		print('did not normalize cout table')
		pass

	# 5 # Write out the final table
	try: 
		normtab_fin.to_csv(outfp, sep=',') 
	except:
		print('did not provide output path for normalized table')
		pass	


# Define subsidiary function to merge normalizaed count 
def merge_normtab(mergeout=None, *args):
	try:
		tabm=pd.DataFrame() # initialize with an empty dataframe as merged table
		for file in args:
			tab = pd.read_csv(file, sep=',', header=0)
			try:
				tabm = pd.merge(tab, tabm, how='outer', on = ['Gene'])
				tabm.fillna(0, inplace=True) # replace nan from merging by 0
			except:
				tabm = tab.copy() # the first loop when tabm is an empty df
		tabm.to_csv(mergeout, sep=',')	
	except: 
		pass	# in python 2, this won't work...*args still requires input

# To ensure that the script can be run by itself (__name__ == "__main__" is true) 
# and individual functions can be imported as modules in other python scripts
if __name__ == "__main__":

	# excute
	make_RPKG_normtab(mcfp=args['mc'], 
					  lenfp=args['genelen'], 
					  countfp=args['count'], 
					  outfp=args['out']) 
	merge_normtab(args['mergeout'], *args['mergein']) # add * to parse the wildcard input to multiple string variables


	