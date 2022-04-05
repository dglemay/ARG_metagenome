#!/usr/bin/python

'''This script generates the "final" output file of the ARG workflow. It combines output from three different intermediate steps:
(1) step6-megares alignment file providing ARG read/sequence ID and MEGID
(2) step9-Contig ID and the aligned ARG read ID
(3) step10-Contig ID and the taxonomy assignment'''

import numpy
import pandas as pd # install pandas in the same directory as this script
import csv

def cat_tab_org(alnfp=None,contigfp=None,taxafp=None,outfp=None):

	# [1] # Read in the alignment file from step 6 (organized in step 9)
	alndict = {}
	with open(alnfp) as samFile:
	    for line in samFile:
	        qname = line.split('\t')[0]
	        if qname.startswith('A0'):
	            alndict[qname] = line.split('\t')[2]
	aln = pd.DataFrame.from_dict(alndict, orient='index', columns=['megid'])
	aln.index.name = 'seqid'
	aln.reset_index(inplace=True)     
	newdf=aln["megid"].str.split("|", expand=True).drop(columns=5) #remove the column containng "RequiresSNPConfirmation"
	aln['megid']=newdf[0]
	aln['Class']=newdf[1]
	aln['Mechanism']=newdf[2]
	aln['Group']=newdf[3]
	aln['Gene']=newdf[4]
	
	# [2] # Read in info about conting ID the aligned ARG sequence IDs from step 9
	contigdict = {}
	with open(contigfp) as samFile:
	    for line in samFile:
	        qname = line.split('\t')[0]
	        if qname.startswith('A0'):
	            contigdict[qname] = line.split('\t')[2]
	contig = pd.DataFrame.from_dict(contigdict, orient='index', columns=['contigid'])
	contig.index.name = 'seqid'
	contig.reset_index(inplace=True)

	# [3] # Read in the taxaid file from step10
	taxa = pd.read_csv(taxafp, sep='\t', header=0)
	taxa.rename(columns={'# contig':'contigid'}, inplace=True)

	# Join the organized tables by shared colums
	fintab = pd.merge(aln, contig, how='left', on='seqid')
	fintab = pd.merge(fintab, taxa, how='left', on='contigid')
	fintab.drop(columns=['reason','lineage','lineage scores'], inplace=True)

	# Write the output file
	fintab.to_csv(outfp, sep=',', index=False)



# Define subsidiary function to merge normalizaed count 
def merge_fintab(outfp=None, *args):
	try:
		tabm=pd.DataFrame() # initialize with an empty dataframe as merged table
		for file in args:
			tab = pd.read_csv(file, sep=',', header=0)
			try:
				tabm = pd.merge(tab, tabm, how='outer', on = 'contigid')
				tabm.fillna("NA", inplace=True) # replace nan from merging by 0
			except KeyError:
				tabm = tab.copy() # the first loop when tabm is an empty df
		tabm.to_csv(outfp, sep=',')	
	except ValueError: 
		pass	# in python 2, this won't work...*args still requires input



# To ensure that the script can be run by itself (__name__ == "__main__" is true) 
# and individual functions can be imported as modules in other python scripts
if __name__ == "__main__":
	# parse input argument 
	import argparse

	parser = argparse.ArgumentParser(description='Organize the CAT taxa id output with ARG seqid and AMR information.')
	parser.add_argument('--a', type=str, help='File path to MEGARes alignment sam file.', required=False)
	parser.add_argument('--c', type=str, help='File path to contig-ARG-sequences alignment sam file.', required=False)
	parser.add_argument('--t', type=str, help='File path to CAT taxaid file.', required=False)
	parser.add_argument('--o', type=str, help='File path to write the final output file for each sample.', required=False)
	# althoug not required for argparse, the wildcard input is required by the merge_fintab() function
	parser.add_argument('--mergein', type=str, help='File path to a number of organized cat tables per sample.', nargs='+', required=False) 
	parser.add_argument('--mergeout', type=str, help='File path to write the merged cat table for all samples.', required=False)
	args = vars(parser.parse_args())


	# excute
	cat_tab_org(alnfp=args['a'], 
				contigfp=args['c'], 
				taxafp=args['t'], 
				outfp=args['o']) 
	merge_fintab(args['mergeout'], *args['mergein']) # add * to parse the wildcard input to multiple string variables


	


