#!/usr/bin/env python

import pandas as pd
import csv
import numpy
import os
import re

import argparse
parser = argparse.ArgumentParser(description='.')
parser.add_argument('--in', type=str, help='File path to MicrobeCensus output txt file.', required=False)
parser.add_argument('--out', type=str, help='File path to write the normalized count table.', required=False)
# althoug not required for argparse, the wildcard input is required by the merge_normtab() function
parser.add_argument('--mergein', type=str, help='File path to a number of normalized count tables per sample.', nargs='+', required=False) 
parser.add_argument('--mergeout', type=str, help='File path to write the normalized count table.', required=False)
args = vars(parser.parse_args())


# Define function to calculate normalized table
def add_sampleid(infp=None, outfp=None):
	# 1 # read in
	try:
		# assumes sample name is the character string after the last / and before .tsv
		# The sample name is 5007 from the path /file/to/your/path/5007_gene.tsv
		fn = os.path.basename(infp) # get the xx_gene.tsv file name
		samid = re.search('(.+?)_org.txt', fn).group(1)

		intab = pd.read_csv(infp, sep=',', header=None, names=["family", samid])
	except:
		pass

	# 2 # Write out the final table
	try: 
		intab.to_csv(outfp, sep=',', index=False) 
	except (TypeError, UnboundLocalError):
		pass	


# Define subsidiary function to merge normalizaed count 
def merge_tab(mergeout=None, *args):
	try:
		tabm=pd.DataFrame() # initialize with an empty dataframe as merged table
		for file in args:
			tab = pd.read_csv(file, sep=',', header=0)
			try:
				tabm = pd.merge(tab, tabm, how='outer', on = ['family'])
				tabm.fillna(0, inplace=True) # replace nan from merging by 0
			except KeyError:
				tabm = tab.copy() # the first loop when tabm is an empty df
		tabm.to_csv(mergeout, sep=',', index=False)	
	except ValueError: 
		pass	# in python 2, this won't work...*args still requires input

# To ensure that the script can be run by itself (__name__ == "__main__" is true) 
# and individual functions can be imported as modules in other python scripts
if __name__ == "__main__":

	# excute
	add_sampleid(infp=args['in'], outfp=args['out']) 
	merge_tab(args['mergeout'], *args['mergein']) # add * to parse the wildcard input to multiple string variables

