#!/bin/bash

# usage: count_fq_length.sh indir outdir 7
# The last digit is to indicate the last letter to keep for the file name as "STEM"   

for file in $1/*.f*
do 
	name=$(basename "$file")
	STEM=$(echo "$name" |cut -c1-$3)

	# 	https://www.biostars.org/p/72433/
	# every second line in every group of 4 lines (the sequence line), measure the length of the sequence and increment the array cell corresponding to that length. When all lines have been read, loop over the array to print its content. In awk, arrays and array cells are initialized when they are called for the first time, no need to initialize them before.
	awk 'NR%4 == 2 {lengths[length($0)]++} END {for (l in lengths) {print l, lengths[l]}}' $file > $2/${STEM}_len

	# add file name as a new column
	# https://unix.stackexchange.com/questions/117568/adding-a-column-of-values-in-a-tab-delimited-file
	sed -i "s/$/\t$STEM/" $2/${STEM}_len # pattern $ to indicate the end of line 
done	

# concatenate all the len files to one 
cat *_len > $2/all_len
