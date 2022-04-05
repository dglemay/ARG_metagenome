#!/usr/bin/env python

'''This script converts partial headers extracted from sam file to full headers based on contigs. For example, convert "k141_0" to "k141_0 flag=0 multi=1.0000 len=225". The output file containing all the headers is used to select contigs containg ARGs. '''

import pandas as pd # install pandas in the same directory as this script
import csv
import sys

def prefix_compline(infile, refile, outfile):
	
	# [1] # read in prefix file
	infile = pd.read_csv(infile, sep="\t", names=["name1"])

	# [2] # read in contig file from megahit containing full headers
	refile = pd.read_csv(refile, sep=",", names=["name"])
	# move every other line to a new column to separate sequence heaser and sequences
	refile = pd.DataFrame({'name':refile["name"].iloc[::2].values, 
		'sequence':refile["name"].iloc[1::2].values})
	# split the full header at the first space 
	refile[['name1','name2']] = refile['name'].str.split(" ", 1, expand=True)
	# remove the > in the first part of the header by keeping 1 to the last character
	refile['name1'] = refile['name1'].str[1:]
	refile['name'] = refile['name'].str[1:]

	# [3] # get the complete headers
	tab = pd.merge(infile, refile, how='inner', on='name1')
	tab.loc[:,'name'].to_csv(outfile, sep='\t', header=False, index=False) 

	##################################################################################
	# Dictionary methods are not good for accessing rows, which will be used for loop.
	# Therefore, I decided to go with the dataframe method
	##################################################################################
	# convert to a dictionary
	# refdict = dict(refile['name1'], refile['name2'])


# To ensure that the script can be run by itself (__name__ == "__main__" is true) 
# and individual functions can be imported as modules in other python scripts
if __name__ == "__main__":
	# parse input argument 
	import argparse
	parser = argparse.ArgumentParser(description='Find and output complete lines in A file based on prefixes supplied in B file.')
	parser.add_argument('--i', type=str, help='File path to the input txt file containing prefixes (partial lines). User can also pass stdin instead of file.', required=False)
	parser.add_argument('--f', type=str, help='File path to the reference file containing full lines (and maybe other lines.', required=True)
	parser.add_argument('--o', type=str, help='File path to the ouput txt file containing complete lines.', required=True)
	args = vars(parser.parse_args())
	
	# excute
	prefix_compline(infile=args['i'], refile=args['f'], outfile=args['o'])
