#!/bin/bash

# read in file path
read -p "Enter input folder path: " path 

# define output file 
read -p "Enter output file name and path: " output
touch $output 

# compute the md5 checksums for each file
for file in $path*.gz; do
	md5sum $file >> $output
	sed -i "s|$path||g" $output
done

# remove the file path string in the sequence name header

exit 0	
